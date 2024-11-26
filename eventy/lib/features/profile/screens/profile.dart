import 'package:eventy/core/providers/auth_provider.dart';
import 'package:eventy/features/authentication/screens/login.dart';
import 'package:eventy/shared/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isExpanded = false;

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
      showToast(message: "Sign-out failed: $e");
    } finally {
      setState(() {
        _isSigningOut = false;
      });
    }
  }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('User Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const UserProfileHeader(
              name: 'John Doe',
              phone: '+123 456 7890',
              email: 'johndoe@example.com',
              address: '123 Main Street, City, Country',
            ),
            const SizedBox(height: 16),
            UserProfileActions(
              isExpanded: isExpanded,
              onToggleExpanded: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              const UserProfileForm(),
            ],
            ElevatedButton(
          onPressed: () async => {await _handleSignOut()},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 79, 48),
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
          ],
        ),
      ),
    );
  }
}

class UserProfileHeader extends StatelessWidget {
  final String name;
  final String phone;
  final String email;
  final String address;

  const UserProfileHeader({
    Key? key,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username: $name',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text('Phone: $phone'),
        const SizedBox(height: 8),
        Text('Email: $email'),
        const SizedBox(height: 8),
        Text('Address: $address'),
      ],
    );
  }
}

class UserProfileActions extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  const UserProfileActions({
    Key? key,
    required this.isExpanded,
    required this.onToggleExpanded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onPressed: onToggleExpanded,
        child: Text(isExpanded
            ? 'Cancel Becoming Service Provider'
            : 'Become Service Provider'),
      ),
    );
  }
}

class UserProfileForm extends StatefulWidget {
  const UserProfileForm({Key? key}) : super(key: key);

  @override
  _UserProfileFormState createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  final _serviceTypeController = TextEditingController();
  final _experienceController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _experienceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submitted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {




    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _serviceTypeController,
          decoration: InputDecoration(
            labelText: 'Service Type',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _experienceController,
          decoration: InputDecoration(
            labelText: 'Experience (in years)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onPressed: _submitForm,
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }


}


      /*body: Center(
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
      ),*/