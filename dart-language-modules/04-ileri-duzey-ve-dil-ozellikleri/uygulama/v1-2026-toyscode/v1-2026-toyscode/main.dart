import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

// --- Tasarım sabitleri (referans görsele göre) ---
const Color _bg = Color(0xFFF4EFE1); // krem/bej arka plan
const Color _card = Color(0xFFFBF8EF); // açık krem kart
const Color _ink = Color(0xFF22211E); // koyu metin/çerçeve
const Color _yellow = Color(0xFFF3B93F); // sarı vurgu (buton)
const Color _green = Color(0xFF178A5E); // yeşil vurgu
const Color _orange = Color(0xFFE1573B); // turuncu vurgu
const Color _grey = Color(0xFF9A958A); // ikincil metin

void main() => runApp(const DartKavramApp());

int fib(int n) => n <= 1 ? 1 : fib(n - 1) + fib(n - 2);

class DartKavramApp extends StatelessWidget {
  const DartKavramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dart Kavramları',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _bg,
        fontFamily: 'Roboto',
      ),
      home: const KavramSayfasi(),
    );
  }
}

class KavramSayfasi extends StatefulWidget {
  const KavramSayfasi({super.key});
  @override
  State<KavramSayfasi> createState() => _KavramSayfasiState();
}

class _KavramSayfasiState extends State<KavramSayfasi> {
  int _aktifMenu = 0; // alt menü seçimi (görsel amaçlı)
  String _durum = 'Bir kart dokunarak bir Dart kavramını keşfedin.';
  String _durumEtiketi = 'Hazır';
  Color _durumRenk = _green;
  bool _mesgul = false;
  Stream<int>? _sayacAkisi;
  String? _atananKisi;
  int _gorevSayisi = 0;

