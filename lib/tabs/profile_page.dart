import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/add_friends_page.dart';
import '../pages/complete_profile_page.dart';
import '../pages/edit_avatar_page.dart';
import '../pages/friends_page.dart';
import '../pages/settings_page.dart';
import '../pages/share_profile_page.dart';
import '../services/avatar_catalog.dart';
import '../services/date_format.dart';
import '../services/language_asset_service.dart';
import '../services/player_progress.dart';
import '../services/profile_service.dart';
import '../widgets/animated_avatar.dart';
import '../widgets/overview_stats_card.dart';
import '../widgets/press_button.dart';

class ProfilePage extends StatefulWidget {
  // Bahasa cadangan sebelum data profil dari backend selesai dimuat.
  final String fallbackLanguage;

  // Dipanggil saat tombol "Continue learning" ditekan (pindah ke tab Learn).
  final VoidCallback? onContinueLearning;

  const ProfilePage({
    super.key,
    required String selectedLanguage,
    this.onContinueLearning,
  }) : fallbackLanguage = selectedLanguage;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _bg = Color(0xFF272F33);
  static const _card = Color(0xFF20272B);
  static const _line = Color(0xFF38474C);
  static const _yellow = Color(0xFFFFF0A8);
  static const _blue = Color(0xFF55B6E8);
  static const _ink = Color(0xFF343A37); // teks gelap di atas kuning

  // Tinggi bar atas (di bawah status bar) dan area potret kuning.
  static const double _barHeight = 60;
  static const double _portraitHeight = 290;

  final _scroll = ScrollController();

  UserProfile? _profile;
  bool _loading = true;
  String? _error;

