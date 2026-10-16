# Görev ve Veri İşleme Sistemi (v1 · 2026 · toyscode)

**Mobil Programlama I · 4. Takım (toyscode)**
Konu: Dart dili, İleri Düzey ve Dil Özellikleri (Concurrency, Asynchronous programming, Isolates, Null safety, Keywords, Language versioning)

Bu klasörde iki şey var:

1. **`main.dart`**: Konuların hepsini tek bir senaryoda kullanan bir konsol uygulaması. Uygulama ham görev verilerini okur, null güvenliği kurallarıyla doğrular, asenkron servis çağrılarını ve canlı olay akışlarını yönetir, yoğun CPU gerektiren hesaplamayı ayrı bir isolate üzerinde çalıştırarak konsola rapor üretir.
2. **`cods/`** ve **`../../sunum/2026-guz-toyscode.pdf`**: dart.dev'deki ilgili kod örneklerinin çalıştırılabilir halleri ve Türkçe rehber. PDF'teki her kod kutusuna tıklayınca `cods/` içindeki ilgili dosya açılır. Bunun için depodaki klasör yapısı (`sunum/` ve `uygulama/` yan yana) korunmalıdır.

## Çalıştırma

Dart SDK 3.8 ya da daha yenisi gerekir (null-aware koleksiyon elemanları ve modern isolate desteği için).

```bash
dart run --enable-asserts main.dart
```

Kod örneklerinden birini çalıştırmak için:

```bash
cd cods
dart pub get
dart run 1_concurrency/01_event_loop.dart
```

VS Code'da `cods` klasörünü açıp bir dosyadayken **Ctrl+Shift+B**'ye basarsanız o dosya doğrudan çalışır.

## Uygulamada hangi konu nerede?

| Bölüm | Ne yapıyor | Kullanılan konular |
|---|---|---|
| 1. Veri doğrulama | Ham map verilerini okur, eksik ve null alanları güvenle işler | Sound null safety, nullable tipler (`String?`), null-coalescing (`??`, `??=`), `late final`, özel `Exception`, `assert` |
| 2. Asenkron servis çağrısı | Uzak API simülasyonundan veri çeker | `Future`, `async`/`await`, `try/catch`, `Future.delayed` |
| 3. Paralel veri yükleme | Bağımsız üç servisi eşzamanlı sorgular ve süreyi ölçer | `Future.wait`, `Stopwatch`, asenkron performans analizi |
| 4. Canlı olay akışı | Sistem olaylarını zamana yayılmış veri akışıyla dinler | `Stream`, `async*` üreteci, `yield`, `await for` |
| 5. Arka plan işlemi (Isolate) | Yoğun CPU işlemini ana olay döngüsünü kilitlemeden çalıştırır | `Isolate`, `Isolate.run`, iş parçacığı yönetimi |
| 6. Dil sürümleme ve anahtar kelimeler | Dart sürüm belirteci ve bağlamsal anahtar kelimeleri doğrular | `// @dart=3.8`, `late`, `required`, `yield`, `assert` |

## Beklenen çıktı (kısaltılmış)

```text
=== 1. Veri Doğrulama ve Null Güvenliği  [Sound Null Safety · Null-coalescing · late] ===
Görev #101 eklendi: Veritabanı yedeklemesi [Öncelik: Yüksek]
Görev #102 eklendi: Log temizliği [Öncelik: Normal]
Uyarı: Null kayıt atlandı.
Görev #103 eklendi: Bildirim gönderimi [Öncelik: Düşük]
Bağlantı: node-eu-01 (Yedek: tanımsız)

=== 2. Asenkron Servis Çağrısı  [Future · async / await · try-catch] ===
Uzak sunucudan sistem durumu isteniyor...
Servis yanıtı: Kimlik Servisi yanıt verdi (+250 ms)

=== 3. Paralel Veri Yükleme  [Future.wait · Stopwatch] ===
3 bağımsız servis paralel sorgulanıyor...
 -> Depolama Servisi yanıt verdi (+300 ms)
 -> Metrik Servisi yanıt verdi (+350 ms)
 -> Bildirim Servisi yanıt verdi (+250 ms)
Toplam geçen süre: 363 ms (sıralı çalışsaydı ~900 ms olurdu).

=== 4. Canlı Olay Akışı  [Stream · async* · yield · await for] ===
Olay dinleyicisi başlatıldı:
 [AKIŞ] Olay #1: Ağ bağlantısı sağlandı
 [AKIŞ] Olay #2: Kimlik doğrulama başarılı
 [AKIŞ] Olay #3: Veri senkronizasyonu tamamlandı
 [AKIŞ] Olay #4: Sistem hazır durumuna geçti

=== 5. Arka Plan İşlemi (Isolate)  [Isolate.run · Multi-threading] ===
Ağır CPU işlemi (Fibonacci 35) ayrı isolate üzerinde çalıştırılıyor...
Isolate tamamlandı: fib(35) = 9227465 (Hesaplama süresi: 67 ms).
Ana olay döngüsü (Event Loop) bu sırada kilitlenmedi.

=== 6. Dil Sürümleme ve Anahtar Kelimeler  [Language Versioning · Keywords · Assert] ===
Dart SDK sürümü: 3.8+ (Sound Null Safety varsayılan olarak aktif).
Tüm kontroller başarıyla tamamlandı.
```

## `cods/` klasör yapısı

```text
cods/
├── 1_concurrency/            Eşzamanlılık, event loop, mikro-görev kuyruğu
├── 2_async/                  Asenkron programlama, Future, async/await, Stream yapıları
├── 3_isolates/               Isolate oluşturma, Isolate.run, portlar arası mesajlaşma
├── 4_null_safety/            Sound null safety, nullable/non-nullable tipler, late, operatörler (?, !, ??)
├── 5_keywords_versioning/    Dart anahtar kelimeleri, dil sürümleme belirteçleri
└── _ortak/                   Örneklerin ortak kullandığı model ve yardımcı fonksiyonlar
```

- Dosya adları dart.dev'deki örnek bölge adlarından gelir (örnek: `01_event_loop.dart`, `02_future_basics.dart`).
- Başında `// Not: Bu örnek bilerek ... hata verir` yazan dosyalar, dokümandaki hatalı kullanım örnekleridir. Bunlar analizden hariç tutulmuştur.
- `_sozdizimi.dart` ile biten dosyalar çalıştırılabilir kod değil, sözdizimi şablonudur.

Kaynak: <https://dart.dev/language> (CC-BY 4.0, kod örnekleri BSD-3-Clause)
