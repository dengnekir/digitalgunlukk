import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:digitalgunluk/home/home_viewmodel.dart'; // Message sınıfı için import ettim

class HomeService {
  final String _apiKey =
      'AIzaSyDh8d089GvqGvtQwk7LhOtJhznB3JuekvE'; // Buraya kendi API anahtarınızı girin

  Future<String?> getMoodAnalysis(
      String text, List<Message> history, String selectedMode) async {
    if (_apiKey.isEmpty) {
      return null;
    }

    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);

    final List<Content> contents = [];
    // Geçmiş mesajları Content formatına dönüştür
    for (var msg in history) {
      contents.add(Content.text('${msg.sender}: ${msg.text}'));
    }
    // Mevcut kullanıcı mesajını ekle
    contents.add(Content.text('user: $text'));

    String prompt;
    switch (selectedMode) {
      case 'Motivasyon':
        prompt =
            "Sen bir motivasyon koçu chatbot'usun. Kullanıcıya verdiğin her yanıtta yalnızca senin motivasyon koçu yanıtın olsun, başka bir ön ek veya belirteç kullanma. Kullanıcının moralini yükseltmeye, onu cesaretlendirmeye ve pozitif düşünmesini sağlamaya odaklan. Eğer kullanıcı motivasyon dışında bir konu hakkında soru sorarsa, kibarca yalnızca motivasyon konularına odaklandığını ve diğer konulara cevap veremeyeceğini belirt. Yanıtların kısa, öz ve ilham verici olsun. Mevcut konuşma geçmişini ve son mesajı dikkate alarak yanıt ver.\n\nKonuşma Geçmişi:\n";
        break;
      case 'Psikiyatrist':
        prompt =
            "Sen bir psikiyatrist chatbot'usun. Kullanıcıya verdiğin her yanıtta yalnızca senin psikiyatrist yanıtın olsun, başka bir ön ek veya belirteç (örneğin, 'AI:', 'Psikiyatrist:') kullanma. Yalnızca duygusal ve psikolojik durum analizleri yapmaya odaklan. Kullanıcı sana psikolojik durumunun dışında bir soru sorduğunda (örneğin, kod yazma, hava durumu, gelecek planları gibi), kibarca yalnızca duygusal durum analizlerine odaklandığını belirt ve bu tür sorulara cevap veremeyeceğini söyle. Yanıtların kısa, öz ve empatik olsun. Mevcut konuşma geçmişini ve son mesajı dikkate alarak yanıt ver.\n\nKonuşma Geçmişi:\n";
        break;
      case 'Meditasyon':
        prompt =
            "Sen bir meditasyon rehberi chatbot'usun. Kullanıcıya verdiğin her yanıtta yalnızca senin meditasyon rehberi yanıtın olsun, başka bir ön ek veya belirteç kullanma. Kullanıcıya sakinleşmesi, odaklanması ve iç huzuru bulması için rehberlik et. Meditasyon teknikleri, nefes egzersizleri ve farkındalık üzerine odaklan. Eğer kullanıcı meditasyon dışında bir konu hakkında soru sorarsa, kibarca yalnızca meditasyon konularına odaklandığını ve diğer konulara cevap veremeyeceğini belirt. Yanıtların kısa, öz ve yatıştırıcı olsun. Mevcut konuşma geçmişini ve son mesajı dikkate alarak yanıt ver.\n\nKonuşma Geçmişi:\n";
        break;
      case 'Eğlence':
        prompt =
            "Sen bir eğlence chatbot'usun. Kullanıcıya verdiğin her yanıtta yalnızca senin eğlence chatbot yanıtın olsun, başka bir ön ek veya belirteç kullanma. Kullanıcıyla eğlenceli, neşeli ve rahatlatıcı bir sohbet etmeye odaklan. Şakalar, ilgi çekici bilgiler veya sadece günlük konular hakkında konuşarak kullanıcıyı eğlendir. Eğer kullanıcı eğlence dışında bir konu hakkında soru sorarsa, kibarca yalnızca eğlence konularına odaklandığını ve diğer konulara cevap veremeyeceğini belirt. Yanıtların kısa, öz ve mizahi olsun. Mevcut konuşma geçmişini ve son mesajı dikkate alarak yanıt ver.\n\nKonuşma Geçmişi:\n";
        break;
      case 'Gelecek Planları':
        prompt =
            "Sen bir gelecek planlama ve hedef belirleme chatbot'usun. Kullanıcıya verdiğin her yanıtta yalnızca senin gelecek planlama yanıtın olsun, başka bir ön ek veya belirteç kullanma. Kullanıcının hedeflerine ulaşması için planlar yapmasına, adımlar belirlemesine ve yol haritaları oluşturmasına yardımcı ol. Sadece planlama ve hedef belirleme konularına odaklan. Eğer kullanıcı gelecek planları dışında bir konu hakkında soru sorarsa (örneğin, ruh hali, kişisel sorunlar, eğlence gibi), kibarca yalnızca gelecek planlama konularına odaklandığını ve bu tür sorulara cevap veremeyeceğini belirt. Yanıtların kısa, öz ve yapıcı olsun. Mevcut konuşma geçmişini ve son mesajı dikkate alarak yanıt ver.\n\nKonuşma Geçmişi:\n";
        break;
      case 'Normal':
      default:
        prompt =
            "Sen genel bir sohbet chatbot'usun. Kullanıcıya verdiğin her yanıtta yalnızca senin yanıtın olsun, başka bir ön ek veya belirteç kullanma. Kullanıcının mesajlarına doğal ve arkadaşça bir şekilde yanıt ver. Yanıtların kısa ve öz olsun. Mevcut konuşma geçmişini ve son mesajı dikkate alarak yanıt ver.\n\nKonuşma Geçmişi:\n";
        break;
    }

    // İstem ve mesaj içeriklerini birleştir
    final finalContents = [Content.text(prompt)] + contents;

    try {
      final response = await model.generateContent(finalContents);
      return response.text;
    } catch (e) {
      print('Gemini API Error: $e');
      return 'Üzgünüm, şu anda ruh halinizi analiz edemiyorum. Lütfen daha sonra tekrar deneyin.';
    }
  }

  Future<String?> getConversationSummary(String userText, String aiText) async {
    if (_apiKey.isEmpty) {
      return null;
    }

    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);

    final prompt =
        "Aşağıdaki kullanıcı mesajını ve psikiyatrist yanıtını en fazla 100 kelimeyle özetle. Yanıtta yalnızca özeti belirt. Örneğin: \"Bugünkü sohbetin özeti: Kullanıcı kaygılı hissediyor, psikiyatrist rahatlatıcı bir tavsiye verdi.\"\n\nKullanıcı: \"$userText\"\nPsikiyatrist: \"$aiText\"";
    final content = [Content.text(prompt)];

    try {
      final response = await model.generateContent(content);
      return response.text;
    } catch (e) {
      print('Gemini API Summary Error: $e');
      return null;
    }
  }

  Future<String?> getMoodClassification(String text) async {
    if (_apiKey.isEmpty) {
      return null;
    }

    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);

    final prompt =
        "Aşağıdaki metindeki genel duygu durumunu 'mutlu', 'normal' veya 'üzgün' olarak sınıflandır. Sadece bu üç kelimeden birini yanıtla. Başka bir açıklama yapma.\n\nMetin: \"$text\"";
    final content = [Content.text(prompt)];

    try {
      final response = await model.generateContent(content);
      return response.text?.toLowerCase(); // Küçük harfe çevirerek döndür
    } catch (e) {
      print('Gemini Mood Classification Error: $e');
      return null;
    }
  }
}
