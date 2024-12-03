import 'package:eventy/shared/widgets/customDialog.dart';
import 'package:flutter/material.dart';
import 'package:slider_button/slider_button.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSigningIn;
  final VoidCallback onLogin;
  final VoidCallback onNavigateToRegister;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isSigningIn,
    required this.onLogin,
    required this.onNavigateToRegister,
  });

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }


  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: isSigningIn ? null : onLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Center(
        child: isSigningIn
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Login",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

    Widget _buildLoginLink() {
    return GestureDetector(
      onTap: onNavigateToRegister,
      child: const Text(
        "Don't have an account? Register here",
        style: TextStyle(
          fontSize: 14,
          color: Color.fromARGB(255, 194, 194, 194),
        ),
      ),
    );
  }

    Widget _sliderBtn() {
    return Row(
      children: [
        SliderButton(action: () async {
          return true;
        },
          width: 160,
          buttonColor: Colors.green,
          backgroundColor: const Color.fromARGB(255, 194, 194, 194),
          highlightedColor: Colors.white,
          baseColor: Colors.green,
        ),
        const Text(
          "Remember me",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 194, 194, 194),
          ),
        ),
      ],
    );
  }

  Widget _forgotPassword(BuildContext context){
    return GestureDetector(
      onTap: () {
        showCustomDialog(greeting: 'Thank you for your registration!', dest: '/home', btn: 'Proceed to the app', message: "We're glad you're here! Before you start exploring, we just sent you the email confirmation.", url: 'https://lottie.host/569afe3d-0778-48d0-bff1-c12f1bd62fe4/IITVMjfZgx.json' ,context:  context);
      },
      child: const Text(
        "Forgot password?",
        style: TextStyle(
          fontSize: 14,
          color: Color.fromARGB(255, 194, 194, 194),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildTextField(controller: emailController, label: "Email"),
              const SizedBox(height: 16),
              _buildTextField(
                controller: passwordController,
                label: "Password",
                isPassword: true,
              ),
              const SizedBox(height: 16),
              const Row(
                  children: [
                    //_sliderBtn(),
                    //_forgotPassword(context)
                  ],
                ),
              const SizedBox(height: 20),
              _buildLoginButton(),
              const SizedBox(height: 20),
              _buildLoginLink(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

}
