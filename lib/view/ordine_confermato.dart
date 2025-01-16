import 'package:flutter/material.dart';
import '../view/home.dart'; 

class OrdineSuccessoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ordine Effettuato'),
      ),
      body: Container(
        color: Colors.orange,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Ordine effettuato con successo!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                          (route) => false,
                    );
                  },
                  child: Text('Torna alla Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}