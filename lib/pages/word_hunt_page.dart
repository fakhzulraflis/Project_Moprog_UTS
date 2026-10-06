import 'package:flutter/material.dart';

import '../models/vocabulary.dart';
import '../services/api_service.dart';

class WordHuntPage extends StatefulWidget {
  final String selectedLanguage;

  const WordHuntPage({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<WordHuntPage> createState() => _WordHuntPageState();
}

class _WordHuntPageState extends State<WordHuntPage> {
  List<Vocabulary> vocabularies = [];

  bool isLoading = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    loadVocabularies();
  }

  // Mengambil terjemahan sesuai bahasa yang dipilih user
  String getTranslation(Vocabulary vocabulary) {
    switch (widget.selectedLanguage) {
      case 'Japanese':
        return vocabulary.japanese;

      case 'Korean':
        return vocabulary.korean;

      case 'English':
      default:
        return vocabulary.english;
    }
  }

  Future<void> loadVocabularies() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getVocabularies();

      if (!mounted) return;

      // Acak vocabulary dari backend
      final shuffled = List<Vocabulary>.from(result)
        ..shuffle();

      // Untuk Perburuan Kata kita gunakan maksimal 8 kata
      final selected = shuffled.length > 8
          ? shuffled.sublist(0, 8)
          : shuffled;

      setState(() {
        vocabularies = selected;

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Gagal mengambil kosakata dari server.';

        isLoading = false;
      });

      debugPrint('Word Hunt error: $e');
    }
  }

  Widget buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFFE7C249),
          ),

          SizedBox(height: 20),

          Text(
            'Menyiapkan Perburuan Kata...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Mengambil kosakata dari server',
            style: TextStyle(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFE7C249),
              size: 70,
            ),

            const SizedBox(height: 20),

            Text(
              errorMessage ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: loadVocabularies,
              child: const Text('COBA LAGI'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVocabularyPreview() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bahasa: ${widget.selectedLanguage}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Kosakata Permainan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${vocabularies.length} kata berhasil dimuat dari server.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.separated(
              itemCount: vocabularies.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                final vocabulary = vocabularies[index];

                final translation =
                    getTranslation(vocabulary);

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF20272B),
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color.fromARGB(
                        40,
                        255,
                        255,
                        255,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          vocabulary.indonesian,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white38,
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Text(
                          translation,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Color(0xFFE7C249),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          const Center(
            child: Text(
              'Grid permainan akan ditambahkan selanjutnya.',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      appBar: AppBar(
        backgroundColor: const Color(0xFF272F33),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Perburuan Kata',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadVocabularies,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? buildLoading()
            : errorMessage != null
                ? buildError()
                : buildVocabularyPreview(),
      ),
    );
  }
}