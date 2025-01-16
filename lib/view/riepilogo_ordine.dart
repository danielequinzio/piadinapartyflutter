import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/ordine_model.dart';
import '../view/ordine_confermato.dart';
import '../view/inserimento_dati.dart';

class RiepilogoDatiScreen extends StatelessWidget {
  final String indirizzo;
  final String orario;
  final String metodoPagamento;
  final Ordine ordine;

  RiepilogoDatiScreen({
    required this.indirizzo,
    required this.orario,
    required this.metodoPagamento,
    required this.ordine,
  });

  Future<void> _confermaOrdine(BuildContext context) async {
    final bool? conferma = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Conferma Ordine'),
          content: Text('Sicuro di confermare l\'ordine?'),
          actions: <Widget>[
            TextButton(
              child: Text('NO'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('SI'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (conferma == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utente non autenticato');
      }

      final piadineSelezionate = Map<String, int>.from(ordine.piadine)..removeWhere((key, value) => value == 0);
      final bevandeSelezionate = Map<String, int>.from(ordine.bevande)..removeWhere((key, value) => value == 0);

      final ordineData = {
        'idUtente': user.uid,
        'piadine': piadineSelezionate,
        'bevande': bevandeSelezionate,
        'prezzo': ordine.prezzo,
      };

      await FirebaseFirestore.instance.collection('ordini').add(ordineData);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OrdineSuccessoScreen()),
      );
    }
  }

  Future<void> _annullaOrdine(BuildContext context) async {
    final bool? annulla = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Annulla Ordine'),
          content: Text('Sicuro di voler annullare l\'ordine?'),
          actions: <Widget>[
            TextButton(
              child: Text('NO'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('SI'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (annulla == true) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riepilogo Dati'),
        automaticallyImplyLeading: false, // Rimuove l'icona di ritorno indietro
      ),
      body: Container(
        color: Colors.orange,
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Indirizzo di Consegna: $indirizzo'),
            Text('Orario di Consegna: $orario'),
            Text('Metodo di Pagamento: $metodoPagamento'),
            Text('Prezzo Totale: €${ordine.prezzo.toStringAsFixed(2)}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _confermaOrdine(context),
              child: Text('Conferma Ordine'),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InserimentoDatiScreen(
                          ordine: ordine,
                          indirizzo: indirizzo,
                          orario: orario,
                          metodoPagamento: metodoPagamento,
                        ),
                      ),
                    );
                  },
                  child: Text('Indietro'),
                ),
                ElevatedButton(
                  onPressed: () => _annullaOrdine(context),
                  child: Text('Annulla Ordine'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}