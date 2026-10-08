import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/avatar_catalog.dart';
import '../services/profile_service.dart';
import '../widgets/animated_avatar.dart';
import '../widgets/press_button.dart';

// Memilih karakter untuk foto profil. Mengembalikan true ke halaman
// sebelumnya kalau pilihan berhasil disimpan.
class EditAvatarPage extends StatefulWidget {
  // Kunci karakter yang sedang terpasang (sudah termasuk default dari bahasa).
  final String currentKey;

  const EditAvatarPage({super.key, required this.currentKey});

  @override
  State<EditAvatarPage> createState() => _EditAvatarPageState();
}

class _EditAvatarPageState extends State<EditAvatarPage> {
  late String _selectedKey;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedKey = widget.currentKey;
  }

  AvatarCharacter get _selected => AvatarCatalog.byKey(_selectedKey)!;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ProfileService.setAvatar(_selectedKey);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      appBar: AppBar(
        backgroundColor: const Color(0xFF272F33),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Choose your character',
          style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: Column(
        children: [
          _buildPreview(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: AvatarCatalog.all.length,
              itemBuilder: (_, i) => _buildTile(AvatarCatalog.all[i]),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      height: 220,
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0A8),
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedAvatar(
                  key: ValueKey(_selected.key),
                  character: _selected,
                  height: 190,
                ),
              ),
            ),
          ),
          Positioned(
            left: 14,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF20272B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selected.name,
                    style: GoogleFonts.baloo2(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    _selected.description,
                    style: GoogleFonts.baloo2(
                      color: Colors.white60,
                      fontSize: 12,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(AvatarCharacter a) {
    final selected = a.key == _selectedKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedKey = a.key),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF20272B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF55B6E8) : Colors.white12,
            width: selected ? 3 : 2,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      a.asset,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                  if (a.special)
                    const Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFD84A),
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              a.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.baloo2(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: PressButton.primary(
          label: _saving ? 'SAVING...' : 'SAVE',
          onTap: _saving ? null : _save,
        ),
      ),
    );
  }
}
