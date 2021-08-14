// @dart=2.9

import 'package:stylist_customer/auth/auth.dart';
import 'package:stylist_customer/widgets/stylistCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foldable_sidebar/foldable_sidebar.dart';
import 'package:swipedetector/swipedetector.dart';

// const stylistData = [
//   {
//     'stylistName': 'Cameron Jones',
//     'salonName': 'Super Cut Salon',
//     'rating': '4.8',
//     'rateAmount': '56',
//     'imgUrl': 'assets/images/stylist1.png',
//     'bgColor': Color(0xffFFF0EB),
//   },
//   {
//     'stylistName': 'Max Robertson',
//     'salonName': 'Rossano Ferretti Salon',
//     'rating': '4.7',
//     'rateAmount': '80',
//     'imgUrl': 'assets/images/stylist2.png',
//     'bgColor': Color(0xffEBF6FF),
//   },
//   {
//     'stylistName': 'Beth Watson',
//     'salonName': 'Neville Hair and Beauty',
//     'rating': '4.7',
//     'rateAmount': '70',
//     'imgUrl': 'assets/images/stylist3.png',
//     'bgColor': Color(0xffFFF3EB),
//   }
// ];

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FSBStatus status; // = FSBStatus.FSB_CLOSE;

  Map<String, dynamic> data;

  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('stylists').snapshots();

  Widget _stylistData(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return Column(
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            data = document.data() as Map<String, dynamic>;
            return StylistCard(data);
            // new ListTile(
            //   title: new Text(data['full_name']),
            //   subtitle: new Text(data['company']),
            // );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff4E295B),
      body: SwipeDetector(
        onSwipeLeft: () {
          setState(() {
            status = FSBStatus.FSB_CLOSE;
          });
        },
        onSwipeRight: () {
          setState(() {
            status = FSBStatus.FSB_OPEN;
          });
        },
        child: FoldableSidebarBuilder(
          // drawerBackgroundColor: Colors.orange,
          status: status,
          drawer: Drawer(closeDrawer: () {
            setState(() {
              status = FSBStatus.FSB_CLOSE;
            });
          }),
          screenContents: SingleChildScrollView(
            child: SafeArea(
              child: Container(
                child: WillPopScope(
                  onWillPop: onWillPop,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                                icon: Icon(
                                  Icons.menu_sharp,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    status = status == FSBStatus.FSB_OPEN
                                        ? FSBStatus.FSB_CLOSE
                                        : FSBStatus.FSB_OPEN;
                                  });
                                }),
                            IconButton(
                              icon: Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        // height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(50),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 50,
                              ),
                              Text(
                                'Hair Stylist',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              _stylistData(context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DateTime currentBackPressTime;
  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Press back again to close app');
      return Future.value(false);
    }
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return true;
  }
}

class Drawer extends StatelessWidget {
  final Function closeDrawer;

  const Drawer({Key key, this.closeDrawer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 5),
      child: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width * 0.60,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey.withAlpha(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/stylist1.png',
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text('Theo')
                ],
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, 'ProfilePage');
                closeDrawer();
              },
              leading: Icon(Icons.person),
              title: Text("Your Profile"),
            ),
            Divider(
              height: 1,
              color: Colors.grey,
            ),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, 'BookList');
                closeDrawer();
              },
              leading: Icon(Icons.list),
              title: Text("Booked List"),
            ),
            Divider(
              height: 1,
              color: Colors.grey,
            ),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.settings),
              title: Text("Settings"),
            ),
            Divider(
              height: 1,
              color: Colors.grey,
            ),
            ListTile(
              onTap: () {
                AuthClass().signOut();
                Navigator.pushNamed(context, '/');
              },
              leading: Icon(Icons.settings),
              title: Text("LogOut"),
            ),
          ],
        ),
      ),
    );
  }
}
