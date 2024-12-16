import 'package:eventy/core/providers/auth_provider.dart';
import 'package:eventy/features/authentication/widgets/register_form.dart';
import 'package:eventy/shared/widgets/customDialog.dart';
import 'package:eventy/shared/widgets/toast.dart';
import 'package:eventy/features/authentication/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSigningUp = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _isSigningUp = true;
    });

    try {
      if (_emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _usernameController.text.isEmpty) {
        showToast(message: "Please fill in all fields");
        return;
      }
      
      final user = await authProvider.register(_emailController.text, _passwordController.text, _usernameController.text);


      if (user != null) {
        showToast(message: "User successfully created");
        showCustomDialog(
          greeting: 'Thank you for your registration!',
          dest: '/home',
          btn: 'Proceed to the app',
          message:
              "We're glad you're here! Before you start exploring, we just sent you the email confirmation.",
          url:
              'https://lottie.host/569afe3d-0778-48d0-bff1-c12f1bd62fe4/IITVMjfZgx.json',
          context: context,
        );
      } else {
        showToast(message: "Failed to create user");
      }
    } catch (e) {
      showToast(message: "Registration failed: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isSigningUp = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 124, 123, 123),
      body: SafeArea(
        child: Column(
          children: [
            /*Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.green),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),*/
            const SizedBox(height: 5),
            Lottie.network(
              'https://lottie.host/a1cfb1cc-982e-4bc1-9841-64f773f8d076/ucpvOzo0g8.json',
              height: 200.0,
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 194, 194, 194),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Create New Account",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      child: RegistrationForm(
                        emailController: _emailController,
                        usernameController: _usernameController,
                        passwordController: _passwordController,
                        isSigningUp: _isSigningUp,
                        onRegister: _signUp,
                        onNavigateToLogin: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
