import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/auth_controller.dart';

class LoginScreen extends StatefulWidget { //si estende statefulwidget per indicare che la classe ha uno stato che può cambiare nel tempo
  @override
  _LoginScreenState createState() => _LoginScreenState(); //si crea lo stato della schermata gestito da _LoginScreenState
}

class _LoginScreenState extends State<LoginScreen> { //_LoginScreenState gestisce il comportamento e i dati dello stato per il widget LoginScreen
  final _emailController = TextEditingController(); //controller per email inserita dall'utente
  final _passwordController = TextEditingController();
  final AuthController _authController = AuthController();
  bool _isLoading = false; //indica se l'app è in fase di caricamento

  Future<void> _login() async {
    setState(() {
      _isLoading = true; //settata a true perchè è in corso operazione di login
    });

    try {
      await _authController.login(  //richiama funzione di login di authController
        _emailController.text.trim(), //trim() rimuove eventuali spazi nell'email inserita dall'utent ecc.
        _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false; //una volta terminata operazione di login
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( //si restituisce scaffold , che rappresenta il layout base della schermata e include: AppBar, backgroundColor, body
      appBar: AppBar( //nell' appBar è presente il titolo della schermata
        title: Column(
          children: [
            Text('Piadina Party'),
          ],
        ),
        automaticallyImplyLeading: false, // Rimuove la freccia per tornare indietro
      ),
      backgroundColor: Colors.orange,
      body: Padding( //body contiene il contenuto della schermata
        padding: const EdgeInsets.all(16.0), //corpo è organizzato con un Padding che applica un margine interno uniforme di 16 pixel
        child: Column( //dispone i widget verticalmente
          crossAxisAlignment: CrossAxisAlignment.stretch, //Allinea i widget in modo che occupino tutta la larghezza disponibile
          children: [
            Text(
              'Login',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32), //spazio tra il titolo e il primo campo di input.
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32),
            _isLoading
                ? Center(child: CircularProgressIndicator()) //cliccando su login viene chiamata la funzione di authController, in attesa di risposta compare un indicatore di caricamento
                : ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            SizedBox(height: 16),
            GestureDetector( //Rende il testo "Non sei ancora registrato? Registrati" interattivo
              onTap: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text(
                "Non sei ancora registrato? Registrati",
                style: TextStyle(color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}