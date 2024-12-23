import 'package:eventy/core/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../authentication/screens/login.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/toast.dart';
import '../widgets/editable_profile_header.dart';
import '../widgets/user_profile_header.dart';
import '../widgets/user_profile_actions.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      try {
        await profileProvider.fetchUserData(authProvider.user!.uid);
      } catch (e) {
        showToast(message: e.toString());
      }
    }
  }

  Future<void> handleSignOut(AuthProvider authProvider) async {
    try {
      await authProvider.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        showToast(message: "Sign-out failed: $e");
      }
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    if (result == true) {
      onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<UserProfileProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: profileProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(profileProvider),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        _buildProfileHeader(size, profileProvider),
                        const SizedBox(height: 20),
                        _buildStatsCard(),
                        const SizedBox(height: 20),
                        _buildActionButtons(),
                        const SizedBox(height: 20),
                        if (profileProvider.isServiceProvider)
                          _buildServiceProviderSection(profileProvider, authProvider),
                        const SizedBox(height: 20),
                        _buildSignOutButton(authProvider),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar(UserProfileProvider profileProvider) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          profileProvider.username,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.green[700]!,
                    Colors.green[500]!,
                  ],
                ),
              ),
            ),
            const Positioned(
              right: -50,
              top: -50,
              child: CircleAvatar(
                radius: 130,
                backgroundColor: Colors.white10,
              ),
            ),
            const Positioned(
              left: -30,
              bottom: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white10,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (!profileProvider.isEditing)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: profileProvider.toggleEditing,
          ),
        if (profileProvider.isEditing)
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              try {
                await profileProvider.saveProfileChanges(authProvider.user!.uid);
                showToast(message: "Profile updated successfully");
              } catch (e) {
                showToast(message: e.toString());
              }
            },
          ),
      ],
    );
  }

  Widget _buildProfileHeader(Size size, UserProfileProvider profileProvider) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: !profileProvider.isEditing
          ? UserProfileHeader(
              name: profileProvider.username,
              phone: profileProvider.phone,
              email: profileProvider.email,
              address: profileProvider.address,
            )
          : EditableProfileHeader(
              usernameController: profileProvider.usernameController,
              phoneController: profileProvider.phoneController,
              addressController: profileProvider.addressController,
              email: profileProvider.email,
            ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.event,
            label: 'Events',
            value: '12',
          ),
          _buildStatItem(
            icon: Icons.star,
            label: 'Rating',
            value: '4.8',
          ),
          _buildStatItem(
            icon: Icons.people,
            label: 'Followers',
            value: '256',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.green[600], size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.event_available,
            label: 'My Events',
            onTap: () {
              // Navigate to events
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.notifications,
            label: 'Notifications',
            onTap: () {
              // Navigate to notifications
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.green[600], size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceProviderSection(
    UserProfileProvider profileProvider,
    AuthProvider authProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Provider',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          UserProfileActions(
            isServiceProvider: profileProvider.isServiceProvider,
            onToggleServiceProvider: () {
              final newStatus = !profileProvider.isServiceProvider;
              showConfirmDialog(
                context: context,
                title: newStatus
                    ? 'Become a Service Provider'
                    : 'Cancel Service Provider Status',
                message: newStatus
                    ? 'Are you sure you want to become a service provider?'
                    : 'Are you sure you want to cancel your service provider status?',
                confirmText: 'Yes',
                onConfirm: () async {
                  try {
                    await profileProvider.toggleServiceProviderStatus(
                      authProvider.user!.uid,
                      newStatus,
                    );
                    showToast(
                      message: newStatus
                          ? "You are now a service provider"
                          : "You are no longer a service provider",
                    );
                  } catch (e) {
                    showToast(message: e.toString());
                  }
                },
              );
            },
            onAddService: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () => handleSignOut(authProvider),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
} 