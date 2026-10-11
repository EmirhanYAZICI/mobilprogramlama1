> **Uyarı:** Bu içerik, SCÜ Şarkışla UBYO Mobil Programlama I dersi kapsamında tamamen eğitim amaçlı çevrilmiş ve derlenmiştir. Orijinal dokümantasyon kaynakları (dart.dev, docs.flutter.dev) kendi orijinal lisanslarına (BSD-3-Clause, CC-BY 4.0) tabidir. Bu çalışmanın hiçbir ticari amacı yoktur.

# Dart Dil Rehberi: İleri Düzey ve Dil Özellikleri

**Mobil Programlama I · 4. Takım (TAKIM-ADI)** · Konu: Concurrency, Asynchronous programming, Isolates, Null safety, Keywords, Language versioning

Bu belge, [dart.dev](https://dart.dev/language) dokümantasyonunun ilgili bölümlerinin Türkçe çevirisidir.

## İçindekiler

- **Eşzamanlılık** (Concurrency)
  - Eşzamanlılık
  - Asenkron programlama
  - Isolate'lar
- **Null güvenliği** (Null safety)
  - Sağlam null güvenliği
  - Null güvenliğini anlamak
- **Anahtar kelimeler ve sürümleme** (Keywords & Versioning)
  - Anahtar kelimeler
  - Dil sürümleme

---

# Eşzamanlılık (Concurrency)

## Eşzamanlılık

*Birden fazla işlemci çekirdeğinde paralel kod çalıştırmayı sağlamak için isolate'ları kullanın.* · Kaynak: <https://dart.dev/language/concurrency>

Bu sayfa, Dart'ta eşzamanlı programlamanın nasıl çalıştığına dair kavramsal bir genel bakış sunar. Olay döngüsünü, asenkron dil özelliklerini ve isolate'ları üst düzeyde açıklar. Dart'ta eşzamanlılığı kullanmaya yönelik daha pratik kod örnekleri için [Asenkron programlama](https://dart.dev/language/async) sayfasını ve [Isolates](https://dart.dev/language/isolates) sayfasını okuyun.

Dart'ta eşzamanlı programlama, hem `Future` ve `Stream` gibi asenkron API'leri hem de süreçleri ayrı çekirdeklere taşımanıza olanak tanıyan *isolate*'ları ifade eder.

Tüm Dart kodu isolate'lar içinde çalışır; varsayılan ana isolate ile başlar ve isteğe bağlı olarak sonradan açıkça oluşturduğunuz isolate'lara genişleyebilir. Yeni bir isolate başlattığınızda, bu isolate'ın kendine ait yalıtılmış belleği ve kendine ait bir olay döngüsü olur. Dart'ta asenkron ve eşzamanlı programlamayı mümkün kılan şey olay döngüsüdür.

### Olay Döngüsü

Dart'ın çalışma zamanı modeli bir olay döngüsüne dayanır. Olay döngüsü; programınızın kodunu çalıştırmaktan, olayları toplayıp işlemekten ve daha fazlasından sorumludur.

Uygulamanız çalışırken tüm olaylar, *olay kuyruğu* adı verilen bir kuyruğa eklenir. Olaylar; kullanıcı arayüzünü yeniden çizme isteklerinden, kullanıcı dokunuşlarına ve tuş vuruşlarına, diskten gelen G/Ç'ye kadar her şey olabilir. Uygulamanız olayların hangi sırayla gerçekleşeceğini öngöremediği için, olay döngüsü olayları kuyruğa alındıkları sırayla, birer birer işler.

![Olayların tek tek olay döngüsüne beslendiğini gösteren bir şekil.](https://dart.dev/assets/img/language/concurrency/event-loop.png)

Olay döngüsünün işleyişi aşağıdaki koda benzer:

```dart
while (eventQueue.waitForEvent()) {
  eventQueue.processNextEvent();
}
```

Bu örnek olay döngüsü senkrondur ve tek bir iş parçacığı üzerinde çalışır. Ancak çoğu Dart uygulamasının aynı anda birden fazla iş yapması gerekir. Örneğin bir istemci uygulaması, bir kullanıcının bir düğmeye dokunmasını dinlerken aynı zamanda bir HTTP isteği de yürütmek zorunda kalabilir. Bunu ele almak için Dart, [Future'lar, Stream'ler ve async-await](https://dart.dev/language/async) gibi birçok asenkron API sunar. Bu API'ler bu olay döngüsünün etrafında inşa edilmiştir.

Örneğin bir ağ isteği yapmayı ele alalım:

```dart
http.get('https://example.com').then((response) {
  if (response.statusCode == 200) {
    print('Success!');
  }
}
```

Bu kod olay döngüsüne ulaştığında, ilk yan tümceyi olan `http.get`'i hemen çağırır ve bir `Future` döndürür. Ayrıca olay döngüsüne, HTTP isteği sonuçlanana kadar `then()` yan tümcesindeki geri çağrıyı elinde tutmasını söyler. İstek sonuçlandığında, isteğin sonucunu argüman olarak ileterek bu geri çağrıyı çalıştırmalıdır.

![Asenkron olayların olay döngüsüne eklendiğini ve daha sonra çalıştırılacak bir callback'i tuttuğunu gösteren şekil.](https://dart.dev/assets/img/language/concurrency/async-event-loop.png)

Olay döngüsünün Dart'taki diğer tüm asenkron olayları — örneğin [`Stream`](https://api.dart.dev/dart-async/Stream-class.html) nesneleri — ele alış biçimi de genel olarak bu modelle aynıdır.

### Asenkron Programlama

Bu bölüm, Dart'taki farklı asenkron programlama türlerini ve sözdizimlerini özetler. `Future`, `Stream` ve async-await konularına zaten aşinaysanız, doğrudan [isolate'lar bölümüne](#isolatelar) geçebilirsiniz.

#### Future'lar

Bir `Future`, sonunda bir değerle ya da bir hatayla tamamlanacak olan asenkron bir işlemin sonucunu temsil eder.

Bu örnek kodda, `Future<String>` dönüş tipi, sonunda bir `String` değeri (ya da bir hata) sağlama sözünü temsil eder.

```dart
Future<String> _readFileAsync(String filename) {
  final file = File(filename);
  // .readAsString() returns a Future.
  // .then() registers a callback to be executed when `readAsString` resolves.
  return file.readAsString().then((contents) {
    return contents.trim();
  });
}
```

#### async-await Sözdizimi

`async` ve `await` anahtar sözcükleri, asenkron fonksiyonları tanımlamak ve sonuçlarını kullanmak için bildirimsel bir yol sağlar.

Aşağıda, dosya G/Ç'sini beklerken bloke olan bazı senkron kodların bir örneği yer alıyor:

```dart
const String filename = 'with_keys.json';
void main() {
  // Read some data.
  final fileData = _readFileSync();
  final jsonData = jsonDecode(fileData);
  // Use that data.
  print('Number of JSON keys: ${jsonData.length}');
}
String _readFileSync() {
  final file = File(filename);
  final contents = file.readAsStringSync();
  return contents.trim();
}
```

İşte benzer bir kod; ancak onu asenkron hale getirmek için yapılan değişiklikler (vurgulanmış olarak) içeriyor:

```dart
const String filename = 'with_keys.json';
void main() async {
  // Read some data.
  final fileData = await _readFileAsync();
  final jsonData = jsonDecode(fileData);
  // Use that data.
  print('Number of JSON keys: ${jsonData.length}');
}
Future<String> _readFileAsync() async {
  final file = File(filename);
  final contents = await file.readAsString();
  return contents.trim();
}
```

`main()` fonksiyonu, yerel kod (dosya G/Ç'si) çalışırken diğer Dart kodlarının (örneğin olay işleyicilerinin) CPU'yu kullanabilmesi için `_readFileAsync()` çağrısının önünde `await` anahtar sözcüğünü kullanır. `await` kullanmanın bir diğer etkisi de, `_readFileAsync()` tarafından döndürülen `Future<String>` değerini bir `String`'e dönüştürmesidir. Sonuç olarak `contents` değişkeni, örtük olarak `String` tipine sahip olur.

> **Not:**
>
> `await` anahtar sözcüğü yalnızca, fonksiyon gövdesinden önce `async` bulunan fonksiyonlarda çalışır.

Aşağıdaki şekilde görüldüğü gibi, `readAsString()` Dart çalışma zamanında ya da işletim sisteminde Dart dışı bir kod çalıştırırken Dart kodu duraklar. `readAsString()` bir değer döndürdüğünde, Dart kodunun yürütülmesi kaldığı yerden devam eder.

![Uygulama kodunun başlangıçtan çıkışa kadar çalıştığını, arada yerel G/Ç'yi beklediğini gösteren akış şeması benzeri şekil.](https://dart.dev/assets/img/language/concurrency/basics-await.png)

#### Stream'ler

Dart, asenkron kodu stream biçiminde de destekler. Stream'ler, değerleri gelecekte ve zaman içinde tekrar tekrar sağlar. Zaman içinde bir dizi `int` değeri sağlama sözü, `Stream<int>` tipine sahiptir.

Aşağıdaki örnekte, `Stream.periodic` ile oluşturulan stream, her saniye yeni bir `int` değeri yayar.

```dart
Stream<int> stream = Stream.periodic(const Duration(seconds: 1), (i) => i * i);
```

##### await-for ve yield

Await-for, döngünün her bir sonraki yinelemesini yeni değerler sağlandıkça çalıştıran bir tür for döngüsüdür. Başka bir deyişle, stream'ler üzerinde "döngü kurmak" için kullanılır. Bu örnekte, argüman olarak verilen stream'den yeni değerler yayıldıkça `sumStream` fonksiyonundan da yeni bir değer yayılacaktır. Değer stream'leri döndüren fonksiyonlarda `return` yerine `yield` anahtar sözcüğü kullanılır.

```dart
Stream<int> sumStream(Stream<int> stream) async* {
  var sum = 0;
  await for (final value in stream) {
    yield sum += value;
  }
}
```

`async`, `await`, `Stream`'ler ve `Future`'lar hakkında daha fazla bilgi edinmek isterseniz [asenkron programlama eğitimine](https://dart.dev/libraries/async/async-await) göz atın.

### Isolate'lar

Dart, [asenkron API'lere](#asenkron-programlama) ek olarak isolate'lar aracılığıyla da eşzamanlılığı destekler. Çoğu modern cihaz çok çekirdekli CPU'lara sahiptir. Birden fazla çekirdekten yararlanmak için geliştiriciler bazen eşzamanlı çalışan, paylaşımlı bellekli iş parçacıkları kullanır. Ancak paylaşımlı durum eşzamanlılığı [hataya açıktır](https://en.wikipedia.org/wiki/Race_condition#In_software) ve karmaşık koda yol açabilir.

İş parçacıkları yerine, tüm Dart kodu isolate'lar içinde çalışır. Isolate'ları kullanarak Dart kodunuz, varsa ek işlemci çekirdeklerini de kullanarak aynı anda birden fazla bağımsız görev gerçekleştirebilir. Isolate'lar iş parçacıklarına veya süreçlere benzer; ancak her isolate'ın kendine ait belleği ve bir olay döngüsü çalıştıran tek bir iş parçacığı vardır.

Her isolate'ın kendi global alanları vardır; bu da bir isolate'daki hiçbir durumun başka bir isolate'dan erişilebilir olmamasını sağlar. Isolate'lar birbirleriyle yalnızca mesaj geçirerek iletişim kurabilir. Isolate'lar arasında paylaşılan durum olmaması, [mutex'ler veya kilitler](https://en.wikipedia.org/wiki/Lock_(computer_science)) ve [veri yarışları](https://en.wikipedia.org/wiki/Race_condition#Data_race) gibi eşzamanlılık karmaşıklıklarının Dart'ta yaşanmayacağı anlamına gelir. Bununla birlikte isolate'lar, yarış koşullarını tümüyle de önlemez. Bu eşzamanlılık modeli hakkında daha fazla bilgi için [Aktör modeli](https://en.wikipedia.org/wiki/Actor_model) hakkında okuyun.

> **Platform notu:**
>
> Isolate'ları yalnızca [Dart Native platformu](https://dart.dev/overview#platform) uygular. Dart Web platformu hakkında daha fazla bilgi edinmek için [Web'de eşzamanlılık](#webde-eşzamanlılık) bölümüne bakın.

#### Ana Isolate

Çoğu durumda isolate'ları hiç düşünmenize gerek yoktur. Dart programları varsayılan olarak ana isolate'da çalışır. Bu, bir programın çalışmaya ve yürütülmeye başladığı iş parçacığıdır; aşağıdaki şekilde gösterildiği gibi:

![main()'i çalıştıran, olaylara yanıt veren ve ardından sonlanan ana isolate'ı gösteren bir şekil.](https://dart.dev/assets/img/language/concurrency/basics-main-isolate.png)

Tek isolate'lı programlar bile sorunsuz çalışabilir. Bu uygulamalar, bir sonraki kod satırına geçmeden önce asenkron işlemlerin tamamlanmasını beklemek için [async-await](https://dart.dev/libraries/async/async-await) kullanır. İyi davranışlı bir uygulama hızlı başlar ve olay döngüsüne mümkün olan en kısa sürede ulaşır. Ardından uygulama, gerektiğinde asenkron işlemlerden yararlanarak kuyruktaki her olaya hızla yanıt verir.

#### Isolate Yaşam Döngüsü

Aşağıdaki şekilde görüldüğü gibi, her isolate `main()` fonksiyonu gibi bir miktar Dart kodu çalıştırarak başlar. Bu Dart kodu, örneğin kullanıcı girdisine veya dosya G/Ç'sine yanıt vermek için bazı olay dinleyicileri kaydedebilir. Isolate'ın başlangıç fonksiyonu döndüğünde, olayları işlemesi gerekiyorsa isolate ortada kalmaya devam eder. Olayları işledikten sonra isolate sonlanır.

![Herhangi bir isolate'ın kod çalıştırdığını, isteğe bağlı olarak olaylara yanıt verdiğini ve ardından sonlandığını gösteren daha genel bir şekil.](https://dart.dev/assets/img/language/concurrency/basics-isolate.png)

#### Olay İşleme

Bir istemci uygulamasında, ana isolate'ın olay kuyruğu yeniden çizim istekleri ile dokunma ve diğer arayüz olaylarına ilişkin bildirimler içerebilir. Örneğin aşağıdaki şekil, bir yeniden çizim olayını, ardından bir dokunma olayını, ardından da iki yeniden çizim olayını göstermektedir. Olay döngüsü olayları kuyruktan ilk giren ilk çıkar sırasıyla alır.

![Olayların tek tek olay döngüsüne beslendiğini gösteren bir şekil.](https://dart.dev/assets/img/language/concurrency/event-loop.png)

Olay işleme, `main()` sonlandıktan sonra ana isolate üzerinde gerçekleşir. Aşağıdaki şekilde, `main()` sonlandıktan sonra ana isolate önce ilk yeniden çizim olayını işler. Ardından ana isolate dokunma olayını, sonra da bir yeniden çizim olayını işler.

Bir senkron işlem çok fazla işlem süresi alırsa, uygulama yanıt vermez hale gelebilir. Aşağıdaki şekilde dokunmayı işleyen kod çok uzun sürdüğü için sonraki olaylar çok geç işlenmektedir. Uygulama donmuş gibi görünebilir ve gerçekleştirdiği her animasyon takılmalı olabilir.

![Çalışma süresi çok uzun olan bir dokunma işleyicisini gösteren bir şekil.](https://dart.dev/assets/img/language/concurrency/event-jank.png)

İstemci uygulamalarında, aşırı uzun süren bir senkron işlemin sonucu çoğunlukla [takılmalı (akıcı olmayan) arayüz animasyonlarıdır](https://docs.flutter.dev/perf/rendering-performance). Daha da kötüsü, arayüz tamamen yanıt vermez hale gelebilir.

#### Arka Plan Çalışanları

Uygulamanızın arayüzü, zaman alan bir hesaplama nedeniyle (örneğin [büyük bir JSON dosyasını ayrıştırmak](https://docs.flutter.dev/cookbook/networking/background-parsing)) yanıt vermez hale geliyorsa, bu hesaplamayı genellikle *arka plan çalışanı* olarak adlandırılan bir çalışan isolate'a devretmeyi düşünün. Aşağıdaki şekilde gösterilen yaygın bir durum, bir hesaplama yapıp ardından sonlanan basit bir çalışan isolate başlatmaktır. Çalışan isolate, sonlanırken sonucunu bir mesaj içinde döndürür.

![Ana isolate'ı ve basit bir işçi isolate'ı gösteren bir şekil.](https://dart.dev/assets/img/language/concurrency/isolate-bg-worker.png)

Bir çalışan isolate G/Ç gerçekleştirebilir (örneğin dosya okuyup yazabilir), zamanlayıcılar kurabilir ve daha fazlasını yapabilir. Kendine ait belleği vardır ve ana isolate ile hiçbir durumu paylaşmaz. Çalışan isolate, diğer isolate'ları etkilemeden bloke olabilir.

#### Isolate'ları Kullanmak

Kullanım senaryosuna bağlı olarak, Dart'ta isolate'larla çalışmanın iki yolu vardır:

- Ayrı bir iş parçacığında tek bir hesaplama yapmak için [`Isolate.run()`](https://api.dart.dev/dart-isolate/Isolate/run.html) kullanın.
- Zaman içinde birden fazla mesajı işleyecek bir isolate ya da bir arka plan çalışanı oluşturmak için [`Isolate.spawn()`](https://api.dart.dev/dart-isolate/Isolate/spawn.html) kullanın. Uzun ömürlü isolate'larla çalışma hakkında daha fazla bilgi için [Isolates](https://dart.dev/language/isolates) sayfasını okuyun.

Çoğu durumda, süreçleri arka planda çalıştırmak için önerilen API `Isolate.run`'dır.

##### Isolate.run()

Statik `Isolate.run()` metodu tek bir argüman gerektirir: yeni oluşturulan isolate üzerinde çalıştırılacak bir geri çağrı.

```dart
int slowFib(int n) => n <= 1 ? 1 : slowFib(n - 1) + slowFib(n - 2);
// Compute without blocking current isolate.
void fib40() async {
  var result = await Isolate.run(() => slowFib(40));
  print('Fib(40) = $result');
}
```

#### Performans ve Isolate Grupları

Bir isolate [`Isolate.spawn()`](https://api.dart.dev/dart-isolate/Isolate/spawn.html) çağırdığında, iki isolate aynı çalıştırılabilir koda sahip olur ve aynı *isolate grubunda* yer alır. Isolate grupları, kod paylaşımı gibi performans optimizasyonlarını mümkün kılar; yeni bir isolate, isolate grubuna ait kodu hemen çalıştırır. Ayrıca `Isolate.exit()` yalnızca isolate'lar aynı isolate grubundayken çalışır.

Bazı özel durumlarda, yeni isolate'ı belirtilen URI'deki kodun bir kopyasıyla kuran [`Isolate.spawnUri()`](https://api.dart.dev/dart-isolate/Isolate/spawnUri.html) metodunu kullanmanız gerekebilir. Ancak `spawnUri()`, `spawn()`'dan çok daha yavaştır ve yeni isolate, kendisini başlatanın isolate grubunda yer almaz. Bir diğer performans sonucu da, isolate'lar farklı gruplardayken mesaj geçirmenin daha yavaş olmasıdır.

#### Isolate'ların Sınırlamaları

##### Isolate'lar iş parçacığı değildir

Dart'a çok iş parçacıklı bir dilden geliyorsanız, isolate'ların iş parçacıkları gibi davranmasını beklemek makul olurdu; ancak durum böyle değildir. Her isolate'ın kendi durumu vardır ve bu, bir isolate'daki hiçbir durumun başka bir isolate'dan erişilebilir olmamasını sağlar. Bu nedenle isolate'lar, yalnızca kendi belleklerine erişimle sınırlıdır.

Örneğin, global bir değiştirilebilir değişkene sahip bir uygulamanız varsa, bu değişken başlatılan isolate'da ayrı bir değişken olacaktır. Bu değişkeni başlatılan isolate'da değiştirirseniz, ana isolate'daki değişken olduğu gibi kalır. Isolate'lar tam da bu şekilde çalışmak üzere tasarlanmıştır ve isolate kullanmayı düşünürken bunu aklınızda tutmak önemlidir.

##### Mesaj tipleri

[`SendPort`](https://api.dart.dev/dart-isolate/SendPort-class.html) üzerinden gönderilen mesajlar neredeyse her tür Dart nesnesi olabilir, ancak birkaç istisna vardır:

- [`Socket`](https://api.dart.dev/dart-io/Socket-class.html) gibi yerel kaynaklara sahip nesneler.

```dart
ReceivePort
DynamicLibrary
Finalizable
Finalizer
NativeFinalizer
Pointer
UserTag
```

- `@pragma('vm:isolate-unsendable')` ile işaretlenmiş sınıfların örnekleri.

Bu istisnalar dışında, her nesne gönderilebilir. Daha fazla bilgi için [`SendPort.send`](https://api.dart.dev/dart-isolate/SendPort/send.html) dokümantasyonuna göz atın.

`Isolate.spawn()` ve `Isolate.exit()` metotlarının `SendPort` nesneleri üzerinde bir soyutlama sağladığını, dolayısıyla aynı sınırlamalara tabi olduklarını unutmayın.

##### Isolate'lar arasında senkron bloke edici iletişim

Paralel çalışabilecek isolate sayısında bir sınır vardır. Bu sınır, Dart'ta isolate'lar arasında mesajlar aracılığıyla yapılan standart *asenkron* iletişimi etkilemez. Yüzlerce isolate'ı eşzamanlı olarak çalıştırabilir ve ilerleme kaydettirebilirsiniz. Isolate'lar CPU üzerinde döngüsel biçimde zamanlanır ve birbirlerine sık sık yol verir.

Isolate'lar, saf Dart'ın dışında yalnızca *senkron* olarak iletişim kurabilir; bunu yapmak için de [FFI](https://dart.dev/interop/c-interop) aracılığıyla C kodu kullanılır. FFI çağrılarında senkron bloke ederek isolate'lar arasında senkron iletişim kurmaya çalışmak, özel bir dikkat gösterilmediği sürece, isolate sayısı sınırı aşarsa kilitlenmeye yol açabilir. Sınır belirli bir sayıya sabitlenmiş değildir; Dart uygulamasının kullanımına açık Dart VM yığın boyutuna göre hesaplanır.

Bu durumdan kaçınmak için, senkron bloke etme işlemini gerçekleştiren C kodunun, bloke edici işlemi yapmadan önce mevcut isolate'dan ayrılması ve FFI çağrısından Dart'a dönmeden önce isolate'a yeniden girmesi gerekir. Daha fazla bilgi edinmek için `Dart_EnterIsolate` ve `Dart_ExitIsolate` hakkında okuyun.

### Web'de Eşzamanlılık

Tüm Dart uygulamaları, bloke etmeyen, iç içe geçmiş hesaplamalar için `async-await`, `Future` ve `Stream` kullanabilir. Ancak [Dart web platformu](https://dart.dev/overview#platform) isolate'ları desteklemez. Dart web uygulamaları, betikleri isolate'lara benzer biçimde arka plan iş parçacıklarında çalıştırmak için [web çalışanlarını](https://developer.mozilla.org/docs/Web/API/Web_Workers_API/Using_web_workers) kullanabilir. Ancak web çalışanlarının işlevselliği ve yetenekleri isolate'lardan bir miktar farklıdır.

Örneğin web çalışanları iş parçacıkları arasında veri gönderirken veriyi ileri geri kopyalar. Ancak veri kopyalama, özellikle büyük mesajlarda çok yavaş olabilir. Isolate'lar da aynı şeyi yapar; ancak bunun yerine mesajı tutan belleği daha verimli biçimde *aktarabilen* API'ler de sunar.

Web çalışanları ile isolate'ları oluşturma biçimi de farklıdır. Web çalışanlarını yalnızca ayrı bir program giriş noktası tanımlayıp onu ayrı olarak derleyerek oluşturabilirsiniz. Bir web çalışanını başlatmak, bir isolate'ı başlatmak için `Isolate.spawnUri` kullanmaya benzer. Bir isolate'ı `Isolate.spawn` ile de başlatabilirsiniz; bu, kendisini başlatan isolate ile [kodun ve verinin bir kısmını yeniden kullandığı](#performans-ve-isolate-grupları) için daha az kaynak gerektirir. Web çalışanları için eşdeğer bir API yoktur.

### Ek Kaynaklar

- Çok sayıda isolate kullanıyorsanız, Flutter'da [`IsolateNameServer`](https://api.flutter.dev/flutter/dart-ui/IsolateNameServer-class.html) veya Flutter dışı Dart uygulamaları için benzer işlevsellik sağlayan [`package:isolate_name_server`](https://pub.dev/packages/isolate_name_server) paketini değerlendirin.
- Dart isolate'larının dayandığı [Aktör modeli](https://en.wikipedia.org/wiki/Actor_model) hakkında daha fazla bilgi edinin.
- `Isolate` API'lerine ilişkin ek dokümantasyon:

```dart
Isolate.exit()
Isolate.spawn()
ReceivePort
SendPort
```

## Asenkron programlama

*Dart'ta asenkron kod yazma hakkında bilgiler.* · Kaynak: <https://dart.dev/language/async>

Dart kütüphaneleri, [`Future`](https://api.dart.dev/dart-async/Future-class.html) veya [`Stream`](https://api.dart.dev/dart-async/Stream-class.html) nesneleri döndüren fonksiyonlarla doludur. Bu fonksiyonlar *asenkrondur*: zaman alması muhtemel bir işlemi (örneğin G/Ç) başlattıktan sonra, o işlemin tamamlanmasını beklemeden geri dönerler.

`async` ve `await` anahtar sözcükleri asenkron programlamayı destekler; böylece senkron koda benzeyen asenkron kod yazmanızı sağlarlar.

### Future'ları yönetmek

Tamamlanmış bir Future'ın sonucuna ihtiyaç duyduğunuzda iki seçeneğiniz vardır:

- `async` ve `await` kullanın; burada ve [asenkron programlama eğitiminde](https://dart.dev/libraries/async/async-await) açıklandığı gibi.
- Future API'sini kullanın; [dart:async belgelerinde](https://dart.dev/libraries/dart-async#future) açıklandığı gibi.

`async` ve `await` kullanan kod asenkrondur, ancak senkron koda çok benzer görünür. Örneğin, aşağıdaki kod bir asenkron fonksiyonun sonucunu beklemek için `await` kullanır:

```dart
await lookUpVersion();
```

`await` kullanmak için kodun bir `async` fonksiyonunda, yani `async` olarak işaretlenmiş bir fonksiyonda olması gerekir:

```dart
Future<void> checkVersion() async {
  var version = await lookUpVersion();
  // version ile bir şey yap
}
```

> **Not:**
>
> Bir `async` fonksiyonu zaman alan işlemler gerçekleştirebilse de bu işlemleri beklemez. Bunun yerine `async` fonksiyonu yalnızca ilk `await` ifadesiyle karşılaşana kadar çalışır. Ardından bir `Future` nesnesi döndürür ve yürütmeye ancak `await` ifadesi tamamlandıktan sonra devam eder.

`await` kullanan koddaki hataları ele almak ve temizlik yapmak için `try`, `catch` ve `finally` kullanın:

```dart
try {
  version = await lookUpVersion();
} catch (e) {
  // Sürümün bulunamamasına tepki ver
}
```

Bir `async` fonksiyonunda `await` ifadesini birden çok kez kullanabilirsiniz. Örneğin, aşağıdaki kod fonksiyonların sonuçları için üç kez bekler:

```dart
var entrypoint = await findEntryPoint();
var exitCode = await runExecutable(entrypoint, args);
await flushThenExit(exitCode);
```

`await expression` içinde `expression` değeri genellikle bir Future'dır; değilse, değer otomatik olarak bir Future içine sarılır. Bu Future nesnesi, bir nesne döndüreceğine dair bir söz belirtir. `await expression` ifadesinin değeri, döndürülen o nesnedir. await ifadesi, bu nesne kullanılabilir olana kadar yürütmenin duraklamasına neden olur.

**await kullanırken derleme zamanı hatası alırsanız, await ifadesinin bir async fonksiyonunda olduğundan emin olun.** Örneğin, uygulamanızın `main()` fonksiyonunda `await` kullanmak için `main()` gövdesinin `async` olarak işaretlenmesi gerekir:

```dart
void main() async {
  checkVersion();
  print('In main: version is ${await lookUpVersion()}');
}
```

> **Not:**
>
> Önceki örnek, sonucunu beklemeden bir `async` fonksiyonunu (`checkVersion()`) kullanır; kod fonksiyonun çalışmasını bitirdiğini varsayıyorsa bu uygulama sorunlara yol açabilir. Bu sorunu önlemek için [unawaited\_futures linter kuralını](https://dart.dev/tools/linter-rules/unawaited_futures) kullanın.

Future'ların, `async` ve `await` kullanımının etkileşimli bir tanıtımı için [asenkron programlama eğitimine](https://dart.dev/libraries/async/async-await) bakın.

### async fonksiyonlarını tanımlamak

Bir `async` fonksiyonu, gövdesi `async` değiştiricisiyle işaretlenmiş bir fonksiyondur.

Bir fonksiyona `async` anahtar sözcüğünü eklemek, o fonksiyonun bir Future döndürmesini sağlar. Örneğin, bir String döndüren şu senkron fonksiyonu ele alalım:

```dart
String lookUpVersion() => '1.0.0';
```

Bunu bir `async` fonksiyonuna dönüştürürseniz (örneğin gelecekteki bir uygulama zaman alacağı için), döndürülen değer bir Future olur:

```dart
Future<String> lookUpVersion() async => '1.0.0';
```

Fonksiyonun gövdesinin Future API'sini kullanması gerekmediğine dikkat edin. Gerekirse Dart, Future nesnesini sizin için oluşturur. Fonksiyonunuz kullanışlı bir değer döndürmüyorsa, dönüş türünü `Future<void>` yapın.

Future'ların, `async` ve `await` kullanımının etkileşimli bir tanıtımı için [asenkron programlama eğitimine](https://dart.dev/libraries/async/async-await) bakın.

### Stream'leri yönetmek

Bir Stream'den değer almanız gerektiğinde iki seçeneğiniz vardır:

- `async` ve bir *asenkron for döngüsü* (`await for`) kullanın.
- Stream API'sini kullanın; [dart:async belgelerinde](https://dart.dev/libraries/dart-async#stream) açıklandığı gibi.

> **Not:**
>
> `await for` kullanmadan önce, kodu daha anlaşılır hale getirdiğinden ve gerçekten stream'in tüm sonuçlarını beklemek istediğinizden emin olun. Örneğin, UI çerçeveleri sonsuz olay akışları gönderdiği için UI olay dinleyicileri için genellikle **kullanmamalısınız**.

Bir asenkron for döngüsü şu biçimdedir:

```dart
await for (varOrType identifier in expression) {
  // Stream her değer yaydığında çalıştırılır.
}
```

`expression` değerinin türü Stream olmalıdır. Yürütme şu şekilde ilerler:

1. Stream bir değer yayana kadar bekle.
2. Değişken, yayılan bu değere ayarlanmış halde for döngüsünün gövdesini çalıştır.
3. Stream kapanana kadar 1. ve 2. adımları tekrarla.

Stream'i dinlemeyi bırakmak için `break` veya `return` deyimini kullanabilirsiniz; bu deyimler for döngüsünden çıkar ve stream aboneliğini sonlandırır.

**Bir asenkron for döngüsü uygularken derleme zamanı hatası alırsanız, await for ifadesinin bir async fonksiyonunda olduğundan emin olun.** Örneğin, uygulamanızın `main()` fonksiyonunda bir asenkron for döngüsü kullanmak için `main()` gövdesinin `async` olarak işaretlenmesi gerekir:

```dart
void main() async {
  // ...
  await for (final request in requestServer) {
    handleRequest(request);
  }
  // ...
}
```

Dart'ın asenkron programlama desteği hakkında daha fazla bilgi için [`dart:async`](https://dart.dev/libraries/dart-async) kütüphane belgelerine göz atın.

## Isolate'lar

*Dart'ta isolate yazma hakkında bilgiler.* · Kaynak: <https://dart.dev/language/isolates>

Bu sayfada, `Isolate` izole uygulamaları hayata geçirmek için API'nin kullanımına dair bazı örnekler ele alınmaktadır.

Uygulamanız, diğer hesaplamaları geçici olarak engelleyecek kadar büyük hesaplamalar yapıyorsa, izole kodlar kullanmalısınız. En yaygın örnek, Flutter uygulamalarında, aksi takdirde kullanıcı arayüzünün yanıt vermemesine neden olabilecek büyük hesaplamalar yapmanız gerektiğinde görülür.

> **Flutter notu:**
>
> Flutter web, birden fazla izole sınıfı desteklemiyor. Ayrıca bakınız: Web'de eşzamanlılık

İzole genleri ne zaman kullanmanız gerektiğine dair kesin kurallar yok , ancak işte bunların faydalı olabileceği bazı durumlar:

- Son derece büyük JSON veri bloklarını ayrıştırma ve kod çözme.
- Fotoğraf, ses ve video dosyalarının işlenmesi ve sıkıştırılması.
- Ses ve video dosyalarını dönüştürme.
- Büyük listelerde veya dosya sistemlerinde karmaşık arama ve filtreleme işlemleri gerçekleştirme.
- Veritabanıyla iletişim kurmak gibi giriş/çıkış işlemleri gerçekleştirmek.
- Çok sayıda ağ isteğini işlemek.

### Basit Bir İşçi İsolate Uygulamak

Bu örnekler, basit bir çalışan izole işlemi başlatan ana bir izole işlemi uygular. `Isolate.run()` Çalışan izole işlemlerinin kurulumu ve yönetimiyle ilgili adımları basitleştirir:

- İzole bir nesne oluşturur (başlatır ve yaratır).
- Oluşturulan izole ortamda bir fonksiyon çalıştırır.
- Sonucu kaydeder.
- Sonucu ana izoleye döndürür.
- İşlem tamamlandığında izolasyonu sonlandırır.
- İstisnaları ve hataları kontrol eder, yakalar ve ana izole ortama geri gönderir.

> **Flutter notu:**
>
> Eğer Flutter kullanıyorsanız, `Isolate.run()` yerine Flutter'ın `compute` fonksiyonunu kullanabilirsiniz.

#### Yeni Bir İsolate Ortamda Mevcut Bir Yöntemi Çalıştırmak

Ana izole işlem içinde, sonuç beklenirken doğrudan yeni bir izole işlem ( arka planda çalışan bir işlem ) `run()` başlatmak için çağrı yapılır : `main()`

```dart
const String filename = 'with_keys.json';
void main() async {
  // Read some data.
  final jsonData = await Isolate.run(_readAndParseJson);
  // Use that data.
  print('Number of JSON keys: ${jsonData.length}');
}
```

Çalışana, çalıştırmasını istediğiniz fonksiyonu ilk argüman olarak iletin. Bu örnekte, mevcut fonksiyondur `_readAndParseJson()`:

```dart
Future<Map<String, dynamic>> _readAndParseJson() async {
  final fileData = await File(filename).readAsString();
  final jsonData = jsonDecode(fileData) as Map<String, dynamic>;
  return jsonData;
}
```

`Isolate.run()` Sonucu alır `_readAndParseJson()`, değeri ana izole cihaza geri gönderir ve işçi izole cihazını kapatır.

Çalışan izole hücre, sonucu tutan belleği ana izole hücreye aktarır . Verileri kopyalamaz . Çalışan izole hücre, nesnelerin aktarılmasına izin verilip verilmediğini doğrulamak için bir doğrulama işlemi gerçekleştirir.

`_readAndParseJson()` Mevcut, eşzamansız bir fonksiyondur ve ana izole ortamda doğrudan çalıştırılabilir. `Isolate.run()` Bunun yerine kullanarak çalıştırmak eşzamanlılığı sağlar. Çalışan izole ortam, hesaplamalarını tamamen soyutlar `_readAndParseJson()`. Ana izole ortamı engellemeden tamamlanabilir.

Sonuç `Isolate.run()` her zaman bir Future'dır, çünkü ana izole ortamdaki kod çalışmaya devam eder. Çalışan izole ortamın yürüttüğü hesaplamanın senkron mu yoksa asenkron mu olduğu ana izole ortamı etkilemez, çünkü her iki durumda da eş zamanlı olarak çalışır.

Programın tamamı için send\_and\_receive.dart örnek dosyasına göz atabilirsiniz.

#### İsolatelerle Birlikte Kapatma İşlemleri Gönderiliyor.

`run()` Ana izole ortamda doğrudan bir fonksiyon değişmezi veya kapatma kullanarak da basit bir çalışan izole ortamı oluşturabilirsiniz .

```dart
const String filename = 'with_keys.json';
void main() async {
  // Read some data.
  final jsonData = await Isolate.run(() async {
    final fileData = await File(filename).readAsString();
    final jsonData = jsonDecode(fileData) as Map<String, dynamic>;
    return jsonData;
  });
  // Use that data.
  print('Number of JSON keys: ${jsonData.length}');
}
```

Bu örnek, bir öncekiyle aynı işlevi görüyor. Yeni bir izole işlem başlatılıyor, bir şeyler hesaplanıyor ve sonuç geri gönderiliyor.

Ancak şimdi izole edilmiş nesne bir closure gönderiyor . Closure'lar, hem işleyiş biçimleri hem de koda yazılma şekilleri bakımından tipik adlandırılmış fonksiyonlardan daha az sınırlıdır. Bu örnekte, yerel kod gibi görünen bir şeyi eş zamanlı olarak yürütüyor. Bu anlamda, "paralel çalıştır" için bir kontrol akışı operatörü gibi çalıştığını `Isolate.run()` düşünebilirsiniz `.run()`

### Portlar Aracılığıyla İsolate Cihazlar Arasında Birden Fazla Mesaj Gönderme

Kısa ömürlü izole ortamlar kullanımı kolaydır, ancak yeni izole ortamlar oluşturmak ve nesneleri bir izole ortamdan diğerine kopyalamak performans açısından ek yük getirir. Kodunuz aynı hesaplamayı tekrar tekrar çalıştırmaya dayanıyorsa `Isolate.run`, bunun yerine hemen çıkmayan uzun ömürlü izole ortamlar oluşturarak performansı artırabilirsiniz.

Bunu yapmak için, soyutlama sağlayan bazı düşük seviyeli izole API'lerden yararlanabilirsiniz `Isolate.run`:

- `Isolate.spawn()` Ve `Isolate.exit()`
- `ReceivePort` Ve `SendPort`
- `SendPort.send()` yöntem

Bu bölümde, yeni oluşturulan bir izole sistem ile ana izole sistem arasında çift yönlü iletişimi kurmak için gereken adımlar ele alınmaktadır . İlk örnek olan "Temel portlar" , süreci genel bir düzeyde tanıtmaktadır. İkinci örnek olan "Sağlam portlar" ise, ilk örneğe kademeli olarak daha pratik, gerçek dünya işlevselliği eklemektedir.

#### `ReceivePort` Ve `SendPort`

İzole cihazlar arasında uzun süreli iletişim kurmak için (ek olarak `Isolate`) iki sınıfa daha ihtiyaç vardır: `ReceivePort` ve `SendPort`. Bu portlar, izole cihazların birbirleriyle iletişim kurmasının tek yoludur.

A `ReceivePort`, diğer izole sistemlerden gönderilen mesajları işleyen bir nesnedir. Bu mesajlar bir aracılığıyla gönderilir `SendPort`.

> **Not:**
>
> Bir `SendPort` nesne yalnızca bir ile ilişkilidir `ReceivePort`, ancak tek bir nesnenin `ReceivePort` birden fazla nesnesi olabilir `SendPorts`. Bir nesne oluşturduğunuzda `ReceivePort`, kendisi için bir nesne daha oluşturur . Mevcut bir nesneye mesaj gönderebilen `SendPort` ek nesneler oluşturabilirsiniz .

Portlar Stream nesnelere benzer şekilde davranır (aslında, alıcı portlar da uygular !). Bir ve portunu sırasıyla Stream'in ve dinleyicileri gibi `Stream` düşünebilirsiniz . Bir port, bir porta benzer çünkü bunlara `request` yöntemiyle mesajlar "eklersiniz" ve bu mesajlar bir dinleyici tarafından, bu durumda `request` tarafından, işlenir . `request` daha sonra aldığı mesajları, sağladığınız bir geri çağırma işlevine argüman olarak geçirerek işler.

#### Bağlantı Noktalarının Ayarlanması

Yeni oluşturulan bir izole hücre, yalnızca çağrı yoluyla aldığı bilgilere sahiptir `Isolate.spawn`. Ana izole hücrenin, ilk oluşturulmasından sonra da yeni oluşturulan izole hücreyle iletişim kurmaya devam etmesi gerekiyorsa, yeni oluşturulan izole hücrenin ana izole hücreye mesaj gönderebileceği bir iletişim kanalı kurmalısınız. İzole hücreler yalnızca mesaj yoluyla iletişim kurabilirler. Birbirlerinin hafızasının içine "bakamazlar", bu da "izolat" adının kökenini oluşturur.

Bu çift yönlü iletişimi kurmak için öncelikle `ReceivePort` ana izole ortamda bir nesnesi oluşturun, ardından `SendPort` bu nesneyi yeni izole ortamı oluştururken argüman olarak yeni izole ortama iletin `Isolate.spawn`. Yeni izole ortam daha sonra kendi nesnesini oluşturur `ReceivePort` ve ana izole ortam tarafından kendisine iletilen nesnesi üzerinden geri gönderir . Ana izole ortam bu nesneyi alır ve artık her iki taraf da mesaj gönderip almak için açık bir kanala sahip olur. `SendPort`

> **Not:**
>
> Bu bölümdeki diyagramlar genel bir bakış açısı sunmakta ve izole cihazlar için portların kullanım konseptini aktarmayı amaçlamaktadır. Gerçek uygulama biraz daha fazla kod gerektirir ve bu kodu sayfanın ilerleyen bölümlerinde bulacaksınız .

![Ana isolate ile işçi isolate arasında port kurulumunu gösteren şekil.](https://dart.dev/assets/img/language/concurrency/ports-setup.png)

1. `ReceivePort` Ana izole ortamda bir tane oluşturun . Bu, `SendPort` üzerinde bir özellik olarak otomatik olarak oluşturulur `ReceivePort`.
2. İşçi izolesini şu şekilde oluşturun: `Isolate.spawn()`
3. `ReceivePort.sendPort` Çalışan izole cihaza ilk mesaj olarak bir referans iletin .
4. `ReceivePort` İşçi izolasyonunda yeni bir tane daha oluşturun .
5. Ana izole cihaza *geri gönderilen* `ReceivePort.sendPort` ilk mesajda, çalışan izole cihazın referansını iletin .

Bağlantı noktalarını oluşturmanın ve iletişimi kurmanın yanı sıra, bağlantı noktalarına mesaj aldıklarında ne yapacaklarını da belirtmeniz gerekecek. Bu, `listen` her birine ait yöntem kullanılarak yapılır `ReceivePort`.

![Olay döngüsüne tek tek beslenen olayları gösteren bir şekil.](https://dart.dev/assets/img/language/concurrency/ports-passing-messages.png)

1. Ana izole cihazın referansı üzerinden çalışan izole cihazına bir mesaj gönderin `SendPort`.
2. Çalışan izole sunucudaki bir dinleyici aracılığıyla mesajı alın ve işleyin `ReceivePort`. Ana izole sunucudan taşımak istediğiniz hesaplama burada yürütülür.
3. Çalışan izole ünitesinin ana izole ünitesine olan referansı aracılığıyla bir yanıt mesajı gönderin `SendPort`.
4. Mesajı ana izole cihazın üzerindeki bir dinleyici aracılığıyla alın `ReceivePort`.

#### Temel Bağlantı Noktaları Örneği

Bu örnek, ana izole ile arasında çift yönlü iletişim bulunan uzun ömürlü bir çalışan izole nasıl kurulabileceğini göstermektedir. Kod, JSON metninin yeni bir izoleye gönderilmesi örneğini kullanmaktadır; burada JSON ayrıştırılıp çözümlendikten sonra ana izoleye geri gönderilecektir.

> **Uyarı:**
>
> Bu örnek , zaman içinde birden fazla mesaj gönderip alabilen yeni bir izole hücre oluşturmak için gereken en temel bilgileri öğretmeyi amaçlamaktadır .
>
> Üretim yazılımlarında beklenen hata yönetimi, port kapatma ve mesaj sıralaması gibi önemli işlevleri kapsamamaktadır.
>
> Sonraki bölümde yer alan Sağlam bağlantı noktaları örneği, bu işlevselliği kapsamakta ve bu işlevsellik olmadan ortaya çıkabilecek bazı sorunları ele almaktadır.

##### Adım 1: Çalışan Sınıfını Tanımlayın

Öncelikle, arka plan çalışanı izole işleminiz için bir sınıf oluşturun. Bu sınıf, aşağıdaki işlevleri yerine getirmek için ihtiyacınız olan tüm fonksiyonları içerir:

- İzole bir varlık oluşturun.
- O izole cihaza mesaj gönder.
- İzole cihazın bazı JSON verilerini çözmesini sağlayın.
- Çözümlenmiş JSON dosyasını ana izole cihaza geri gönderin.

Bu sınıf iki genel yöntem sunar: biri çalışan izole sunucuyu başlatır, diğeri ise bu çalışan izole sunucuya mesaj göndermeyi yönetir.

Bu örneğin geri kalan bölümleri, sınıf yöntemlerini tek tek nasıl dolduracağınızı gösterecektir.

```dart
class Worker {
  Future<void> spawn() async {
    // TODO: Add functionality to spawn a worker isolate.
  }
  void _handleResponsesFromIsolate(dynamic message) {
    // TODO: Handle messages sent back from the worker isolate.
  }
  static void _startRemoteIsolate(SendPort port) {
    // TODO: Define code that should be executed on the worker isolate.
  }
  Future<void> parseJson(String message) async {
    // TODO: Define a public method that can
    // be used to send messages to the worker isolate.
  }
}
```

##### Adım 2: Bir İşçi İsolate Hücresi Oluşturun

Bu `Worker.spawn` yöntem, çalışan izole işlemini oluşturmak ve mesaj alıp gönderebilmesini sağlamak için gereken kodu gruplandıracağınız yerdir.

- Öncelikle bir tane oluşturun `ReceivePort`. Bu, ana izole cihazın yeni oluşturulan işçi izole cihazından gönderilen mesajları almasını sağlar.
- Ardından, çalışan izole cihazın geri göndereceği mesajları işlemek için alma portuna bir dinleyici ekleyin. Dinleyiciye iletilen geri çağırma işlevi, 4. `_handleResponsesFromIsolate` adımda ele alınacaktır .
- Son olarak, `worker isolate`'ı `spatch` komutuyla başlatın `Isolate.spawn`. Bu komut iki argüman bekler: worker isolate üzerinde yürütülecek bir fonksiyon ( 3. adımda ele alınmıştır ) ve `sendPort` alma portunun özelliği.

```dart
Future<void> spawn() async {
  final receivePort = ReceivePort();
  receivePort.listen(_handleResponsesFromIsolate);
  await Isolate.spawn(_startRemoteIsolate, receivePort.sendPort);
}
```

Bu `receivePort.sendPort` argüman, işçi izolesinde çağrıldığında geri çağrı fonksiyonuna ( ) bir argüman olarak iletilecektir `_startRemoteIsolate`. Bu, işçi izolesinin ana izoleye mesaj gönderebilmesini sağlamanın ilk adımıdır.

##### Adım 3: Çalışan İsolate Sunucuda Kodu Çalıştırın.

`_startRemoteIsolate` Bu adımda, çalışan izole işlem başlatıldığında yürütülecek olan yöntemi tanımlarsınız . Bu yöntem, çalışan izole işlem için "ana" yöntem gibidir.

- Öncelikle, yeni bir port daha oluşturun `ReceivePort`. Bu port, ana izole cihazdan gelen gelecekteki mesajları alacaktır.
- Ardından, o portun verilerini `SendPort` ana izole cihaza geri gönderin.
- Son olarak, yeni yapıya bir dinleyici ekleyin `ReceivePort`. Bu dinleyici, ana izole cihazın çalışan izole cihaza gönderdiği mesajları işler.

```dart
static void _startRemoteIsolate(SendPort port) {
  final receivePort = ReceivePort();
  port.send(receivePort.sendPort);
  receivePort.listen((dynamic message) async {
    if (message is String) {
      final transformed = jsonDecode(message);
      port.send(transformed);
    }
  });
}
```

Çalışan cihazdaki dinleyici, `ReceivePort` ana izole cihazdan gelen JSON verisini çözümler ve ardından çözümlenmiş JSON verisini ana izole cihaza geri gönderir.

Bu dinleyici, ana izole sistemden çalışan izole sisteme gönderilen mesajlar için giriş noktasıdır. Çalışan izole sisteme gelecekte hangi kodu çalıştıracağını söyleyebileceğiniz tek fırsat budur.

##### Adım 4: Ana İsolate Cihazda Mesajları İşleyin

Son olarak, ana izole cihazın, işçi izole cihazından ana izole cihaza gönderilen mesajları nasıl işleyeceğini belirtmeniz gerekiyor. Bunu yapmak için, ilgili metodu doldurmanız gerekir `_handleResponsesFromIsolate`. Hatırlayın ki, bu metot 2. adımda açıklandığı gibi `receivePort.listen` metoduna iletilir :

```dart
Future<void> spawn() async {
  final receivePort = ReceivePort();
  receivePort.listen(_handleResponsesFromIsolate);
  await Isolate.spawn(_startRemoteIsolate, receivePort.sendPort);
}
```

Ayrıca 3. adımda `SendPort` ana izoleye bir mesaj gönderdiğinizi de hatırlayın. Bu yöntem, bu mesajın alınmasının yanı sıra gelecekteki mesajları (çözümlenmiş JSON olacak) da işler.

- Öncelikle, mesajın bir port olup olmadığını kontrol edin `SendPort`. Eğer öyleyse, daha sonra mesaj göndermek için kullanılabilmesi için bu portu sınıfın `_sendPort` özelliğine atayın.
- Ardından, mesajın `Map<String, dynamic>` beklenen çözümlenmiş JSON türü olan türünde olup olmadığını kontrol edin. Eğer öyleyse, bu mesajı uygulamanıza özgü mantıkla işleyin. Bu örnekte, mesaj yazdırılıyor.

```dart
void _handleResponsesFromIsolate(dynamic message) {
  if (message is SendPort) {
    _sendPort = message;
    _isolateReady.complete();
  } else if (message is Map<String, dynamic>) {
    print(message);
  }
}
```

##### Adım 5: İsolate Kurulduğundan Emin Olmak İçin Bir Tamamlayıcı Ekleyin.

Sınıfı tamamlamak için, `parseJson` çalışan izole sunucuya mesaj göndermekten sorumlu olan adlı bir public metot tanımlayın. Ayrıca, izole sunucu tamamen kurulmadan önce mesajların gönderilebilmesini de sağlaması gerekir. Bunu ele almak için bir kullanın `Completer`.

- Öncelikle, sınıf düzeyinde "a" adında bir özellik ekleyin `Completer` ve ona "a" adını verin `_isolateReady`.
- Ardından, mesaj bir `SendPort` ise, ( 4. adımda oluşturulan) `_handleResponsesFromIsolate` yöntemde tamamlayıcıya bir `complete()` çağrısı ekleyin .
- Son olarak, yöntemde `parseJson`, `_sendPort.send` eklemeden önce `await _isolateReady.future` ekleyin. Bu, işçi izole hücresi oluşturulup ana izole hücreye `SendPort` geri gönderilmeden önce hiçbir mesajın işçi izole hücresine gönderilememesini sağlar .

```dart
Future<void> parseJson(String message) async {
  await _isolateReady.future;
  _sendPort.send(message);
}
```

##### Tam Örnek

#### Sağlam Bağlantı Noktaları Örneği

Önceki örnek, çift yönlü iletişime sahip uzun ömürlü bir izole ortam kurmak için gereken temel yapı taşlarını açıklamıştı. Bahsedildiği gibi, bu örnekte hata yönetimi, artık kullanılmadığında portları kapatma yeteneği ve bazı durumlarda mesaj sıralamasındaki tutarsızlıklar gibi bazı önemli özellikler eksiktir.

Bu örnek, ilk örnekteki bilgileri genişleterek, bu ek özelliklere ve daha fazlasına sahip, daha iyi tasarım kalıplarını izleyen uzun ömürlü bir çalışan izole süreci oluşturur. Bu kod ilk örneğe benzerlik gösterse de, o örneğin bir uzantısı değildir.

> **Not:**
>
> Bu örnek, önceki örnekte `Isolate.spawn` ele alınan, izole cihazlar arasında ve portlar aracılığıyla iletişim kurma konusuna zaten aşina olduğunuzu varsaymaktadır .

##### Adım 1: Çalışan Sınıfını Tanımlayın

Öncelikle, arka plan çalışanı izole işleminiz için bir sınıf oluşturun. Bu sınıf, aşağıdaki işlevleri yerine getirmek için ihtiyacınız olan tüm fonksiyonları içerir:

- İzole bir varlık oluşturun.
- O izole cihaza mesaj gönder.
- İzole cihazın bazı JSON verilerini çözmesini sağlayın.
- Çözümlenmiş JSON dosyasını ana izole cihaza geri gönderin.

Bu sınıf üç genel yöntem sunar: biri çalışan izole sunucuyu oluşturur, diğeri bu çalışan izole sunucuya mesaj göndermeyi yönetir ve üçüncüsü de artık kullanılmadığında portları kapatabilir.

```dart
class Worker {
  final SendPort _commands;
  final ReceivePort _responses;
  Future<Object?> parseJson(String message) async {
    // TODO: Ensure the port is still open.
    _commands.send(message);
  }
  static Future<Worker> spawn() async {
    // TODO: Add functionality to create a new Worker object with a
    //  connection to a spawned isolate.
    throw UnimplementedError();
  }
  Worker._(this._responses, this._commands) {
    // TODO: Initialize main isolate receive port listener.
  }
  void _handleResponsesFromIsolate(dynamic message) {
    // TODO: Handle messages sent back from the worker isolate.
  }
  static void _handleCommandsToIsolate(ReceivePort rp, SendPort sp) async {
    // TODO: Handle messages sent back from the worker isolate.
  }
  static void _startRemoteIsolate(SendPort sp) {
    // TODO: Initialize worker isolate's ports.
  }
}
```

> **Not:**
>
> Bu örnekte, `SendPort` örnekler `ReceivePort` en iyi uygulama adlandırma kuralına uyarak ana izoleye göre adlandırılır. `SendPort` Ana izoleden çalışan izoleye gönderilen mesajlara komut , ana izoleye geri gönderilen mesajlara ise yanıt denir .

##### Adım 2: Yöntem `Worker.spawn` İçinde Bir `RawReceivePort` Oluşturun

`RawReceivePort` Bir izole ortam oluşturmadan önce, daha alt seviye bir yapı olan bir `<iostream>` oluşturmanız gerekir `ReceivePort`. `<iostream>` kullanmak `RawReceivePort` tercih edilen bir yöntemdir çünkü izole ortamın başlatma mantığını, izole ortamda mesaj iletimini yöneten mantıktan ayırmanıza olanak tanır.

Yöntemde `Worker.spawn`:

- Öncelikle, `RawReceivePort`. Bu, `ReceivePort` yalnızca çalışan izole sunucusundan gelen ilk mesajı almakla sorumludur; bu mesaj bir . olacaktır `SendPort`.
- Ardından, izole cihazın mesaj almaya hazır olduğunu gösteren bir `Completer` kaydı oluşturun . Bu işlem tamamlandığında, bir `ReceivePort` ve bir `SendPort` içeren bir kayıt döndürecektir .
- Ardından, özelliği tanımlayın `RawReceivePort.handler`. Bu özellik, `Function?` şu şekilde davranan bir özelliktir `ReceivePort.listener`: . Bu porttan bir mesaj alındığında fonksiyon çağrılır.
- İşleyici fonksiyonu içinde, `connection.complete()` yöntemini çağırın. Bu yöntem, argüman olarak bir `ReceivePort` ve bir `SendPort` içeren bir kayıt bekler. `SendPort`, bir sonraki adımda `_commands` adlı sınıf düzeyine atanacak olan, çalışan izole işleminden gönderilen ilk mesajdır .
- `ReceivePort` Ardından, yapıcıyı kullanarak yeni bir nesne oluşturun `ReceivePort.fromRawReceivePort` ve ona `initPort` değerini iletin.

```dart
class Worker {
  final SendPort _commands;
  final ReceivePort _responses;
  static Future<Worker> spawn() async {
    // Create a receive port and add its initial message handler.
    final initPort = RawReceivePort();
    final connection = Completer<(ReceivePort, SendPort)>.sync();
    initPort.handler = (initialMessage) {
      final commandPort = initialMessage as SendPort;
      connection.complete((
        ReceivePort.fromRawReceivePort(initPort),
        commandPort,
      ));
    };
  }
}
```

`RawReceivePort` Önce bir tane, sonra da bir tane oluşturarak `ReceivePort`, daha sonra yeni bir geri çağırma işlevi ekleyebileceksiniz `ReceivePort.listen`. Tersine, doğrudan bir tane oluşturursanız `ReceivePort`, yalnızca bir tane ekleyebilirsiniz `listener`, çünkü yerine `ReceivePort` arayüzünü uygular . `Stream` `BroadcastStream`

Esasen bu, izole başlatma mantığınızı, iletişim kurulumu tamamlandıktan sonra mesaj alma mantığını ayırmanıza olanak tanır. Diğer yöntemlerdeki mantık geliştikçe bu avantaj daha belirgin hale gelecektir.

##### Adım 3: Aşağıdaki Komutla Bir İşçi İzole Hücresi Oluşturun: `Isolate.spawn`

Bu adımda metodu doldurmaya devam edersiniz `Worker.spawn`. Bir izole ortam oluşturmak için gereken kodu ekleyecek ve `Worker` bu sınıftan bir örnek döndüreceksiniz. Bu örnekte, çağrısı bir `try` / `catch` bloğu `Isolate.spawn` içine alınmıştır ; bu, izole ortamın başlatılamaması durumunda `initPort` kapatılacağını ve `Worker` nesnenin oluşturulmayacağını garanti eder.

- Öncelikle, bir `try` / `catch` bloğunda bir işçi izole hücresi oluşturmayı deneyin. İşçi izole hücresi oluşturma başarısız olursa, önceki adımda oluşturulan alma portunu kapatın. iletilecek yöntem `Isolate.spawn` daha sonraki bir adımda ele alınacaktır.
- Ardından, yanıtı bekleyin `connection.future` ve döndürdüğü kayıttan gönderme portunu ve alma portunu ayrıştırın.
- Son olarak, `Worker` özel kurucusunu çağırarak ve bu tamamlayıcıdan gelen portları parametre olarak geçirerek bir örnek döndürün.

```dart
class Worker {
  final SendPort _commands;
  final ReceivePort _responses;
  static Future<Worker> spawn() async {
    // Create a receive port and add its initial message handler.
    final initPort = RawReceivePort();
    final connection = Completer<(ReceivePort, SendPort)>.sync();
    initPort.handler = (initialMessage) {
      final commandPort = initialMessage as SendPort;
      connection.complete((
        ReceivePort.fromRawReceivePort(initPort),
        commandPort,
      ));
    };
    // Spawn the isolate.
    try {
      await Isolate.spawn(_startRemoteIsolate, (initPort.sendPort));
    } on Object {
      initPort.close();
      rethrow;
    }
    final (ReceivePort receivePort, SendPort sendPort) =
        await connection.future;
    return Worker._(receivePort, sendPort);
  }
}
```

Bu örnekte ( önceki örneğe kıyasla ), `Worker.spawn` bu sınıf için eşzamansız statik bir kurucu görevi gördüğünü ve bir örneğini oluşturmanın tek yolu olduğunu unutmayın `Worker`. Bu, API'yi basitleştirerek bir örneğini oluşturan kodu `Worker` daha temiz hale getirir.

##### Adım 4: İsolate Kurulum İşlemini Tamamlayın

Bu adımda, temel izole kurulum sürecini tamamlayacaksınız. Bu, önceki örnekle neredeyse tamamen örtüşüyor ve yeni bir kavram yok. Kodun daha fazla metoda bölünmesiyle küçük bir değişiklik var; bu, bu örneğin geri kalanında daha fazla işlevsellik eklemenizi kolaylaştıran bir tasarım uygulamasıdır. İzole kurulumunun temel sürecinin ayrıntılı bir açıklaması için temel portlar örneğine bakın .

Öncelikle, `Worker.spawn` metottan döndürülen özel kurucu metodu oluşturun. Kurucu metodun gövdesinde, ana izole ortam tarafından kullanılan alma portuna bir dinleyici ekleyin ve bu dinleyiciye henüz tanımlanmamış bir metot iletin `_handleResponsesFromIsolate`.

```dart
class Worker {
  final SendPort _commands;
  final ReceivePort _responses;
  Worker._(this._responses, this._commands) {
    _responses.listen(_handleResponsesFromIsolate);
  }
}
```

`_startRemoteIsolate` Ardından, işçi izolesindeki portları başlatmaktan sorumlu kodu ekleyin. Bu yöntemin, `Isolate.spawn` yönteminde geçirildiğini ve `Worker.spawn` ana izolenin `SendPort` argümanı olarak kendisine iletileceğini hatırlayın.

1. Yeni bir tane oluşturun `ReceivePort`.
2. O portları `SendPort` ana izole cihaza geri gönderin.
3. Yeni bir metot çağırın `_handleCommandsToIsolate` ve hem yeni metodu `ReceivePort` hem de `SendPort` ana izole ortamdan gelen metodu argüman olarak geçirin.

```dart
static void _startRemoteIsolate(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  _handleCommandsToIsolate(receivePort, sendPort);
}
```

`_handleCommandsToIsolate` Ardından, ana izole sunucudan gelen mesajları almaktan, çalışan izole sunucuda JSON'u çözmekten ve çözülmüş JSON'u yanıt olarak geri göndermekten sorumlu olan yöntemi ekleyin .

1. Öncelikle, işçi izole cihazında bir dinleyici tanımlayın `ReceivePort`.
2. Dinleyiciye eklenen geri çağırma işlevi içinde, ana izole cihazdan gelen JSON verisini bir `try` / `catch` bloğu içinde çözmeye çalışın. Çözme işlemi başarılı olursa, çözülmüş JSON verisini ana izole cihaza geri gönderin.
3. Bir hata oluşursa, bir `RemoteError` ile geri dönün.

```dart
static void _handleCommandsToIsolate(
  ReceivePort receivePort,
  SendPort sendPort,
) {
  receivePort.listen((message) {
    try {
      final jsonData = jsonDecode(message as String);
      sendPort.send(jsonData);
    } catch (e) {
      sendPort.send(RemoteError(e.toString(), ''));
    }
  });
}
```

Ardından, metodun kodunu ekleyin `_handleResponsesFromIsolate`.

1. Öncelikle, mesajın bir hata mesajı olup olmadığını kontrol edin `RemoteError`; eğer öyleyse, `throw` o hatayı düzeltmelisiniz.
2. Aksi takdirde, mesajı yazdırın. İlerleyen adımlarda, bu kodu mesajları yazdırmak yerine döndürecek şekilde güncelleyeceksiniz.

```dart
void _handleResponsesFromIsolate(dynamic message) {
  if (message is RemoteError) {
    throw message;
  } else {
    print(message);
  }
}
```

`parseJson` Son olarak, dışarıdan gelen kodun JSON verilerini çözümlenmek üzere çalışan izole sunucuya göndermesine olanak tanıyan, herkese açık bir yöntem olan metodu ekleyin .

```dart
Future<Object?> parseJson(String message) async {
  _commands.send(message);
}
```

Bu yöntemi bir sonraki adımda güncelleyeceksiniz.

##### Adım 5: Aynı Anda Birden Fazla Mesajı İşleme

Şu anda, eğer çalışan izole sunucuya hızlı bir şekilde mesaj gönderirseniz, izole sunucu çözümlenmiş JSON yanıtını gönderilme sırasına göre değil, tamamlanma sırasına göre gönderir. Hangi yanıtın hangi mesaja karşılık geldiğini belirlemenin bir yolu yoktur.

Bu adımda, her mesaja bir kimlik (id) vererek ve dış kod `parseJson` çağırdığında çağırana döndürülen yanıtın doğru yanıt olmasını sağlamak için `Completer` nesneler kullanarak bu sorunu çözeceksiniz .

Öncelikle, sınıf düzeyinde iki özellik ekleyin `Worker`:

```dart
Map<int, Completer<Object?>> _activeRequests
int _idCounter
```

```dart
class Worker {
  final SendPort _commands;
  final ReceivePort _responses;
  final Map<int, Completer<Object?>> _activeRequests = {};
  int _idCounter = 0;
  // ···
}
```

Bu `_activeRequests` harita, çalışan izole cihazına gönderilen bir mesajı bir `Completer` ile ilişkilendirir. Kullanılan anahtarlar , daha fazla mesaj gönderildikçe artırılacak olan `_idCounter` dosyasından alınır.

`parseJson` Ardından, mesajları çalışan izoleye göndermeden önce tamamlayıcılar oluşturacak şekilde yöntemi güncelleyin .

1. `Completer` Öncelikle bir . oluşturun .
2. Ardından, her `Completer` birine benzersiz bir numara atanacak `_idCounter` şekilde artırın.
3. `_activeRequests` Haritaya, anahtarı mevcut sayı `_idCounter`, tamamlayıcısı ise değer olan bir giriş ekleyin .
4. Mesajı, kimlik numarasıyla birlikte izole çalışana gönderin. Sadece tek bir değer gönderebileceğiniz için `SendPort`, kimlik numarasını ve mesajı bir kayıt içine alın .
5. Son olarak, tamamlayıcının geleceğini döndürün; bu gelecek nihayetinde işçi izole edicisinden gelen yanıtı içerecektir.

```dart
Future<Object?> parseJson(String message) async {
  final completer = Completer<Object?>.sync();
  final id = _idCounter++;
  _activeRequests[id] = completer;
  _commands.send((id, message));
  return await completer.future;
}
```

`_handleResponsesFromIsolate` Ayrıca bu sistemi güncellemeniz ve `_handleCommandsToIsolate` yönetmeniz gerekiyor .

Burada `_handleCommandsToIsolate`, yalnızca JSON metni değil, iki değere sahip bir kayıt olduğunu hesaba katmanız gerekir `message`. Bunu, değerleri ayrıştırarak yapabilirsiniz `message`.

Ardından, JSON'u çözdükten sonra, `sendPort.send` hem kimliği hem de çözülmüş JSON'u bir kayıt kullanarak ana izoleye geri göndermek için çağrıyı güncelleyin.

```dart
static void _handleCommandsToIsolate(
  ReceivePort receivePort,
  SendPort sendPort,
) {
  receivePort.listen((message) {
    final (int id, String jsonText) = message as (int, String); // New
    try {
      final jsonData = jsonDecode(jsonText);
      sendPort.send((id, jsonData)); // Updated
    } catch (e) {
      sendPort.send((id, RemoteError(e.toString(), '')));
    }
  });
}
```

Son olarak, `_handleResponsesFromIsolate` dosyasını güncelleyin.

1. Öncelikle, mesaj argümanından gelen kimliği ve yanıtı tekrar ayrıştırın.
2. Ardından, bu isteğe karşılık gelen tamamlayıcıyı haritadan kaldırın `_activeRequests`.
3. `parseJson` Son olarak, hata fırlatmak veya çözümlenmiş JSON'u yazdırmak yerine, yanıtı ileterek tamamlayıcıyı tamamlayın. Bu işlem tamamlandığında, yanıt ana izole üzerinde çağrı yapan koda geri döndürülecektir .

```dart
void _handleResponsesFromIsolate(dynamic message) {
  final (int id, Object? response) = message as (int, Object?); // New
  final completer = _activeRequests.remove(id)!; // New
  if (response is RemoteError) {
    completer.completeError(response); // Updated
  } else {
    completer.complete(response); // Updated
  }
}
```

##### Adım 6: Bağlantı Noktalarını Kapatma İşlevini Ekleyin

Kodunuz artık izole ortamı kullanmadığında, ana izole ortam ve çalışan izole ortamdaki portları kapatmalısınız.

1. Öncelikle, portların kapalı olup olmadığını takip eden sınıf düzeyinde bir boolean değişkeni ekleyin.
2. Ardından `Worker.close` metodu ekleyin. Bu metodun içinde:
   - Güncelleme `_closed` doğru olacak.
   - Çalışan izole cihaza son bir mesaj gönderin. Bu mesaj `String` "kapatma" yazan bir nesne olacak, ancak istediğiniz herhangi bir nesne de olabilir. Bunu bir sonraki kod parçacığında kullanacaksınız.
   - Son olarak, `_activeRequests` boş olup olmadığını kontrol edin. Eğer boşsa, ana izolenin `ReceivePort` adlandırılmış olanını kapatın `_responses`.

```dart
class Worker {
  bool _closed = false;
  // ···
  void close() {
    if (!_closed) {
      _closed = true;
      _commands.send('shutdown');
      if (_activeRequests.isEmpty) _responses.close();
      print('--- port closed --- ');
    }
  }
}
```

Ardından, çalışan izole işleminde "kapatma" mesajını ele almanız gerekiyor. Metoda aşağıdaki kodu ekleyin `_handleCommandsToIsolate`. Bu kod, mesajın `String` "kapatma" olup olmadığını kontrol edecektir. Eğer öyleyse, çalışan izole işlemini kapatacak `ReceivePort` ve geri dönecektir.

```dart
static void _handleCommandsToIsolate(
  ReceivePort receivePort,
  SendPort sendPort,
) {
  receivePort.listen((message) {
    // New if-block.
    if (message == 'shutdown') {
      receivePort.close();
      return;
    }
    final (int id, String jsonText) = message as (int, String);
    try {
      final jsonData = jsonDecode(jsonText);
      sendPort.send((id, jsonData));
    } catch (e) {
      sendPort.send((id, RemoteError(e.toString(), '')));
    }
  });
}
```

Son olarak, mesaj göndermeden önce portların kapalı olup olmadığını kontrol edecek bir kod eklemelisiniz. Metodun içine tek bir satır ekleyin `Worker.parseJson`.

```dart
Future<Object?> parseJson(String message) async {
  if (_closed) throw StateError('Closed'); // New
  final completer = Completer<Object?>.sync();
  final id = _idCounter++;
  _activeRequests[id] = completer;
  _commands.send((id, message));
  return await completer.future;
}
```

---

# Null güvenliği (Null safety)

## Sağlam null güvenliği

*Dart'ta null güvenliğine giriş.* · Kaynak: <https://dart.dev/null-safety>

### Genel bakış

Dart dili sağlam null güvenliğini zorunlu kılar; bu da bir `null` değer üzerindeki bir üyeye istemeden erişmeyi imkânsız hale getirir.

Dart'ta türler varsayılan olarak null olamaz. Null olamayan türdeki değişkenlerin başlatılması gerekir ve bunlara yalnızca null olmayan değerler atanabilir.

Dart analizcisi ve derleyicileri, potansiyel olarak `null` olabilecek değerlerin güvensiz kullanımını düzenleme zamanında yakalar; böylece diğer dillerde çalışma zamanı hatası olacak durumlar, yayına almadan önce düzeltebileceğiniz analiz hatalarına dönüşür.

### Örnekler

Aşağıdaki koddaki değişkenlerin hiçbiri `null` olamaz:

```dart
// Bunların hiçbiri asla null olamaz.
var i = 42; // int olarak çıkarsanır.
String name = getFileName();
final b = Foo();
```

Bir değişkenin `null` değerine sahip olabileceğini belirtmek için, tür bildirimine `?` ekleyin:

```dart
int? aNullableInt = null;
```

**Kaynaklar:**

- Etkileşimli örnekler için [Dart cheatsheet](https://dart.dev/resources/dart-cheatsheet) sayfasını deneyin.
- Null güvenliği hakkında daha fazla bilgi edinmek için [Null güvenliğini anlamak](https://dart.dev/null-safety/understanding-null-safety) sayfasına göz atın.

### Null güvenliği ilkeleri

Dart'ta null güvenliği iki temel tasarım ilkesi üzerine kuruludur:

**Varsayılan olarak null olamaz**

Dart'a bir değişkenin null olabileceğini açıkça söylemediğiniz sürece, o değişken null olamaz kabul edilir. Bu varsayılan, araştırmalarda API'lerde null olmamanın açık farkla en yaygın tercih olduğu görüldükten sonra seçilmiştir.

**Tamamen sağlam**

Tür sistemi bir değişkenin veya ifadenin null olamayan bir türe sahip olduğunu belirlerse, çalışma zamanında asla `null` olarak değerlendirilmeyeceği garanti edilir.

Bu ilkeler birlikte daha az hata, daha küçük ikili dosyalar ve daha hızlı çalışma sağlar.

### Geçmiş geçiş kaynakları

Dart, Mayıs 2023'te yayımlanan Dart 3'ten beri sağlam null güvenliğini zorunlu kılmaktadır. Uygulamalarınızı veya paketlerinizi hâlâ null güvenliğine geçirmeniz gerekiyorsa, `dart-community/migrate-to-null-safety` deposundaki arşivlenmiş belgelere göz atın.

## Null güvenliğini anlamak

*Dart dilindeki ve kütüphanelerindeki null safety ile ilgili değişikliklere derinlemesine bir bakış.* · Kaynak: <https://dart.dev/null-safety/understanding-null-safety>

Null safety, Dart 2.0'da orijinal sağlam olmayan (unsound) opsiyonel tip sistemini sağlam (sound) bir statik tip sistemiyle değiştirdiğimizden beri Dart'ta yaptığımız en büyük değişiklik. Dart ilk çıktığında, derleme zamanında null safety nadir görülen ve uzun bir girişle anlatılması gereken bir özellikti. Bugün Kotlin, Swift, Rust ve diğer diller, artık çok tanıdık hale gelen bu soruna kendi cevaplarını sunuyor. İşte bir örnek:

```dart
// Without null safety:
bool isEmpty(String string) => string.length == 0;
```

```dart
void main() {
  isEmpty(null);
}
```

Bu Dart programını null safety olmadan çalıştırırsan, `.length` çağrısında `NoSuchMethodError` istisnası fırlatır. `null` değeri `Null` sınıfının bir örneğidir ve `Null` sınıfında "length" adlı bir getter yoktur. Çalışma zamanı hataları berbat bir şey. Bu, Dart gibi son kullanıcının cihazında çalışmak üzere tasarlanmış bir dilde özellikle geçerli. Bir sunucu uygulaması çökerse, çoğu zaman kimse fark etmeden yeniden başlatabilirsin. Ama bir Flutter uygulaması kullanıcının telefonunda çöktüğünde, kullanıcı memnun olmaz. Kullanıcıların memnun değilse, sen de memnun olmazsın.

Geliştiriciler Dart gibi statik tipli dilleri sever, çünkü tip denetleyicisi koddaki hataları derleme zamanında, çoğu zaman doğrudan IDE içinde bulabilir. Bir hatayı ne kadar erken bulursan, o kadar erken düzeltirsin. Dil tasarımcıları "null referans hatalarını düzeltmekten" bahsettiğinde, statik tip denetleyicisini zenginleştirmeyi kastederler; böylece dil, `null` olabilecek bir değer üzerinde `.length` çağırmaya çalışmak gibi hataları yakalayabilir.

Bu soruna tek bir doğru çözüm yok. Rust ve Kotlin'in her birinin kendi dilleri bağlamında anlamlı olan kendi yaklaşımı var. Bu doküman, Dart için bulduğumuz cevabın tüm ayrıntılarını anlatıyor. Statik tip sistemindeki değişiklikleri ve null-safe kod yazmanı, hatta umarım bundan keyif almanı sağlayacak bir dizi başka değişikliği ve yeni dil özelliğini içeriyor.

Bu doküman uzun. Çalışmaya başlamak için bilmen gerekenleri kapsayan daha kısa bir şey istiyorsan, genel bakış (overview) ile başla. Daha derin bir anlayışa hazır olduğunda ve vaktin olduğunda buraya dön; böylece dilin `null` ile nasıl başa çıktığını, neden bu şekilde tasarladığımızı ve idiomatik, modern, null-safe Dart'ın nasıl yazılacağını anlayabilirsin. (Spoiler: sonuç, bugün Dart yazma şeklinle şaşırtıcı derecede benzer.)

Bir dilin null referans hatalarını ele almasının çeşitli yollarının her birinin artıları ve eksileri var. Aldığımız kararlara şu ilkeler yön verdi:

Kod varsayılan olarak güvenli olmalı. Yeni Dart kodu yazarsan ve açıkça güvensiz hiçbir özellik kullanmazsan, çalışma zamanında asla null referans hatası fırlatmaz. Olası tüm null referans hataları statik olarak yakalanır. Daha fazla esneklik için bu denetimin bir kısmını çalışma zamanına bırakmak istersen bunu yapabilirsin, ama bunu kodda metin olarak görünen bir özellik kullanarak bilinçli şekilde seçmen gerekir.

Başka bir deyişle, sana bir can yeleği verip suya her çıktığında onu giymeyi hatırlamayı sana bırakmıyoruz. Bunun yerine sana batmayan bir tekne veriyoruz. Tekneden kendin atlamadıkça kuru kalırsın.

Null-safe kod yazması kolay olmalı. Mevcut Dart kodunun çoğu dinamik olarak doğrudur ve null referans hatası fırlatmaz. Dart programının şu anki görünümünü seviyorsun ve biz de kodu bu şekilde yazmaya devam edebilmeni istiyoruz. Güvenlik; kullanım kolaylığından fedakârlık etmeyi, tip denetleyicisine kefaret ödemeyi ya da düşünme şeklini ciddi biçimde değiştirmeyi gerektirmemeli.

Ortaya çıkan null-safe kod tamamen sağlam (sound) olmalı. Statik denetim bağlamında "soundness" farklı insanlar için farklı anlamlara gelir. Bizim için, null safety bağlamında bunun anlamı şu: bir ifadenin `null` değerine izin vermeyen bir statik tipi varsa, o ifadenin hiçbir olası çalışması asla `null` olarak değerlendirilemez. Dil bu garantiyi çoğunlukla statik denetimlerle sağlar, ama işin içinde bazı çalışma zamanı denetimleri de olabilir. (Ancak ilk ilkeyi unutma: bu çalışma zamanı denetimlerinin yapıldığı her yer senin seçimin olacak.)

Soundness kullanıcı güveni için önemlidir. Çoğunlukla yüzeyde kalan bir tekneyle açık denizlere çıkmak seni heyecanlandırmaz. Ama cesur derleyici hacker'larımız için de önemlidir. Dil bir programın anlamsal özellikleri hakkında kesin garantiler verdiğinde, derleyici bu özelliklerin doğru olduğunu varsayan optimizasyonlar yapabilir. `null` söz konusu olduğunda bu, gereksiz `null` denetimlerini ortadan kaldıran daha küçük kod ve üzerinde metot çağırmadan önce alıcının `null` olmadığını doğrulamasına gerek olmayan daha hızlı kod üretebileceğimiz anlamına gelir.

Bir uyarı: Soundness garantisini yalnızca tamamen null safe olan Dart programlarında veriyoruz. Dart, daha yeni null-safe kod ile eski (legacy) kodun karışımını içeren programları destekler. Bu karma sürümlü programlarda null referans hataları yine de oluşabilir. Karma sürümlü bir programda null safe olan kısımlarda statik güvenliğin tüm faydalarını elde edersin, ama uygulamanın tamamı null safe olana kadar tam çalışma zamanı soundness'ına sahip olmazsın.

`null`'ı ortadan kaldırmanın bir hedef olmadığını unutma. `null`'da yanlış bir şey yok. Aksine, bir değerin yokluğunu temsil edebilmek gerçekten çok faydalı. Dilin içine özel bir "yok" değeri desteğini doğrudan yerleştirmek, yokluğla çalışmayı esnek ve kullanışlı kılar. Bu; opsiyonel parametrelerin, kullanışlı `?.` null-aware operatörünün ve varsayılan başlatmanın temelini oluşturur. Kötü olan `null` değil, `null`'ın beklemediğin yerlere gitmesidir.

Dolayısıyla null safety ile hedefimiz, sana `null`'ın programında nereden akabileceği konusunda kontrol ve içgörü vermek ve bir çökmeye yol açacak bir yere akamayacağından emin olmanı sağlamak.

### Tip sisteminde nullability

Null safety statik tip sisteminde başlar, çünkü geri kalan her şey buna dayanır. Dart programında koca bir tip evreni var: `int` ve `String` gibi ilkel tipler, `List` gibi koleksiyon tipleri ve senin ve kullandığın paketlerin tanımladığı tüm sınıflar ve tipler. Null safety'den önce, statik tip sistemi `null` değerinin bu tiplerin herhangi birindeki ifadelere akmasına izin veriyordu.

Tip teorisi jargonuyla, `Null` tipi tüm tiplerin bir alt tipi (subtype) olarak ele alınıyordu:

![Null güvenliği öncesi tip hiyerarşisi: Null, tüm tiplerin alt tipi.](https://dart.dev/assets/img/null-safety/understanding-null-safety/hierarchy-before.png)

Bir ifade üzerinde izin verilen işlemler kümesi (getter'lar, setter'lar, metotlar ve operatörler) o ifadenin tipi tarafından tanımlanır. Tip `List` ise üzerinde `.add()` veya `[]` çağırabilirsin. `int` ise `+` kullanabilirsin. Ama `null` değeri bu metotların hiçbirini tanımlamaz. `null`'ın başka bir tipteki ifadeye akmasına izin vermek, bu işlemlerin herhangi birinin başarısız olabileceği anlamına gelir. Null referans hatalarının özü gerçekten de budur: her hata, `null` üzerinde onda olmayan bir metodu veya özelliği aramaya çalışmaktan kaynaklanır.

#### Non-nullable ve nullable tipler

Null safety, tip hiyerarşisini değiştirerek bu sorunu kökünden ortadan kaldırır. `Null` tipi hâlâ var, ama artık tüm tiplerin alt tipi değil. Bunun yerine tip hiyerarşisi şöyle görünüyor:

![Null güvenliği sonrası tip hiyerarşisi: Null, diğer tiplerden ayrılmış.](https://dart.dev/assets/img/null-safety/understanding-null-safety/hierarchy-after.png)

`Null` artık bir alt tip olmadığından, özel `Null` sınıfı dışında hiçbir tip `null` değerine izin vermez. Tüm tipleri varsayılan olarak non-nullable yaptık. `String` tipinde bir değişkenin varsa, her zaman bir string içerir. İşte, tüm null referans hatalarını düzelttik.

`null`'ın hiç faydalı olmadığını düşünseydik burada durabilirdik. Ama `null` faydalı, bu yüzden onu ele almanın yine de bir yoluna ihtiyacımız var. Opsiyonel parametreler iyi bir açıklayıcı örnek. Şu null-safe Dart koduna bak:

```dart
// Using null safety:
void makeCoffee(String coffee, [String? dairy]) {
  if (dairy != null) {
    print('$coffee with $dairy');
  } else {
    print('Black $coffee');
  }
}
```

Burada `dairy` parametresinin herhangi bir string'i ya da `null` değerini, başka hiçbir şeyi kabul etmesini istiyoruz. Bunu ifade etmek için, temel tip `String`'in sonuna `?` ekleyerek `dairy`'ye nullable bir tip veriyoruz. Arka planda bu, esasen temel tip ile `Null` tipinin bir birleşimini (union) tanımlamak demek. Yani Dart'ta tam özellikli union tipler olsaydı, `String?` aslında `String|Null` için bir kısaltma olurdu.

#### Nullable tipleri kullanmak

Nullable tipte bir ifaden varsa, sonucuyla ne yapabilirsin? İlkemiz varsayılan olarak güvenli olmak olduğundan, cevap pek bir şey. Temel tipin metotlarını çağırmana izin veremeyiz, çünkü değer `null` ise bunlar başarısız olabilir:

```dart
// Hypothetical unsound null safety:
void bad(String? maybeString) {
  print(maybeString.length);
}
```

```dart
void main() {
  bad(null);
}
```

Bunu çalıştırmana izin verseydik çökerdi. Güvenle erişmene izin verebileceğimiz tek metotlar ve özellikler, hem temel tip hem de `Null` sınıfı tarafından tanımlananlar. Bunlar sadece `toString()`, `==` ve `hashCode`. Yani nullable tipleri map anahtarı olarak kullanabilir, set'lerde saklayabilir, başka değerlerle karşılaştırabilir ve string interpolasyonunda kullanabilirsin, ama o kadar.

Peki non-nullable tiplerle nasıl etkileşirler? Nullable tip bekleyen bir şeye non-nullable tip geçirmek her zaman güvenlidir. Bir fonksiyon `String?` kabul ediyorsa ona `String` geçirmek serbesttir, çünkü hiçbir soruna yol açmaz. Bunu, her nullable tipi temel tipinin bir üst tipi (supertype) yaparak modelliyoruz. Nullable tip bekleyen bir şeye güvenle `null` da geçirebilirsin, dolayısıyla `Null` da her nullable tipin bir alt tipidir:

![Nullable tipin, temel tip ile Null'un birleşimi olduğunu gösteren hiyerarşi.](https://dart.dev/assets/img/null-safety/understanding-null-safety/nullable-hierarchy.png)

Ama diğer yöne gidip, temel non-nullable tipi bekleyen bir şeye nullable bir tip geçirmek güvensizdir. `String` bekleyen kod, değer üzerinde `String` metotlarını çağırabilir. Ona bir `String?` geçirirsen, `null` içeri akabilir ve bu başarısız olabilir:

```dart
// Hypothetical unsound null safety:
void requireStringNotNull(String definitelyString) {
  print(definitelyString.length);
}
```

```dart
void main() {
  String? maybeString = null; // Or not!
  requireStringNotNull(maybeString);
}
```

Bu program güvenli değil ve buna izin vermemeliyiz. Ancak Dart'ta her zaman *implicit downcast* (örtük aşağı tip dönüşümü) denen bir şey oldu. Örneğin `String` bekleyen bir fonksiyona `Object` tipinde bir değer geçirirsen, tip denetleyicisi buna izin verir:

```dart
// Without null safety:
void requireStringNotObject(String definitelyString) {
  print(definitelyString.length);
}
```

```dart
void main() {
  Object maybeString = 'it is';
  requireStringNotObject(maybeString);
}
```

Soundness'ı korumak için derleyici, `requireStringNotObject()` fonksiyonuna verilen argümana sessizce bir `as String` cast'i ekler. Bu cast çalışma zamanında başarısız olup istisna fırlatabilir, ama derleme zamanında Dart bunun sorun olmadığını söyler. Non-nullable tipler nullable tiplerin alt tipleri olarak modellendiğinden, implicit downcast'ler `String` bekleyen bir şeye `String?` geçirmene izin verirdi. Buna izin vermek, varsayılan olarak güvenli olma hedefimizi ihlal ederdi. Bu yüzden null safety ile implicit downcast'leri tamamen kaldırıyoruz.

Bu, `requireStringNotNull()` çağrısının derleme hatası vermesini sağlıyor, ki istediğin de bu. Ama aynı zamanda tüm implicit downcast'lerin derleme hatası olacağı anlamına geliyor; `requireStringNotObject()` çağrısı da dahil. Açık (explicit) downcast'i kendin eklemen gerekecek:

```dart
// Using null safety:
void requireStringNotObject(String definitelyString) {
  print(definitelyString.length);
}
```

```dart
void main() {
  Object maybeString = 'it is';
  requireStringNotObject(maybeString as String);
}
```

Bunun genel olarak iyi bir değişiklik olduğunu düşünüyoruz. İzlenimimiz, çoğu kullanıcının implicit downcast'leri hiç sevmediği yönünde. Özellikle daha önce şuna yanmış olabilirsin:

```dart
// Without null safety:
List<int> filterEvens(List<int> ints) {
  return ints.where((n) => n.isEven);
}
```

Hatayı gördün mü? `.where()` metodu tembeldir (lazy), bu yüzden `List` değil `Iterable` döndürür. Bu program derlenir, ama sonra `Iterable`'ı `filterEvens()` fonksiyonunun döndüreceğini bildirdiği `List` tipine cast etmeye çalışırken çalışma zamanında istisna fırlatır. Implicit downcast'lerin kaldırılmasıyla bu bir derleme hatası olur.

Nerede kalmıştık? Evet, tamam, yani programındaki tip evrenini alıp iki yarıya böldük gibi:

![Tip hiyerarşisinin nullable ve non-nullable tipler olarak ikiye ayrılması.](https://dart.dev/assets/img/null-safety/understanding-null-safety/bifurcate.png)

Non-nullable tiplerden oluşan bir bölge var. Bu tipler tüm ilginç metotlara erişmene izin verir, ama asla `null` içeremez. Sonra bunların karşılığı olan tüm nullable tiplerden oluşan paralel bir aile var. Bunlar `null`'a izin verir, ama onlarla pek bir şey yapamazsın. Değerlerin non-nullable taraftan nullable tarafa akmasına izin veriyoruz çünkü bunu yapmak güvenli, ama diğer yöne değil.

Bu, nullable tiplerin temelde işe yaramaz olduğu izlenimini veriyor. Hiçbir metotları yok ve onlardan kurtulamıyorsun. Merak etme, değerleri nullable yarıdan diğer tarafa taşımana yardım edecek bir dizi özelliğimiz var; yakında onlara geleceğiz.

#### Üst ve alt tipler (top ve bottom)

Bu bölüm biraz egzotik. Tip sistemi işlerine meraklı değilsen, en sondaki iki madde dışında büyük ölçüde atlayabilirsin. Programındaki tüm tipleri, birbirinin alt tipi ve üst tipi olanlar arasında kenarlar olacak şekilde hayal et. Bunu, bu dokümandaki diyagramlar gibi çizersen, `Object` gibi üst tiplerin tepeye, kendi tiplerin gibi yaprak sınıfların dibe yakın olduğu kocaman bir yönlü graf oluşur.

Bu yönlü graf tepede, (doğrudan ya da dolaylı olarak) tüm tiplerin üst tipi olan tek bir tipte birleşiyorsa, bu tipe *top type* (üst tip) denir. Aynı şekilde, dipte her tipin alt tipi olan tuhaf bir tip varsa, bir *bottom type*'ın (alt tip) vardır. (Bu durumda yönlü grafın bir lattice'tir.)

Tip sisteminin bir top ve bottom tipinin olması kullanışlıdır, çünkü *least upper bound* (en küçük üst sınır) gibi tip düzeyindeki işlemlerin (tip çıkarımı bunu, iki dalının tiplerine göre koşullu bir ifadenin tipini bulmak için kullanır) her zaman bir tip üretebilmesi anlamına gelir. Null safety'den önce `Object` Dart'ın top tipi, `Null` ise bottom tipiydi.

`Object` artık non-nullable olduğundan top tip değil. `Null` onun alt tipi değil. Dart'ta adı konmuş bir top tip yok. Bir top tipe ihtiyacın varsa, istediğin `Object?`. Aynı şekilde `Null` da artık bottom tip değil. Öyle olsaydı her şey hâlâ nullable olurdu. Bunun yerine `Never` adında yeni bir bottom tip ekledik:

![Null güvenliğinde tip hiyerarşisinin en üst (Object?) ve en alt (Never) tipleri.](https://dart.dev/assets/img/null-safety/understanding-null-safety/top-and-bottom.png)

Pratikte bu şu anlama geliyor:

- Herhangi bir tipte bir değere izin verdiğini belirtmek istiyorsan `Object` yerine `Object?` kullan. Aslında `Object` kullanmak oldukça nadir hale gelir, çünkü bu tip "bu tuhaf şekilde yasaklanmış `null` değeri dışında herhangi bir olası değer olabilir" anlamına gelir.
- Bir bottom tipe ihtiyaç duyduğun nadir durumlarda `Null` yerine `Never` kullan. Bu, özellikle bir fonksiyonun asla geri dönmediğini belirtip erişilebilirlik (reachability) analizine yardımcı olmak için kullanışlıdır. Bir bottom tipe ihtiyacın olup olmadığını bilmiyorsan, muhtemelen ihtiyacın yoktur.

### Doğruluğu sağlamak

Tip evrenini nullable ve non-nullable yarılara böldük. Soundness'ı ve çalışma zamanında sen istemedikçe asla null referans hatası alamayacağın ilkemizi korumak için, `null`'ın non-nullable taraftaki hiçbir tipte asla görünmemesini garanti etmemiz gerekiyor.

Implicit downcast'lerden kurtulmak ve `Null`'ı bottom tip olmaktan çıkarmak, tiplerin bir program içinde atamalar boyunca ve argümanlardan fonksiyon çağrılarındaki parametrelere akışının ana yerlerinin hepsini kapsıyor. `null`'ın içeri sızabileceği geriye kalan ana yerler, bir değişkenin ilk var olduğu an ve bir fonksiyondan çıktığın an. Bu yüzden bazı ek derleme hataları var:

#### Geçersiz return'ler

Bir fonksiyonun non-nullable bir dönüş tipi varsa, fonksiyon içindeki her yol, bir değer döndüren bir `return` ifadesine ulaşmalıdır. Null safety'den önce Dart eksik return'ler konusunda oldukça gevşekti. Örneğin:

```dart
// Without null safety:
String missingReturn() {
  // No return.
}
```

Bunu analiz edersen, belki bir return'ü unuttuğuna dair nazik bir ipucu alırdın, ama almasan da büyük bir sorun değildi. Çünkü çalışma bir fonksiyon gövdesinin sonuna ulaşırsa Dart örtük olarak `null` döndürür. Her tip nullable olduğundan, bu fonksiyon teknik olarak güvenlidir, muhtemelen istediğin şey olmasa da.

Sound non-nullable tiplerle bu program tamamen yanlış ve güvensizdir. Null safety altında, non-nullable dönüş tipine sahip bir fonksiyon güvenilir şekilde bir değer döndürmüyorsa derleme hatası alırsın. "Güvenilir şekilde" derken, dilin fonksiyon içindeki tüm kontrol akış yollarını analiz ettiğini kastediyorum. Hepsi bir şey döndürdüğü sürece memnun olur. Analiz oldukça akıllı, bu yüzden şu fonksiyon bile sorun değil:

```dart
// Using null safety:
String alwaysReturns(int n) {
  if (n == 0) {
    return 'zero';
  } else if (n < 0) {
    throw ArgumentError('Negative values not allowed.');
  } else {
    if (n > 1000) {
      return 'big';
    } else {
      return n.toString();
    }
  }
}
```

Yeni akış analizine (flow analysis) bir sonraki bölümde daha derinlemesine gireceğiz.

#### Başlatılmamış değişkenler

Bir değişken tanımladığında, ona açık bir başlatıcı (initializer) vermezsen Dart değişkeni varsayılan olarak `null` ile başlatır. Bu kullanışlı, ama değişkenin tipi non-nullable ise tamamen güvensiz. Bu yüzden non-nullable değişkenler için işleri sıkılaştırmamız gerekiyor:

Üst düzey (top level) değişken ve static alan tanımlarının bir başlatıcısı olmalıdır. Bunlara programın herhangi bir yerinden erişilip atama yapılabildiğinden, derleyicinin değişkene kullanılmadan önce bir değer verildiğini garanti etmesi imkânsızdır. Tek güvenli seçenek, tanımın kendisinin doğru tipte bir değer üreten bir başlatıcı ifadeye sahip olmasını zorunlu kılmaktır:

```dart
// Using null safety:
int topLevel = 0;
```

```dart
class SomeClass {
  static int staticField = 0;
}
```

Örnek (instance) alanlarının ya tanımda bir başlatıcısı olmalı, ya bir initializing formal kullanmalı, ya da yapıcının (constructor) başlatma listesinde başlatılmalıdır. Bu çok jargon oldu. İşte örnekler:

```dart
// Using null safety:
class SomeClass {
  int atDeclaration = 0;
  int initializingFormal;
  int initializationList;
```

```dart
  SomeClass(this.initializingFormal)
      : initializationList = 0;
}
```

Başka bir deyişle, alan yapıcı gövdesine ulaşmadan önce bir değere sahip olduğu sürece sorun yok.

Yerel değişkenler en esnek durumdur. Non-nullable bir yerel değişkenin başlatıcısı olması gerekmez. Bu gayet sorunsuz:

```dart
// Using null safety:
int tracingFibonacci(int n) {
  int result;
  if (n < 2) {
    result = n;
  } else {
    result = tracingFibonacci(n - 2) + tracingFibonacci(n - 1);
  }
```

```dart
  print(result);
  return result;
}
```

Kural sadece, bir yerel değişkenin kullanılmadan önce *kesin olarak atanmış* (definitely assigned) olması gerektiği. Bunun için de değindiğim yeni akış analizine güveniyoruz. Bir değişkenin kullanımına giden her yol önce onu başlattığı sürece, kullanım sorunsuzdur.

Opsiyonel parametrelerin varsayılan bir değeri olmalıdır. Opsiyonel bir konumsal ya da isimli parametre için argüman geçirmezsen, dil onu varsayılan değerle doldurur. Varsayılan bir değer belirtmezsen, *varsayılanın varsayılanı* `null`'dır ve bu, parametrenin tipi non-nullable ise kabul edilmez.

Yani bir parametrenin opsiyonel olmasını istiyorsan, ya onu nullable yapmalı ya da geçerli, `null` olmayan bir varsayılan değer belirtmelisin.

Bu kısıtlamalar bunaltıcı gelebilir, ama pratikte o kadar kötü değiller. `final` değişkenlerle ilgili mevcut kısıtlamalara çok benziyorlar ve muhtemelen yıllardır bunlarla, fark etmeden bile çalışıyorsun. Ayrıca bunların yalnızca *non-nullable* değişkenler için geçerli olduğunu unutma. Tipi her zaman nullable yapıp varsayılan olarak `null` ile başlatılmasını sağlayabilirsin.

Yine de bu kurallar sürtünmeye yol açıyor. Neyse ki, bu yeni sınırlamaların seni yavaşlattığı en yaygın kalıpları yağlayacak bir dizi yeni dil özelliğimiz var. Ama önce, akış analizinden (flow analysis) bahsetmenin zamanı geldi.

### Flow analizi

Kontrol akışı analizi, derleyicilerde yıllardır mevcut. Çoğunlukla kullanıcılardan gizlidir ve derleyici optimizasyonu sırasında kullanılır, ancak bazı yeni diller aynı teknikleri görünür dil özellikleri için kullanmaya başladı. Dart'ta zaten tür yükseltmesi (type promotion) şeklinde bir miktar akış analizi bulunmaktadır:

```dart
// With (or without) null safety:
bool isEmptyList(Object object) {
  if (object is List) {
    return object.isEmpty; // <-- OK!
  } else {
    return false;
  }
}
```

İşaretli satırda `object` üzerinde `isEmpty` çağırabildiğimize dikkat edin. Bu metot `Object` üzerinde değil, `List` üzerinde tanımlanmıştır. Bunun nedeni, tür denetleyicisinin programdaki tüm `is` ifadelerini ve kontrol akışı yollarını incelemesidir. Bir kontrol akışı yapısının gövdesi yalnızca bir değişken üzerindeki belirli bir `is` ifadesi doğru olduğunda yürütülüyorsa, o gövde içinde değişkenin türü test edilen türe "yükseltilir".

Buradaki örnekte, `if` ifadesinin `then` dalı yalnızca `object` gerçekten bir liste içerdiğinde çalışır. Bu nedenle Dart, `object`'i bildirilen `Object` türü yerine `List` türüne yükseltir. Bu kullanışlı bir özelliktir, ancak oldukça sınırlıdır. Null güvenliğinden önce, işlevsel olarak aynı olan aşağıdaki program çalışmazdı:

```dart
// Without null safety:
bool isEmptyList(Object object) {
  if (object is! List) return false;
  return object.isEmpty; // <-- Error!
}
```

Yine, `.isEmpty` çağrısına yalnızca `object` bir liste içerdiğinde ulaşabilirsiniz, bu nedenle bu program dinamik olarak doğrudur. Ancak tür yükseltme kuralları, `return` ifadesinden sonraki ifadeye yalnızca `object` bir liste olduğunda ulaşılabileceğini anlayacak kadar akıllı değildi.

Null güvenliği için, bu sınırlı analizi alıp çeşitli şekillerde çok daha güçlü hale getirdik.

#### Reachability analizi

Öncelikle, tür yükseltmesinin erken dönüşler ve diğer erişilemeyen kod yolları konusunda akıllı davranmadığına dair uzun süredir devam eden şikayetleri giderdik. Bir fonksiyonu analiz ederken, artık `return`, `break`, `throw` ve bir fonksiyonda yürütmenin erken sonlanabileceği diğer tüm yolları dikkate alıyor. Null güvenliği altında, bu fonksiyon:

```dart
// Using null safety:
bool isEmptyList(Object object) {
  if (object is! List) return false;
  return object.isEmpty;
}
```

Artık tamamen geçerli. `if` ifadesi, `object` bir `List` olmadığında fonksiyondan çıkacağı için, Dart ikinci ifadede `object`'i `List`'e yükseltiyor. Bu, null değerlerle ilgisi olmayan şeyler de dahil olmak üzere birçok Dart koduna yardımcı olan gerçekten güzel bir iyileştirme.

#### Unreachable kod için Never

Bu erişilebilirlik analizini siz de programlayabilirsiniz. Yeni alt tür `Never`'ın hiçbir değeri yoktur. (Aynı anda `String`, `bool` ve `int` olan bir değer ne tür bir değerdir?) Peki bir ifadenin `Never` türüne sahip olması ne anlama gelir? Bu, ifadenin hiçbir zaman başarıyla değerlendirilmesini tamamlayamayacağı anlamına gelir. Bir istisna fırlatmalı, işlemi durdurmalı veya ifadenin sonucunu bekleyen çevreleyen kodun asla çalışmamasını sağlamalıdır.

Aslında dile göre bir `throw` ifadesinin statik türü `Never`'dır. Bu tür temel kütüphanelerde tanımlanır ve bir tür açıklaması olarak kullanabilirsiniz. Belki belirli bir tür istisnayı fırlatmayı kolaylaştırmak için bir yardımcı fonksiyonunuz vardır:

```dart
// Using null safety:
Never wrongType(String type, Object value) {
  throw ArgumentError('Expected $type, but was ${value.runtimeType}.');
}
```

Şöyle kullanabilirsiniz:

```dart
// Using null safety:
class Point {
  final int x, y;

  Point(this.x, this.y);

  Point operator +(Object other) {
    if (other is int) return Point(x + other, y + other);
    if (other is! Point) wrongType('int | Point', other);

    print('Adding two Point instances together: $this + $other');
    return Point(x + other.x, y + other.y);
  }

  // toString, hashCode, and other implementations...
}
```

Bu program hatasız analiz ediliyor. Metodun son satırının `other.x` ve `other.y`'ye eriştiğine dikkat edin. Fonksiyonun herhangi bir `return` veya `throw` ifadesi olmamasına rağmen, `other` `Point`'e yükseltildi. Kontrol akışı analizi, `wrongType()`'ın bildirilen dönüş türünün `Never` olduğunu biliyor; bu da `if` ifadesinin `then` dalının bir şekilde sonlandırılması gerektiği anlamına geliyor. Son ifadeye yalnızca `other` bir `Point` olduğunda ulaşılabildiğinden, Dart onu yükseltiyor.

Başka bir deyişle, `Never`'ı kendi API'lerinizde kullanmak, Dart'ın erişilebilirlik analizini genişletmenizi sağlar.

#### Definite assignment analizi

Yerel değişkenlerle ilgili olarak bundan kısaca bahsetmiştim. Dart, null değer alamayan yerel bir değişkenin okunmadan önce her zaman başlatılmasını sağlamalıdır. Bunu olabildiğince esnek bir şekilde yapabilmek için *kesin atama analizini* (definite assignment analysis) kullanıyoruz. Dil, her fonksiyon gövdesini analiz eder ve tüm kontrol akışı yolları boyunca yerel değişkenlere ve parametrelere yapılan atamaları izler. Değişken, kullanıldığı her yolda atandığı sürece başlatılmış kabul edilir. Bu, değişkeni başlatıcı olmadan bildirmenize ve daha sonra karmaşık kontrol akışı kullanarak başlatmanıza olanak tanır, hatta değişken null değer alamayan bir türe sahip olsa bile.

Ayrıca `final` değişkenleri daha esnek hale getirmek için de kesin atama analizini kullanıyoruz. Null güvenliği öncesinde, `final` yerel değişkenleri ilginç bir şekilde başlatmanız gerekiyorsa bunu yapmak zor olabilirdi:

```dart
// Using null safety:
int tracingFibonacci(int n) {
  final int result;
  if (n < 2) {
    result = n;
  } else {
    result = tracingFibonacci(n - 2) + tracingFibonacci(n - 1);
  }

  print(result);
  return result;
}
```

Bu bir hata olurdu çünkü `result` değişkeni `final` ancak başlatıcısı yok. Null güvenliği altındaki daha akıllı akış analiziyle bu program sorunsuz çalışır. Analiz, `result` değişkeninin her kontrol akışı yolunda kesinlikle bir kez başlatıldığını söyleyebilir, bu nedenle bir değişkeni `final` olarak işaretlemek için gereken kısıtlamalar karşılanmıştır.

#### Null check'lerde type promotion

Daha akıllı akış analizi, null değerlerle ilgisi olmayan kodlar da dahil olmak üzere birçok Dart koduna yardımcı oluyor. Ancak bu değişiklikleri şimdi yapmamız tesadüf değil. Türleri null değer alabilen ve alamayan kümeler olarak ayırdık. Null değer alabilen bir türün değerine sahipseniz, onunla gerçekten faydalı bir şey yapamazsınız. Değerin `null` olduğu durumlarda bu kısıtlama iyidir. Çökmenizi önler.

Ancak değer `null` değilse, üzerinde metotlar çağırabilmek için onu null değer alamayan tarafa taşımak iyi olurdu. Akış analizi, yerel değişkenler ve parametreler (ve Dart 3.2'den itibaren özel final alanlar) için bunu yapmanın başlıca yollarından biridir. Tür yükseltmesini, `== null` ve `!= null` ifadelerini de inceleyecek şekilde genişlettik.

Yerel bir değişkenin `null` olup olmadığını kontrol ederseniz, Dart bu değişkeni temelindeki null değer alamayan türe yükseltir:

```dart
// Using null safety:
String makeCommand(String executable, [List<String>? arguments]) {
  var result = executable;
  if (arguments != null) {
    result += ' ' + arguments.join(' ');
  }
  return result;
}
```

Burada `arguments` null değer alabilen bir türe sahip. Normalde bu, üzerinde `.join()` metodunu çağırmanızı engeller. Ancak değerin `null` olmadığından emin olmak için kontrol eden bir `if` ifadesiyle bu çağrıyı koruduğumuz için, Dart onu `List<String>?` türünden `List<String>` türüne yükseltir ve üzerinde metot çağırmanıza veya null değer alamayan listeler bekleyen fonksiyonlara geçirmenize olanak tanır.

Bu oldukça önemsiz bir şey gibi görünebilir, ancak null kontrollerine dayalı bu akış tabanlı yaklaşım, mevcut Dart kodlarının çoğunun null güvenliği altında çalışmasını sağlar. Çoğu Dart kodu dinamik olarak doğrudur ve metotları çağırmadan önce `null` kontrolü yaparak null referans hatalarını önler. Null kontrolleri için yeni akış analizi, bu dinamik doğruluğu kanıtlanabilir statik doğruluğa dönüştürür.

Elbette, erişilebilirlik için yaptığımız daha akıllı analizlerle de uyumlu çalışıyor. Yukarıdaki fonksiyon şu şekilde de yazılabilir:

```dart
// Using null safety:
String makeCommand(String executable, [List<String>? arguments]) {
  var result = executable;
  if (arguments == null) return result;
  return result + ' ' + arguments.join(' ');
}
```

Dil, hangi tür ifadelerin tür yükseltmesine neden olacağı konusunda da daha akıllıca davranıyor. Açık bir `== null` veya `!= null` ifadesi elbette işe yarıyor. Ancak `as` ile yapılan açık tür dönüştürmeleri, atamalar veya sonek `!` operatörü (ki bunu daha sonra ele alacağız) de tür yükseltmesine neden oluyor. Genel amaç, kod dinamik olarak doğruysa ve bunu statik olarak anlamak mantıklıysa, analizin bunu yapacak kadar akıllı olmasıdır.

Unutmayın ki, tür yükseltme özelliği başlangıçta yalnızca yerel değişkenlerde çalışıyordu ve Dart 3.2'den itibaren özel final alanlarında da çalışmaktadır. Yerel olmayan değişkenlerle çalışma hakkında daha fazla bilgi için, "Working with nullable fields" bölümüne bakın.

#### Gereksiz kod uyarıları

Daha akıllı erişilebilirlik analizi yapmak ve `null` değerinin programınızda hangi noktalardan akabileceğini bilmek, bu durumu ele almak için kod eklemenizi sağlar. Ancak aynı analizi, ihtiyacınız olmayan `null` kodunu tespit etmek için de kullanabiliriz. Null güvenliği öncesinde, şöyle bir şey yazsaydınız:

```dart
// Using null safety:
String checkList(List<Object> list) {
  if (list?.isEmpty ?? false) {
    return 'Got nothing';
  }
  return 'Got something';
}
```

Dart, bu null-aware `?.` operatörünün yararlı olup olmadığını bilmenin bir yoluna sahip değildi. Bildiği kadarıyla, fonksiyona `null` değerini geçirebilirdiniz. Ancak null-safe Dart'ta, bu fonksiyonda `list`'i null değer alamayan bir `List` türüyle işaretlediyseniz, `list`'in asla `null` olmayacağını bilir. Bu, `?.` operatörünün asla yararlı bir şey yapmayacağı ve sadece `.` kullanmanız gerektiği anlamına gelir.

Kodunuzu basitleştirmenize yardımcı olmak için, statik analiz artık bunu tespit edebilecek kadar hassas olduğundan, bu gibi gereksiz kodlar için uyarılar ekledik. Null-aware bir operatörü veya `== null` ya da `!= null` gibi bir kontrolü null değer alamayan bir tür üzerinde kullanmak uyarı olarak raporlanır.

Ve elbette, bu durum aynı zamanda null değer alamayan tür yükseltmesiyle de ilgilidir. Bir değişken null değer alamayan bir türe yükseltildikten sonra, onu gereksiz yere tekrar `null` için kontrol ederseniz bir uyarı alırsınız:

```dart
// Using null safety:
String checkList(List<Object>? list) {
  if (list == null) return 'No list';
  if (list?.isEmpty ?? false) {
    return 'Empty list';
  }
  return 'Got something';
}
```

Burada `?.` için bir uyarı alıyorsunuz çünkü kod çalıştırıldığı anda `list`'in `null` olmasının mümkün olmadığını zaten biliyoruz. Bu uyarıların amacı sadece gereksiz kodları temizlemek değil. Gereksiz `null` kontrollerini kaldırarak, geriye kalan anlamlı kontrollerin öne çıkmasını sağlıyoruz. Kodunuza baktığınızda `null`'ın nerede oluşabileceğini görebilmenizi istiyoruz.

### Nullable türlerle çalışma

Artık `null` değeri null değer alabilen türler kümesine dahil. Akış analizi ile, `null` olmadığını kanıtlayabildiğimiz bazı değerlerin güvenli bir şekilde null değer alamayan tarafa geçmesine ve orada kullanılmasına izin verebiliriz. Bu büyük bir adım, ancak burada durursak, ortaya çıkan sistem hala oldukça kısıtlayıcı olur. Akış analizi yalnızca yerel değişkenler, parametreler ve özel final alanlar için yardımcı olur.

Dart'ın null güvenliği öncesindeki esnekliğinin mümkün olduğunca çoğunu geri kazanmak ve bazı noktalarda onu aşmak için, bir avuç yeni özellik daha ekledik.

#### Daha akıllı null-aware metotlar

Dart'ın null-aware operatörü `?.`, null güvenliğinden çok daha eskidir. Çalışma zamanı semantiği, alıcı `null` ise sağ taraftaki özellik erişiminin atlandığını ve ifadenin `null` olarak değerlendirildiğini belirtir:

```dart
// Without null safety:
String notAString = null;
print(notAString?.length);
```

Bu, bir istisna fırlatmak yerine "null" yazdırır. Null-aware operatörü, Dart'ta null değer alabilen türleri kullanılabilir hale getirmek için güzel bir araçtır. Null değer alabilen türler üzerinde metot çağırmanıza izin veremesek de, bunlar üzerinde null-aware operatörlerini kullanmanıza izin verebiliriz ve veriyoruz da. Programın null güvenliği sonrası sürümü şöyledir:

```dart
// Using null safety:
String? notAString = null;
print(notAString?.length);
```

Öncekiyle tamamen aynı şekilde çalışıyor.

Ancak Dart'ta null-aware operatörleri kullandıysanız, metot zincirlerinde kullanırken muhtemelen can sıkıcı bir durumla karşılaşmışsınızdır. Diyelim ki, potansiyel olarak eksik bir dizenin uzunluğunun çift sayı olup olmadığını görmek istiyorsunuz (pek gerçekçi bir sorun değil, biliyorum, ama lütfen beni dinleyin):

```dart
// Using null safety:
String? notAString = null;
print(notAString?.length.isEven);
```

Bu program `?.` kullanmasına rağmen çalışma zamanında yine de bir istisna fırlatıyor. Sorun şu ki, `.isEven` ifadesinin alıcısı, solundaki tüm ifadenin, yani `notAString?.length` ifadesinin sonucudur. Bu ifade `null` olarak değerlendirilir, bu nedenle `null` üzerinde `.isEven` çağırmaya çalışırken bir null referans hatası alıyoruz. Dart'ta null-aware operatörünü kullandıysanız, muhtemelen bir kez kullandıktan sonra zincirdeki her özellik veya metoda `?.` uygulamanız gerektiğini zor yoldan öğrenmişsinizdir:

```dart
String? notAString = null;
print(notAString?.length?.isEven);
```

Bu can sıkıcı, ama daha da kötüsü, önemli bilgileri gizliyor. Şunu düşünün:

```dart
// Using null safety:
showGizmo(Thing? thing) {
  print(thing?.doohickey?.gizmo);
}
```

İşte size bir soru: `Thing` üzerindeki `doohickey` getter'ı `null` döndürebilir mi? Sonuç üzerinde `?.` kullandığınız için döndürebilirmiş gibi görünüyor. Ancak ikinci `?.` operatörünün yalnızca `doohickey` sonucunu değil, `thing`'in `null` olduğu durumları ele almak için orada olması da mümkün. Bunu bilemeyiz.

Bu sorunu çözmek için, C#'ın aynı özelliğin tasarımından akıllı bir fikir ödünç aldık. Bir metot zincirinde null-aware bir operatör kullandığınızda, alıcı `null` olarak değerlendirilirse, metot zincirinin geri kalanının tamamı kısa devre edilir ve atlanır. Bu, `doohickey` null değer alamayan bir dönüş türüne sahipse, şunu yazabileceğiniz ve yazmanız gerektiği anlamına gelir:

```dart
// Using null safety:
void showGizmo(Thing? thing) {
  print(thing?.doohickey.gizmo);
}
```

Aslında, bunu yapmazsanız ikinci `?.` için gereksiz kod uyarısı alırsınız. Eğer şöyle bir kod görürseniz:

```dart
// Using null safety:
void showGizmo(Thing? thing) {
  print(thing?.doohickey?.gizmo);
}
```

O zaman `doohickey`'nin kendisinin de null değer alabilen bir dönüş tipine sahip olduğunu kesin olarak bilirsiniz. Her `?.`, metot zincirine `null`'ın akmasına neden olabilecek benzersiz bir yola karşılık gelir. Bu, metot zincirlerindeki null-aware operatörleri hem daha özlü hem de daha hassas hale getirir.

Bu arada, birkaç tane daha null-aware operatör ekledik:

```dart
// Using null safety:

// Null-aware cascade:
receiver?..method();

// Null-aware index operator:
receiver?[index];
```

Null-aware bir fonksiyon çağrı operatörü yok, ancak şöyle yazabilirsiniz:

```dart
// Allowed with or without null safety:
function?.call(arg1, arg2);
```

#### Non-null assertion operatörü

Akış analizini kullanarak null değer alabilen bir değişkeni null değer alamayan bir değişkene taşımanın en güzel yanı, bunun kanıtlanabilir şekilde güvenli olmasıdır. Null değer alamayan türlerin güvenliğinden veya performansından ödün vermeden, daha önce null değer alabilen değişken üzerinde metotlar çağırabilirsiniz.

Ancak null değer alabilen türlerin birçok geçerli kullanımının, statik analizi tatmin edecek şekilde güvenli olduğu kanıtlanamaz. Örneğin:

```dart
// Using null safety, incorrectly:
class HttpResponse {
  final int code;
  final String? error;

  HttpResponse.ok()
      : code = 200,
        error = null;
  HttpResponse.notFound()
      : code = 404,
        error = 'Not found';

  @override
  String toString() {
    if (code == 200) return 'OK';
    return 'ERROR $code ${error.toUpperCase()}';
  }
}
```

Bunu çalıştırmayı denerseniz, `toUpperCase()` çağrısında derleme hatası alırsınız. `error` alanı null değer alabilir çünkü başarılı bir yanıtta bir değeri olmayacaktır. Sınıfı inceleyerek, `error` mesajı `null` olduğunda ona asla erişmediğimizi görebiliriz. Ancak bu, `code` değeri ile `error`'ın null değer alabilirliği arasındaki ilişkiyi anlamayı gerektirir. Tür denetleyicisi bu bağlantıyı göremez.

Başka bir deyişle, kodun insan yöneticileri olarak, `error`'ın kodu kullandığımız noktada `null` olmayacağını biliyoruz ve bunu doğrulamak için bir yönteme ihtiyacımız var. Normalde, türleri `as` ile bir tür dönüştürme (cast) kullanarak doğrularsınız ve burada da aynı şeyi yapabilirsiniz:

```dart
// Using null safety:
String toString() {
  if (code == 200) return 'OK';
  return 'ERROR $code ${(error as String).toUpperCase()}';
}
```

`error`'ı null değer alamayan `String` türüne dönüştürme işlemi başarısız olursa çalışma zamanı hatası verir. Aksi takdirde, üzerinde metotlar çağırabileceğimiz null değer alamayan bir dize elde ederiz.

"Null değer alabilme özelliğini ortadan kaldırma" işlemi o kadar sık karşımıza çıkıyor ki, yeni bir kısaltılmış sözdizimimiz var. Sondaki ünlem işareti (`!`) soldaki ifadeyi alır ve onu temelindeki null değer alamayan türe dönüştürür. Dolayısıyla yukarıdaki fonksiyon şuna eşdeğerdir:

```dart
// Using null safety:
String toString() {
  if (code == 200) return 'OK';
  return 'ERROR $code ${error!.toUpperCase()}';
}
```

Bu tek karakterlik "ünlem işareti operatörü", özellikle temel tür uzun ve ayrıntılı olduğunda çok kullanışlıdır. Null değer alabilme özelliğini kaldırmak için `as Map<TransactionProviderFactory, List<Set<ResponseFilter>>>` yazmak gerçekten can sıkıcı olurdu.

Elbette, herhangi bir tür dönüştürme işleminde olduğu gibi, `!` kullanmak statik güvenliğin kaybına yol açar. Doğruluğu korumak için dönüştürme işlemi çalışma zamanında kontrol edilmelidir ve başarısız olup bir istisna fırlatabilir. Ancak bu dönüştürme işlemlerinin nereye eklendiğini kontrol edebilirsiniz ve kodunuzu inceleyerek bunları her zaman görebilirsiniz.

### Late değişkenler

Tür denetleyicisinin kodun güvenliğini kanıtlayamadığı en yaygın yer, üst düzey değişkenler ve alanlardır. İşte bir örnek:

```dart
// Using null safety, incorrectly:
class Coffee {
  String _temperature;

  void heat() { _temperature = 'hot'; }
  void chill() { _temperature = 'iced'; }

  String serve() => _temperature + ' coffee';
}

void main() {
  var coffee = Coffee();
  coffee.heat();
  coffee.serve();
}
```

Burada, `heat()` metodu `serve()` metodundan önce çağrılıyor. Bu, `_temperature` alanının kullanılmadan önce null olmayan bir değere başlatılacağı anlamına gelir. Ancak statik analizle bunu belirlemek mümkün değildir. (Bunun gibi basit bir örnek için mümkün olabilir, ancak bir sınıfın her örneğinin durumunu izlemeye çalışmanın genel durumu imkansızdır.)

Tür denetleyicisi alanların ve üst düzey değişkenlerin kullanımını analiz edemediği için, null değer alamayan alanların ya bildirim sırasında (ya da örnek alanlar için kurucu başlatma listesinde) başlatılması gerektiği konusunda muhafazakar bir kurala sahiptir. Bu nedenle Dart, bu sınıf için derleme hatası bildirir.

Alanı null değer alabilir hale getirerek ve ardından kullanımlarda null olmayan doğrulama operatörünü kullanarak hatayı düzeltebilirsiniz:

```dart
// Using null safety:
class Coffee {
  String? _temperature;

  void heat() { _temperature = 'hot'; }
  void chill() { _temperature = 'iced'; }

  String serve() => _temperature! + ' coffee';
}
```

Bu yöntem sorunsuz çalışıyor. Ancak sınıfın yöneticisine kafa karıştırıcı bir sinyal gönderiyor. `_temperature` alanını null değer alabilir olarak işaretleyerek, o alan için kullanışlı ve anlamlı bir değer olarak `null`'ın var olduğunu ima ediyorsunuz. Ama amaç bu değil. `_temperature` alanı, mevcut durumunda asla `null` olarak gözlemlenmemelidir.

Gecikmeli başlatma içeren durumların yaygın kullanım şeklini ele almak için yeni bir değiştirici ekledik: `late`. Bunu şu şekilde kullanabilirsiniz:

```dart
// Using null safety:
class Coffee {
  late String _temperature;

  void heat() { _temperature = 'hot'; }
  void chill() { _temperature = 'iced'; }

  String serve() => _temperature + ' coffee';
}
```

Dikkat edin, `_temperature` alanı null değer alamayan bir türe sahip ancak başlatılmamış. Ayrıca, kullanıldığında açık bir null olmayan doğrulama da yok. `late` değiştiricisinin semantiğine uygulayabileceğiniz birkaç model var, ancak ben bunu şöyle düşünüyorum: `late` değiştiricisi, "bu değişkenin kısıtlamalarını derleme zamanında değil, çalışma zamanında uygula" anlamına gelir. Bu, "late" (geç) kelimesinin değişkenin garantilerini ne zaman uyguladığını açıklamasına neredeyse benziyor.

Bu durumda, alan kesin olarak başlatılmadığı için, alan her okunduğunda, ona bir değer atanıp atanmadığını kontrol etmek için çalışma zamanında bir kontrol eklenir. Atanmamışsa, bir istisna fırlatılır. Değişkene `String` türünü vermek "beni asla bir dizeden başka bir değerle görmemelisiniz" anlamına gelir ve `late` değiştiricisi "bunu çalışma zamanında doğrula" anlamına gelir.

Bir bakıma, `late` değiştiricisi `?` kullanmaktan daha "sihirli"dir, çünkü alanın herhangi bir kullanımı başarısız olabilir ve kullanım yerinde metinsel olarak görünür hiçbir şey yoktur. Ancak bu davranışı elde etmek için bildirimde `late` yazmanız gerekir ve bizce değiştiriciyi orada görmek, bunun sürdürülebilir olması için yeterince açık bir ifadedir.

Bunun karşılığında, null değer alabilen bir tür kullanmaktan daha iyi statik güvenlik elde edersiniz. Alanın türü artık null değer alamaz olduğundan, alana `null` atamaya çalışmak derleme hatasına neden olur. `late` değiştiricisi başlatmayı ertelemenizi sağlar, ancak yine de `String` türünü null değer alabilen bir değişken gibi ele almanızı engeller.

#### Lazy initialization

`late` değiştiricisi başka özel yeteneklere de sahip. Paradoksal gibi görünse de, başlatıcısı olan bir alanda da `late` kullanabilirsiniz:

```dart
// Using null safety:
class Weather {
  late int _temperature = _readThermometer();
}
```

Bunu yaptığınızda, başlatıcı *tembel* hale gelir. Örnek oluşturulur oluşturulmaz çalıştırılmak yerine, ertelenir ve alana ilk erişildiğinde tembelce çalıştırılır. Başka bir deyişle, üst düzey bir değişken veya statik alan üzerindeki bir başlatıcı gibi çalışır. Bu, başlatma ifadesinin maliyetli olduğu ve gerekli olmayabileceği durumlarda kullanışlı olabilir.

Başlatıcıyı tembel bir şekilde çalıştırmak, `late` değiştiricisini bir örnek alanında kullandığınızda size ekstra bir avantaj sağlar. Genellikle örnek alan başlatıcıları `this` üzerinden erişemez, çünkü tüm alan başlatıcıları tamamlanana kadar yeni nesneye erişemezsiniz. Ancak bir `late` alan söz konusu olduğunda bu artık geçerli değildir, bu nedenle `this` üzerinden örneğe erişebilir, metotları çağırabilir veya alanlara erişebilirsiniz.

#### Late final değişkenler

`late` değiştiricisini `final` ile de birleştirebilirsiniz:

```dart
// Using null safety:
class Coffee {
  late final String _temperature;

  void heat() { _temperature = 'hot'; }
  void chill() { _temperature = 'iced'; }

  String serve() => _temperature + ' coffee';
}
```

Normal `final` alanların aksine, alanı bildiriminde veya kurucu başlatma listesinde başlatmanız gerekmez. Daha sonra çalışma zamanında ona değer atayabilirsiniz. Ancak yalnızca bir kez değer atayabilirsiniz ve bu durum çalışma zamanında kontrol edilir. Birden fazla kez değer atamaya çalışırsanız (burada olduğu gibi hem `heat()` hem de `chill()` çağırarak), ikinci atama bir istisna fırlatır. Bu, sonunda başlatılan ve sonrasında değiştirilemez olan durumu modellemenin harika bir yoludur.

Başka bir deyişle, yeni `late` değiştiricisi, Dart'ın diğer değişken değiştiricileriyle birlikte Kotlin'deki `lateinit` ve Swift'teki `lazy` özelliğinin büyük bir bölümünü kapsıyor. Hatta biraz yerel tembel değerlendirme istiyorsanız, yerel değişkenlerde bile kullanabilirsiniz.

### Required named parametreler

Bir parametrenin hiçbir zaman `null` olarak görülmemesini garanti etmek için, tür denetleyicisi tüm isteğe bağlı parametrelerin ya null değer alabilen bir türe ya da varsayılan bir değere sahip olmasını gerektirir. Peki ya null değer alamayan bir türe sahip ve varsayılan değeri olmayan adlandırılmış bir parametre istiyorsanız? Bu, çağıranın onu her zaman geçirmesini istediğiniz anlamına gelir. Başka bir deyişle, adlandırılmış ancak isteğe bağlı olmayan bir parametre istiyorsunuz.

Dart parametrelerinin çeşitli türlerini bu tabloyla görselleştiriyorum:

```plaintext
             mandatory    optional
            +------------+------------+
positional  | f(int x)   | f([int x]) |
            +------------+------------+
named       | ???        | f({int x}) |
            +------------+------------+
```

Anlaşılmaz nedenlerden dolayı, Dart uzun zamandır bu tablonun üç köşesini desteklemiş ancak adlandırılmış+zorunlu kombinasyonunu boş bırakmıştır. Null güvenliği ile bunu doldurduk. Gerekli bir adlandırılmış parametreyi, parametrenin önüne `required` koyarak belirtirsiniz:

```dart
// Using null safety:
function({int? a, required int? b, int? c, required int? d}) {}
```

Burada tüm parametreler isimleriyle geçirilmelidir. `a` ve `c` parametreleri isteğe bağlıdır ve atlanabilir. `b` ve `d` parametreleri zorunludur ve geçirilmelidir. Zorunluluğun, null değer alabilme özelliğinden bağımsız olduğunu unutmayın. Null değer alabilen türlerde zorunlu adlandırılmış parametrelere ve (varsayılan değerleri varsa) null değer alamayan türlerde isteğe bağlı adlandırılmış parametrelere sahip olabilirsiniz.

Bence bu da, null güvenliğinden bağımsız olarak Dart'ı daha iyi yapan özelliklerden biri. Bana göre bu, dili daha eksiksiz hissettiriyor.

### Abstract alanlar

Dart'ın güzel özelliklerinden biri de *tekdüze erişim ilkesini* (uniform access principle) desteklemesidir. İnsan dilinde bu, alanların getter ve setter'lardan ayırt edilemez olduğu anlamına gelir. Bir Dart sınıfındaki bir "özelliğin" hesaplanıp hesaplanmadığı veya depolanıp depolanmadığı bir uygulama detayıdır. Bu nedenle, soyut bir sınıf kullanarak bir arayüz tanımlarken, alan bildirimi kullanmak tipiktir:

```dart
abstract class Cup {
  Beverage contents;
}
```

Amaç, kullanıcıların yalnızca bu sınıfı uygulamaları ve onu genişletmemeleridir. Alan sözdizimi, basitçe bir getter/setter çifti yazmanın daha kısa bir yoludur:

```dart
abstract class Cup {
  Beverage get contents;
  set contents(Beverage);
}
```

Ancak Dart, bu sınıfın hiçbir zaman somut bir tür olarak kullanılmayacağını bilmiyor. Bu bildirimi gerçek bir `contents` alanı olarak görüyor. Ve ne yazık ki, bu alan null değer alamaz ve başlatıcısı yoktur, bu nedenle derleme hatası alırsınız.

Bir çözüm, ikinci örnekteki gibi açık soyut getter/setter bildirimleri kullanmaktır. Ancak bu biraz uzun olduğundan, null güvenliği ile birlikte açık soyut alan bildirimleri için de destek ekledik:

```dart
abstract class Cup {
  abstract Beverage contents;
}
```

Bu, ikinci örnekle tamamen aynı şekilde davranır. Verilen isim ve türle soyut bir getter ve setter tanımlar.

### Nullable alanlarla çalışma

Bu yeni özellikler birçok yaygın kalıbı kapsıyor ve çoğu zaman null değer alamayan türlerle çalışmayı oldukça kolaylaştırıyor. Ancak yine de, deneyimlerimize göre, null değer alabilen alanlar hala zor olabiliyor. Alanı null değer alamaz hale getirebildiğiniz durumlarda sorun yok. Ancak birçok durumda, alanın bir değeri olup olmadığını kontrol etmeniz gerekiyor ve bu da onu `late` yerine null değer alabilir hale getirmeyi gerektiriyor, böylece `null` değerini gözlemleyebilirsiniz.

Hem private hem de final olarak tanımlanmış, null değer alabilen alanlar (bazı özel nedenler hariç) tür yükseltmesi yapabilir. Herhangi bir nedenle bir alanı private ve final yapamıyorsanız, yine de bir çözüm bulmanız gerekecektir.

Örneğin, bunun işe yarayacağını düşünebilirsiniz:

```dart
// Using null safety, incorrectly:
class Coffee {
  String? _temperature;

  void heat() { _temperature = 'hot'; }
  void chill() { _temperature = 'iced'; }

  void checkTemp() {
    if (_temperature != null) {
      print('Ready to serve ' + _temperature + '!');
    }
  }

  String serve() => _temperature! + ' coffee';
}
```

`checkTemp()` içinde, `_temperature` alanının `null` olup olmadığını kontrol ediyoruz. Değilse, ona erişiyoruz ve üzerinde `+` operatörünü çağırıyoruz. Maalesef, buna izin verilmiyor.

Akış tabanlı tür yükseltmesi yalnızca hem private hem de final olan alanlar için geçerlidir. Aksi takdirde, statik analiz, alanın değerinin kontrol ettiğiniz nokta ile kullandığınız nokta arasında değişmediğini kanıtlayamaz. (Patolojik durumlarda, alanın kendisinin, ikinci kez çağrıldığında `null` değeri döndüren bir alt sınıftaki bir getter tarafından geçersiz kılınabileceğini göz önünde bulundurun.)

Dolayısıyla, sağlamlığı önemsediğimiz için, public ve/veya final olmayan alanlar yükseltilmiyor ve yukarıdaki metot derlenmiyor. Bu can sıkıcı. Buradaki gibi basit durumlarda, en iyi çözüm alanın kullanımına bir `!` eklemektir. Gereksiz gibi görünse de, Dart bugün aşağı yukarı böyle davranıyor.

Yardımcı olabilecek bir diğer yöntem ise önce alanı yerel bir değişkene kopyalamak ve ardından bu değişkeni kullanmaktır:

```dart
// Using null safety:
void checkTemp() {
  var temperature = _temperature;
  if (temperature != null) {
    print('Ready to serve ' + temperature + '!');
  }
}
```

Tür yükseltmesi yerel değişkenler için de geçerli olduğundan, bu artık sorunsuz çalışıyor. Değeri değiştirmeniz gerekirse, yalnızca yerel değişkene değil, alana da geri kaydetmeyi unutmayın.

Bu ve diğer tür yükseltme sorunlarının çözümü hakkında daha fazla bilgi için, "Fixing type promotion failures" bölümüne bakın.

### Nullability ve generics

Çoğu modern statik tipli dil gibi, Dart'ın da genel (generic) sınıfları ve genel metotları vardır. Bunlar, sezgisel görünmeyen ancak sonuçlarını düşündüğünüzde anlam kazanan birkaç şekilde null değer alabilirlik ile etkileşime girer. Birincisi, "bu tür null değer alabilir mi?" sorusu artık basit bir evet veya hayır sorusu değildir. Şunu düşünün:

```dart
// Using null safety:
class Box<T> {
  final T object;
  Box(this.object);
}

void main() {
  Box<String>('a string');
  Box<int?>(null);
}
```

`Box` tanımında, `T` null değer alabilen bir tür mü yoksa null değer alamayan bir tür mü? Gördüğünüz gibi, her iki türle de örneklendirilebilir. Cevap, `T`'nin *potansiyel olarak null değer alabilen* bir tür olduğudur. Genel bir sınıfın veya metodun gövdesi içinde, potansiyel olarak null değer alabilen bir tür, hem null değer alabilen türlerin hem de null değer alamayan türlerin tüm kısıtlamalarına sahiptir.

Birincisi, `Object` üzerinde tanımlanmış birkaç metot dışında hiçbir metodu çağıramayacağınız anlamına gelir. İkincisi ise, bu türdeki tüm alanları veya değişkenleri kullanmadan önce başlatmanız gerektiği anlamına gelir. Bu da tür parametreleriyle çalışmayı oldukça zorlaştırabilir.

Pratikte birkaç kalıp ortaya çıkar. Tür parametresinin herhangi bir tür ile örneklendirilebildiği koleksiyon benzeri sınıflarda, kısıtlamalarla başa çıkmanız gerekir. Çoğu durumda, buradaki örnekte olduğu gibi, bu, bir tür bağımsız değişkeniyle çalışmanız gerektiğinde, o türden bir değere erişebildiğinizden emin olmak anlamına gelir. Neyse ki, koleksiyon benzeri sınıflar nadiren elemanları üzerinde metot çağırır.

Değere erişiminizin olmadığı yerlerde, tür parametresinin kullanımını null değer alabilir hale getirebilirsiniz:

```dart
// Using null safety:
class Box<T> {
  T? object;
  Box.empty();
  Box.full(this.object);
}
```

`object` alanının bildirimindeki `?` işaretine dikkat edin. Artık alanın açıkça null değer alabilen bir türü var, bu nedenle başlatılmamış olarak bırakmak sorun değil.

Burada olduğu gibi bir tür parametresini `T?` ile null değer alabilir hale getirdiğinizde, null değer alabilme özelliğini ortadan kaldırmak için tür dönüştürme işlemi yapmanız gerekebilir. Bunu yapmanın doğru yolu, `!` operatörü yerine açık bir `as T` tür dönüştürmesi kullanmaktır:

```dart
// Using null safety:
class Box<T> {
  T? object;
  Box.empty();
  Box.full(this.object);

  T unbox() => object as T;
}
```

`!` operatörü, değer `null` ise her zaman hata fırlatır. Ancak tür parametresi null değer alabilen bir türle örneklendirilmişse, `null` değeri `T` için tamamen geçerli bir değerdir:

```dart
// Using null safety:
void main() {
  var box = Box<int?>.full(null);
  print(box.unbox());
}
```

Bu program hatasız çalışmalıdır. `as T` bunu sağlar; `!` ise bir istisna fırlatırdı.

Diğer genel türlerin, uygulanabilecek tür bağımsız değişkenlerinin türlerini kısıtlayan bazı sınırları vardır:

```dart
// Using null safety:
class Interval<T extends num> {
  T min, max;

  Interval(this.min, this.max);

  bool get isEmpty => max <= min;
}
```

Eğer sınır null değer alamazsa, tür parametresi de null değer alamaz. Bu, null değer alamayan türlerin kısıtlamalarına tabi olduğunuz anlamına gelir; alanları ve değişkenleri başlatılmamış bırakamazsınız. Buradaki örnek sınıfın, alanları başlatan bir kurucuya sahip olması gerekir.

Bu kısıtlamanın karşılığında, tür parametresinin sınırında tanımlanan değerler üzerinde herhangi bir metodu çağırabilirsiniz. Ancak null değer alamayan bir sınıra sahip olmak, genel sınıfınızın kullanıcılarının onu null değer alabilen bir tür bağımsız değişkeniyle örneklemesini engeller. Bu, çoğu sınıf için muhtemelen makul bir sınırlamadır.

Ayrıca null değer alabilen bir sınır da kullanabilirsiniz:

```dart
// Using null safety:
class Interval<T extends num?> {
  T min, max;

  Interval(this.min, this.max);

  bool get isEmpty {
    var localMin = min;
    var localMax = max;

    // No min or max means an open-ended interval.
    if (localMin == null || localMax == null) return false;
    return localMax <= localMin;
  }
}
```

Bu, sınıfın gövdesinde tür parametresini null değer alabilir olarak ele alma esnekliğine sahip olduğunuz, ancak aynı zamanda null değer alabilirliğin kısıtlamalarına da tabi olduğunuz anlamına gelir. Null değer alabilme sorununu önce çözmeden bu türdeki bir değişken üzerinde hiçbir şey çağıramazsınız. Buradaki örnekte, alanları yerel değişkenlere kopyalıyoruz ve `<=` işleminden önce null akış analizinin bunları null değer alamayan türlere yükseltmesi için bu yerel değişkenleri kontrol ediyoruz.

Null değer alabilen sınırın, kullanıcıların sınıfı null değer alamayan türlerle örneklemesini engellemediğini unutmayın. Null değer alabilen sınır, tür bağımsız değişkeninin null değer alabileceği anlamına gelir, olması gerektiği anlamına gelmez. (Aslında, bir `extends` yan tümcesi yazmazsanız, tür parametrelerindeki varsayılan sınır null değer alabilen `Object?` sınırıdır.) Null değer alabilen bir tür bağımsız değişkeni *gerektirmenin* bir yolu yoktur. Tür parametresinin kullanımlarının güvenilir bir şekilde null değer alabilir olmasını ve örtük olarak `null` ile başlatılmasını istiyorsanız, sınıfın gövdesi içinde `T?` kullanabilirsiniz.

### Core library değişiklikleri

Dilde birkaç ufak değişiklik daha var, ancak bunlar önemsiz. Örneğin, `on` yan tümcesi içermeyen bir `catch` yan tümcesinin varsayılan türü artık `dynamic` yerine `Object`. `switch` ifadelerindeki fall-through (geçiş) analizi yeni akış analizini kullanıyor.

Sizin için gerçekten önemli olan kalan değişiklikler temel kütüphanelerde. Büyük Null Güvenliği Macerası'na başlamadan önce, temel kütüphanelerimizi dünyayı büyük ölçüde bozmadan null güvenli hale getirmenin bir yolu olmadığı konusunda endişelenmiştik. Ancak durum o kadar da vahim çıkmadı. Birkaç önemli değişiklik var, ancak çoğunlukla geçiş sorunsuz gerçekleşti. Çoğu temel kütüphane ya doğal olarak null değer alamayan türlere geçti ya da `null`'ı kabul edip null değer alabilen bir türle sorunsuz bir şekilde geçiş yaptı.

Ancak birkaç önemli nokta var:

#### Map index operatörü nullable'dır

Bu aslında bir değişiklik değil, daha çok bilinmesi gereken bir şey. `Map` sınıfındaki `[]` indeks operatörü, anahtar mevcut değilse `null` döndürür. Bu, operatörün dönüş türünün null değer alabileceği anlamına gelir: `V` yerine `V?`.

Anahtar mevcut olmadığında bir istisna fırlatacak şekilde metodu değiştirebilir ve daha kolay kullanımlı, null değer alamayan bir dönüş türü verebilirdik. Ancak indeks operatörünü kullanan ve `null` sonucunu kontrol ederek anahtarın mevcut olup olmadığını anlayan kodlar çok yaygın, analizimize göre tüm kullanımların yaklaşık yarısı bu şekilde. Bu kodun tamamını bozmak Dart ekosistemini alevlendirirdi.

Bunun yerine, çalışma zamanı davranışı aynıdır ve bu nedenle dönüş türü null değer alabilir olmak zorundadır. Bu, genellikle bir harita aramasının sonucunu hemen kullanamayacağınız anlamına gelir:

```dart
// Using null safety, incorrectly:
var map = {'key': 'value'};
print(map['key'].length); // Error.
```

Bu, null değer alabilen bir dize üzerinde `.length` çağrısı yapmaya çalışırken derleme hatasına neden olur. Anahtarın mevcut olduğunu bildiğiniz durumlarda, tür denetleyicisine `!` ile bilgi verebilirsiniz:

```dart
// Using null safety:
var map = {'key': 'value'};
print(map['key']!.length); // OK.
```

`Map`'e bunu sizin için yapacak başka bir metot eklemeyi düşündük: anahtarı arayın, bulunamazsa hata fırlatın, aksi takdirde null değer alamayan bir değer döndürün. Ama ona ne ad vereceğiz? `!` işaretinden daha kısa bir isim olamazdı ve metot adı, çağrı yerinde yerleşik anlamıyla birlikte bir `!` görmekten daha açık olmazdı. Bu nedenle, bir haritada bilinen, mevcut bir öğeye erişmenin en yaygın yolu `[]!` kullanmaktır. Buna alışırsınız.

#### Unnamed List constructor yok

`List` sınıfının isimsiz kurucusu, verilen boyutta yeni bir liste oluşturur ancak hiçbir elemanı başlatmaz. Eğer null değer alamayan bir türde bir liste oluşturup daha sonra bir elemana erişirseniz, bu durum sağlamlık garantilerinde çok büyük bir açık oluşturur.

Bunu önlemek için, kurucuyu tamamen kaldırdık. Null-safe kodda `List()` çağırmak, null değer alabilen bir türle bile hatadır. Bu kulağa korkutucu geliyor, ancak pratikte çoğu kod, liste değişmezleri, `List.filled()`, `List.generate()` kullanarak veya başka bir koleksiyonu dönüştürmenin sonucu olarak listeler oluşturur. Belirli bir türün boş bir listesini oluşturmak istediğiniz uç durum için yeni bir `List.empty()` kurucusu ekledik.

Tamamen başlatılmamış bir liste oluşturma yöntemi Dart'ta her zaman yersiz görünmüştür ve şimdi daha da öyle. Eğer bu yöntem yüzünden kodunuz bozulduysa, liste oluşturmanın diğer birçok yolundan birini kullanarak her zaman düzeltebilirsiniz.

#### Non-nullable listelerde daha büyük length ayarlanamaz

Bu pek bilinmiyor, ancak `List`'in `length` getter'ının karşılık gelen bir setter'ı da var. Listeyi kısaltmak için uzunluğu daha kısa bir değere ayarlayabilirsiniz. Ayrıca, listeyi başlatılmamış öğelerle doldurmak için daha uzun bir uzunluğa da ayarlayabilirsiniz.

Eğer bunu null değer alamayan bir türdeki listeyle yaparsanız, daha sonra yazılmamış öğelere eriştiğinizde sağlamlığı ihlal edersiniz. Bunu önlemek için, liste null değer alamayan bir öğe türüne sahipse ve siz onu daha uzun bir uzunluğa ayarlarsanız (ve yalnızca bu durumda) `length` setter'ı bir çalışma zamanı istisnası fırlatacaktır. Her türden listeyi kısaltmak hala sorunsuzdur ve null değer alabilen türlerdeki listeleri uzatabilirsiniz.

`ListBase` veya `ListMixin`'i genişleten ya da uygulayan kendi liste türlerinizi tanımlarsanız bunun önemli bir sonucu vardır. Bu türlerin her ikisi de, uzunluğu ayarlayarak eklenen öğe için yer açan bir `insert()` uygulaması sağlar. Bu, null güvenliğiyle başarısız olurdu, bu nedenle bunun yerine `ListMixin`'deki (`ListBase`'in paylaştığı) `insert()` uygulamasını `add()` çağıracak şekilde değiştirdik. Bu miras alınan `insert()` metodunu kullanabilmek istiyorsanız, özel liste sınıfınız bir `add()` tanımı sağlamalıdır.

#### Iterator.current'a iterasyondan önce veya sonra erişilemez

`Iterator` sınıfı, `Iterable` arayüzünü uygulayan bir türün öğelerini dolaşmak için kullanılan değiştirilebilir bir "imleç"tir. Herhangi bir öğeye erişmeden önce ilk öğeye ilerlemek için `moveNext()` metodunu çağırmanız beklenir. Bu metot `false` döndürdüğünde, sona ulaşmışsınız demektir ve daha fazla öğe yoktur.

Eskiden, ilk `moveNext()` çağrısından önce veya yineleme bittikten sonra çağrıldığında `current`, `null` değeri döndürürdü. Null güvenliği ile bu, `current` dönüş türünün `E` değil `E?` olması gerektiği anlamına gelir. Bu da her öğe erişiminin çalışma zamanı `null` kontrolü gerektireceği anlamına gelir.

Bu kontroller, neredeyse hiç kimsenin mevcut öğeye bu hatalı şekilde erişmediği göz önüne alındığında işe yaramaz olurdu. Bunun yerine, `current` değerinin türünü `E` olarak belirledik. Yineleme öncesinde veya sonrasında bu türde bir değer mevcut olmayabileceğinden, yineleyiciyi çağırmamanız gereken bir durumda çağırdığınızda davranışını tanımsız bıraktık. Çoğu `Iterator` uygulaması bir `StateError` fırlatır.

### Özet

Bu, null güvenliğiyle ilgili tüm dil ve kütüphane değişikliklerine dair çok detaylı bir tur. Bir sürü şey var, ama bu oldukça büyük bir dil değişikliği. Daha da önemlisi, Dart'ın hala tutarlı ve kullanılabilir hissettirdiği bir noktaya ulaşmak istedik. Bu, sadece tip sistemini değil, etrafındaki bir dizi diğer kullanılabilirlik özelliğini de değiştirmeyi gerektiriyor. Null güvenliğinin sonradan eklenmiş gibi hissettirmesini istemedik.

Özetle, şu noktalara dikkat etmek gerekiyor:

- Türler varsayılan olarak null değer almaz ve sonlarına `?` eklenerek null değer alabilir hale getirilir.
- İsteğe bağlı parametreler null değer alabilir olmalı veya varsayılan bir değere sahip olmalıdır. Adlandırılmış parametreleri isteğe bağlı olmaktan çıkarmak için `required` kullanabilirsiniz. Null değer alamayan üst düzey değişkenler ve statik alanlar başlatıcılara sahip olmalıdır. Null değer alamayan örnek alanlar, kurucu gövdesi başlamadan önce başlatılmalıdır.
- Null-aware operatörlerden sonraki metot zincirleri, alıcı `null` ise kısa devre yapar. Yeni null-aware cascade (`?..`) ve indeks (`?[]`) operatörleri vardır. Sonek null olmayan doğrulama "bang" operatörü (`!`), null değer alabilen işlenenini temel null değer alamayan türe dönüştürür.
- Akış analizi, null değer alabilen yerel değişkenleri ve parametreleri (ve Dart 3.2'den itibaren özel final alanlarını) güvenli bir şekilde kullanılabilir, null değer alamayan değişkenlere yükseltmenizi sağlar. Yeni akış analizi ayrıca tür yükseltme, eksik dönüş değerleri, erişilemeyen kod ve değişken başlatma için daha akıllı kurallara sahiptir.
- `late` değiştiricisi, çalışma zamanı kontrolü pahasına, normalde kullanamayacağınız yerlerde null değer alamayan türleri ve `final` kullanmanıza olanak tanır. Ayrıca, tembel başlatmalı alanlar da sağlar.
- Başlatılmamış öğeleri önlemek için `List` sınıfı değiştirildi.

Son olarak, tüm bunları özümseyip kodunuzu null güvenliği dünyasına taşıdığınızda, derleyicilerin optimize edebileceği ve çalışma zamanı hatasının oluşabileceği her yerin kodunuzda görünür olduğu sağlam bir program elde edersiniz. Bunun için harcanan çabaya değeceğini umuyoruz.

---

# Anahtar kelimeler ve sürümleme (Keywords & Versioning)

## Anahtar kelimeler

*Dart'ta anahtar kelimeler.* · Kaynak: <https://dart.dev/language/keywords>

Aşağıdaki tablo, Dart dilinin kendi kullanımı için ayırdığı (rezerve ettiği) kelimeleri listeler. Aksi belirtilmedikçe bu kelimeler tanımlayıcı (identifier) olarak kullanılamaz. İzin verildiği durumlarda bile anahtar kelimeleri tanımlayıcı olarak kullanmak, kodunuzu okuyan diğer geliştiricilerin kafasını karıştırabilir ve bundan kaçınılmalıdır. Tanımlayıcı kullanımı hakkında daha fazla bilgi edinmek için ilgili terime tıklayın.

|  |  |  |  |
| --- | --- | --- | --- |
| abstract² | as² | assert | async³ |
| await¹ | base³ | break | case |
| catch | class | const | continue |
| covariant² | default | deferred² | do |
| dynamic² | else | enum | export² |
| extends | extension² | external² | factory² |
| false | final (var) | final (class) | finally |
| for | Function² | get² | hide³ |
| if | implements² | import² | in |
| interface² | is | late² | library² |
| mixin² | new | null | of³ |
| on³ | operator² | part² | required² |
| rethrow | return | sealed³ | set² |
| show³ | static² | super | switch |
| sync³ | this | throw | true |
| try | type² | typedef² | var |
| void | when³ | with | while |
| yield¹ |  |  |  |

¹ Bu anahtar kelime, bağlama göre tanımlayıcı olarak kullanılabilir.

² Bu anahtar kelime; bir türün (sınıf, mixin, enum, extension type veya type alias) adı, bir extension'ın adı ya da import öneki olarak kullanılamaz. Diğer tüm durumlarda tanımlayıcı olarak kullanılabilir.

³ Bu anahtar kelime, herhangi bir kısıtlama olmaksızın tanımlayıcı olarak kullanılabilir.

## Dil sürümleme

*Dart'ta dil sürümlendirmenin dilin evrimini nasıl mümkün kıldığını ve projenizin ile kütüphanelerinizin dil sürümlerini nasıl yapılandıracağınızı öğrenin.* · Kaynak: <https://dart.dev/language/versioning>

### Genel Bakış

Tek bir Dart SDK'sı, Dart dilinin birden fazla sürümünü aynı anda destekleyebilir. Derleyici, kodun hangi sürümü hedeflediğini belirler ve kodu o sürüme göre yorumlar.

Dil sürümlendirme, Dart'ın null safety gibi geriye dönük uyumsuz bir özellik getirdiği nadir durumlarda önem kazanır. Dart uyumsuz bir değişiklik getirdiğinde, daha önce derlenen kod artık derlenmeyebilir. Dil sürümlendirme, uyumluluğu korumak için her kütüphanenin dil sürümünü ayrı ayrı ayarlamanıza olanak tanır.

Null safety örneğinde, Dart SDK 2.12'den 2.19'a kadar olan sürümler, kodunuzu null safety kullanacak şekilde güncellemeyi *isteğe bağlı* bırakıyordu. Dart, null safety olmayan kodun null safety'li kodla birlikte çalışmasına izin vermek için dil sürümlendirmeyi kullanır. Bu karar, null safety olmayan koddan null safety'li koda geçişi mümkün kıldı. Bir uygulamanın veya paketin uyumsuz bir özellik içeren yeni bir dil sürümüne nasıl geçebileceğine dair bir örnek için, Büyük Dart projeleri için kademeli null safety geçişi makalesine göz atın.

Her paketin varsayılan dil sürümü, `pubspec.yaml` dosyasındaki SDK kısıtlamasının **alt sınırına** eşittir.

**Örnek:** `pubspec.yaml` dosyasındaki aşağıdaki giriş, bu paketin varsayılan olarak Dart 2.18 dil sürümünü kullandığını belirtir.

```yaml
environment:
  sdk: '>=2.18.0 <3.0.0'
```

Dart ekibinin bu sürümlendirme yöntemini nasıl ve neden geliştirdiğini öğrenmek için dil sürümlendirme belirtimine göz atın.

### Dil Sürüm Numaraları

Dart, dil sürümlerini nokta ile ayrılmış iki sayı olarak biçimlendirir. Bu, bir ana (major) sürüm numarası ve bir alt (minor) sürüm numarası olarak okunur. Alt sürüm numaraları uyumsuzluk getiren değişiklikler içerebilir.

Dart sürümleri, dil sürümüne bir yama (patch) numarası ekleyebilir. Yamalar, hata düzeltmeleri dışında dili değiştirmemelidir. Örneğin: Dart 2.18.3, Dart 2.18 SDK dil sürümünün en son sürümüdür.

Her Dart SDK sürümü, kendi dil sürümünü ve aynı ana sürüm numarasındaki tüm önceki sürümleri destekler. Yani Dart SDK 2.18.3, 2.0 ile 2.18 (dahil) arasındaki dil sürümlerini destekler, ancak Dart 1.x'i desteklemez.

Dil sürümünün SDK sürümünden türetilmesi şunları ima eder:

- SDK'nın her alt sürümü yayımlandığında yeni bir dil sürümü ortaya çıkar. Uygulamada bu dil sürümlerinin çoğu, önceki sürümlerle büyük ölçüde aynı şekilde çalışır ve aralarında tam uyumluluk vardır. Örneğin: Dart 2.9 dili, Dart 2.8 diliyle hemen hemen aynı çalışır.
- SDK'nın bir yama sürümü yayımlandığında yeni dil özellikleri getiremez. Örneğin: 2.18.3 sürümü, 2.18 dil sürümü olarak kalır. 2.18.2, 2.18.1 ve 2.18.0 ile uyumlu kalmalıdır.

### Kütüphane Başına Dil Sürümü Seçimi

Varsayılan olarak bir paketteki her Dart dosyası aynı dil sürümünü kullanır. Dart, varsayılan dil sürümünü `pubspec.yaml` dosyasında belirtilen SDK kısıtlamasının alt sınırı olarak belirler. Bazen bir Dart dosyasının daha eski bir dil sürümünü kullanması gerekebilir. Örneğin, bir paketteki tüm dosyaları aynı anda null safety'ye geçiremeyebilirsiniz.

Dart, kütüphane başına dil sürümü seçimini destekler. Paketin geri kalanından farklı bir dil sürümü kullanmak için bir Dart kütüphanesi aşağıdaki biçimde bir yorum içermelidir:

```dart
// @dart = <major>.<minor>
```

Örneğin:

```dart
// Bu dosyanın içeriğinin açıklaması.
// @dart = 2.17
import 'dart:math';
// ...
```

`@dart` dizesi bir `//` yorumu içinde olmalıdır (`///` veya `/*` olmamalıdır) ve dosyadaki herhangi bir Dart kodundan önce görünmelidir. Boşluklar (sekmeler ve boşluklar), `@dart` ve sürüm dizeleri içindekiler dışında önemli değildir. Önceki örnekte görüldüğü gibi, `@dart` yorumundan önce başka yorumlar da bulunabilir.

### Dil Sürümüne Bağlı Değişiklikler

Dil sürümlendirme, Dart'ın ve araçlarının zaman içinde gelişmesine yardımcı olur. Sözdizimi ve anlamsal dil değişikliklerinin yanı sıra, yeni özellikler ve araç değişiklikleri de bir dil sürümüne bağlanabilir. Örneğin, `dart format`, biçimlendirdiği kütüphanenin dil sürümüne bağlı olarak Dart kodunu farklı biçimlendirebilir.

Her dil sürümünün hangi değişiklikleri getirdiğini öğrenmek için filtrelenebilir Dart değişiklik günlüğüne (changelog) başvurabilirsiniz. Her dil sürümünün ve özelliklerinin ayrıntılarını öğrenmek için dil dokümantasyonuna ve dil belirtimine göz atın.

> **İpucu:**
>
> Tartışılan, tasarlanan ve uygulanan yeni Dart özelliklerini ve değişikliklerini incelemek için GitHub'daki Dart language funnel projesine göz atın.
