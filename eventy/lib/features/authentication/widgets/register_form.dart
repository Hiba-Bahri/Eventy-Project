import 'package:flutter/material.dart';

class RegistrationForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isSigningUp;
  final VoidCallback onRegister;
  final VoidCallback onNavigateToLogin;

  const RegistrationForm({
    super.key,
    required this.emailController,
    required this.usernameController,
    required this.passwordController,
    required this.isSigningUp,
    required this.onRegister,
    required this.onNavigateToLogin,
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

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: isSigningUp ? null : onRegister,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Center(
        child: isSigningUp
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "REGISTER",
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
      onTap: onNavigateToLogin,
      child: const Text(
        "Already have an account? Login here",
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
              _buildTextField(controller: usernameController, label: "Name"),
              const SizedBox(height: 16),
              _buildTextField(
                controller: passwordController,
                label: "Password",
                isPassword: true,
              ),
              const SizedBox(height: 20),
              _buildRegisterButton(),
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
