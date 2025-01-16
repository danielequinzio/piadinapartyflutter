import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/ordine_model.dart';

class OrdineController {
  final Ordine ordine;

  OrdineController(this.ordine);

  void incrementQuantity(String item) {
    if (ordine.piadine.containsKey(item)) {
      ordine.piadine[item] = (ordine.piadine[item] ?? 0) + 1;
    } else if (ordine.bevande.containsKey(item)) {
      ordine.bevande[item] = (ordine.bevande[item] ?? 0) + 1;
    }
    ordine.calcolaPrezzo();
  }

  void decrementQuantity(String item) {
    if (ordine.piadine.containsKey(item) && (ordine.piadine[item] ?? 0) > 0) {
      ordine.piadine[item] = (ordine.piadine[item] ?? 0) - 1;
    } else if (ordine.bevande.containsKey(item) && (ordine.bevande[item] ?? 0) > 0) {
      ordine.bevande[item] = (ordine.bevande[item] ?? 0) - 1;
    }
    ordine.calcolaPrezzo();
  }

  double getPrezzoTotale() {
    return ordine.prezzo;
  }

  Future<void> salvaOrdineSuFirestore() async {
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
  }
}