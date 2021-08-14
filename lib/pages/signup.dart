import 'dart:ui';

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
// import 'package:beauty_plus/widgets/widgets.dart';

class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = '';
  String name = '';
  String password = '';
  String passwordConf = '';
  bool isLoading = false;

  validateName(String name) {
    Map errorHandler = {'status': false, 'message': ''};

    if (name.isEmpty) {
      errorHandler['message'] = 'Username should not be empty';
      return errorHandler;
    } else if (name.length < 4 || name.length > 15 ) {
      errorHandler['message'] = 'Username should be between 4 to 15  characters';
      return errorHandler;
    } else {
      errorHandler['status'] = true;
      return errorHandler;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return isLoading == false
        ? Stack(
            children: [
              backgroundImage('assets/images/register_bg.png'),
              Scaffold(
                backgroundColor: Colors.transparent,
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      // Stack(
                      //   children: [
                      //     Center(
                      //       child: ClipOval(
                      //         child: BackdropFilter(
                      //           filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      //           child: CircleAvatar(
                      //             radius: size.width * 0.14,
                      //             backgroundColor:
                      //                 Colors.grey[400]!.withOpacity(
                      //               0.4,
                      //             ),
                      //             child: Icon(
                      //               FontAwesomeIcons.user,
                      //               color: kWhite,
                      //               size: size.width * 0.1,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     Positioned(
                      //       top: size.height * 0.08,
                      //       left: size.width * 0.56,
                      //       child: Container(
                      //         height: size.width * 0.1,
                      //         width: size.width * 0.1,
                      //         decoration: BoxDecoration(
                      //           color: kBlue,
                      //           shape: BoxShape.circle,
                      //           border: Border.all(color: kWhite, width: 2),
                      //         ),
                      //         child: Icon(
                      //           FontAwesomeIcons.arrowUp,
                      //           color: kWhite,
                      //         ),
                      //       ),
                      //     )
                      //   ],
                      // ),
                      // SizedBox(
                      //   height: size.width * 0.1,
                      // ),
                      Column(
                        children: [
                          TextInputField(
                            onChanged: (value) {
                              setState(() {
                                name = value;
                              });
                            },
                            icon: FontAwesomeIcons.user,
                            hint: 'User Name',
                            inputType: TextInputType.name,
                            inputAction: TextInputAction.next,
                          ),
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
                            inputAction: TextInputAction.next,
                            inputType: TextInputType.text,
                          ),
                          PasswordInput(
                            onChanged: (value) {
                              setState(() {
                                passwordConf = value;
                              });
                            },
                            icon: FontAwesomeIcons.lock,
                            hint: 'Confirm Password',
                            inputAction: TextInputAction.done,
                            inputType: TextInputType.text,
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          RoundedButton(
                            buttonName: 'Register',
                            action: validateAndSignUp,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: kBodyText,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/');
                                },
                                child: Text(
                                  'Login',
                                  style: kBodyText.copyWith(
                                      color: kBlue,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  void validateAndSignUp() {
    final userData = Provider.of<UserData>(context, listen: false);
    UserData _userData = userData.userDataRef;
    final errorResult = validateName(name);
    if (errorResult['status']) {
      setState(() {
        isLoading = true;
      });
      AuthClass().createAccount(_userData, email, password).then((value) async {
        if (value['status']) {
          setState(() {
            isLoading = false;
          });
          _userData.name = name;
          userData.userName = name;
          print('UserDataId : ' + _userData.id);
          await _userData.saveInfo();
          Navigator.pushNamed(context, 'HomeScreen');
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(value['message'])));
        }
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorResult['message'])));
    }
  }
}
