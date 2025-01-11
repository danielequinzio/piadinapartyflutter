import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login.dart'; // Importa la pagina di login
import 'registrazione.dart'; // Importa la pagina di registrazione
import 'home.dart'; // Importa la pagina della Home

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
      initialRoute: '/', // La rotta iniziale è la pagina di login
      routes: {
        '/': (context) => LoginScreen(), // Rotta per la pagina di login
        '/register': (context) => RegisterScreen(), // Rotta per la pagina di registrazione
        '/home': (context) => HomeScreen(), // Rotta per la Home Page
      },
    );
  }
}
