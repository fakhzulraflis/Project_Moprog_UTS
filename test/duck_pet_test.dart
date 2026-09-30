import 'package:flutter_test/flutter_test.dart';
import 'package:moprog_uts/services/duck_pet.dart';
import 'package:moprog_uts/services/player_progress.dart';
import 'package:moprog_uts/widgets/duck_painter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final pet = DuckPet.instance;
  final progress = PlayerProgress.instance;

  // Jam palsu yang bisa dimajukan, supaya bisa menguji efek waktu
  // tanpa menunggu berjam-jam.
  late DateTime now;

  Future<void> start([Map<String, Object> saved = const {}]) async {
    SharedPreferences.setMockInitialValues(saved);
    now = DateTime(2026, 10, 1, 7); // jam 7 pagi
    pet.clock = () => now;
    pet.resetForTest();
    progress.resetForTest();
    await pet.load();
    await progress.load();
  }

  void skip(Duration d) => now = now.add(d);

  test('Quacko baru mulai dengan kenyang dan senang 80%', () async {
    await start();

    expect(pet.fullness, 80);
    expect(pet.happiness, 80);
    expect(pet.mood, DuckMood.happy);
    expect(pet.name, 'Quacko');
  });

  test('kenyang dan senang berkurang seiring waktu', () async {
    await start();

    skip(const Duration(hours: 5));
    expect(pet.fullness, 60); // 80 - 4 x 5
    expect(pet.happiness, 65); // 80 - 3 x 5
    expect(pet.mood, DuckMood.normal);
  });

  test('Quacko lapar kalau lama tidak diberi makan', () async {
    await start();

    skip(const Duration(hours: 14)); // jam 9 malam
    expect(pet.fullness, 24);
    expect(pet.mood, DuckMood.hungry);
  });

  test('nilai tidak pernah di bawah 0', () async {
    await start();

    skip(const Duration(days: 3));
    expect(pet.fullness, 0);
    expect(pet.happiness, 0);
  });

  test('Quacko tidur di malam hari dan tidak bisa dielus', () async {
    await start();

    now = DateTime(2026, 10, 1, 23);
    expect(pet.mood, DuckMood.sleeping);
    expect(await pet.pet(), isFalse);
  });

  test('memberi roti memotong gem dan menambah kenyang', () async {
    await start();
    skip(const Duration(hours: 10)); // kenyang jadi 40

    expect(await pet.feed(), isNull);
    expect(progress.gems, 50 - DuckPet.breadPrice);
    expect(pet.fullness, 65);
  });

  test('tidak bisa memberi roti kalau sudah kenyang', () async {
    await start({'pet_fullness': 100.0});

    expect(await pet.feed(), isNotNull);
    expect(progress.gems, 50);
  });

  test('tidak bisa memberi roti kalau gem kurang', () async {
    await start({'gems': 5});
    skip(const Duration(hours: 10));

    expect(await pet.feed(), 'Gem kamu belum cukup.');
    expect(pet.fullness, 40);
  });

  test('mengelus ada jeda 1 menit', () async {
    await start();

    expect(await pet.pet(), isTrue);
    expect(pet.happiness, 84);
    expect(await pet.pet(), isFalse);

    skip(const Duration(minutes: 1));
    expect(await pet.pet(), isTrue);
  });

  test('menyelesaikan lesson membuat Quacko lebih senang', () async {
    await start({'pet_happiness': 50.0});

    await progress.completeLesson();
    expect(pet.happiness, 65);
  });

  test('aksesoris di slot yang sama saling menggantikan', () async {
    await start({'gems': 500});
    final hat = DuckPet.wardrobe.firstWhere(
      (a) => a.type == DuckAccessory.partyHat,
    );
    final crown = DuckPet.wardrobe.firstWhere(
      (a) => a.type == DuckAccessory.crown,
    );

    await pet.buyAccessory(hat);
    await pet.buyAccessory(crown);

    expect(pet.owned, {DuckAccessory.partyHat, DuckAccessory.crown});
    expect(pet.equipped, {DuckAccessory.crown});
    expect(progress.gems, 500 - hat.price - crown.price);

    // Aksesoris yang sudah dimiliki tidak perlu dibeli lagi
    await pet.toggleAccessory(DuckAccessory.partyHat);
    expect(pet.equipped, {DuckAccessory.partyHat});
    expect(progress.gems, 500 - hat.price - crown.price);
  });

  test('nama dan aksesoris tersimpan setelah aplikasi dibuka ulang', () async {
    await start({'gems': 100});
    await pet.rename('  Bebeku  ');
    await pet.buyAccessory(DuckPet.wardrobe.first);

    pet.resetForTest();
    await pet.load();

    expect(pet.name, 'Bebeku');
    expect(pet.equipped, {DuckPet.wardrobe.first.type});
  });
}
