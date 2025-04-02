import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Farmingapp/services/notifications_service.dart';
import 'dart:async';
import 'dart:math';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final String otherUserId;

  const ChatDetailPage({
    Key? key,
    required this.chatId,
    required this.otherUserId,
  }) : super(key: key);

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _recordingTimer;

  // User data
  String _otherUserName = '';
  String _otherUserImage = 'assets/3d_avatar_12.png';
  bool _isOtherUserOnline = false;
  String _lastSeen = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadOtherUserInfo();
    _markConversationAsRead();

    // Set user as active in this chat
    _updateUserActivity(true);

    // Auto-scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _recordingTimer?.cancel();

    // Update user activity status when leaving chat
    _updateUserActivity(false);
    super.dispose();
  }

  Future<void> _loadOtherUserInfo() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUserId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;

        setState(() {
          _otherUserName = userData['username'] ?? userData['name'] ?? 'User';
          _otherUserImage = userData['profileImage'] ?? 'assets/3d_avatar_12.png';
          _isOtherUserOnline = userData['isOnline'] ?? false;

          if (!_isOtherUserOnline && userData['lastSeenAt'] != null) {
            final lastSeen = (userData['lastSeenAt'] as Timestamp).toDate();
            _lastSeen = _formatLastSeen(lastSeen);
          }
        });
      } else {
        // Handle demo/placeholder user for seller123
        if (widget.otherUserId == "seller123") {
          setState(() {
            _otherUserName = "Demo Seller";
            _otherUserImage = 'assets/3d_avatar_12.png';
            _isOtherUserOnline = false;
            _lastSeen = "Not available";
          });
        }
      }
    } catch (e) {
      print('Error loading user info: $e');
      
      // Fallback for demo data
      if (widget.otherUserId == "seller123") {
        setState(() {
          _otherUserName = "Demo Seller";
          _otherUserImage = 'assets/3d_avatar_12.png';
          _isOtherUserOnline = false;
          _lastSeen = "Not available";
        });
      }
    }
  }

  Future<void> _markConversationAsRead() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Reset the unread messages counter for the current user
      await NotificationsService.resetMessageCount(user.uid);

      // Get unread messages from the other user
      final messagesQuery = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .where('senderId', isEqualTo: widget.otherUserId)
          .where('read', isEqualTo: false)
          .get();

      // Mark all messages as read
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in messagesQuery.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Future<void> _updateUserActivity(bool isActive) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Update user document to show activity
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'isOnline': true,
        'lastActivityTimestamp': FieldValue.serverTimestamp(),
        'activeChat': isActive ? widget.chatId : null,
      });

      // Also update the chat document with this information
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({
        'lastActivity': FieldValue.serverTimestamp(),
        'activeUsers': isActive
            ? FieldValue.arrayUnion([user.uid])
            : FieldValue.arrayRemove([user.uid]),
      });
    } catch (e) {
      print('Error updating user activity: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      print('Sending message: $text');

      // Create a server timestamp for consistent ordering
      final timestamp = FieldValue.serverTimestamp();

      // Create message document with a server timestamp
      final messageData = {
        'text': text,
        'senderId': user.uid,
        'timestamp': timestamp,
        'read': false,
        'isVoice': false,
        'delivered': false,
      };

      // Add message to Firestore
      final messageRef = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add(messageData);

      print('Message added with ID: ${messageRef.id}');

      // Update the chat document with latest message info
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({
        'lastMessageTime': timestamp,
        'lastMessage': text,
        'lastSenderId': user.uid,
        'updatedAt': timestamp,
      });

      // Update notification count for the other user
      await NotificationsService.updateMessageCount(widget.otherUserId);

      print('Chat document updated');

      // Mark as delivered after a short delay to simulate network latency
      Future.delayed(const Duration(milliseconds: 500), () async {
        try {
          await messageRef.update({'delivered': true});
          print('Message marked as delivered');
        } catch (e) {
          print('Error marking message as delivered: $e');
        }
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordingDuration = 0;
    });

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();

    final duration = _formatDuration(_recordingDuration);

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Add voice message to Firestore
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'text': 'Voice message',
        'duration': duration,
        'senderId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'isVoice': true,
      });

      // Update the last message time
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isRecording = false;
      });

      _scrollToBottom();
    } catch (e) {
      print('Error sending voice message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send voice message: $e')),
      );

      setState(() {
        _isRecording = false;
      });
    }
  }

  void _cancelRecording() {
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C624A),
        elevation: 0,
        leadingWidth: 30,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(_otherUserImage),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _otherUserName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _isOtherUserOnline ? 'Online' : _lastSeen,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.white70,
                    ),
                  ),
                ],
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
      ),
      body: Column(
        children: [
          // Chat messages with improved error handling
          Expanded(
            child: FutureBuilder<bool>(
              future: _validateChatExists(),
              builder: (context, validateSnapshot) {
                if (validateSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (validateSnapshot.hasError || validateSnapshot.data == false) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 72,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'This conversation is no longer available',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Go back to messages'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFECE5DD),
                    image: DecorationImage(
                      image: AssetImage('assets/chat_bg.png'),
                      fit: BoxFit.cover,
                      opacity: 0.2,
                    ),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getChatMessagesStream(),
                    builder: (context, snapshot) {
                      // Show appropriate loading/error states
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Loading messages...'),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        // Check for index error
                        final error = snapshot.error.toString();
                        if (error.contains('index') ||
                            error.contains('failed-precondition')) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.view_list,
                                    size: 64, color: Colors.orange),
                                const SizedBox(height: 16),
                                const Text(
                                  'Database Index Required',
                                  style: TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'This message view requires a database index. Please try again or contact support.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {}); // Refresh the page
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        // Other error
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 48, color: Colors.red),
                              const SizedBox(height: 12),
                              Text(
                                'Error loading messages: ${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {}); // Refresh the page
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 72,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet.\nStart a conversation!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Type a message below to begin chatting with $_otherUserName',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Auto-scroll to bottom when new messages arrive
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                        _markConversationAsRead();
                      });

                      // Build message list
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final doc = snapshot.data!.docs[index];
                          final data = doc.data() as Map<String, dynamic>;

                          final senderId = data['senderId'] as String;
                          final currentUser = _auth.currentUser;

                          if (currentUser == null) return const SizedBox();

                          final isSentByMe = senderId == currentUser.uid;
                          final isVoice = data['isVoice'] as bool? ?? false;

                          DateTime messageTime;
                          if (data['timestamp'] != null) {
                            final timestamp = data['timestamp'] as Timestamp;
                            messageTime = timestamp.toDate();
                          } else {
                            messageTime = DateTime.now();
                          }

                          return _buildMessageBubble(
                            isSentByMe: isSentByMe,
                            isVoice: isVoice,
                            message: data,
                            messageTime: messageTime,
                            messageId: doc.id,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Recording indicator
          if (_isRecording)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.mic, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('Recording... ${_formatDuration(_recordingDuration)}'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.stop, color: Colors.red),
                    onPressed: _stopRecording,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: _cancelRecording,
                  ),
                ],
              ),
            ),

          // Message input
          if (!_isRecording)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (text) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _messageController.text.trim().isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFF8C624A)),
                          onPressed: _sendMessage,
                        )
                      : GestureDetector(
                          onLongPress: _startRecording,
                          child: const Icon(Icons.mic, color: Color(0xFF8C624A)),
                        ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required bool isSentByMe,
    required bool isVoice,
    required Map<String, dynamic> message,
    required DateTime messageTime,
    required String messageId,
  }) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            padding: EdgeInsets.all(isVoice ? 8 : 12),
            decoration: BoxDecoration(
              color: isSentByMe ? const Color(0xFFDCF8C6) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isVoice
                    ? _buildVoiceMessage(message, isSentByMe)
                    : Text(
                        message['text'] as String,
                        style: const TextStyle(fontSize: 16),
                      ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(messageTime),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (isSentByMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message['read'] as bool
                            ? Icons.done_all
                            : Icons.done,
                        size: 14,
                        color: message['read'] as bool
                            ? Colors.blue
                            : Colors.grey[600],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceMessage(Map<String, dynamic> message, bool isSentByMe) {
    final duration = message['duration'] as String? ?? '0:00';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.play_circle_fill,
          color: isSentByMe ? Colors.green[700] : const Color(0xFF8C624A),
          size: 32,
        ),
        const SizedBox(width: 8),
        Container(
          width: 100,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CustomPaint(
              painter: WaveformPainter(
                color: isSentByMe ? Colors.green[700] : const Color(0xFF8C624A),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          duration,
          style: TextStyle(
            color: isSentByMe ? Colors.green[700] : const Color(0xFF8C624A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inDays > 7) {
      String day = lastSeen.day.toString().padLeft(2, '0');
      String month = lastSeen.month.toString().padLeft(2, '0');
      String year = (lastSeen.year % 100).toString().padLeft(2, '0');
      return '$day/$month/$year';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  Future<bool> _validateChatExists() async {
    try {
      final chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .get()
          .timeout(const Duration(seconds: 5));

      return chatDoc.exists;
    } catch (e) {
      print('Error validating chat: $e');
      return false;
    }
  }

  // Improved method to ensure the chat messages stream updates in real time
  Stream<QuerySnapshot> _getChatMessagesStream() {
    try {
      final messagesStream = FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots();
          
      // Listen for new messages and mark them as read automatically
      messagesStream.listen((snapshot) {
        if (snapshot.docChanges.isNotEmpty) {
          _handleNewMessages(snapshot.docChanges);
        }
      }, onError: (e) {
        print('Error in messages stream: $e');
      });
      
      return messagesStream;
    } catch (e) {
      print('Error creating message stream: $e');
      return const Stream<QuerySnapshot>.empty();
    }
  }
  
  // Handle new messages to mark them as read
  void _handleNewMessages(List<DocumentChange> docChanges) {
    final user = _auth.currentUser;
    if (user == null) return;
    
    // Get only added messages from the other user
    final newMessages = docChanges
        .where((change) => change.type == DocumentChangeType.added)
        .map((change) => change.doc)
        .where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['senderId'] == widget.otherUserId && data['read'] == false;
        })
        .toList();
        
    if (newMessages.isEmpty) return;
    
    // Mark messages as read
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in newMessages) {
      batch.update(doc.reference, {'read': true});
    }
    
    batch.commit().then((_) {
      print('Marked ${newMessages.length} new messages as read');
    }).catchError((e) {
      print('Error marking messages as read: $e');
    });
  }
}

// Custom painter for voice message waveform
class WaveformPainter extends CustomPainter {
  final Color? color;

  WaveformPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.blue
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final random = Random(42); // Fixed seed for consistent waveform

    final width = size.width;
    final height = size.height;
    const lineCount = 20;
    final lineSpacing = width / lineCount;

    for (int i = 0; i < lineCount; i++) {
      final x = i * lineSpacing;
      final lineHeight = height * (0.1 + 0.8 * random.nextDouble());

      final startY = (height - lineHeight) / 2;
      final endY = startY + lineHeight;

      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
