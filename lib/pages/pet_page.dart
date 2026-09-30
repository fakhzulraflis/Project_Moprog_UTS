import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/duck_pet.dart';
import '../services/player_progress.dart';
import '../widgets/duck_painter.dart';

// Halaman bebek peliharaan Quacko.
class PetPage extends StatefulWidget {
  const PetPage({super.key});

  @override
  State<PetPage> createState() => _PetPageState();
}

class _PetPageState extends State<PetPage> with TickerProviderStateMixin {
  static const Color backgroundColor = Color(0xFF272F33);
  static const Color cardColor = Color(0xFF20272B);
  static const Color gemColor = Color(0xFF1CB0F6);
  static const Color yellowColor = Color(0xFFE7C249);

  final pet = DuckPet.instance;
  final progress = PlayerProgress.instance;

  // Gerakan naik-turun pelan dan kepakan sayap
  late final AnimationController idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  // Lompatan kecil waktu Quacko dielus
  late final AnimationController jump = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  // Hati yang melayang setiap kali dielus. Isinya id unik tiap hati.
  final List<int> floatingHearts = [];
  int heartCounter = 0;

  // Nilai kenyang & senang berkurang seiring waktu, jadi layar
  // diperbarui berkala.
  Timer? clock;

  @override
  void initState() {
    super.initState();
    pet.load();
    progress.load();
    clock = Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
  }

