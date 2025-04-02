import 'package:flutter/material.dart';
import 'package:Farmingapp/farmer_dashboard.dart';
import 'package:Farmingapp/profile_page.dart';
import 'package:Farmingapp/cart_page.dart';
import 'package:Farmingapp/chat_detail_page.dart';
import 'package:Farmingapp/seller_dashboard.dart';
import 'package:Farmingapp/seller_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // Add this import for StreamSubscription

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _conversations = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _userType = '';
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription? _chatSubscription;
  
  @override
  void initState() {
    super.initState();
    _getUserType();
    _setupChatListener();
    
    // Set user as online when opening the chat page
    _updateUserOnlineStatus(true);
  }
  
  @override
  void dispose() {
    // Cancel subscription to prevent memory leaks
    _chatSubscription?.cancel();
    
    // Set user as offline when leaving the chat page
    _updateUserOnlineStatus(false);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _updateUserOnlineStatus(bool isOnline) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'isOnline': isOnline,
              'lastSeenAt': isOnline ? null : FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  Future<void> _getUserType() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        setState(() {
          _userType = userDoc.data()?['userType'] ?? '';
        });
      }
    }
  }
  
  void _setupChatListener() {
    setState(() {
      _isLoading = true;
    });
    
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _conversations = [];
      });
      return;
    }
    
    try {
      // Get real-time updates for chat documents
      _chatSubscription = FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: user.uid)
          .snapshots()
          .listen((snapshot) {
            _processConversations(snapshot.docs);
          }, onError: (error) {
            print('Error in chat stream: $error');
            setState(() {
              _isLoading = false;
            });
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading conversations: $error')),
              );
            }
          });
    } catch (e) {
      print('Error setting up chat listener: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadConversations() async {
    // Cancel existing subscription if any
    _chatSubscription?.cancel();
    
    // Set up the listener again
    _setupChatListener();
  }

  Future<void> _createNewChat(String otherUserId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      print('Creating or finding chat with user: $otherUserId');
      // Check if a chat already exists
      final existingChatsQuery = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: user.uid)
          .get();
      
      String chatId = '';
      
      for (var doc in existingChatsQuery.docs) {
        final participants = doc['participants'] as List<dynamic>;
        if (participants.contains(otherUserId)) {
          chatId = doc.id;
          print('Found existing chat: $chatId');
          break;
        }
      }
      
      // If no chat exists, create a new one
      if (chatId.isEmpty) {
        print('Creating new chat...');
        final newChatRef = FirebaseFirestore.instance.collection('chats').doc();
        
        await newChatRef.set({
          'participants': [user.uid, otherUserId],
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessageTime': FieldValue.serverTimestamp(),
        });
        
        print('New chat created with ID: ${newChatRef.id}');
        chatId = newChatRef.id;
      }
      
      // Navigate to the chat detail page
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(chatId: chatId, otherUserId: otherUserId),
          ),
        ).then((_) => _loadConversations());
      }
      
    } catch (e) {
      print('Error creating new chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create chat: $e')),
      );
    }
  }

  Future<void> _showNewChatDialog() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      // Get all users with a different user type from the current user
      print('Loading potential chat partners...');
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isNotEqualTo: _userType)
          .get();
      
      print('Found ${usersSnapshot.docs.length} potential chat partners');
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Start New Chat'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: usersSnapshot.docs.length,
              itemBuilder: (context, index) {
                final userData = usersSnapshot.docs[index].data();
                final userId = usersSnapshot.docs[index].id;
                
                final userName = userData['username'] ?? userData['name'] ?? 'User';
                final userType = userData['userType'] ?? '';
                print('User option: $userName ($userType)');
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(userData['profileImage'] ?? 'assets/3d_avatar_12.png'),
                    backgroundColor: Colors.grey[300],
                  ),
                  title: Text(userName),
                  subtitle: Text(userType),
                  onTap: () {
                    Navigator.pop(context);
                    _createNewChat(userId);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
      
    } catch (e) {
      print('Error showing new chat dialog: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: $e')),
      );
    }
  }

  Future<void> _processConversations(List<QueryDocumentSnapshot> chatDocs) async {
    if (!mounted) return;
    
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
        _conversations = [];
      });
      return;
    }
    
    try {
      print('Processing ${chatDocs.length} chat documents...');
      List<Map<String, dynamic>> conversations = [];
      List<Future> futures = [];
      
      for (var chatDoc in chatDocs) {
        try {
          final chatData = chatDoc.data() as Map<String, dynamic>;
          
          // Get the other participant's ID
          final List<dynamic> participants = chatData['participants'] ?? [];
          if (participants.length < 2) {
            print('Invalid participants list in chat ${chatDoc.id}: $participants');
            continue;
          }
          
          final otherUserId = participants.firstWhere(
            (id) => id != currentUser.uid, 
            orElse: () => ''
          );
          
          if (otherUserId.isEmpty) {
            print('Could not find other user in participants: $participants');
            continue;
          }
          
          // Create a Future for each chat to process in parallel
          futures.add(
            _processChat(chatDoc.id, chatData, otherUserId, currentUser.uid)
              .then((conversationData) {
                if (conversationData != null) {
                  conversations.add(conversationData);
                }
              })
          );
        } catch (docError) {
          print('Error processing chat document ${chatDoc.id}: $docError');
          // Skip this document and continue
        }
      }
      
      // Wait for all futures to complete
      await Future.wait(futures);
      
      // Sort conversations by timestamp (most recent first)
      conversations.sort((a, b) {
        final aTime = a['timestamp'] as DateTime;
        final bTime = b['timestamp'] as DateTime;
        return bTime.compareTo(aTime); // Descending order
      });
      
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
      
      print('Processed ${conversations.length} conversations successfully');
    } catch (e) {
      print('Global error in _processConversations: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<Map<String, dynamic>?> _processChat(
    String chatId, 
    Map<String, dynamic> chatData,
    String otherUserId,
    String currentUserId
  ) async {
    try {
      // Get the other user's information
      final otherUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get()
          .timeout(const Duration(seconds: 5)); // Increase timeout for slower networks
      
      if (!otherUserDoc.exists) {
        print('Other user document does not exist: $otherUserId');
        
        // Create a placeholder user if the user document doesn't exist
        // This is needed for demo data with dummy seller IDs
        if (otherUserId == "seller123") {
          return {
            'id': chatId,
            'name': 'Demo Seller',
            'userType': 'Seller',
            'lastMessage': chatData['lastMessage'] ?? 'Start a conversation',
            'timestamp': chatData['lastMessageTime'] != null 
                ? (chatData['lastMessageTime'] as Timestamp).toDate() 
                : DateTime.now(),
            'unread': 0,
            'image': 'assets/3d_avatar_12.png',
            'isVoice': false,
            'isOnline': false,
            'userId': otherUserId,
          };
        }
        
        return null;
      }
      
      final otherUserData = otherUserDoc.data() ?? {};
      final otherUserName = otherUserData['username'] ?? otherUserData['name'] ?? 'User';
      
      // Get unread messages count with simplified query
      QuerySnapshot unreadQuery;
      try {
        unreadQuery = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where('senderId', isEqualTo: otherUserId)
            .where('read', isEqualTo: false)
            .get();
        
        // Use actual count from query result
        final int unreadCount = unreadQuery.docs.length;
        
        // Get last message with simplified query
        final lastMessagesQuery = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
        
        String lastMessage = 'Start a conversation';
        bool isVoice = false;
        DateTime timestamp = chatData['lastMessageTime'] != null 
            ? (chatData['lastMessageTime'] as Timestamp).toDate() 
            : DateTime.now();
        
        if (lastMessagesQuery.docs.isNotEmpty) {
          final lastMessageData = lastMessagesQuery.docs.first.data();
          lastMessage = lastMessageData['isVoice'] == true
              ? 'Voice message (0:${lastMessageData['duration'] ?? '00'})' 
              : lastMessageData['text'] ?? 'Message';
          isVoice = lastMessageData['isVoice'] == true;
          
          if (lastMessageData['timestamp'] != null) {
            timestamp = (lastMessageData['timestamp'] as Timestamp).toDate();
          }
        }
        
        // Return conversation data
        return {
          'id': chatId,
          'name': otherUserName,
          'userType': otherUserData['userType'] ?? '',
          'lastMessage': lastMessage,
          'timestamp': timestamp,
          'unread': unreadCount,
          'image': otherUserData['profileImage'] ?? 'assets/3d_avatar_12.png',
          'isVoice': isVoice,
          'isOnline': otherUserData['isOnline'] ?? false,
          'userId': otherUserId,
        };
      } catch (e) {
        print('Error getting messages for chat $chatId: $e');
        
        // Return basic conversation data on error
        return {
          'id': chatId,
          'name': otherUserName,
          'userType': otherUserData['userType'] ?? '',
          'lastMessage': chatData['lastMessage'] ?? 'Start a conversation',
          'timestamp': chatData['lastMessageTime'] != null 
              ? (chatData['lastMessageTime'] as Timestamp).toDate() 
              : DateTime.now(),
          'unread': 0,
          'image': otherUserData['profileImage'] ?? 'assets/3d_avatar_12.png',
          'isVoice': false,
          'isOnline': otherUserData['isOnline'] ?? false,
          'userId': otherUserId,
        };
      }
    } catch (e) {
      print('Error processing chat $chatId: $e');
      
      // Handle demo data (fallback for errors)
      if (otherUserId == "seller123") {
        return {
          'id': chatId,
          'name': 'Demo Seller',
          'userType': 'Seller',
          'lastMessage': chatData['lastMessage'] ?? 'Start a conversation',
          'timestamp': chatData['lastMessageTime'] != null 
              ? (chatData['lastMessageTime'] as Timestamp).toDate() 
              : DateTime.now(),
          'unread': 0,
          'image': 'assets/3d_avatar_12.png',
          'isVoice': false,
          'isOnline': false,
          'userId': otherUserId,
        };
      }
      
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if user is seller or farmer to show correct bottom navigation
    final isSeller = _userType == 'Seller';
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C624A),
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 22, 
            fontWeight: FontWeight.bold, 
            color: Colors.white
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Show search field
              showSearch(
                context: context, 
                delegate: ChatSearchDelegate(_conversations, (conversation) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailPage(
                        chatId: conversation['id'] as String,
                        otherUserId: conversation['userId'] as String,
                      ),
                    ),
                  ).then((_) => _loadConversations());
                }),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadConversations,
          ),
        ],
      ),
      
      body: FutureBuilder<bool>(
        future: _ensureFirestoreConnection(),
        builder: (context, connectionSnapshot) {
          // Handle connection checking state
          if (connectionSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Connecting to messaging service...'),
                ],
              ),
            );
          }
          
          // Handle connection error
          if (connectionSnapshot.hasError || connectionSnapshot.data == false) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Could not connect to the messaging service',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });
                      _loadConversations();
                    },
                  ),
                ],
              ),
            );
          }
          
          // Return the conversations list or appropriate message
          return _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _conversations.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadConversations,
                      child: ListView.separated(
                        itemCount: _conversations.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final conversation = _conversations[index];
                          return _buildChatTile(conversation);
                        },
                      ),
                    );
        },
      ),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD3E597),
        onPressed: _showNewChatDialog,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
      
      bottomNavigationBar: isSeller
          // Seller bottom navigation bar (3 items) - Updated order
          ? BottomNavigationBar(
              backgroundColor: const Color(0xFF592507),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              currentIndex: 0, // Messages tab is selected
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outlined),
                  activeIcon: Icon(Icons.chat_bubble),
                  label: 'Messages',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              onTap: (index) {
                if (index == 0) {
                  // Already on chat page
                } else if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SellerDashboard()),
                  );
                } else if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SellerProfilePage()),
                  );
                }
              },
            )
          // Farmer bottom navigation bar (4 items)
          : BottomNavigationBar(
              backgroundColor: const Color(0xFF592507),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              currentIndex: 2, // Messages tab
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_outlined),
                  activeIcon: Icon(Icons.shopping_cart),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outlined),
                  activeIcon: Icon(Icons.chat_bubble),
                  label: 'Messages',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outlined),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const FarmerDashboard()),
                  );
                } else if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );
                } else if (index == 2) {
                  // Already on chat page
                } else if (index == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                }
              },
            ),
    );
  }
  
  Stream<QuerySnapshot> _getChatStream() {
    final user = _auth.currentUser;
    if (user == null) {
      // Return empty stream if no user
      return const Stream<QuerySnapshot>.empty();
    }
    
    try {
      // Simple query that doesn't require complex indexing
      return FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: user.uid)
          .snapshots();
    } catch (e) {
      print('Error creating chat stream: $e');
      // Return empty stream on error
      return const Stream<QuerySnapshot>.empty();
    }
  }
  
  Widget _buildIndexErrorMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.view_list, size: 64, color: Colors.orange[300]),
            const SizedBox(height: 16),
            const Text(
              'Database Index Required',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'This search requires an index in Firestore. Please contact the app administrator to create the necessary index.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Load Basic Conversations'),
              onPressed: () {
                _loadConversations();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<bool> _ensureFirestoreConnection() async {
    try {
      // Try a simple Firestore operation to verify connection
      await FirebaseFirestore.instance
          .collection('connection_test')
          .doc('test')
          .set({'timestamp': FieldValue.serverTimestamp()});
      return true;
    } catch (e) {
      print('Firestore connection error: $e');
      return false;
    }
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize:18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start chatting with farmers or sellers',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Start a new chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD3E597),
              foregroundColor: Colors.white,
            ),
            onPressed: _showNewChatDialog,
          ),
        ],
      ),
    );
  }
  
  Widget _buildChatTile(Map<String, dynamic> conversation) {
    final DateTime timestamp = conversation['timestamp'] as DateTime;
    final String timeString = _formatChatTime(timestamp);
    final int unreadCount = conversation['unread'] as int;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage(conversation['image'] as String),
            backgroundColor: Colors.grey[300],
          ),
          if (conversation['isOnline'] as bool)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation['name'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            conversation['userType'] as String,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          if (conversation['isVoice'] as bool)
            const Icon(Icons.mic, size: 16, color: Colors.grey)
          else 
            const Icon(Icons.check, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              conversation['lastMessage'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeString,
            style: TextStyle(
              fontSize: 12,
              color: unreadCount > 0 ? const Color(0xFF8C624A) : Colors.grey,
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF8C624A),
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const SizedBox(height: 16),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              chatId: conversation['id'] as String,
              otherUserId: conversation['userId'] as String,
            ),
          ),
        ).then((_) => _loadConversations());
      },
    );
  }
  
  String _formatChatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (dateToCheck == today) {
      // Format as HH:MM instead of using intl package
      String hour = timestamp.hour.toString().padLeft(2, '0');
      String minute = timestamp.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      // Format as dd/mm/yy instead of using intl package
      String day = timestamp.day.toString().padLeft(2, '0');
      String month = timestamp.month.toString().padLeft(2, '0');
      String year = (timestamp.year % 100).toString().padLeft(2, '0');
      return '$day/$month/$year';
    }
  }
}

// Search functionality for chats
class ChatSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> conversations;
  final Function(Map<String, dynamic>) onSelect;
  
  ChatSearchDelegate(this.conversations, this.onSelect);
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }
  
  Widget _buildSearchResults() {
    final filteredConversations = conversations.where((conv) {
      final name = conv['name'] as String;
      final userType = conv['userType'] as String;
      final lastMessage = conv['lastMessage'] as String;
      
      return name.toLowerCase().contains(query.toLowerCase()) ||
             userType.toLowerCase().contains(query.toLowerCase()) ||
             lastMessage.toLowerCase().contains(query.toLowerCase());
    }).toList();
    
    return ListView.builder(
      itemCount: filteredConversations.length,
      itemBuilder: (context, index) {
        final conv = filteredConversations[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(conv['image'] as String),
          ),
          title: Text(conv['name'] as String),
          subtitle: Text(conv['userType'] as String),
          onTap: () {
            close(context, null);
            onSelect(conv);
          },
        );
      },
    );
  }
}
