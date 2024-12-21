import 'package:eventy/core/providers/auth_provider.dart';
import 'package:eventy/core/providers/notification_provider.dart';
import 'package:eventy/features/authentication/screens/login.dart';
import 'package:eventy/features/conversations_List.dart';
import 'package:eventy/features/event_management/screens/schedule_event.dart';
import 'package:eventy/features/home/screens/home.dart';
import 'package:eventy/features/notifications/notifications_page.dart';
import 'package:eventy/features/profile/screens/profile.dart';
import 'package:eventy/features/user_events/screens/user_events.dart';
import 'package:eventy/features/user_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Navigation_Bar extends StatefulWidget {
  const Navigation_Bar({super.key});

  @override
  _Navigation_Bar createState() => _Navigation_Bar();
}

class _Navigation_Bar extends State<Navigation_Bar> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const Home(),
    const UserEvents(),
    const ScheduleEvent(),
    const UserServices(),
    const ConversationsList(),
  ];

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

   @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, NotificationProvider>(
      builder: (context, authProvider, notificationProvider, _) {
        if (!authProvider.isLoggedIn) {
          return const Login();
        }

        // Listen to notifications for the logged-in user
        notificationProvider.listenToNotifications(authProvider.user!.uid);

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
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications),
                    if (notificationProvider.unreadNotificationsCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                          child: Text(
                            '${notificationProvider.unreadNotificationsCount}',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  NotificationsPage(),
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
                      _buildNavItem(Icons.wechat_outlined, 4),
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
