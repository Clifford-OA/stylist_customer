import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserData extends ChangeNotifier{
  UserData(this.id, this.email, this.password, this.name);

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  String id;
  String email;
  String password;
  String name;

  // Future<void> getData() async {
  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .get()
  //       .then((QuerySnapshot querySnapshot) {
  //     querySnapshot.docs.forEach((doc) {
  //       if (doc.id == id) {}
  //     });
  //   });
  // }

 String get userName => name;
 set userName(String newName) => name = newName;
  UserData get userDataRef => UserData(id, email, password, name);

  DocumentReference get firestoreRef =>
      FirebaseFirestore.instance.collection('users').doc('$id');

  Future<void> saveInfo() async {
    await firestoreRef.set(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'name': name,
      'email': email,
    };
  }
}

// class UserManagement {
//   storeNewUser(user) {
//     var firebaseUser = FirebaseAuth.instance.currentUser!;
//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(firebaseUser.uid)
//         .set({'email': user.email, 'uid': user.uid}).then((value) {
//       print('Information set');
//     }).catchError((e) {
//       print(e);
//     });
//   }
// }
