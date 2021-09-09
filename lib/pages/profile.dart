import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:stylist_customer/auth/userData.dart';
import 'package:stylist_customer/widgets/rounded-button.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();

  String imgUrl = '';
  String name = '';
  int _tel = 0;
  bool _loadImage = false;

  Widget textfield({@required hintText, onChanged}) {
    return Material(
      elevation: 3,
      shadowColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        onChanged: onChanged,
        keyboardType:
            hintText == 'tel' ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              letterSpacing: 2,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
            fillColor: Colors.white30,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context, listen: true);
    String name = userData.userRef['name'];
    String email = userData.userRef['email'];
    imgUrl = userData.userRef['imgUrl'];
    String tel = userData.userRef['tel'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
        elevation: 0.0,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Profile",
                        style: TextStyle(
                          fontSize: 35,
                          letterSpacing: 1.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5.0),
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.width / 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: _loadImage == false
                            ? FadeInImage.assetNetwork(
                                placeholder: 'assets/images/no_picture.png',
                                image: imgUrl,
                                imageErrorBuilder:
                                    (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/no_picture.png',
                                  );
                                },
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: CircularProgressIndicator(),
                              ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 400,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      textfield(
                          hintText: name,
                          onChanged: (value) {
                            setState(() {
                              name = value;
                            });
                          }),
                      textfield(
                          hintText: email,
                          onChanged: (value) {
                            setState(() {
                              email = value;
                            });
                          }),
                      textfield(
                          hintText: tel,
                          onChanged: (value) {
                            setState(() {
                              _tel = int.parse(value);
                            });
                          }),
                      // textfield(
                      //     hintText: tel.toString(),
                      //     onChanged: (value) {
                      //       setState(() {
                      //         tel = int.parse(value);
                      //       });
                      //     }),
                      RoundedButton(
                        buttonName: 'Update',
                        action: _validateAndUpdate,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 270, left: 184),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: _getImage,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future _getImage() async {
    final userData = Provider.of<UserData>(context, listen: false);
    late File image;
    String tid = userData.userRef['uid'];
    print(tid);
    final img = await _picker.pickImage(source: ImageSource.gallery);
    _loadImage = true;
    File file = File(img!.path);
    setState(() {
      image = file;
    });
    print('image');
    print(image);
    print(image.path);
    var storeImage = FirebaseStorage.instance.ref().child(image.path);
    var task = await storeImage.putFile(image);
    var imgUrl = await storeImage.getDownloadURL();
    print('downloadurl ' + imgUrl);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(tid)
        .update({'imgUrl': imgUrl}).then((value) {
      userData.imageUrl = imgUrl;
      _loadImage = false;
    });
  }

// validate and update stylist info
  void _validateAndUpdate() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final userData = Provider.of<UserData>(context, listen: false);
    String tid = userData.id;
    final errorResult = validateName();
    if (errorResult['status']) {
      await users.doc(tid).update({'name': name, 'tel': _tel}).then((value) {
        _reloadUserData();
        Navigator.pushNamed(context, 'HomeScreen');
        print('created successfully');
      }).catchError((error) {
        print("Failed to book: $error");
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorResult['message'])));
    }
  }

// reload user data for provider to get access
  void _reloadUserData() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final userData = Provider.of<UserData>(context, listen: false);
    String tid = userData.id;

    await users.doc(tid).get().then((query) {
      Map<String, dynamic> data = query.data() as Map<String, dynamic>;
      // userData.stylistRef = data;
    });
  }

// validate all field
  validateName() {
    Map errorHandler = {'status': false, 'message': ''};

    if (name.isEmpty || _tel.isNaN) {
      errorHandler['message'] = 'None of the field should be empty';
      return errorHandler;
    } else if (name.length < 4) {
      errorHandler['message'] =
          'stylist name should not be less than 4 characters';
      return errorHandler;
    } else if (_tel.toString().trim().length != 10) {
      errorHandler['message'] = 'tel field should be only 10 integers';
      return errorHandler;
    } else {
      errorHandler['status'] = true;
      return errorHandler;
    }
  }
}
