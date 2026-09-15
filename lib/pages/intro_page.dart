import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'understand_page.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 80.0,
              right: 80,
              bottom: 0,
              top: 146,
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Image.asset(
                'assets/app/wavingduck.gif',
                height: 170.0,
                fit: BoxFit.cover,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Learn languages one Quack at a time.",
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
            child: Text(
              "Quack — O serving you anywhere, anytime, for free.",
              textAlign: TextAlign.center,
              style: GoogleFonts.pixelifySans(
                fontSize: 12.8,
                color: Color.fromARGB(172, 255, 255, 255),
              ),
            ),
          ),

          // Get started Button.
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const UnderstandPage();
                },
              ),
            ),

            child: Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 0,
                top: 31,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 30,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 231, 194, 73),
                  borderRadius: BorderRadius.circular(16),

                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(255, 190, 155, 45),
                      offset: Offset(0, 4), // (x, y) y = kebawah
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "GET STARTED",
                    style: GoogleFonts.baloo2(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // I already have account button
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 0,
              top: 20,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 40, 50, 55),
                borderRadius: BorderRadius.circular(16),

                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 190, 155, 45),
                    offset: Offset(0, 0), // (x, y) y = kebawah
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  "I ALREADY HAVE ACCOUNT",
                  style: GoogleFonts.baloo2(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
