// TODO Implement this library.
import 'package:flutter/material.dart';
import 'auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Navigator.pushReplacementNamed(context, '/auth');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              'Welcome${user?.displayName != null ? ', ${user?.displayName}' : ''}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (user?.phoneNumber != null)
              Text(
                'Phone: ${user?.phoneNumber}',
                style: const TextStyle(fontSize: 16),
              ),
            if (user?.email != null)
              Text(
                'Email: ${user?.email}',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}