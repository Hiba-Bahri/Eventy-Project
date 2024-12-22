import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/core/providers/auth_provider.dart';
import 'package:eventy/features/authentication/screens/login.dart';
import 'package:eventy/shared/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isExpanded = false;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  bool isEditing = false;

  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _fetchUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try{
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null){
        final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.user!.uid)
          .get();

        setState(() {
          userData = userDoc.data();
          _usernameController.text = userData?['username'] ?? '';
          _phoneController.text = userData?['phone'] ?? '';
          _addressController.text = userData?['address'] ?? '';
          isLoading = false;
        });
      }
    }catch(e){
      setState(() {
        isLoading = false;
      });
      showToast(message: "Failed to fetch user data: $e");
    }
  }

  Future<void> _saveProfileChanges() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authProvider.user!.uid)
            .update({
          'username': _usernameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
        });

        // Refresh user data
        await _fetchUserData();

        setState(() {
          isEditing = false;
        });

        showToast(message: "Profile updated successfully");
      }
    } catch (e) {
      showToast(message: "Failed to update profile: $e");
    }
  }
  
  Future<void> handleSignOut(AuthProvider authProvider) async {
    setState(() {
      isLoading = true;
    });

    try {
      await authProvider.logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Login(),
        ),
      );
    } catch (e) {
      showToast(message: "Sign-out failed: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    required String confirmText,
  }) async {
      final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false),
           child: const Text('No'))
           ,
           ElevatedButton(onPressed: (){
            Navigator.of(context).pop(true);
           }, child: Text(confirmText)
           )
        ],
      ));
      if (result == true){
        onConfirm();
      }
  }

  Future<void> toggleServiceProviderStatus(bool status) async{
    try{
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if(authProvider.user != null){
          await FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.user!.uid)
          .update({
            'is_service_provider': status,
          });
          await _fetchUserData();
          showToast(message: status? "You are now a service provider" : "You are no longer a service provider");
        }
    }catch(e){
      showToast(message: "Failed to update status $e");
    }
  }



  


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green[600],
        title: const Text(
          'User Profile', 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _saveProfileChanges,
            ),
        ],
      ),
      body: isLoading
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          )
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: !isEditing
                        ? UserProfileHeader(
                            name: userData?['username'] ?? 'N/A',
                            phone: userData?['phone'] ?? 'N/A',
                            email: userData?['email'] ?? 'N/A',
                            address: userData?['address'] ?? 'N/A',
                          )
                        : EditableProfileHeader(
                            usernameController: _usernameController,
                            phoneController: _phoneController,
                            addressController: _addressController,
                            email: userData?['email'] ?? 'N/A',
                          ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Become Service Provider Section
                  UserProfileActions(
                    isServiceProvider: userData?['is_service_provider']?? false,
                    onToggleServiceProvider: () {
                      final newStatus = !(userData?['is_service_provider'] ?? false);
                      showConfirmDialog(
                        context: context,
                        title: newStatus
                            ? 'Become a Service Provider'
                            : 'Cancel Becoming a Service Provider',
                        message: newStatus
                            ? 'Are you sure you want to become a service provider?'
                            : 'Are you sure you want to cancel becoming a service provider?',
                        confirmText: 'Yes',
                        onConfirm: () => toggleServiceProviderStatus(newStatus),
                      );
                    },
                    onAddService: () => {},
                  ),
                  
                  if (isExpanded) ...[
                    const SizedBox(height: 16),
                    const UserProfileForm(),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  // Sign Out Button
                  ElevatedButton.icon(
                    onPressed: () => handleSignOut(authProvider),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class EditableProfileHeader extends StatelessWidget{
final TextEditingController usernameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final String email;
  
  const EditableProfileHeader({
    super.key,
    required this.usernameController,
    required this.phoneController,
    required this.addressController,
    required this.email,
});
@override
Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: phoneController,
          decoration: InputDecoration(
            labelText: 'Phone',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 8),
        Text('Email: $email', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: addressController,
          decoration: InputDecoration(
            labelText: 'Address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class UserProfileHeader extends StatelessWidget {
  final String name;
  final String phone;
  final String email;
  final String address;

  const UserProfileHeader({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

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
  final bool isServiceProvider;
  final VoidCallback onAddService;
  final VoidCallback onToggleServiceProvider;

  const UserProfileActions({
    super.key,
    required this.isServiceProvider,
    required this.onAddService,
    required this.onToggleServiceProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onToggleServiceProvider,
          style: ElevatedButton.styleFrom(
            backgroundColor: isServiceProvider ? Colors.red : Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text(isServiceProvider
              ? 'Cancel Becoming Service Provider'
              : 'Become Service Provider'),
        ),
      ],
    );
  }
}


class UserProfileForm extends StatefulWidget {
  const UserProfileForm({super.key});

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