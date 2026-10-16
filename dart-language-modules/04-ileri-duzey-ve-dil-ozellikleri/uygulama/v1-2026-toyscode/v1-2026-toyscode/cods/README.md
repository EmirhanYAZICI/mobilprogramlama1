#  Dart Kavramları (Dart Concepts Showcase)

Flutter ve Dart ekosisteminin en kritik modern programlama kavramlarını pratik, etkileşimli ve görsel bir arayüz üzerinde deneyimleten modern bir Flutter uygulamasıdır.

Bu proje; asenkron programlama, çoklu iş parçacığı (multi-threading), veri akışları ve tip güvenliği gibi temel Dart yeteneklerini hem görsel geri bildirimlerle hem de gerçek kod mantıklarıyla somutlaştırmaktadır.

---

##  Projenin Amacı

Dart ve Flutter öğrenen ya da bilgilerini tazelemek isteyen geliştiriciler için soyut kavramları (Isolate, Stream, Future, Null Safety) canlı bir mobil arayüz üzerinde test edilebilir hale getirmektir. Kullanıcı, her karta dokunduğunda ilgili kavramın nasıl çalıştığını durum kartı ve arayüz tepkileri üzerinden anlık olarak gözlemleyebilir.

---

##  İşlenen Temel Dart Kavramları

Uygulamada yer alan 5 ana kavram ve teknik işleyişleri:

| Kavram | Dart Mekanizması | Uygulamadaki İşlevi |
| :--- | :--- | :--- |
| **Veri Çek** | `async / await` & `Future` | 1 saniyelik ağ gecikmesi simülasyonu ile asenkron veri çeker ve arayüzü kitlemeden sonucu durum kartına yansıtır. |
| **Canlı Sayaç** | `Stream` & `StreamBuilder` | `Stream.periodic` kullanarak her saniye yeni bir değer üreten bir veri akışı başlatır ve UI'ı reaktif olarak günceller. |
| **Ağır Hesap** | `Isolate` (`Isolate.run`) | Yoğun CPU tüketen `Fibonacci(35)` işlemini ayrı bir arka plan iş parçacığına taşır; böylece ana UI thread (Event Loop) donmaz. |
| **Görev Ekle** | Sound `Null Safety` | Nullable değişkenler (`String?`) ve null-coalescing (`??`) operatörünün varsayılan değer atama mantığını gösterir. |
| **Paralel Yükle** | `Future.wait` | 3 ayrı asenkron işlemi sıralı (~3000 ms) bekletmek yerine eş zamanlı/paralel koşturarak toplam süreyi ~1000 ms seviyesine indirir. |

---

##  Tasarım & UI Mimarisi

Uygulama, standart materyal tasarımların ötesine geçerek **Neobrutalism** esintili retro-modern bir arayüz stili sunar:

- **Özgün Renk Paleti:** Krem/bej zemin (`#F4EFE1`), sıcak açık kartlar (`#FBF8EF`) ve canlı vurgu renkleri (Sarı, Turuncu, Yeşil, Teal).
- **Yüksek Kontrastlı Hatlar:** Neobrutalism çizgisine uygun 2px kalınlığında koyu çerçeveler (`#22211E`) ve yuvarlatılmış köşeler.
- **Dinamik Durum Kartı:** İşlemler sürerken gösterilen `LinearProgressIndicator`, renkli durum etiketleri ve canlı Stream sayaç alanı.
- **Özel Alt Gezinme Menüsü:** Sayfa akışını ve hızlı Isolate çalıştırma aksiyonunu sağlayan şık bir bottom bar.

---

##  Proje Yapısı

```text
uygulama_dart/
├── lib/
│   └── main.dart            # Tüm UI bileşenleri, durum yönetimi ve Dart kavramlarının mantığı
├── test/
│   └── widget_test.dart     # Uygulamanın başarıyla derlendiğini ve temel bileşenleri doğrulayan testler
├── pubspec.yaml             # Proje bağımlılıkları ve meta bilgileri
└── README.md                # Proje dokümantasyonu
```

---

## Kurulum ve Çalıştırma

Projeyi yerel ortamınızda çalıştırmak için aşağıdaki adımları izleyebilirsiniz:

### 1. Ön Gereksinimler
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Sürüm: `3.0.0` veya üzeri)
- Dart SDK (`>=3.0.0 <4.0.0`)
- Android Studio / VS Code (Flutter eklentileriyle) veya bir emülatör / fiziksel cihaz

### 2. Bağımlılıkları Yükleme
Terminalde proje ana dizinine giderek:
```bash
flutter pub get
```

### 3. Uygulamayı Başlatma
Cihazınızı veya emülatörünüzü bağladıktan sonra:
```bash
flutter run
```

### 4. Testleri Koşturma
Mevcut widget testlerini doğrulamak için:
```bash
flutter test
```

---

## Hızlı İpuçları & Gözlemler

- **Ekran Donmasını Test Edin:** `Ağır Hesap` (Isolate) butonuna bastığınızda progress bar'ın akmaya devam ettiğini ve butonların tıklanabilir kaldığını göreceksiniz. Isolate olmasaydı arayüz tamamen kilitlenirdi.
- **Paralel Süre Tasarrufu:** `Paralel Yükle` kartına tıkladığınızda geçen milisaniye süresi ekrana yazılır; 3 adet 1 saniyelik işlemin tek seferde ~1 saniyede tamamlandığına şahit olabilirsiniz.
