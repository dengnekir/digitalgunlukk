import 'package:flutter/material.dart';
import 'package:digitalgunluk/home/home_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeService _homeService = HomeService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Message> _messages = [];
  List<Message> get messages => _messages;

  String? _mood;
  String? get mood => _mood;

  String _selectedMode = 'Normal'; // Varsayılan mod
  String get selectedMode => _selectedMode;

  final List<String> availableModes = [
    'Normal',
    'Motivasyon',
    'Psikiyatrist',
    'Meditasyon',
    'Eğlence',
    'Gelecek Planları', // Yeni mod eklendi
  ];

  void setSelectedMode(String mode) {
    _selectedMode = mode;
    notifyListeners();
  }

  HomeViewModel() {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      _messages =
          snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Mesajlar yüklenirken hata oluştu: $e');
    }
  }

  Future<bool> sendMessage(String text) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final userMessage =
          Message(text: text, sender: 'user', timestamp: DateTime.now());
      _messages.add(userMessage);
      notifyListeners();

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('messages')
          .add(userMessage.toJson());

      // Geçmiş mesajları AI'ya göndererek bağlamı koru ve seçilen modu ilet
      String? aiResponse =
          await _homeService.getMoodAnalysis(text, _messages, _selectedMode);
      if (aiResponse != null) {
        final aiMessage =
            Message(text: aiResponse, sender: 'ai', timestamp: DateTime.now());
        _messages.add(aiMessage);
        notifyListeners();

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('messages')
            .add(aiMessage.toJson());

        // Sohbet özetini kaydet
        await _saveConversationSummary(userMessage.text, aiMessage.text);
        return true;
      } else {
        debugPrint('Yapay zeka yanıtı alınamadı.');
        return false;
      }
    } catch (e) {
      debugPrint('Mesaj gönderilirken veya işlenirken hata oluştu: $e');
      return false;
    }
  }

  Future<bool> _saveConversationSummary(String userText, String aiText) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final summary =
          await _homeService.getConversationSummary(userText, aiText);
      final mood = await _homeService.getMoodClassification(userText);

      if (summary != null) {
        final conversationSummary = ConversationSummary(
          userText: userText,
          aiResponse: aiText,
          summary: summary,
          timestamp: DateTime.now(),
          mood: mood,
        );
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('conversation_summaries')
            .add(conversationSummary.toJson());
        return true;
      } else {
        debugPrint('Özet oluşturulamadı.');
        return false;
      }
    } catch (e) {
      debugPrint('Sohbet özeti kaydedilirken hata oluştu: $e');
      return false;
    }
  }

  Future<void> analyzeMood(String text) async {
    _mood = await _homeService.getMoodAnalysis(text, _messages, _selectedMode);
    notifyListeners();
  }

  Future<bool> deleteAllMessages() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Mesajları sil
      final messagesCollection =
          _firestore.collection('users').doc(user.uid).collection('messages');
      final messageDocs = await messagesCollection.get();
      for (var doc in messageDocs.docs) {
        await doc.reference.delete();
      }

      // Sohbet özetlerini sil
      final summariesCollection = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('conversation_summaries');
      final summaryDocs = await summariesCollection.get();
      for (var doc in summaryDocs.docs) {
        await doc.reference.delete();
      }

      _messages.clear();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Mesajlar silinirken hata oluştu: $e');
      return false;
    }
  }
}

class Message {
  final String text;
  final String sender;
  final DateTime timestamp;

  Message({required this.text, required this.sender, required this.timestamp});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'],
      sender: json['sender'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'sender': sender,
      'timestamp': timestamp,
    };
  }
}

class ConversationSummary {
  final String userText;
  final String aiResponse;
  final String summary;
  final DateTime timestamp;
  final String? mood;

  ConversationSummary({
    required this.userText,
    required this.aiResponse,
    required this.summary,
    required this.timestamp,
    this.mood,
  });

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    return ConversationSummary(
      userText: json['userText'],
      aiResponse: json['aiResponse'],
      summary: json['summary'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      mood: json['mood'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userText': userText,
      'aiResponse': aiResponse,
      'summary': summary,
      'timestamp': timestamp,
      'mood': mood,
    };
  }
}
