import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/complete_profile_page.dart';
import '../pages/edit_avatar_page.dart';
import '../services/avatar_catalog.dart';
import '../widgets/animated_avatar.dart';
import '../services/language_asset_service.dart';
import '../services/profile_service.dart';

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
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  UserProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
  String get selectedLanguage =>
      _profile?.learningLanguage ?? widget.fallbackLanguage;

  AvatarCharacter get _avatar => AvatarCatalog.resolve(
    character: _profile?.avatarCharacter,
    language: selectedLanguage,
  );

  Future<void> _openEditAvatar() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditAvatarPage(currentKey: _avatar.key),
      ),
    );
    if (changed == true) _loadProfile();
  }

  String get _fullname => _profile?.fullname ?? '';
  String get _username => _profile?.username ?? '';

  String get _memberSince {
    final date = _profile?.joinedAt;
    if (date == null) return '-';
    return '${_months[date.month - 1]} ${date.year}';
  }

  Future<void> _openCompleteProfile() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CompleteProfilePage()),
    );
    if (changed == true) _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF272F33),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF272F33),
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
                ElevatedButton(
                  onPressed: _loadProfile,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF272F33),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 24),

                  _buildProfileIdentity(),

                  const SizedBox(height: 4),

                  _buildProfileInfo(),

                  const SizedBox(height: 24),

                  _buildStats(),

                  const SizedBox(height: 30),

                  _buildProfileDivider(),

                  const SizedBox(height: 30),

                  if (!_profile!.isComplete) ...[
                    _buildCompleteProfileCard(),

                    const SizedBox(height: 24),
                  ],

                  _buildCurrentLanguageCard(),

                  const SizedBox(height: 24),

                  _buildAccountInformationCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AspectRatio(
      aspectRatio: 1.6,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0A8),
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: _buildAvatar()),
            Positioned(top: 14, right: 14, child: _buildEditButton()),
          ],
        ),
      ),
    );
  }

  // Potret karakter: lebih besar dari kartu supaya bagian kaki terpotong
  // dan wajahnya terlihat jelas. Hanya wajah yang dianimasikan.
  Widget _buildAvatar() {
    return LayoutBuilder(
      builder: (context, c) => OverflowBox(
        alignment: Alignment.topCenter,
        minWidth: 0,
        maxWidth: double.infinity,
        minHeight: 0,
        maxHeight: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: AnimatedAvatar(
            key: ValueKey(_avatar.key),
            character: _avatar,
            height: c.maxHeight * 1.3,
            bodyMotion: false,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Text(
      "Joined $_memberSince",
      style: GoogleFonts.baloo2(color: Colors.white70, fontSize: 16),
    );
  }

  Widget _buildStats() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _statItem("${_profile!.followingCount}", "Following")),
        Expanded(child: _statItem("${_profile!.followersCount}", "Followers")),
        Expanded(child: _buildCoursesStatItem()),
      ],
    );
  }

  Widget _statItem(String value, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.baloo2(
            color: const Color(0xFF55B6E8),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.pixelifySans(
            color: const Color(0xFF55B6E8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0A8),
        border: Border.all(color: const Color(0xFFB7A85E), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        tooltip: "Edit profile",
        onPressed: _openEditAvatar,
        icon: const Icon(Icons.edit_rounded),
        color: const Color(0xFF343A37),
        iconSize: 24,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.expand(),
      ),
    );
  }

  Widget _buildProfileIdentity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _fullname,
          style: GoogleFonts.baloo2(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          _username,
          style: GoogleFonts.baloo2(color: Colors.white54, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildCoursesStatItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          _getCurrentLanguageFlag(),
          width: 35,
          height: 35,
          fit: BoxFit.contain,
        ),
        Text(
          "Courses",
          style: GoogleFonts.pixelifySans(
            color: const Color(0xFF55B6E8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _getCurrentLanguageFlag() =>
      LanguageAssetService.flagFor(selectedLanguage);

  Widget _buildCompleteProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF20272B),
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
                      "Complete your profile!",
                      style: GoogleFonts.baloo2(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${_profile!.stepsLeft} ${_profile!.stepsLeft == 1 ? "STEP" : "STEPS"} LEFT",
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
          GestureDetector(
            onTap: _openCompleteProfile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF55B6E8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF3895C5),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  "CONTINUE",
                  style: GoogleFonts.baloo2(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLanguageCard() {
    final String currentLanguage = selectedLanguage;
    final String currentFlag = _getCurrentLanguageFlag();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF20272B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Current Learning Language",
            style: GoogleFonts.pixelifySans(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(currentFlag, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentLanguage,
                      style: GoogleFonts.baloo2(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Beginner Level",
                      style: GoogleFonts.pixelifySans(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: widget.onContinueLearning,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  "CONTINUE LEARNING",
                  style: GoogleFonts.baloo2(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInformationCard() {
    final String username = _username;
    final String memberSince = _memberSince;
    final String currentLanguage = selectedLanguage;
    final String currentFlag = _getCurrentLanguageFlag();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF20272B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Account Information",
            style: GoogleFonts.baloo2(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Username",
                      style: GoogleFonts.pixelifySans(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      username,
                      style: GoogleFonts.baloo2(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Member Since",
                      style: GoogleFonts.pixelifySans(color: Colors.white54),
                    ),
                    Text(
                      memberSince,
                      style: GoogleFonts.baloo2(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Learning Language",
                      style: GoogleFonts.pixelifySans(color: Colors.white54),
                    ),
                    Row(
                      children: [
                        Image.asset(
                          currentFlag,
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          currentLanguage,
                          style: GoogleFonts.baloo2(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AnimatedAvatar(
                key: ValueKey('account-${_avatar.key}'),
                character: _avatar,
                height: 170,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDivider() {
    return Container(
      width: double.infinity,
      height: 2,
      color: const Color(0xFF38474C),
    );
  }
}
