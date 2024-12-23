import 'package:eventy/core/providers/auth_provider.dart';
import 'package:eventy/core/providers/chat_provider.dart';
import 'package:eventy/features/authentication/screens/login.dart';
import 'package:eventy/features/chat/screens/conversations_List.dart';
import 'package:eventy/features/event_management/screens/schedule_event.dart';
import 'package:eventy/features/home/screens/home.dart';
import 'package:eventy/features/notifications/my_offers.dart';
import 'package:eventy/features/profile/screens/profile.dart';
import 'package:eventy/features/user_events/screens/user_events.dart';
import 'package:eventy/features/user_services/screens/user_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Navigation_Bar extends StatefulWidget {
  const Navigation_Bar({super.key});

  @override
  _Navigation_Bar createState() => _Navigation_Bar();
}

class _Navigation_Bar extends State<Navigation_Bar> {
  int _selectedIndex = 0;
  int _unreadMessages = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const Home(),
    const UserEvents(),
    const ScheduleEvent(),
    const UserServices(),
    const ConversationsList(),
  ];

@override
void initState() {
  super.initState();
  _fetchUnreadMessages();
}

Future<void> _fetchUnreadMessages() async {
  final chatService = Provider.of<ChatProvider>(context, listen: false);
  final unreadCount = await chatService.getTotalUnreadMessages();
  setState(() {
    _unreadMessages = unreadCount;
  });
}


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding:
            EdgeInsets.symmetric(vertical: _selectedIndex == index ? 8.0 : 4.0),
        child: Icon(
          icon,
          size: _selectedIndex == index ? 30.0 : 24.0,
          color: _selectedIndex == index ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  
  Widget _buildChatIconWithBadge() {
  final chatService = Provider.of<ChatProvider>(context, listen: false);

  return StreamBuilder<int>(
    stream: chatService.getTotalUnreadMessagesStream(),
    initialData: _unreadMessages,
    builder: (context, snapshot) {
      final unreadMessages = snapshot.data ?? 0;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () => _onItemTapped(4),
            child: Icon(
              Icons.wechat_outlined,
              size: _selectedIndex == 4 ? 30.0 : 24.0,
              color: _selectedIndex == 4 ? Colors.green : Colors.grey,
            ),
          ),
          if (unreadMessages > 0)
            Positioned(
              right: -5,
              top: -5,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadMessages.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isLoggedIn) {
          return const Login();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Flutter App'),
            backgroundColor: Colors.green,
            leading: IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfilePage(),
                  ),
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white,),    
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  const MyOffers(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          bottomNavigationBar: Stack(
            children: [
              BottomAppBar(
                shape: const CircularNotchedRectangle(),
                notchMargin: 6.0,
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home_filled, 0),
                      _buildNavItem(Icons.event_note, 1),
                      const SizedBox(width: 40),
                      _buildNavItem(Icons.cases_rounded, 3),
                      _buildChatIconWithBadge(),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: MediaQuery.of(context).size.width / 2 - 28,
                child: FloatingActionButton(
                  onPressed: () => _onItemTapped(2),
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
