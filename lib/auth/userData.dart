import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserData extends ChangeNotifier {
  UserData(
      this.id, this.email, this.password, this.name, this.imgUrl, this.tel);

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  String id;
  String email;
  String password;
  String name;
  String imgUrl;
  String tel;

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

// image getter and setter
  String get imageUrl => imgUrl;
  set imageUrl(String newImageUrl){
    imgUrl = newImageUrl;
    notifyListeners();
  } 

// id setters and getters
  String get userId => id;
  set userId(String newUserId) => id = newUserId;
// name getter and setter
  String get userName => name;
  set userName(String newName) => name = newName;
  UserData get userDataRef => UserData(id, email, password, name, imgUrl, tel);

  Map<String, dynamic> get userRef {
    return {'uid': id, 'name': name, 'email': email, 'tel': tel, 'imgUrl': imgUrl};
  }

  set userRef(Map<String, dynamic> data) {
    name = data['name'];
    imgUrl = data['imgUrl'];
    id = data['uid'];
    email = data['email'];
    tel = data['tel'];
    notifyListeners();
  }

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
      'imgUrl': imgUrl,
      'tel': '+233$tel'
    };
  }
}
