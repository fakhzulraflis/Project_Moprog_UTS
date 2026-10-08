import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_session.dart';
import '../services/language_asset_service.dart';
import '../services/profile_service.dart';
import '../tabs/home_page.dart';
import '../widgets/press_button.dart';
import '../widgets/quack_app_bar.dart';
import 'blocked_users_page.dart';
import 'intro_page.dart';

// Pengaturan akun: info akun, ganti bahasa belajar, daftar blokir, dan sign out.
class SettingsPage extends StatefulWidget {
  final UserProfile profile;

  const SettingsPage({super.key, required this.profile});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _languages = ['English', 'Japanese', 'Korean'];

  bool _busy = false;

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _changeLanguage() async {
    final current = widget.profile.learningLanguage;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF20272B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Learning language',
                style: GoogleFonts.baloo2(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              for (final language in _languages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PressButton.outline(
                    height: 56,
                    onTap: () => Navigator.pop(sheetContext, language),
                    child: Row(
                      children: [
                        Image.asset(
                          LanguageAssetService.flagFor(language),
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            language,
                            style: GoogleFonts.baloo2(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (language == current)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF58CC02),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (picked == null || picked == current || _busy) return;

    setState(() => _busy = true);
    try {
      await ProfileService.setLanguage(picked);
      if (!mounted) return;
      // Muat ulang aplikasi dengan bahasa baru
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomePage(selectedLanguage: picked)),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _signOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF20272B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Sign out?',
          style: GoogleFonts.baloo2(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'You will need to log in again to continue learning.',
          style: GoogleFonts.baloo2(color: Colors.white70, fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: PressButton.outline(
                  label: 'CANCEL',
                  height: 44,
                  fontSize: 15,
                  onTap: () => Navigator.pop(dialogContext, false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PressButton.danger(
                  label: 'SIGN OUT',
                  height: 44,
                  fontSize: 15,
                  onTap: () => Navigator.pop(dialogContext, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (ok != true || _busy) return;

    setState(() => _busy = true);
    await AuthSession.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const IntroPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;

    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      appBar: quackAppBar('Settings'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _sectionTitle('ACCOUNT'),
            _infoCard([
              _infoRow('Name', p.fullname),
              _infoRow('Username', '@${p.username}'),
              _infoRow('Email', p.email),
            ]),
            const SizedBox(height: 24),
            _sectionTitle('LEARNING'),
            PressButton.outline(
              height: 60,
              onTap: _busy ? null : _changeLanguage,
              child: Row(
                children: [
                  Image.asset(
                    LanguageAssetService.flagFor(p.learningLanguage),
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Learning language',
                          style: GoogleFonts.pixelifySans(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          p.learningLanguage,
                          style: GoogleFonts.baloo2(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white38,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('PRIVACY'),
            PressButton.outline(
              height: 60,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BlockedUsersPage()),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.block_rounded,
                    color: Color(0xFFFF6B6B),
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Blocked players',
                      style: GoogleFonts.baloo2(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white38,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('ABOUT'),
            _infoCard([
              Row(
                children: [
                  Image.asset('assets/app/logo.png', height: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Quack-O\nLearn languages one Quack at a time.',
                      style: GoogleFonts.baloo2(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 32),
            PressButton.danger(
              label: 'SIGN OUT',
              icon: Icons.logout_rounded,
              onTap: _busy ? null : _signOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(
      text,
      style: GoogleFonts.pixelifySans(color: Colors.white54, fontSize: 14),
    ),
  );

  Widget _infoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF20272B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF38474C), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.pixelifySans(color: Colors.white54, fontSize: 12),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.baloo2(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}
