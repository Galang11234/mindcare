import 'package:flutter/material.dart';
import '../../services/chatbot_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();

  List<Map<String, String>> messages = [];

  void sendMessage() {
    if (controller.text.isEmpty) return;

    final userMessage = controller.text;

    setState(() {
      messages.add({
        'sender': 'user',
        'text': userMessage,
      });
    });

    final botReply =
        ChatbotService.getResponse(userMessage);

    setState(() {
      messages.add({
        'sender': 'bot',
        'text': botReply,
      });
    });

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MindCare Chat"),
      ),
      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context,index){

                final msg=messages[index];

                return ListTile(
                  title: Align(
                    alignment:
                    msg['sender']=="user"
                    ? Alignment.centerRight
                    : Alignment.centerLeft,

                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                        msg['sender']=="user"
                        ? Colors.blue
                        : Colors.grey.shade300,

                        borderRadius:
                        BorderRadius.circular(12),
                      ),

                      child: Text(
                        msg['text']!,
                        style: TextStyle(
                          color:
                          msg['sender']=="user"
                          ? Colors.white
                          : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration:
                    const InputDecoration(
                      hintText: "Ketik pesan...",
                    ),
                  ),
                ),

                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                )

              ],
            ),
          )

        ],
      ),
    );
  }
}