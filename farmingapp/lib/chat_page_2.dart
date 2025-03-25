import 'package:flutter/material.dart';

class ChatDetailPage extends StatelessWidget {
  const ChatDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> messages = [
      {'text': 'Hey There!', 'isSentByMe': false},
      {'text': 'How are you?', 'isSentByMe': false},
      {'text': 'How was your day?', 'isSentByMe': false},
      {'text': 'Hello!', 'isSentByMe': true},
      {'text': 'I am fine and how are you?', 'isSentByMe': true},
      {'text': 'Today was great!!!', 'isSentByMe': true},
      {'text': 'I am doing well, Can we meet tomorrow?', 'isSentByMe': false},
      {'text': 'Yes Sure!', 'isSentByMe': true},
      {'text': 'At what time?', 'isSentByMe': true},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F7755),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
            const SizedBox(width: 10),
            const Text(
              'Sarali',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message['isSentByMe']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: message['isSentByMe']
                          ? const Color(0xFF6F7755)
                          : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: message['isSentByMe']
                            ? const Radius.circular(15)
                            : const Radius.circular(0),
                        bottomRight: message['isSentByMe']
                            ? const Radius.circular(0)
                            : const Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: message['isSentByMe']
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: const Color(0xFFD6D5C7),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFF6F7755)),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: const Color(0xFF6F7755),
                  child: IconButton(
                    icon: const Icon(Icons.mic, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
