import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login.dart'; // Importa la pagina di login
import 'registrazione.dart'; // Importa la pagina di registrazione
import 'home.dart'; // Importa la pagina della Home
import 'package:firebase_auth/firebase_auth.dart'; // Per verificare l'utente autenticato

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Determina la rotta iniziale in base all'autenticazione dell'utente
      initialRoute: FirebaseAuth.instance.currentUser != null ? '/home' : '/',
      routes: {
        '/': (context) => LoginScreen(), // Rotta per la pagina di login
        '/register': (context) => RegisterScreen(), // Rotta per la pagina di registrazione
        '/home': (context) => HomeScreen(), // Rotta per la Home Page
      },
    );
  }
}
