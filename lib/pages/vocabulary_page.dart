import 'package:flutter/material.dart';

class VocabularyPage extends StatefulWidget {
  const VocabularyPage({super.key});

  @override
  State<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> {
  String selectedLanguage = 'Inggris';

  final Map<String, String> flags = {
    'Inggris': 'assets/flags/inggris.png',
    'Jepang': 'assets/flags/japan.png',
    'Korea': 'assets/flags/korea.png',
  };

  final Map<String, List<Map<String, String>>> vocabularies = {
    'Inggris': [
      {
        'word': 'Morning',
        'meaning': 'Pagi',
        'example': 'Good morning, everyone.',
      },
      {
        'word': 'Book',
        'meaning': 'Buku',
        'example': 'I read a book every night.',
      },
      {
        'word': 'Friend',
        'meaning': 'Teman',
        'example': 'She is my best friend.',
      },
      {
        'word': 'Water',
        'meaning': 'Air',
        'example': 'Please give me a glass of water.',
      },
      {
        'word': 'School',
        'meaning': 'Sekolah',
        'example': 'We go to school by bus.',
      },
      {
        'word': 'Food',
        'meaning': 'Makanan',
        'example': 'This food tastes delicious.',
      },
      {
        'word': 'House',
        'meaning': 'Rumah',
        'example': 'Their house is near the park.',
      },
      {
        'word': 'Study',
        'meaning': 'Belajar',
        'example': 'I study English every day.',
      },
    ],
    'Jepang': [
      {
        'word': 'Ohayou',
        'meaning': 'Selamat pagi',
        'example': 'Ohayou gozaimasu, sensei.',
      },
      {
        'word': 'Hon',
        'meaning': 'Buku',
        'example': 'Hon o yomimasu. (Saya membaca buku.)',
      },
      {
        'word': 'Tomodachi',
        'meaning': 'Teman',
        'example': 'Kare wa watashi no tomodachi desu.',
      },
      {
        'word': 'Mizu',
        'meaning': 'Air',
        'example': 'Mizu o kudasai. (Tolong airnya.)',
      },
      {
        'word': 'Gakkou',
        'meaning': 'Sekolah',
        'example': 'Gakkou ni ikimasu. (Saya pergi ke sekolah.)',
      },
      {
        'word': 'Tabemono',
        'meaning': 'Makanan',
        'example': 'Kono tabemono wa oishii desu.',
      },
      {
        'word': 'Ie',
        'meaning': 'Rumah',
        'example': 'Watashi no ie wa chiisai desu.',
      },
      {
        'word': 'Benkyou',
        'meaning': 'Belajar',
        'example': 'Mainichi benkyou shimasu.',
      },
    ],
    'Korea': [
      {
        'word': 'Annyeong',
        'meaning': 'Halo',
        'example': 'Annyeong! Jal jinaess-eoyo?',
      },
      {
        'word': 'Chaek',
        'meaning': 'Buku',
        'example': 'Chaek-eul ilgeoyo. (Saya membaca buku.)',
      },
      {
        'word': 'Chingu',
        'meaning': 'Teman',
        'example': 'Geu-neun nae chingu-yeyo.',
      },
      {
        'word': 'Mul',
        'meaning': 'Air',
        'example': 'Mul juseyo. (Tolong airnya.)',
      },
      {
        'word': 'Hakgyo',
        'meaning': 'Sekolah',
        'example': 'Hakgyo-e gayo. (Saya pergi ke sekolah.)',
      },
      {
        'word': 'Eumsik',
        'meaning': 'Makanan',
        'example': 'I eumsik-eun masisseoyo.',
      },
      {
        'word': 'Jip',
        'meaning': 'Rumah',
        'example': 'Uri jip-eun keoyo.',
      },
      {
        'word': 'Gongbu',
        'meaning': 'Belajar',
        'example': 'Maeil gongbu-haeyo.',
      },
    ],
  };

  // Kartu detail yang muncul dari bawah layar waktu satu kata diketuk.
  void showDetail(Map<String, String> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF20272B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['word']!,
                style: const TextStyle(
                  color: Color(0xFFE7C249),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                item['meaning']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Contoh kalimat',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF272F33),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item['example']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget buildLanguageButton(String language) {
    final bool isSelected = selectedLanguage == language;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedLanguage = language;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFE7C249)
                : const Color(0xFF20272B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Image.asset(
                flags[language]!,
                height: 24,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 6),

              Text(
                language,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tanda seru aman di sini karena selectedLanguage selalu diisi salah satu
    // kunci yang memang ada di dalam map.
    final words = vocabularies[selectedLanguage]!;

    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      appBar: AppBar(
        backgroundColor: const Color(0xFF272F33),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Kosakata',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                buildLanguageButton('Inggris'),
                buildLanguageButton('Jepang'),
                buildLanguageButton('Korea'),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              '${words.length} kata tersedia. Ketuk untuk melihat contoh.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: ListView.builder(
                itemCount: words.length,
                itemBuilder: (context, index) {
                  final item = words[index];

                  return GestureDetector(
                    onTap: () {
                      showDetail(item);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF20272B),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['word']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  item['meaning']!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white54,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
