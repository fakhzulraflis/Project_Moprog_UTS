import 'package:flutter/material.dart';

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
              top: 200,
            ),
            child: Image.asset('assets/app/2.gif'),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Learn languages one Quack at a time.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),

          Text(
            "Quack — O serving you anywhere, anytime, for free.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color.fromARGB(172, 255, 255, 255)),
          ),

          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 0,
              top: 30,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
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
              child: const Center(
                child: Text(
                  "GET STARTED",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ),
          ),
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
              child: const Center(
                child: Text(
                  "I ALREADY HAVE ACCOUNT",
                  style: TextStyle(
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
