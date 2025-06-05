import 'package:flutter/material.dart';
import '../../core/widgets/colors.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uygulama Hakkında',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/app_logo.png',
                  height: screenSize.height * 0.15,
                  width: screenSize.width * 0.3,
                ),
              ),
              SizedBox(height: screenSize.height * 0.03),
              Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenSize.width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: colorss.primaryColor,
                              size: screenSize.width * 0.06),
                          SizedBox(width: screenSize.width * 0.02),
                          Text(
                            'Proje Özeti',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenSize.width * 0.055,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenSize.height * 0.015),
                      Text(
                        'Bu uygulama, kullanıcıların günlük duygu durumlarını yazılı olarak kaydettikleri bir dijital günlük ortamı sunar. Gelişmiş doğal dil işleme (NLP) ve makine öğrenmesi teknikleri ile bu metinler analiz edilerek kullanıcının haftalık ve günlük ruh hali değerlendirilir. Uygulama, kullanıcıya önerilerde ve destekleyici mesajlarda bulunur.',
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: screenSize.width * 0.038),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.03),
              Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenSize.width * 0.04),
                  child: _buildInfoSection(
                    context: context,
                    title: 'Özellikler',
                    items: [
                      '- Günlük Yazma: Kullanıcılar her gün istedikleri kadar günlük girişi yapabilir.',
                      '- Ruh Hali Analizi: Yapay zeka tarafından metin analizi ile ruh hali (mutlu, üzgün, stresli vb.) tahmini yapılır.',
                      '- Haftalık ve Günlük Raporlar: Ruh hali geçmişini grafiklerle takip edebilme.',
                      '- Destekleyici Öneriler: Kullanıcının ruh haline göre olumlu mesajlar veya öneriler sunar.',
                      '- Gizlilik: Tüm veriler cihazda saklanır veya anonim şekilde işlenir. Kullanıcı verileri gizlidir.',
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.03),
              Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenSize.width * 0.04),
                  child: _buildInfoSection(
                    context: context,
                    title: 'Kullanılan Teknolojiler',
                    items: [
                      'Gemini API ve Flutter kullanıldı.',
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildInfoSection({
    required BuildContext context,
    required String title,
    required List<String> items,
  }) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: screenSize.width * 0.055,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenSize.height * 0.015),
        ...items
            .map((item) => Padding(
                  padding: EdgeInsets.only(bottom: screenSize.height * 0.01),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.03,
                          vertical: screenSize.height * 0.015),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: colorss.primaryColor,
                              size: screenSize.width * 0.04),
                          SizedBox(width: screenSize.width * 0.02),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: screenSize.width * 0.038),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }
}
