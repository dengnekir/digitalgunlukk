import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digitalgunluk/home/home_viewmodel.dart'; // ConversationSummary sınıfı için import ettim
import 'package:digitalgunluk/home/home_service.dart'; // HomeService'i import ettim
import '../../core/widgets/colors.dart'; // colorss sınıfı için import ettim

class HistoryViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final HomeService _homeService = HomeService();

  // Değişiklik: Artık her gün için tek bir özet saklayacağız
  Map<DateTime, ConversationSummary> _summaries = {};
  Map<DateTime, ConversationSummary> get summaries => _summaries;

  // Değişiklik: Seçilen gün için tek bir özet saklayacağız
  ConversationSummary? _selectedDaySummary;
  ConversationSummary? get selectedDaySummary => _selectedDaySummary;

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
      debugPrint('Özetler yükleniyor...');

      // Geçici olarak günlük özetleri gruplamak için bir harita
      Map<DateTime, List<ConversationSummary>> dailyGroupedSummaries = {};

      for (var doc in snapshot.docs) {
        final summary = ConversationSummary.fromJson(doc.data());
        final date = DateTime(summary.timestamp.year, summary.timestamp.month,
            summary.timestamp.day);
        dailyGroupedSummaries.update(date, (value) => value..add(summary),
            ifAbsent: () => [summary]);
      }

      // Her gün için tek bir özet ve ruh hali oluştur
      for (var entry in dailyGroupedSummaries.entries) {
        final date = entry.key;
        final summariesList = entry.value;

        // Tüm userText ve aiResponse'ları birleştir
        final combinedUserTexts =
            summariesList.map((s) => s.userText).join(' ');
        final combinedAiResponses =
            summariesList.map((s) => s.aiResponse).join(' ');

        // Yeni özet ve ruh hali oluşturmak için HomeService kullan
        final newSummaryText = await _homeService.getConversationSummary(
            combinedUserTexts,
            combinedAiResponses.isNotEmpty
                ? combinedAiResponses
                : 'Hiçbir yapay zeka yanıtı yok.');
        final newMood =
            await _homeService.getMoodClassification(combinedUserTexts);

        if (newSummaryText != null) {
          final aggregatedSummary = ConversationSummary(
            userText: combinedUserTexts,
            aiResponse: combinedAiResponses,
            summary: newSummaryText, // Yeni oluşturulan özet
            timestamp: date, // Normalleştirilmiş tarih
            mood: newMood, // Yeni oluşturulan ruh hali
          );
          _summaries[date] = aggregatedSummary;
          debugPrint(
              'Agregasyon sonrası yeni özet eklendi: $date - ${aggregatedSummary.summary} (Mood: ${aggregatedSummary.mood})');
        } else {
          debugPrint('Agregasyon sonrası özet oluşturulamadı: $date');
        }
      }

      debugPrint(
          'Toplam yüklenen agregasyonlu özet sayısı: ${_summaries.length}');
      // Seçili gün varsa, onu da güncelle
      if (_selectedDaySummary != null) {
        final normalizedSelectedDay = DateTime(
            _selectedDaySummary!.timestamp.year,
            _selectedDaySummary!.timestamp.month,
            _selectedDaySummary!.timestamp.day);
        _selectedDaySummary = _summaries[normalizedSelectedDay];
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Özetler yüklenirken hata oluştu: $e');
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
      debugPrint('Günlük mesajlar yüklenirken hata oluştu: $e');
      return [];
    }
  }

  void onDaySelected(DateTime selectedDay) async {
    debugPrint('Seçilen gün: $selectedDay');
    final normalizedSelectedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    _selectedDaySummary = _summaries[normalizedSelectedDay]; // Tek özeti al
    debugPrint(
        'Seçilen gün için özet (${normalizedSelectedDay}): ${_selectedDaySummary?.summary ?? "Bulunamadı"}');

    // Eğer seçilen gün bugünse ve henüz özet yoksa, anlık özet oluşturmaya çalış
    if (_selectedDaySummary == null && isSameDay(selectedDay, DateTime.now())) {
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
            _selectedDaySummary = ConversationSummary(
              // Tek özeti set et
              userText: userTexts,
              aiResponse: aiTexts,
              summary: temporarySummaryText,
              timestamp: DateTime.now(), // Geçici olduğu için şimdiki zaman
              mood: temporaryMood,
            );
            debugPrint(
                'Anlık özet oluşturuldu: ${_selectedDaySummary!.summary}');
          }
        }
      }
    }
    notifyListeners();
  }

  Color getMoodColorForDay(DateTime day) {
    final ConversationSummary? dailySummary = _summaries[day];
    if (dailySummary == null) {
      return Colors.transparent;
    }

    switch (dailySummary.mood?.trim()) {
      case 'mutlu':
        return Colors.limeAccent.shade700;
      case 'üzgün':
        return Colors.deepPurple.shade700;
      case 'normal':
        return Colors.amber.shade400;
      default:
        return Colors.blueGrey.shade400;
    }
  }

  String getMoodEmoji(String? mood) {
    switch (mood?.trim()) {
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
