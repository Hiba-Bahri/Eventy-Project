import 'package:eventy/core/providers/auth_provider.dart';
import 'package:eventy/core/providers/service_provider.dart';
import 'package:eventy/features/authentication/screens/login.dart';
import 'package:eventy/features/navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
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