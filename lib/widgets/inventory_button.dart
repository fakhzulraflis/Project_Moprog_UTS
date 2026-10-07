import 'package:flutter/material.dart';

import '../pages/inventory_page.dart';
import '../services/auth_session.dart';
import '../services/inventory_service.dart';

// Tombol melayang berlogo tas untuk membuka Inventori. Dipasang di halaman
// Learn, Misi, dan Toko. Angka merah menunjukkan jumlah barang yang belum
// dipakai.
class InventoryButton extends StatefulWidget {
  const InventoryButton({super.key});

  @override
  State<InventoryButton> createState() => _InventoryButtonState();
}

class _InventoryButtonState extends State<InventoryButton> {
  final inventory = InventoryService.instance;

  @override
  void initState() {
    super.initState();
    loadIfNeeded();
  }

  Future<void> loadIfNeeded() async {
    await AuthSession.instance.load();
    if (AuthSession.instance.isLoggedIn && !inventory.isLoaded) {
      await inventory.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: inventory,
      builder: (context, _) {
        final count = inventory.unusedCount;

        return FloatingActionButton(
          // heroTag null supaya tidak bentrok dengan tombol yang sama di
          // halaman lain waktu pindah halaman
          heroTag: null,
          tooltip: 'Inventori',
          backgroundColor: const Color(0xFFE7C249),
          foregroundColor: const Color(0xFF272F33),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InventoryPage()),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.backpack_rounded, size: 30),
              if (count > 0)
                Positioned(
                  right: -10,
                  top: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    constraints: const BoxConstraints(minWidth: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4B4B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF272F33),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
