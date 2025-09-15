import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // We get the AuthService to access user data and the signOut method.
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (user?.email != null) ...[
            const Text(
              'Connecté en tant que :',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              user!.email!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
          ],
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
    );
  }
}