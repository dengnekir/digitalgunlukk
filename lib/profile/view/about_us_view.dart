import 'package:flutter/material.dart';
import '../../core/widgets/colors.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uygulama Hakkında',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Proje Özeti',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Bu uygulama, kullanıcıların günlük duygu durumlarını yazılı olarak kaydettikleri bir dijital günlük ortamı sunar. Gelişmiş doğal dil işleme (NLP) ve makine öğrenmesi teknikleri ile bu metinler analiz edilerek kullanıcının haftalık ve günlük ruh hali değerlendirilir. Uygulama, kullanıcıya önerilerde ve destekleyici mesajlarda bulunur.',
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
            SizedBox(height: 30),
            Text(
              'Özellikler',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '- Günlük Yazma: Kullanıcılar her gün istedikleri kadar günlük girişi yapabilir.\n- Ruh Hali Analizi: Yapay zeka tarafından metin analizi ile ruh hali (mutlu, üzgün, stresli vb.) tahmini yapılır.\n- Haftalık ve Günlük Raporlar: Ruh hali geçmişini grafiklerle takip edebilme.\n- Destekleyici Öneriler: Kullanıcının ruh haline göre olumlu mesajlar veya öneriler sunar.\n- Gizlilik: Tüm veriler cihazda saklanır veya anonim şekilde işlenir. Kullanıcı verileri gizlidir.',
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
            SizedBox(height: 30),
            Text(
              'Kullanılan Teknolojiler',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Gemini API ve Flutter kullanıldı.',
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
