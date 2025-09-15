import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';  // Généré par flutterfire (on le fixera après)
import 'providers/transaction_provider.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        // This StreamProvider listens to auth changes and provides the User object.
        StreamProvider<User?>(
          create: (context) => context.read<AuthService>().authStateChanges,
          initialData: null,
        ),
        // TransactionProvider now depends on the user's authentication state.
        // It will be initialized or cleared automatically on login/logout.
        ChangeNotifierProxyProvider<User?, TransactionProvider>(
          create: (_) => TransactionProvider(),
          update: (_, user, previousProvider) => previousProvider!..init(user?.uid),
        ),
      ],
      child: MaterialApp(
        title: 'Gestion de Dépenses',
        theme: ThemeData(primarySwatch: Colors.blue),
        routes: {'/signup': (context) => SignupScreen(), '/home': (context) => HomeScreen()},
        home: AuthWrapper(),
      ),
    );
  }
}

/// A wrapper that decides which screen to show based on the auth state.
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Listens to the User object provided by the StreamProvider.
    final user = Provider.of<User?>(context);
    return user != null ? HomeScreen() : LoginScreen();
  }
}