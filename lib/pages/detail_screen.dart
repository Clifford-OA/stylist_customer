// import 'package:beauty_plus/pages/home_screen.dart';
import 'package:stylist_customer/auth/stylist.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> stylist;

  DetailScreen(this.stylist);

  Widget _serviceList(BuildContext context) {
    final stylistClass = Provider.of<Stylist>(context, listen: false);
    stylistClass.stylistRef = stylist;

    List<dynamic> data = stylist['serviceList'];
    List<Widget> list = [];

    for (var i = 0; i < data.length; i++) {
      list.add(ServiceTile(data[i]));
    }
    return Column(
      children: list,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(
      children: [
        Container(
          // width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 3 + 60,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    FadeInImage.assetNetwork(
                placeholder: 'assets/images/stylist1.png',
                image: stylist['imgUrl'],
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/stylist1.png',width: MediaQuery.of(context).size.width * 0.60,
                  );
                },
                fit: BoxFit.cover,
               ),
                    // Image.asset(
                    //   stylist['imgUrl'].toString(),
                    //   fit: BoxFit.contain,
                    // ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.purple.withOpacity(0.1),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              Positioned(
                right: 10,
                top: 50,
                child: MaterialButton(
                  onPressed: () {},
                  padding: EdgeInsets.all(10),
                  shape: CircleBorder(),
                  color: Colors.white,
                  child: Icon(Icons.favorite_rounded),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Service List',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                _serviceList(context),

                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width,
                        color: Color(0xff4E295B),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  stylist['stylistName'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '  Mar 9, 2020',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Color(0xffFF8573),
                                  size: 16,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Color(0xffFF8573),
                                  size: 16,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Color(0xffFF8573),
                                  size: 16,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Color(0xffFF8573),
                                  size: 16,
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Color(0xffFF8573),
                                  size: 16,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Cameron is the best colorist and stylish I’ve ever met. He has an amazing talent! He is ver...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    )));
  }
}


class ServiceTile extends StatelessWidget {
  final service;
  ServiceTile(this.service);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 40,
                child: Text(
                  service['title'],
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
                '${service['duration']} Min',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Text(
            '\$${service['price']}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          MaterialButton(
            onPressed: () {
              final serviceIns = Provider.of<Service>(context, listen: false);
              serviceIns.serviceRef = service;
              Navigator.pushNamed(context, 'BookingScreen');
            },
            color: Color(0xffFF8573),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Book',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
