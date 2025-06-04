import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digitalgunluk/home/home_viewmodel.dart'; // ConversationSummary sınıfı için import ettim
import 'package:digitalgunluk/home/home_service.dart'; // HomeService'i import ettim
import '../../core/widgets/colors.dart'; // colorss sınıfı için import ettim

class HistoryViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final HomeService _homeService = HomeService(); // HomeService'i ekledim

  Map<DateTime, List<ConversationSummary>> _summaries = {};
  Map<DateTime, List<ConversationSummary>> get summaries => _summaries;

  List<ConversationSummary> _selectedDaySummaries = [];
  List<ConversationSummary> get selectedDaySummaries => _selectedDaySummaries;

  HistoryViewModel() {
    _loadSummaries();
  }

  Future<void> _loadSummaries() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('conversation_summaries')
          .orderBy('timestamp', descending: false)
          .get();

      _summaries = {}; // Önceki verileri temizle
      for (var doc in snapshot.docs) {
        final summary = ConversationSummary.fromJson(doc.data());
        final date = DateTime(summary.timestamp.year, summary.timestamp.month,
            summary.timestamp.day);
        _summaries.update(date, (value) => value..add(summary),
            ifAbsent: () => [summary]);
      }
      notifyListeners();
    } catch (e) {
      print('Özetler yüklenirken hata oluştu: $e');
    }
  }

  Future<List<Message>> _loadDailyMessages(DateTime day) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('messages')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
    } catch (e) {
      print('Günlük mesajlar yüklenirken hata oluştu: $e');
      return [];
    }
  }

  void onDaySelected(DateTime selectedDay) async {
    _selectedDaySummaries = _summaries[selectedDay] ?? [];

    // Eğer seçilen gün bugünse ve henüz özet yoksa, anlık özet oluşturmaya çalış
    if (_selectedDaySummaries.isEmpty &&
        isSameDay(selectedDay, DateTime.now())) {
      final dailyMessages = await _loadDailyMessages(selectedDay);
      if (dailyMessages.isNotEmpty) {
        final userTexts = dailyMessages
            .where((msg) => msg.sender == 'user')
            .map((msg) => msg.text)
            .join(' ');
        final aiTexts = dailyMessages
            .where((msg) => msg.sender == 'ai')
            .map((msg) => msg.text)
            .join(' ');

        if (userTexts.isNotEmpty) {
          final temporarySummaryText =
              await _homeService.getConversationSummary(
                  userTexts,
                  aiTexts.isNotEmpty
                      ? aiTexts
                      : 'Hiçbir yapay zeka yanıtı yok.');
          final temporaryMood =
              await _homeService.getMoodClassification(userTexts);

          if (temporarySummaryText != null) {
            _selectedDaySummaries.add(ConversationSummary(
              userText: userTexts,
              aiResponse: aiTexts,
              summary: temporarySummaryText,
              timestamp: DateTime.now(),
              mood: temporaryMood,
            ));
          }
        }
      }
    }
    notifyListeners();
  }

  // Takvimde günleri renklendirmek için kullanılacak
  Color getMoodColorForDay(DateTime day) {
    final dailySummaries = _summaries[day];
    if (dailySummaries == null || dailySummaries.isEmpty) {
      // Eğer bugünse ve henüz özet yoksa, anlık ruh halini belirlemeye çalış
      // Ancak bu metot senkron olduğu için burada anlık ruh hali belirleme yapılamaz.
      // Takvim işaretleyicileri için şeffaf döndürüyorum.
      return Colors.transparent;
    }

    // Günlük ruh hallerinin ortalamasını veya en baskın olanı alabilirsiniz.
    // Basitçe ilk özetteki ruh haline göre renk belirliyorum.
    switch (dailySummaries.first.mood) {
      case 'mutlu':
        return Colors.green.shade300; // Mutlu için yeşil tonu
      case 'üzgün':
        return Colors.red.shade300; // Üzgün için kırmızı tonu
      case 'normal':
        return Colors.blue.shade300; // Normal için mavi tonu
      default:
        return Colors.transparent;
    }
  }

  String getMoodEmoji(String? mood) {
    switch (mood) {
      case 'mutlu':
        return '😊';
      case 'üzgün':
        return '😔';
      case 'normal':
        return '😐';
      default:
        return '';
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
