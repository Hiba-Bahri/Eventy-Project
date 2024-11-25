import 'package:eventy/core/providers/auth_provider.dart';
import 'package:eventy/features/authentication/screens/login.dart';
import 'package:eventy/shared/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    bool _isSigningOut = false;

    Future<void> _handleSignOut() async {
      setState(() {
        _isSigningOut = true;
      });

      try {
        await authProvider.logout();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Login(),
          ),
        );
      } catch (e) {
        showToast(message:"Sign-out failed: $e");
      } finally {
        setState(() {
          _isSigningOut = false;
        });
      }
    }

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async => {await _handleSignOut()},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Center(
            child: _isSigningOut
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Sign Out",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
