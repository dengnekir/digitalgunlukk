# 📓 Yapay Zeka Destekli Dijital Psikiyatri

Flutter ile geliştirilen, kullanıcıların duygularını takip etmelerine yardımcı olan yapay zeka destekli mobil psikiyatri uygulaması.

## 🧠 Proje Özeti

Bu uygulama, kullanıcıların günlük duygu durumlarını yazılı olarak kaydettikleri bir dijital günlük ortamı sunar. Gelişmiş doğal dil işleme (NLP) ve makine öğrenmesi teknikleri ile bu metinler analiz edilerek kullanıcının haftalık ve günlük ruh hali değerlendirilir. Uygulama, kullanıcıya önerilerde ve destekleyici mesajlarda bulunur.

## 🚀 Özellikler

- 📝 _Günlük Yazma_: Kullanıcılar her gün istedikleri kadar günlük girişi yapabilir.
- 📊 _Ruh Hali Analizi_: Yapay zeka tarafından metin analizi ile ruh hali (mutlu, üzgün, stresli vb.) tahmini yapılır.
- 🧭 _Haftalık ve Günlük Raporlar_: Ruh hali geçmişini grafiklerle takip edebilme.
- 💡 _Destekleyici Öneriler_: Kullanıcının ruh haline göre olumlu mesajlar veya öneriler sunar.
- 🔒 _Gizlilik_: Tüm veriler cihazda saklanır veya anonim şekilde işlenir. Kullanıcı verileri gizlidir.

## 🛠 Kullanılan Teknolojiler

| Teknoloji                   | Açıklama                                |
| --------------------------- | --------------------------------------- |
| Flutter                     | Uygulama geliştirme                     |
| Dart                        | Programlama dili                        |
| Firebase                    | Kimlik doğrulama ve veri saklama        |
| Python (API)                | NLP analizlerinin arka planda işlenmesi |
| Flask/FastAPI               | AI API sunucusu                         |
| scikit-learn / Transformers | Ruh hali tahmini modeli (NLP)           |

## 📈 NLP / AI Süreci

1. Kullanıcının yazdığı metin mobil uygulama üzerinden backend API'ye gönderilir.
2. Bu metin ön işlenir (temizleme, tokenizasyon).
3. Bir duygu analiz modeli (örneğin: BERT, DistilBERT, VADER, TextBlob gibi) ile analiz edilir.
4. Çıktı olarak bir duygu etiketi (örneğin: mutlu, üzgün, anksiyeteli) ve duygu puanı döner.
5. Bu sonuç, Flutter arayüzünde grafiklerle ve mesajlarla kullanıcıya sunulur.

## 📷 Ekran Görüntüleri (Opsiyonel)

> 📌 Buraya uygulama ekran görüntüleri eklenecek.

## 🔧 Kurulum ve Çalıştırma

```bash
git clone https://github.com/kullaniciAdi/dijital-psikiyatri.git
cd dijital-psikiyatri
flutter pub get
flutter run
```
