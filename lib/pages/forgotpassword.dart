import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stylist_customer/auth/auth.dart';
import 'package:stylist_customer/constant.dart';
import 'package:stylist_customer/widgets/background-image.dart';
import 'package:stylist_customer/widgets/rounded-button.dart';
import 'package:stylist_customer/widgets/text-field-input.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  bool isLoading = false;
  String email = '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return isLoading == false ? Stack(
      children: [
        backgroundImage('assets/images/4.jpg'),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: kWhite,
              ),
            ),
            title: Text(
              'Forgot Password',
              style: kBodyText,
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.height * 0.1,
                      ),
                      Container(
                        width: size.width * 0.8,
                        child: Text(
                          'Enter your email we will send instruction to reset your password',
                          style: kBodyText,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextInputField(
                        onChanged: (value) {
                         
                            print('value');
                         
                        },
                        icon: FontAwesomeIcons.envelope,
                        hint: 'Email',
                        inputType: TextInputType.emailAddress,
                        inputAction: TextInputAction.done,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      RoundedButton(buttonName: 'Reset', action: _resetPasswordHandler,)
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    ) : Center(child: CircularProgressIndicator(),);
  }

  void _resetPasswordHandler() {
    setState(() {
      isLoading = true;
    });
    AuthClass().resetPassword(email).then((value) async {
      if (value['status']) {
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Alert!!",style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold,),),
              content: Text("Check in your email to reset your password"),
              actions: <Widget>[
                FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(value['message'])));
      }
    });
  }
}
