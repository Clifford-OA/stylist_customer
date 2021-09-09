import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stylist_customer/auth/auth.dart';
import 'package:stylist_customer/auth/userData.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stylist_customer/constant.dart';
import 'package:stylist_customer/widgets/background-image.dart';
import 'package:stylist_customer/widgets/password-input.dart';
import 'package:stylist_customer/widgets/rounded-button.dart';
import 'package:stylist_customer/widgets/text-field-input.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextEditingController _passwordController = TextEditingController();
  // TextEditingController _emailController = TextEditingController();

  String email = '';
  String password = '';

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return isLoading == false
        ? Stack(
            children: [
              backgroundImage(
                'assets/images/4.jpg',
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 80),
                      Container(
                        child: Center(
                          child: Text(
                            'Beauty Plus',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 60,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 90,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextInputField(
                            onChanged: (value) {
                              setState(() {
                                email = value;
                              });
                            },
                            icon: FontAwesomeIcons.envelope,
                            hint: 'Email',
                            inputType: TextInputType.emailAddress,
                            inputAction: TextInputAction.next,
                          ),
                          PasswordInput(
                            onChanged: (value) {
                              setState(() {
                                password = value;
                              });
                            },
                            icon: FontAwesomeIcons.lock,
                            hint: 'Password',
                            inputType: TextInputType.text,
                            inputAction: TextInputAction.done,
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, 'ForgotPassword'),
                            child: Text(
                              'Forgot Password',
                              style: kBodyText,
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          RoundedButton(
                            buttonName: 'Login',
                            action: signUserIn,
                          ),
                          SizedBox(
                            height: 25,
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, 'SignUp'),
                        child: Container(
                          child: Text(
                            'Create Account',
                            style: kBodyText,
                          ),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(width: 1, color: kWhite))),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
        : Center(child: CircularProgressIndicator());
  }

  void signUserIn() {
    final userData = Provider.of<UserData>(context, listen: false);
    UserData _userData = userData.userDataRef;
    setState(() {
      isLoading = true;
    });
    AuthClass().signIN(_userData, email, password).then((value) async {
      if (value['status']) {
        setState(() {
          isLoading = false;
        });
        _loadUserData();
        Navigator.pushNamed(context, 'HomeScreen');
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(value['message'])));
      }
    });
  }

  void _loadUserData()async {
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      final authClass = Provider.of<AuthClass>(context, listen: false);
      final userData = Provider.of<UserData>(context, listen: false);
      String uid = authClass.auth.currentUser!.uid;
      await users.doc(uid).get().then((query){
        Map<String, dynamic> data = query.data() as Map<String, dynamic>;
       userData.userRef = data;
      });

  }
}
