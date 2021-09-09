import 'package:provider/provider.dart';
import 'package:stylist_customer/auth/stylist.dart';
import 'package:stylist_customer/pages/detail_screen.dart';
import 'package:flutter/material.dart';

class StylistCard extends StatelessWidget {
  final Map<String, dynamic> stylist;
  StylistCard(this.stylist);


  @override
  Widget build(BuildContext context) {
    final stylistClass = Provider.of<Stylist>(context, listen: false);
    stylistClass.stylistRef = stylist;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3 - 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xffFFF0EB),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 2,
            right: -60,
            child: stylist['imgUrl'].contains('http') ? FadeInImage.assetNetwork(
              width: MediaQuery.of(context).size.width * 0.60,
                placeholder: 'assets/images/no_picture.png',
                image: stylist['imgUrl'],
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/no_picture.png',width: MediaQuery.of(context).size.width * 0.60,
                  );
                },
                fit: BoxFit.cover,
              ) : Image.asset(
               'assets/images/no_picture.png',
              width: MediaQuery.of(context).size.width * 0.60,
             ),
            // child: Image.asset(
            //   stylist['imgUrl'],
            //   width: MediaQuery.of(context).size.width * 0.60,
            // ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 40, left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  stylist['stylistName'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  stylist['saloonName'],
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Color(0xff4E295B),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                    stylist['rating'].toString(),
                      style: TextStyle(
                        color: Color(0xff4E295B),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  onPressed: () {
                    print(stylist['tid']);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailScreen(stylist)));
                  },
                  color: Color(0xff4E295B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'View Profile',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
