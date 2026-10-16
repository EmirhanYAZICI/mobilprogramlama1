# Dart Konu Örnek Uygulaması

Bu klasör, verilen resmî Dart doküman sayfalarındaki konuları öğreten bir
örnek uygulama içerir. Her konu başlığına göre ayrı bir klasör oluşturulmuş
ve ilgili sayfadaki Dart kod örnekleri sırasıyla bu klasörlere
yerleştirilmiştir. Ana uygulama ise bu klasörlerden bağımsız olarak kökteki
`main.dart` dosyasıdır.

Dosya adlandırması **`NN-kisa-aciklama.dart`** biçimindedir; örneğin
`concurrency/01-event-loop-dongusu.dart`. Baştaki `NN` numarası kodun sayfada
geçtiği sırayı, sonrasındaki kısa açıklama ise kodun ne yaptığını belirtir.

## Klasör Yapısı

| Klasör | Kaynak sayfa | İçerik |
|--------|--------------|--------|
| `concurrency/` | dart.dev/language/concurrency | Event loop, Future, Stream, async-await, Isolate örnekleri |
| `async/` | dart.dev/language/async | `async`, `await`, `Future`, `await for` örnekleri |
| `isolates/` | dart.dev/language/isolates | `Isolate.run`, closure, `ReceivePort`/`SendPort`, uzun ömürlü işçi izoleleri |
| `null-safety/` | dart.dev/null-safety | Sound null safety girişi, non-nullable / nullable örnekler |
| `understanding-null-safety/` | dart.dev/null-safety/understanding-null-safety | Null safety'nin derinlemesine açıklaması ve 50 kod örneği |
| `keywords/` | dart.dev/language/keywords | Rezerve edilmiş anahtar kelimelerin listesi (bu sayfada çalıştırılabilir kod bloğu yer almaz) |
| `versioning/` | dart.dev/language/versioning | Dil sürümü (language versioning) yorumu örnekleri |
| `main.dart` | — | Tüm konuları birleştiren örnek uygulama |

> Not: Her klasördeki `NN-kisa-aciklama.dart` dosyaları, ilgili sayfada geçen
> kod bloklarının belge içindeki sırasına göre adlandırılmıştır.
> Bazı dosyalar yalnızca bir fonksiyon parçası veya söz dizimi şablonu
> içerir; bu nedenle tek başına her zaman çalıştırılabilir olmayabilir.
> Amaç, dokümandaki örneği birebir göstermektir.

## Ana Uygulama: `main.dart`

`main.dart`, yukarıdaki konuların tamamını tek bir çalıştırılabilir demo
halinde birleştirir. Programı çalıştırdığınızda dört bölüm sırayla işlenir:

### 1) Future / async-await
`fetchUserName(id)` fonksiyonu 300 ms gecikmeyle bir kullanıcı adı
döndüren bir `Future<String>` üretir.
- `await fetchUserName(1)` ve `await fetchUserName(2)` çağrıları **sıralı**
  olarak beklenir.
- `Future.wait([...])` ise birden çok Future'ı **eş zamanlı** bekler.

Amaç: `async`/`await` sözdiziminin ve `Future`'ların temel kullanımını
göstermek.

### 2) Stream / await-for
`taskIdStream(count)` fonksiyonu `async*` + `yield` kullanarak her 100 ms'de
bir artan bir `int` değeri yayınlar. `main` içindeki `await for` döngüsü bu
stream'i dinler ve her değer için bir `Task` nesnesi oluşturur.
Bu bölümde ayrıca `late` ve null-aware (`??=`, `!`) kullanımları gösterilir.

### 3) Null safety
`Task` sınıfı üzerinden null safety kavramları gösterilir:
- `title` ve `id` **non-nullable**'dır (asla null olamaz).
- `assignee` **nullable**'dır (`String?`).
- `assignee ?? 'atanmadı'` → null ise varsayılan değer (`??`).
- `assignee!.toUpperCase()` → değerin null olmadığını bildirme (`!`).
- `isAssigned` → `assignee != null` kontrolü (null-check promotion).

### 4) Isolate (arka plan işçisi)
`slowFib(n)` bilerek yavaş, özyineli (recursive) bir Fibonacci hesabıdır.
`computeFib(n)` bunu `Isolate.run(...)` ile **ayrı bir izolede** çalıştırır,
böylece ağır hesap ana izolenin event loop'unu kilitlemez. Program bu sonucu
beklerken ana izol serbest kaldığı için diğer olayları işleyebilir.

## Nasıl Çalıştırılır?

Bu depo için [Dart SDK](https://dart.dev/get-dart) (3.x) kurulu olmalıdır.
Kök dizinde aşağıdaki komutu çalıştırın:

```bash
dart run main.dart
```

Beklenen çıktı (kısa özet):

```
=== Dart Konu Demo Başladı ===

[1] Future / async-await örneği
   Çekilen kullanıcılar: kullanici_1, kullanici_2
   Paralel çekilenler: [kullanici_3, kullanici_4]

[2] Stream / await-for örneği
   Yeni görev geldi -> Görev 1 (atanan: atanmadı)
   ... (Görev 5'e kadar)
   Toplam 5 görev işlendi. İlk görev: Görev 1
   Özet: Stream toplam 5 görev üretti.

[3] Null safety örneği
   Atanmamış görev: atandı mı? false (atanan: atanmadı)
   Atanmış görev: atandı mı? true (büyük harf: AYŞE)

[4] Isolate örneği (arka plan işçisi)
   slowFib(35) = 14930352 (arka planda hesaplandı, ... ms)
   Ana izol bu süre boyunca serbest kaldı.

=== Demo Tamamlandı ===
```

> Not: `slowFib(35)` sonucu `14930352` olup yukarıdaki `concurrency/` ve
> `main.dart` içindeki tanıma göre `n <= 1 ? 1 : ...` biçiminde hesaplanır.

## Kavram → Kod Eşlemesi

| Kavram | Ana uygulamadaki karşılığı |
|--------|----------------------------|
| `Future` | `fetchUserName` |
| `async` / `await` | `fetchUserName`, `main`, `await for` |
| `Future.wait` | Eş zamanlı kullanıcı çekme |
| `Stream` / `async*` / `yield` | `taskIdStream` |
| `await for` | `taskIdStream` dinleme döngüsü |
| Null safety (`?`, `!`, `??`, promotion) | `Task` sınıfı ve bölüm 3 |
| `late` | `summary` değişkeni |
| Isolate (arka plan) | `computeFib` / `Isolate.run` |
| Language versioning | `main.dart` başındaki `// @dart = 3.4` |

## Önemli Notlar / Sınırlamalar

- Ana uygulama sadece Dart'ın yerel (native) platformda `Isolate.run`
  kullandığı için **Dart Native (CLI)** üzerinde çalıştırılmalıdır. Dart Web
  platformunda izole desteği farklıdır.
- Klasörlerdeki örnek dosyalar belgelerden birebir alınmıştır; bazıları
  eksik bağlam (örn. sadece bir fonksiyon gövdesi) içerir ve tek başına
  derlenmeyebilir. Bunlar referans amaçlıdır.
- `dart` komutu bu makinede kurulu değilse, önce
  <https://dart.dev/get-dart> adresinden SDK'yı kurun.
