import 'package:flutter/material.dart';

class StudyTimePage extends StatefulWidget {
  const StudyTimePage({super.key});

  @override
  State<StudyTimePage> createState() => _StudyTimePageState();
}

class _StudyTimePageState extends State<StudyTimePage> {
  String? selectedTime;

  final List<Map<String, String>> studyTimes = [
    {
      'title': 'Morning',
      'time': '08:00',
    },
    {
      'title': 'Afternoon',
      'time': '13:00',
    },
    {
      'title': 'Evening',
      'time': '18:00',
    },
    {
      'title': 'Night',
      'time': '20:00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      appBar: AppBar(
        backgroundColor: const Color(0xFF272F33),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'When would you like to study?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Choose your preferred study time',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: ListView.builder(
                itemCount: studyTimes.length,
                itemBuilder: (context, index) {
                  final studyTime = studyTimes[index];

                  final bool isSelected =
                      selectedTime == studyTime['time'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTime = studyTime['time'];
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
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            studyTime['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            studyTime['time']!,
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
                onPressed: selectedTime == null
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Study time set to $selectedTime',
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE7C249),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
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