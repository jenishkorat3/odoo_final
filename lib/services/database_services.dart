import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  final String? uid;
  DatabaseServices({this.uid});

  final userCollectionRef = FirebaseFirestore.instance.collection('users');

  Future savingUserData(String fullName, String email , String token) async {

    return userCollectionRef.doc(uid).set({
      'name': fullName,
      'email': email,
      'uid': uid,
      'token':token
    });
  }

}