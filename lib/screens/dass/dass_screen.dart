import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/dass21_data.dart';
import '../../utils/app_theme.dart';

class DassScreen extends StatefulWidget {
  const DassScreen({super.key});

  @override
  State<DassScreen> createState() => _DassScreenState();
}

class _DassScreenState extends State<DassScreen> {
  int currentQuestion = 0;

  // Menyimpan jawaban (0-3)
  List<int> answers = List.filled(
    Dass21Data.questions.length,
    0,
  );

  void answerQuestion(int value) {
    answers[currentQuestion] = value;

    if (currentQuestion <
        Dass21Data.questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    final scores =
        Dass21Data.calculateScores(answers);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hasil DASS-21"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text("Depresi"),
                Text(
                  scores['depression'].toString(),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text("Kecemasan"),
                Text(
                  scores['anxiety'].toString(),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text("Stress"),
                Text(
                  scores['stress'].toString(),
                ),
              ],
            ),

          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              setState(() {
                currentQuestion = 0;

                answers = List.filled(
                  Dass21Data.questions.length,
                  0,
                );
              });
            },
            child: const Text(
              "Ulangi Tes",
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final question =
        Dass21Data.questions[currentQuestion];

    return Scaffold(
      backgroundColor: AppTheme.bgLight,

      appBar: AppBar(
        title: Text(
          "Tes DASS-21",
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            LinearProgressIndicator(
              value: (currentQuestion + 1) /
                  Dass21Data.questions.length,
            ),

            const SizedBox(height: 20),

            Text(
              "Pertanyaan ${currentQuestion + 1}/${Dass21Data.questions.length}",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Text(
                  question['text'],
                  style:
                      GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            ...List.generate(
              Dass21Data.answerOptions.length,
              (index) {

                return Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),

                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets
                              .all(16),
                    ),

                    onPressed: () {
                      answerQuestion(
                          index);
                    },

                    child: Text(
                      Dass21Data
                          .answerOptions[
                              index],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
