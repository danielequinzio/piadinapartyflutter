import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/utente_controller.dart';
import '../model/utente_model.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  UserModel? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      if (user != null) {
        UserModel? fetchedUserData = await UserController().getUserData(user!.uid);
        setState(() {
          userData = fetchedUserData;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Errore nel recupero dei dati utente: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sei sicuro di uscire?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Sì'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/'); // Torna al login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange, // Imposta lo sfondo arancione
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: userData != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nome: ${userData!.name}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Cognome: ${userData!.surname}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Email: ${userData!.email}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _confirmLogout,
                child: Text('Logout'),
              ),
            ),
          ],
        )
            : Center(
          child: Text(
            'Nessun dato utente disponibile.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}