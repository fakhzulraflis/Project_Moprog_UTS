import 'package:flutter/material.dart';

import 'study_time_page.dart';

class DailyGoalPage extends StatefulWidget {
  final String selectedLanguage;

  const DailyGoalPage({super.key, required this.selectedLanguage});

  @override
  State<DailyGoalPage> createState() => _DailyGoalPageState();
}

class _DailyGoalPageState extends State<DailyGoalPage> {
  int? selectedGoal;

  final List<Map<String, dynamic>> goals = [
    {'title': 'Casual', 'minutes': 5},
    {'title': 'Regular', 'minutes': 10},
    {'title': 'Serious', 'minutes': 15},
    {'title': 'Intense', 'minutes': 20},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),

      appBar: AppBar(
        backgroundColor: const Color(0xFF272F33),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your daily goal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Learning ${widget.selectedLanguage}',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];

                  final bool isSelected = selectedGoal == goal['minutes'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedGoal = goal['minutes'];
                      });
                    },

                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE7C249)
                            : const Color(0xFF20272B),
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Text(
                            goal['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            '${goal['minutes']} min/day',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: selectedGoal == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudyTimePage(
                              selectedLanguage: widget.selectedLanguage,
                            ),
                          ),
                        );
                      },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE7C249),
                  disabledBackgroundColor: const Color(0xFF555555),

                  padding: const EdgeInsets.symmetric(vertical: 15),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                child: const Text(
                  'CONTINUE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
