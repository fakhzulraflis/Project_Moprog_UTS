import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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

                const SizedBox(height: 40),

                _buildAvatar(),

                const SizedBox(height: 25),

                _buildProfileInfo(),

                const SizedBox(height: 25),

                _buildStats(),

                const SizedBox(height: 30),

                _buildEditButton(),

                const SizedBox(height: 30),

                _buildCompleteProfileCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      "USERNAME",
      style: GoogleFonts.baloo2(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          color: const Color(0xFF20272B),
          borderRadius: BorderRadius.circular(100),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.asset('assets/app/avatar.png', fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        Text(
          "@username",
          style: GoogleFonts.baloo2(color: Colors.white70, fontSize: 18),
        ),

        const SizedBox(height: 8),

        Text(
          "Joined 2026",
          style: GoogleFonts.baloo2(color: Colors.white38, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,

      children: [
        _statItem("1", "Courses"),
        _statItem("0", "Following"),
        _statItem("0", "Followers"),
      ],
    );
  }

  Widget _statItem(String value, String title) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.baloo2(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(title, style: GoogleFonts.pixelifySans(color: Colors.white70)),
      ],
    );
  }

  Widget _buildEditButton() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(vertical: 14),

      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 231, 194, 73),

        borderRadius: BorderRadius.circular(16),

        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 190, 155, 45),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),

      child: Center(
        child: Text(
          "EDIT PROFILE",
          style: GoogleFonts.baloo2(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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

              Image.asset('assets/app/qua.gif', 
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
}
