import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'view/login.dart';
import 'view/registrazione.dart';
import 'view/home.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Garantisce che i binding di Flutter siano pronti prima di eseguire codice asincrono
  await Firebase.initializeApp( //inizializza firebase nell'app
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp()); //metodo per lanciare l'applicazione Flutter
}

class MyApp extends StatelessWidget { //classe MyMap è utilizzata come punto di configurazione per temi, rotte e la struttura principale dell'app
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
