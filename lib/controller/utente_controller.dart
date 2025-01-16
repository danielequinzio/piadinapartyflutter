import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/utente_model.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUserData(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore.collection('users').doc(uid).get();
    if (snapshot.exists) {
      return UserModel.fromMap(snapshot.data()!, uid);
    }
    return null;
  }
}