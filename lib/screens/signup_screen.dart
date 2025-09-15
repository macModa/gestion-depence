// Copie de login_screen.dart, mais change le bouton en 'S\'inscrire' et appelle signUp
// Ajoute Navigator.pushReplacementNamed(context, '/home'); après succès.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // La navigation est gérée par AuthWrapper, donc pas de Navigator ici.
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Le mot de passe est trop faible (6 caractères minimum).';
          break;
        case 'email-already-in-use':
          message = 'Un compte existe déjà pour cet email.';
          break;
        case 'invalid-email':
          message = 'L\'adresse email n\'est pas valide.';
          break;
        default:
          message = 'Une erreur est survenue. Veuillez réessayer.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Une erreur inattendue est survenue.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inscription')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Mot de passe')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0))
                  : const Text('S\'inscrire'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Déjà un compte ?'),
            ),
          ],
        ),
      ),
    );
  }
}