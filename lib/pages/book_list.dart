import 'package:stylist_customer/auth/auth.dart';
import 'package:stylist_customer/auth/stylist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class BookList extends StatelessWidget {
  // Display booked list for you
  Future<Widget> _displayBook(BuildContext context) async {
    final authClass = Provider.of<AuthClass>(context, listen: false);
    String userId = authClass.auth.currentUser!.uid;
    List<Widget> list = [
      SizedBox(height: 0.0),
    ];
    await FirebaseFirestore.instance
        .collection('booklist')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc.id == userId) {
          List<dynamic> data = doc['bookedList'];
          data
            ..sort(
                (a, b) => b['date'].compareTo(a['date']));
          data..sort((a, b) => b['time'].compareTo(a['time']));
          for (var i = 0; i < data.length; i++) {
            list.add(BookedTile(data[i]));
          }
        }
      });
    });

    return list.length > 1
        ? Column(
            children: list,
          )
        : Center(
            child: Text('Your book list is empty'),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, 'HomeScreen')),
                            IconButton(
                        icon: Icon(
                          Icons.history,
                          color: Colors.white,
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, 'History')),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                // height: MediaQuery.of(context).size.height,
                // width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(50),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                        'Booked List and Its Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      FutureBuilder<Widget>(
                          future: _displayBook(context),
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                return snapshot.data as Widget;
                              }
                            }
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookedTile extends StatelessWidget {
  final service;
  BookedTile(this.service);

  @override
  Widget build(BuildContext context) {
    final serviceRef = Provider.of<Service>(context, listen: false);
    Map<String, dynamic> serviceInfo = serviceRef.serviceRef;

    return Container(
      height: 70,
      margin: EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          service['imgUrl'].contains('http')
              ? CircleAvatar(
                  radius: 30,
                  child: Image.network(service['imgUrl']),
                )
              : CircleAvatar(radius: 30),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 40,
                child: Text(
                  service['stylistName'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                serviceInfo['title'],
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'date: ' + service['date'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                'time: ' + service['time'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              )
            ],
          ),
          // Text(
          //   '\Ghc${serviceInfo['price']}',
          //   style: TextStyle(
          //     fontWeight: FontWeight.bold,
          //     fontSize: 18,
          //   ),
          // ),
          MaterialButton(
            onPressed: () {},
            color: service['status'] == 'pending'
                ? Color(0xffFF8573)
                : Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              service['status'],
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
