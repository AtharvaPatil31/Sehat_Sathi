import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

// ------------------ Chat Message Model ------------------
class ChatMessage {
  final String role; // "user" or "assistant"
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {"role": role, "content": content};
}

// ------------------ Groq Chat API Service ------------------
class GroqChatService {
  static const String apiUrl =
      "https://api.groq.com/openai/v1/chat/completions";
  static const String apiKey =
      "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"; // Replace with secure storage

  static Future<String?> sendMessage(List<ChatMessage> conversation) async {
    final body = jsonEncode({
      "model": "openai/gpt-oss-120b",
      "messages": conversation.map((m) => m.toJson()).toList(),
      "temperature": 0.5,
      "max_tokens": 1024,
      "top_p": 1.0,
    });

    try {
      final response =
      await http.post(Uri.parse(apiUrl), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      }, body: body);

      print("API Response: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Safe access: handle different JSON structures
        final choices = data["choices"];
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]["message"];
          if (message != null && message["content"] != null) {
            return message["content"];
          }
        }
        return "No response from assistant";
      } else {
        // Try parsing error from API
        try {
          final error = jsonDecode(response.body)["error"];
          return "API Error: ${error?["message"] ?? response.body}";
        } catch (_) {
          return "HTTP Error: ${response.statusCode}";
        }
      }
    } catch (e) {
      return "Network error: $e";
    }
  }
}

// ------------------ Chat ViewModel ------------------
class ChatViewModel extends ChangeNotifier {
  List<ChatMessage> messages = [];
  List<ChatMessage> conversationHistory = [
    ChatMessage(
      role: "system",
      content: """
You are a friendly medical assistant chatbot. 
Ask exactly 5 questions one by one to understand the user's health situation. 
Do not ask the next question until the user answers the previous one. 
After all 5 questions, provide a summary and suggestion. Only respond to medical queries.
""",
    ),
  ];

  bool isLoading = false;

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(role: "user", content: text);
    messages.add(userMessage);
    conversationHistory.add(userMessage);
    isLoading = true;
    notifyListeners();

    final reply = await GroqChatService.sendMessage(conversationHistory);

    if (reply != null) {
      final botMessage = ChatMessage(role: "assistant", content: reply);
      messages.add(botMessage);
      conversationHistory.add(botMessage);
    } else {
      messages.add(ChatMessage(
          role: "assistant", content: "Error: No response from server"));
    }

    isLoading = false;
    notifyListeners();
  }

  void clearChat() {
    messages = [];
    conversationHistory = [conversationHistory.first];
    notifyListeners();
  }
}

// ------------------ Medical Assistant Screen ------------------
class MedicalAssistantPage extends StatefulWidget {
  const MedicalAssistantPage({Key? key}) : super(key: key);

  @override
  _MedicalAssistantPageState createState() => _MedicalAssistantPageState();
}

class _MedicalAssistantPageState extends State<MedicalAssistantPage> {
  final ChatViewModel viewModel = ChatViewModel();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _dialOfflineNumber() async {
    const phoneNumber = "tel:+13262170794";
    if (await canLaunchUrl(Uri.parse(phoneNumber))) {
      await launchUrl(Uri.parse(phoneNumber));
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    viewModel.sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical Assistant"),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          TextButton(
            onPressed: _dialOfflineNumber,
            child: const Text(
              "Offline",
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              viewModel.clearChat();
            },
            child: const Text(
              "Clear",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: viewModel,
              builder: (_, __) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10),
                  itemCount: viewModel.messages.length,
                  itemBuilder: (context, index) {
                    final msg = viewModel.messages[index];
                    final isUser = msg.role == "user";
                    return Align(
                      alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg.content,
                          style: TextStyle(
                              color: isUser ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (viewModel.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          SafeArea(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
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
