# Dart İleri Düzey Konuları — Pekiştirme Soruları (Takım 4)

Bu dokümanda **Eşzamanlılık (Concurrency)**, **Null Güvenliği (Null Safety)**, **Dil Sürümlendirme (Language Versioning)** ve **Dart Anahtar Kelimeleri (Keywords)** konularıyla ilgili 2 çoktan seçmeli (test) ve 2 açık uçlu (yazmalı) pekiştirme sorusu yer almaktadır. Soruların cevapları ve kısa açıklamaları en sonda verilmiştir.

---

## 📝 Bölüm 1: Çoktan Seçmeli Sorular (Test)

### Soru 1 (Eşzamanlılık / Concurrency)
Dart dilinde asenkron olarak çalışacak bir fonksiyonu bildirmek ve içinde `await` ifadesini kullanabilmek için fonksiyon gövdesinin hemen önüne hangi anahtar kelime yazılır?

- **A)** `sync`
- **B)** `isolate`
- **C)** `async`
- **D)** `future`

---

### Soru 2 (Null Güvenliği / Null Safety)
Dart'ta bir değişkenin `null` değer alabileceğini (yani nullable olduğunu) derleyiciye belirtmek için tür adının sonuna hangi işaret konur? (Örn: `String... ad;`)

- **A)** `!` *(Ünlem işareti)*
- **B)** `?` *(Soru işareti)*
- **C)** `#` *(Kare işareti)*
- **D)** `*` *(Yıldız işareti)*

---

## ✍️ Bölüm 2: Kısa Cevaplı / Açık Uçlu Sorular (Yazmalı)

### Soru 3 (Isolate ve Bellek Mimarisi)
Dart dilinde ağır hesaplamaları arka planda çalıştırmayı sağlayan, geleneksel iş parçacıklarının (threads) aksine birbiriyle **bellek paylaşmayan** (her birinin kendi yalıtılmış belleği ve olay döngüsü olan) bağımsız çalışma birimlerine ne ad verilir?

**Cevap:**  
> *(Öğrencinin yazacağı yer)*

---

### Soru 4 (Dil Sürümlendirme / Language Versioning)
Bir Dart dosyasının, projedeki diğer dosyalardan farklı olarak belirli bir Dart sürümüyle (örneğin Dart 2.17) derlenmesini sağlamak için dosyanın en başında kullanılan tek satırlık yorum yönergesi nasıl yazılır?

**Cevap:**  
> *(Öğrencinin yazacağı yer)*

---

<br>

---

## 🔑 Cevap Anahtarı ve Açıklamalar

### Soru 1'in Cevabı: **C) async**
- **Açıklama:** Dart'ta bir fonksiyonun içerisinde asenkron işlemler yapabilmek ve `await` anahtar sözcüğü ile bir `Future` sonucunu bekleyebilmek için ilgili fonksiyonun tanımına `async` eklenir (Örnek: `Future<void> veriGetir() async { ... }`).

### Soru 2'nin Cevabı: **B) ? (Soru işareti)**
- **Açıklama:** Sesli Null Güvenliği (Sound Null Safety) kuralına göre Dart'ta tüm türler varsayılan olarak non-nullable'dır (null değer kabul etmez). Bir değişkenin null değer tutmasına izin vermek için türünün sonuna `?` eklenir (Örnek: `String? isim;`). `!` işareti ise tam tersine, nullable bir değerin o an kesinlikle null olmadığını iddia etmek (null assertion) için kullanılır.

### Soru 3'ün Cevabı: **Isolate (veya İzole)**
- **Açıklama:** Dart'ta çok çekirdekli paralellik "Isolate" (İzole) yapısıyla sağlanır. Isolate'lar geleneksel thread'ler gibi belleği paylaşmazlar (`shared-nothing`). Bu sayede veri yarışması (race condition) ve kilitlenme (deadlock) riskleri ortadan kalkar; aralarında yalnızca portlar (`SendPort` / `ReceivePort`) aracılığıyla mesajlaşırlar.

### Soru 4'ün Cevabı: **`// @dart = 2.17` (veya `// @dart = <major>.<minor>`)**
- **Açıklama:** Dart'ta kütüphane veya dosya bazında dil sürümünü geçersiz kılmak için dosyanın en başında `// @dart = <major>.<minor>` formatında bir yorum satırı kullanılır. Örneğin Dart 2.17 sürümünü zorlamak için `// @dart = 2.17` yazılır.
