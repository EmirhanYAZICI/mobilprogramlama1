# Dart İleri Düzey Konuları — Pekiştirme Soruları (Toyscode Takımı)

Bu dokümanda **Eşzamanlılık (Concurrency)**, **Null Güvenliği (Null Safety)**, **Isolate Mimarisi** ve **Dart 3 Sınıf Belirleyicileri (Modifiers)** konularıyla ilgili, orta-ileri seviye 2 çoktan seçmeli ve 2 açık uçlu pekiştirme sorusu yer almaktadır. Soruların cevapları ve teknik açıklamaları belgenin sonunda verilmiştir.

---

## 📝 Bölüm 1: Çoktan Seçmeli Sorular (Test)

### Soru 1 (Eşzamanlılık / Asenkron Üreteçler)
Dart dilinde, zaman içinde asenkron olarak birden fazla değer üreten (yani `Stream` dönen) bir üreteç (generator) fonksiyonu tanımlamak için fonksiyon gövdesinin hemen önüne hangi anahtar kelime yazılır?

- **A)** `async`
- **B)** `async*`
- **C)** `sync*`
- **D)** `yield*`

---

### Soru 2 (Null Güvenliği / Lazy Initialization)
Dart'ta null güvenliği (null safety) bağlamında; değeri sonradan atanacak olan, atama yapılmadan kullanıldığında derleme zamanı (compile-time) yerine çalışma zamanı (runtime) hatası fırlatan ve **aynı zamanda bellekteki başlatma işlemi değişkene ilk erişilene kadar ertelenen (lazy initialization)** değişkenleri tanımlamak için hangi anahtar kelime kullanılır?

- **A)** `deferred`
- **B)** `lazy`
- **C)** `final`
- **D)** `late`

---

## ✍️ Bölüm 2: Açık Uçlu Sorular 

### Soru 3 (Isolate ve Otomatik Yönetim)
Dart'ta geleneksel iş parçacıklarının (threads) aksine bellek paylaşmayan Isolate'ler, eski sürümlerde manuel port (`SendPort`/`ReceivePort`) yönetimi gerektiriyordu. Dart 2.15 ile standart kütüphaneye eklenen; arka planda kısa ömürlü bir Isolate oluşturup, ağır hesaplamayı yapıp sonucu ana thread'e döndürdükten sonra Isolate'i **otomatik olarak sonlandıran (kill)** yüksek seviyeli asenkron metodun adı nedir?

**Cevap:**  
> *(Öğrencinin yazacağı yer)*

---

### Soru 4 (Dart 3 Sınıf Belirleyicileri / Modifiers)
Dart 3 ile birlikte dilin nesne yönelimli yapısına yeni erişim belirleyiciler eklenmiştir. Bir sınıfın hiyerarşisini kısıtlayarak, o sınıftan türetilecek alt sınıfların (subclasses) **yalnızca aynı dosya (library) içerisinde** tanımlanmasını zorunlu kılan ve `switch` ifadelerinde derleyicinin tüm alt sınıfları kontrol etmesini (exhaustiveness) sağlayan anahtar kelime nedir?

**Cevap:**  
> *(Öğrencinin yazacağı yer)*

---

<br>
<br>
<br>

---

## 🔑 Cevap Anahtarı ve Kapsamlı Açıklamalar

### Soru 1'in Cevabı: **B) async\***
- **Açıklama:** Dart'ta tek bir asenkron değer döneceksek (Future) `async` kullanırız. Ancak bir fonksiyon belirli aralıklarla birden çok değer üretecekse (Stream dönüyorsa), bu bir asenkron üreteçtir ve `async*` anahtar kelimesi ile işaretlenir. Bu fonksiyonların içinde değerleri dışarı aktarmak için `yield` anahtar kelimesi kullanılır. (`sync*` senkron iteratörler, `yield*` ise başka bir üreteci delege etmek için kullanılır.)

### Soru 2'nin Cevabı: **D) late**
- **Açıklama:** `late` anahtar kelimesi derleyiciye şu iki şeyi söyler: 1) "Bu değişkeni nullable (`?`) yapma, ben ona kullanmadan önce kesinlikle bir değer atayacağım." (Eğer atamazsanız kod derlenir ancak çalışırken `LateInitializationError` fırlatır). 2) "Bu değişkenin değerini (özellikle maliyetli bir fonksiyon içeriyorsa) bellekte hemen oluşturma, sadece kod içinde ilk çağrıldığı/okunduğu anda oluştur (lazy evaluation)."

### Soru 3'ün Cevabı: **`Isolate.run()`**
- **Açıklama:** Eskiden Isolate oluşturmak için `Isolate.spawn()` kullanır ve iletişim için manuel portlar kurardık. Dart 2.15 ile gelen `Isolate.run()`, arka planda hızlıca bir Isolate açar, içine verilen fonksiyonu (closure) çalıştırır, dönüş değerini ana Isolate'e güvenli bir şekilde aktarır ve işlemi bitince kendi kendini kapatır. Ağır JSON parse işlemleri veya büyük matematiksel hesaplamalar için en modern ve kolay yöntemdir.

### Soru 4'ün Cevabı: **`sealed`**
- **Açıklama:** Dart 3'ün en güçlü özelliklerinden biri olan `sealed` class'lar, exhaustiveness (kapsamlılık) kontrolü sağlar. Bir sınıfı `sealed class Ortak{}` olarak tanımladığınızda, bu sınıf dışarıdan extend, implement veya mixin olarak kullanılamaz. Alt sınıflar sadece o sınıfın bulunduğu aynı dosyada oluşturulabilir. Böylece derleyici, bu sınıftan türetilen tüm alt sınıfları bilir ve bir `switch` bloğunda tüm ihtimalleri yönetip yönetmediğinizi size derleme anında bildirir.
