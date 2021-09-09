// @dart=2.9

import 'package:stylist_customer/auth/auth.dart';
import 'package:stylist_customer/auth/stylist.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stylist_customer/pages/book_list.dart';
import 'package:stylist_customer/pages/booking_screen.dart';
import 'package:stylist_customer/pages/forgotpassword.dart';
import 'package:stylist_customer/pages/history_screen.dart';
import 'package:stylist_customer/pages/home_screen.dart';
import 'package:stylist_customer/pages/login.dart';
import 'package:stylist_customer/pages/profile.dart';
import 'package:stylist_customer/pages/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'auth/userData.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container();
          }
          // once initialization is done, show login page
          if (snapshot.connectionState == ConnectionState.done) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider<AuthClass>(
                  create: (_) => AuthClass(),
                ),
                ChangeNotifierProvider<UserData>(
                  create: (_) => UserData('', '', '', '','',''),
                ),
                ChangeNotifierProvider<Stylist>(
                  create: (_) => Stylist('', '', 0, 0, '', [], ''),
                ),
                Provider<Service>(
                  create: (_) => Service('', 0.0, ''),
                ),
              ],
              child: MaterialApp(
                title: 'Saloon Demo',
                theme: ThemeData(
                  textTheme: GoogleFonts.josefinSansTextTheme(
                      Theme.of(context).textTheme),
                  primarySwatch: Colors.blue,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
                initialRoute: '/',
                routes: {
                  '/': (context) => LoginScreen(),
                  'ForgotPassword': (context) => ForgotPassword(),
                  'SignUp': (context) => SignUp(),
                  'HomeScreen': (context) => HomeScreen(),
                  'BookingScreen': (context) => BookingScreen(),
                  'BookList': (context) => BookList(),
                  'ProfilePage': (context) => ProfilePage(),
                  'History': (context) => History(),
                },
              ),
            );
          }

          // if not yet initialized show some process
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
