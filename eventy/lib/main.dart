import 'package:eventy/core/providers/auth_provider.dart';
import 'package:eventy/core/providers/chat_provider.dart';
import 'package:eventy/core/providers/event_details_provider.dart';
import 'package:eventy/core/providers/request_service_provider.dart';
import 'package:eventy/core/providers/service_provider.dart';
import 'package:eventy/core/providers/user_profile_provider.dart';
import 'package:eventy/core/services/event_service.dart';
import 'package:eventy/core/services/request_service_repository.dart';
import 'package:eventy/features/authentication/screens/login.dart';
import 'package:eventy/features/navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async{
  const mockEventId = 'mockEventId';
  const mockUserId = 'mockUserId';
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => EventDetailsProvider(eventService: EventService(), eventId: mockEventId, userId: mockUserId)),
        ChangeNotifierProvider(create: (_) => RequestServiceProvider(RequestServiceRepository())),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        //ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      theme: ThemeData(scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255)),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return authProvider.isLoggedIn ? const Navigation_Bar() : const Login();
        },
      )
    );
  }
}