  // true selama bar atas masih berada di atas area kuning
  bool _overYellow = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    PlayerProgress.instance.load();
    _loadProfile();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final over = _scroll.offset < _portraitHeight - _barHeight;
    if (over != _overYellow) setState(() => _overYellow = over);
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = _profile == null;
      _error = null;
    });
    try {
      final profile = await ProfileService.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  // Bahasa yang dipelajari user (dari database), cadangan dari login.
  String get _language => _profile?.learningLanguage ?? widget.fallbackLanguage;

  AvatarCharacter get _avatar => AvatarCatalog.resolve(
    character: _profile?.avatarCharacter,
    language: _language,
  );

  // Membuka halaman lain, lalu memuat ulang profil kalau ada yang berubah.
  Future<void> _open(Widget page) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (changed == true) _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    if (_loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile == null) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _error ?? 'Could not load profile.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                PressButton.primary(
                  label: 'RETRY',
                  width: 140,
                  onTap: _loadProfile,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final topInset = MediaQuery.of(context).padding.top;

    // Ikon status bar menyesuaikan latar di bawahnya (kuning = ikon gelap)
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _overYellow
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: _overYellow ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _loadProfile,
              edgeOffset: topInset + _barHeight,
              child: SingleChildScrollView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPortrait(topInset),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                      child: _buildContent(profile),
                    ),
                  ],
                ),
              ),
            ),
            _buildTopBar(profile, topInset),
          ],
        ),
      ),
    );
  }

  // ---------- Bar atas yang tetap di tempat ----------

  Widget _buildTopBar(UserProfile profile, double topInset) {
    final fg = _overYellow ? _ink : Colors.white;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: topInset + _barHeight,
        padding: EdgeInsets.only(top: topInset, left: 24, right: 12),
        decoration: BoxDecoration(
          color: _overYellow ? _yellow : _bg,
          border: Border(
            bottom: BorderSide(
              color: _overYellow ? Colors.transparent : _line,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.baloo2(
                  color: fg,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                child: Text(profile.fullname.toUpperCase()),
              ),
            ),
            _barIcon(
              Icons.ios_share_rounded,
              'Share',
              fg,
              () => _open(ShareProfilePage(profile: profile)),
            ),
            _barIcon(
              Icons.settings_rounded,
              'Settings',
              fg,
              () => _open(SettingsPage(profile: profile)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barIcon(
    IconData icon,
    String tooltip,
    Color color,
    VoidCallback onTap,
  ) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 28),
    );
  }

  // ---------- Potret karakter (kuning) ----------

  Widget _buildPortrait(double topInset) {
    final visible = _portraitHeight - _barHeight;

    return Container(
      width: double.infinity,
      height: topInset + _portraitHeight,
      color: _yellow,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Lebih besar dari area kuning supaya kaki terpotong dan wajah jelas.
          Positioned.fill(
            top: topInset + _barHeight,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                minWidth: 0,
                maxWidth: double.infinity,
                minHeight: 0,
                maxHeight: double.infinity,
                child: AnimatedAvatar(
                  key: ValueKey('portrait-${_avatar.key}'),
                  character: _avatar,
                  height: visible * 1.32,
                  bodyMotion: false,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 14,
            child: PressButton(
              width: 52,
              height: 46,
              depth: 4,
              radius: 14,
              color: _yellow,
              shadowColor: const Color(0xFFD9C97A),
              borderColor: const Color(0xFFB7A85E),
              textColor: _ink,
              icon: Icons.edit_rounded,
              fontSize: 17,
              padding: EdgeInsets.zero,
              onTap: () => _open(EditAvatarPage(currentKey: _avatar.key)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Isi halaman ----------

  Widget _buildContent(UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '@${profile.username.toUpperCase()}  ·  JOINED ${monthYear(profile.joinedAt).toUpperCase()}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.baloo2(
            color: Colors.white54,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 14),
        _buildStats(profile),
        const SizedBox(height: 22),
        PressButton.outline(
          label: 'ADD FRIENDS',
          icon: Icons.person_add_alt_1_rounded,
          onTap: () => _open(AddFriendsPage(profile: profile)),
        ),
        const SizedBox(height: 30),
        Container(height: 2, color: _line),
        const SizedBox(height: 30),
        _buildOverviewCard(profile),
        const SizedBox(height: 24),
        if (!profile.isComplete) ...[
          _buildCompleteProfileCard(profile),
          const SizedBox(height: 24),
        ],
        _buildCurrentLanguageCard(),
      ],
    );
  }

  // Ringkasan statistik. Angkanya dari progres di HP (selalu yang terbaru dan
  // berubah langsung saat kita belajar); peringkat dari server.
  Widget _buildOverviewCard(UserProfile profile) {
    final progress = PlayerProgress.instance;

    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        final loaded = progress.isLoaded;

        return OverviewStatsCard(
          xp: loaded
              ? (progress.totalXp > profile.xp ? progress.totalXp : profile.xp)
              : profile.xp,
          streak: loaded ? progress.streak : 0,
          bestStreak: loaded ? progress.bestStreak : 0,
          gems: loaded ? progress.gems : 0,
          hearts: 5 + (loaded ? progress.bonusHearts : 0),
          lessons: loaded ? progress.completedLessonIds.length : 0,
          rank: profile.rank,
          totalPlayers: profile.totalPlayers,
        );
      },
    );
  }

  // Tiga kolom sama lebar: nilai di atas, label di bawah, rata kiri.
  Widget _buildStats(UserProfile profile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _stat(
            title: 'Courses',
            value: Image.asset(
              LanguageAssetService.flagFor(_language),
              width: 34,
              height: 34,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Expanded(
          child: _stat(
            title: 'Following',
            value: _statNumber(profile.followingCount),
            onTap: () => _open(FriendsPage(profile: profile)),
          ),
        ),
        Expanded(
          child: _stat(
            title: 'Followers',
            value: _statNumber(profile.followersCount),
            onTap: () => _open(FriendsPage(profile: profile, initialTab: 1)),
          ),
        ),
      ],
    );
  }

  Widget _statNumber(int count) => Text(
    '$count',
    style: GoogleFonts.baloo2(
      color: _blue,
      fontSize: 26,
      fontWeight: FontWeight.bold,
      height: 1,
    ),
  );

  Widget _stat({
    required String title,
    required Widget value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 36,
            child: Align(alignment: Alignment.centerLeft, child: value),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.pixelifySans(color: _blue, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteProfileCard(UserProfile profile) {
    final left = profile.stepsLeft;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete your profile!',
                      style: GoogleFonts.baloo2(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$left ${left == 1 ? 'STEP' : 'STEPS'} LEFT',
                      style: GoogleFonts.pixelifySans(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/app/qua.gif',
                height: 100,
                width: 80,
                fit: BoxFit.cover,
              ),
            ],
          ),
          const SizedBox(height: 15),
          PressButton.primary(
            label: 'CONTINUE',
            onTap: () => _open(const CompleteProfilePage()),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLanguageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Learning Language',
            style: GoogleFonts.pixelifySans(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    LanguageAssetService.flagFor(_language),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _language,
                      style: GoogleFonts.baloo2(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Beginner Level',
                      style: GoogleFonts.pixelifySans(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PressButton.outline(
            label: 'CONTINUE LEARNING',
            fontSize: 16,
            onTap: widget.onContinueLearning,
          ),
        ],
      ),
    );
  }
}
