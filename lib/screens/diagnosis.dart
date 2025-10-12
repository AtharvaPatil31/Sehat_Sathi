import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicalAssistantPage extends StatefulWidget {
  const MedicalAssistantPage({Key? key}) : super(key: key);

  @override
  _MedicalAssistantPageState createState() => _MedicalAssistantPageState();
}

class _MedicalAssistantPageState extends State<MedicalAssistantPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];

  final String apiUrl = "https://api.groq.com/openai/v1/chat/completions";
  final String apiKey =
      "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"; // 🔑 replace with your Groq API key
  final String model = "openai/gpt-oss-120b";

  // Predefined 5 questions
  final List<String> questions = [
    "What symptom is bothering you the most right now?",
    "How long have you been experiencing this symptom?",
    "Do you have any other medical conditions?",
    "Are you currently taking any medications?",
    "Have you noticed anything that improves or worsens your symptom?"
  ];

  int currentQuestionIndex = 0;
  final List<String> userAnswers = [];

  @override
  void initState() {
    super.initState();
    _askNextQuestion(); // Start with Question 1
  }

  // ------------------ Ask the next question ------------------
  void _askNextQuestion() {
    if (currentQuestionIndex < questions.length) {
      setState(() {
        messages.add(
            {"role": "assistant", "content": questions[currentQuestionIndex]});
      });
    } else {
      _sendFinalAnalysis();
    }
  }

  // ------------------ Handle user input ------------------
  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    String userMessage = _controller.text.trim();
    setState(() {
      messages.add({"role": "user", "content": userMessage});
      userAnswers.add(userMessage);
    });
    _controller.clear();

    currentQuestionIndex++;
    _askNextQuestion();
  }

  // ------------------ Send collected answers for final solution ------------------
  Future<void> _sendFinalAnalysis() async {
    setState(() {
      messages.add({
        "role": "assistant",
        "content": "Analyzing your answers... Please wait."
      });
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": model,
          "messages": [
            {
              "role": "system",
              "content":
              "You are a concise medical assistant. Final answers must be only 1–2 lines. If relevant, suggest safe OTC medicines (like paracetamol, ibuprofen, antihistamines) with a disclaimer: 'Consult a doctor before taking any medicine.' Never provide prescriptions or detailed dosing."
            },
            {
              "role": "user",
              "content": """
Here are the patient's answers:

1. ${questions[0]} → ${userAnswers[0]}
2. ${questions[1]} → ${userAnswers[1]}
3. ${questions[2]} → ${userAnswers[2]}
4. ${questions[3]} → ${userAnswers[3]}
5. ${questions[4]} → ${userAnswers[4]}

Now give the final guidance in **just 1–2 lines**, extremely concise, and include OTC medicine suggestions (if applicable).
"""
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String reply = data["choices"][0]["message"]["content"];

        // Ensure it's max 2 lines
        List<String> lines = reply.trim().split("\n");
        if (lines.length > 2) {
          reply = lines.take(2).join(" ");
        }

        setState(() {
          messages.add({"role": "assistant", "content": reply});
        });
      } else {
        setState(() {
          messages
              .add({"role": "assistant", "content": "Error: ${response.body}"});
        });
      }
    } catch (e) {
      setState(() {
        messages.add(
            {"role": "assistant", "content": "Failed to connect to API: $e"});
      });
    }
  }

  // ------------------ Clear messages ------------------
  void _clearMessages() {
    setState(() {
      messages.clear();
      currentQuestionIndex = 0;
      userAnswers.clear();
      _askNextQuestion();
    });
  }

  // ------------------ Dial offline number ------------------
  void _dialOfflineNumber() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+13262170794');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot open dialer")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make transparent to show bg
        elevation: 0, // Remove shadow
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: _dialOfflineNumber,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "Try Offline Mode",
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Medical Assistant",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            GestureDetector(
              onTap: _clearMessages,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "Clear",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
              child: Text(
                "No messages yet",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isUser = messages[index]["role"] == "user";
                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.blue[100]?.withOpacity(0.9)
                          : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(messages[index]["content"] ?? ""),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type your answer...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    child: const Text("Send"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}