  // 1) async/await + Future
  Future<String> _ornekVeriCek() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    const sozler = [
      'Dart ile mobil yazmak keyifli!',
      'Async/await, beklemeyi kolaylaştırır.',
      'Null safety, sürprizleri azaltır.',
      'Stream, veriyi zamanla taşır.',
      'Isolate, ekranı kilitlemeden hesap yapar.',
    ];
    return (sozler..shuffle()).first;
  }

  Future<void> _veriCek() async {
    setState(() {
      _mesgul = true;
      _durumEtiketi = 'Yükleniyor';
      _durumRenk = _orange;
      _durum = 'Veri çekiliyor (async/await)...';
    });
    final veri = await _ornekVeriCek();
    setState(() {
      _mesgul = false;
      _durumEtiketi = 'async/await';
      _durumRenk = _green;
      _durum = 'Çekilen veri: $veri';
    });
  }

  // 2) Stream
  void _sayacBaslat() {
    setState(() {
      _sayacAkisi = Stream<int>.periodic(
        const Duration(seconds: 1),
        (i) => i + 1,
      );
      _durumEtiketi = 'Stream';
      _durumRenk = _green;
      _durum = 'Canlı sayaç çalışıyor — aşağıdaki sayacı izleyin.';
    });
  }

  // 3) Isolate
  Future<void> _agirHesap() async {
    setState(() {
      _mesgul = true;
      _durumEtiketi = 'Isolate';
      _durumRenk = _orange;
      _durum = 'Fibonacci(35) arka planda hesaplanıyor...';
    });
    final sonuc = await Isolate.run(() => fib(35));
    setState(() {
      _mesgul = false;
      _durumEtiketi = 'Isolate';
      _durumRenk = _green;
      _durum = 'Fibonacci(35) = $sonuc — ekran DONMADI.';
    });
  }

  // 4) Null safety
  void _gorevEkle() {
    setState(() {
      _gorevSayisi++;
      _atananKisi = null;
      final kisi = _atananKisi ?? 'atanmadı';
      _durumEtiketi = 'Null safety';
      _durumRenk = _green;
      _durum = 'Görev #$_gorevSayisi eklendi. Kişi: $kisi (String? + ??).';
    });
  }

  // 5) Future.wait
  Future<void> _tekIslem(int id) =>
      Future<void>.delayed(const Duration(seconds: 1));

  Future<void> _paralelYukle() async {
    setState(() {
      _mesgul = true;
      _durumEtiketi = 'Future.wait';
      _durumRenk = _orange;
      _durum = '3 işlem paralel yükleniyor...';
    });
    final sw = Stopwatch()..start();
    await Future.wait([_tekIslem(1), _tekIslem(2), _tekIslem(3)]);
    sw.stop();
    setState(() {
      _mesgul = false;
      _durumEtiketi = 'Future.wait';
      _durumRenk = _green;
      _durum = '3 işlem ~${sw.elapsedMilliseconds} ms\'de bitti (tek tek ~3000 ms olurdu).';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ustBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                children: [
                  _durumKarti(),
                  const SizedBox(height: 22),
                  _baslikSatiri(),
                  const SizedBox(height: 14),
                  _kavramKarti(0),
                  _kavramKarti(1),
                  _kavramKarti(2),
                  _kavramKarti(3),
                  _kavramKarti(4),
                  const SizedBox(height: 18),
                  _buyukButon(),
                ],
              ),
            ),
            _altMenu(),
          ],
        ),
      ),
    );
  }

  // Üst bar: avatar + selamlama + buton (referanstaki gibi)
  Widget _ustBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: const BoxDecoration(
        color: _card,
        border: Border(bottom: BorderSide(color: _ink, width: 2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _yellow,
              shape: BoxShape.circle,
              border: Border.all(color: _ink, width: 2),
            ),
            child: const Icon(Icons.code, color: _ink, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Merhaba!',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _ink)),
                Text('Dart kavramlarını keşfet',
                    style: TextStyle(fontSize: 13, color: _grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _ink, width: 2),
            ),
            child: const Row(
              children: [
                Icon(Icons.play_arrow, size: 18, color: _ink),
                SizedBox(width: 4),
                Text('Demo',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Durum kartı: gösterge + durum mesajı (referanstaki profil kartı gibi)
  Widget _durumKarti() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _ink, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _etiketKutu('Durum', _ink, _card),
              const Spacer(),
              _etiketKutu(_durumEtiketi, Colors.white, _durumRenk),
            ],
          ),
          const SizedBox(height: 12),
          if (_mesgul) ...[
            const LinearProgressIndicator(
                color: _green, backgroundColor: _bg),
            const SizedBox(height: 12),
          ],
          Text(_durum,
              style: const TextStyle(
                  fontSize: 15, height: 1.4, color: _ink)),
          if (_sayacAkisi != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _ink, width: 2),
              ),
              child: StreamBuilder<int>(
                stream: _sayacAkisi,
                builder: (context, snapshot) => Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: _green),
                    const SizedBox(width: 10),
                    Text('Canlı sayaç: ${snapshot.data ?? 0}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _ink)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _etiketKutu(String metin, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ink, width: 1.5),
      ),
      child: Text(metin,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  Widget _baslikSatiri() {
    return Row(
      children: [
        const Text('Kavramlar',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: _ink)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: _orange,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _ink, width: 1.5),
          ),
          child: const Text('5',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ),
      ],
    );
  }

  // Kavram verileri
  static const List<List<Object>> _kavramlar = [
    ['Veri Çek', 'async / await · Future', Icons.cloud_download, _teal],
    ['Canlı Sayaç', 'Stream · periyodik akış', Icons.stream, _orange],
    ['Ağır Hesap', 'Isolate · arka plan', Icons.memory, _green],
    ['Görev Ekle', 'Null safety · ? ve ??', Icons.task_alt, _yellow],
    ['Paralel Yükle', 'Future.wait · eş zamanlı', Icons.bolt, _ink],
  ];

  Widget _kavramKarti(int i) {
    final baslik = _kavramlar[i][0] as String;
    final alt = _kavramlar[i][1] as String;
    final ikon = _kavramlar[i][2] as IconData;
    final renk = _kavramlar[i][3] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            switch (i) {
              case 0:
                _veriCek();
              case 1:
                _sayacBaslat();
              case 2:
                _agirHesap();
              case 3:
                _gorevEkle();
              case 4:
                _paralelYukle();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _ink, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: renk,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _ink, width: 2),
                  ),
                  child: Icon(ikon,
                      color: renk == _yellow ? _ink : Colors.white,
                      size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(baslik,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _ink)),
                      const SizedBox(height: 2),
                      Text(alt,
                          style: TextStyle(fontSize: 12, color: _grey)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: _grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buyukButon() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _yellow,
          foregroundColor: _ink,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _ink, width: 2),
          ),
        ),
        onPressed: () => _sayacBaslat(),
        child: const Text('Canlı Akışı Başlat',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _altMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      decoration: const BoxDecoration(
        color: _card,
        border: Border(top: BorderSide(color: _ink, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _menuItem(0, Icons.home, 'Anasayfa'),
          _menuItem(1, Icons.stream, 'Akış'),
          _ortaDugme(),
          _menuItem(3, Icons.memory, 'İzol'),
          _menuItem(4, Icons.settings, 'Ayar'),
        ],
      ),
    );
  }

  Widget _menuItem(int i, IconData ikon, String etiket) {
    final secili = _aktifMenu == i;
    return GestureDetector(
      onTap: () => setState(() => _aktifMenu = i),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, color: secili ? _ink : _grey, size: 24),
          const SizedBox(height: 2),
          Text(etiket,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: secili ? FontWeight.w800 : FontWeight.w500,
                  color: secili ? _ink : _grey)),
        ],
      ),
    );
  }

  Widget _ortaDugme() {
    return GestureDetector(
      onTap: _agirHesap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _yellow,
          shape: BoxShape.circle,
          border: Border.all(color: _ink, width: 2),
        ),
        child: const Icon(Icons.play_arrow, color: _ink, size: 28),
      ),
    );
  }
}




