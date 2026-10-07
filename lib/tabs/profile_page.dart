import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  final String selectedLanguage;

  const ProfilePage({super.key, required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),

      body: SafeArea(
        child: SingleChildScrollView(
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

                _buildCompleteProfileCard(),

                const SizedBox(height: 24),

                _buildCurrentLanguageCard(),

                const SizedBox(height: 24),

                _buildAccountInformationCard(),
              ],
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

  Widget _buildAvatar() {
    return Image.asset(
      'assets/avatar/japduck.png',
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
    );
  }

  Widget _buildProfileInfo() {
    return Text(
      "Joined August 2026",
      style: GoogleFonts.baloo2(color: Colors.white70, fontSize: 16),
    );
  }

  Widget _buildStats() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _statItem("0", "Following")),
        Expanded(child: _statItem("0", "Followers")),
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
        onPressed: () {},
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
          "FAKHZUL RAFLI S",
          style: GoogleFonts.baloo2(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "zupazuu_",
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

  String _getCurrentLanguageFlag() {
    switch (selectedLanguage.toLowerCase()) {
      case 'japanese':
      case 'jepang':
        return 'assets/flags/japan.png';
      case 'korean':
      case 'korea':
        return 'assets/flags/korea.png';
      case 'english':
      case 'inggris':
      default:
        return 'assets/flags/inggris.png';
    }
  }

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
                      "1 STEP LEFT",
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
          Container(
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
            onTap: () {},
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
    final String username = "zupazuu_";
    final String memberSince = "August 2026";
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
              Image.asset(
                'assets/avatar/japduck.png',
                height: 110,
                fit: BoxFit.contain,
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