  @override
  void dispose() {
    clock?.cancel();
    idle.dispose();
    jump.dispose();
    super.dispose();
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: cardColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> petDuck() async {
    if (pet.isSleeping) {
      showMessage('Ssst... ${pet.name} lagi tidur.');
      return;
    }

    final ok = await pet.pet();
    if (!mounted) return;
    if (!ok) {
      showMessage('${pet.name} baru saja dielus, tunggu sebentar ya.');
      return;
    }

    jump.forward(from: 0);
    setState(() => floatingHearts.add(heartCounter++));
  }

  Future<void> feedDuck() async {
    final error = await pet.feed();
    if (!mounted) return;
    showMessage(error ?? 'Nyam! ${pet.name} makan roti.');
  }

  Future<void> buyAccessory(AccessoryInfo item) async {
    final error = await pet.buyAccessory(item);
    if (!mounted) return;
    showMessage(error ?? '${item.name} dipakai ${pet.name}!');
  }

  Future<void> renameDuck() async {
    final controller = TextEditingController(text: pet.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: const Text('Ganti nama', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 12,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nama bebekmu',
            hintStyle: TextStyle(color: Colors.white38),
            counterStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('SIMPAN', style: TextStyle(color: yellowColor)),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName != null) await pet.rename(newName);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([pet, progress]),
      builder: (context, _) {
        if (!pet.isLoaded || !progress.isLoaded) {
          return const Scaffold(
            backgroundColor: backgroundColor,
            body: Center(child: CircularProgressIndicator(color: yellowColor)),
          );
        }

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            foregroundColor: Colors.white,
            title: GestureDetector(
              onTap: renameDuck,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pet.name,
                    style: GoogleFonts.baloo2(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit, size: 18, color: Colors.white54),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Image.asset('assets/icons/gems.png', height: 20),
                    const SizedBox(width: 6),
                    Text(
                      '${progress.gems}',
                      style: const TextStyle(
                        color: gemColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              buildScene(),
              const SizedBox(height: 16),
              buildStats(),
              const SizedBox(height: 16),
              buildActions(),
              const SizedBox(height: 28),
              Text(
                'Lemari ${pet.name}',
                style: GoogleFonts.baloo2(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              buildWardrobe(),
            ],
          ),
        );
      },
    );
  }

  // Kolam tempat Quacko berdiri, lengkap dengan balon ucapan.
  Widget buildScene() {
    final mood = pet.mood;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: mood == DuckMood.sleeping
              ? const [Color(0xFF1B2340), Color(0xFF20272B)]
              : const [Color(0xFF2E7D8C), Color(0xFF20272B)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Kolam
          Positioned(
            bottom: 22,
            child: Container(
              width: 230,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF3FA7B8).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),

          Positioned(top: 14, left: 16, right: 16, child: buildSpeechBubble()),

          Positioned(
            bottom: 34,
            child: GestureDetector(
              onTap: petDuck,
              child: AnimatedBuilder(
                animation: Listenable.merge([idle, jump]),
                builder: (context, _) {
                  final bob = Curves.easeInOut.transform(idle.value) * 5;
                  final hop = sin(jump.value * pi) * 26;
                  return Transform.translate(
                    offset: Offset(0, -bob - hop),
                    child: CustomPaint(
                      size: const Size(170, 170),
                      painter: DuckPainter(
                        mood: mood,
                        accessories: pet.equipped,
                        wingFlap: idle.value,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          if (mood == DuckMood.sleeping)
            const Positioned(
              right: 70,
              top: 90,
              child: Text(
                'Z z z',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          for (final id in floatingHearts)
            FloatingHeart(
              key: ValueKey(id),
              onDone: () => setState(() => floatingHearts.remove(id)),
            ),
        ],
      ),
    );
  }

  Widget buildSpeechBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        pet.speech,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF272F33),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              buildMoodChip(),
              const Spacer(),
              Text(
                'Bersama ${pet.daysTogether} hari',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),
          buildBar('Kenyang', pet.fullness, const Color(0xFFFF9A1F)),
          const SizedBox(height: 10),
          buildBar('Senang', pet.happiness, const Color(0xFFFF6B9A)),
        ],
      ),
    );
  }

  Widget buildMoodChip() {
    final color = switch (pet.mood) {
      DuckMood.happy => const Color(0xFF58CC02),
      DuckMood.normal => yellowColor,
      DuckMood.hungry => const Color(0xFFFF9A1F),
      DuckMood.sad => const Color(0xFFFF4B4B),
      DuckMood.sleeping => const Color(0xFF7B61FF),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        pet.moodLabel,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 14,
              backgroundColor: const Color(0xFF3A4449),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(
            '${value.round()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget buildActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: buildActionButton(
                icon: Icons.bakery_dining,
                label: 'Beri Roti',
                price: DuckPet.breadPrice,
                color: const Color(0xFFFF9A1F),
                onTap: feedDuck,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildActionButton(
                icon: Icons.pan_tool_alt,
                label: 'Elus',
                color: const Color(0xFFFF6B9A),
                onTap: petDuck,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Tiap lesson yang kamu selesaikan bikin ${pet.name} '
          '+${DuckPet.lessonHappiness.round()}% senang.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }

  Widget buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    int? price,
  }) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (price != null) ...[
              const SizedBox(width: 8),
              Image.asset('assets/icons/gems.png', height: 16),
              const SizedBox(width: 3),
              Text(
                '$price',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildWardrobe() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.82,
      children: [for (final item in DuckPet.wardrobe) buildAccessoryCard(item)],
    );
  }

  Widget buildAccessoryCard(AccessoryInfo item) {
    final owned = pet.owned.contains(item.type);
    final wearing = pet.equipped.contains(item.type);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: wearing ? yellowColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Pratinjau: Quacko memakai aksesoris ini
          Expanded(
            child: CustomPaint(
              size: const Size(100, 100),
              painter: DuckPainter(
                mood: DuckMood.normal,
                accessories: {item.type},
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: owned
                ? OutlinedButton(
                    onPressed: () => pet.toggleAccessory(item.type),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: wearing ? Colors.white70 : yellowColor,
                      side: BorderSide(
                        color: wearing ? Colors.white24 : yellowColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      wearing ? 'LEPAS' : 'PAKAI',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                : ElevatedButton(
                    onPressed: progress.gems >= item.price
                        ? () => buyAccessory(item)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gemColor,
                      disabledBackgroundColor: const Color(0xFF3A4449),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white38,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/icons/gems.png', height: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${item.price}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// Hati kecil yang melayang ke atas lalu menghilang.
class FloatingHeart extends StatelessWidget {
  final VoidCallback onDone;

  const FloatingHeart({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final drift = (key.hashCode % 60) - 30.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      onEnd: onDone,
      builder: (context, t, child) => Positioned(
        bottom: 150 + t * 90,
        child: Transform.translate(
          offset: Offset(drift * t, 0),
          child: Opacity(opacity: 1 - t, child: child),
        ),
      ),
      child: const Icon(Icons.favorite, color: Color(0xFFFF6B9A), size: 30),
    );
  }
}
