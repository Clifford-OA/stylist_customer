import 'package:flutter/foundation.dart';

class Stylist extends ChangeNotifier {
  Stylist(this.imgUrl, this.tid, this.rateAmount, this.rating, this.saloonName,
      this.serviceList, this.stylistName);

  String saloonName;
  String tid;
  String stylistName;
  String imgUrl;
  double rating;
  int rateAmount;
  List<dynamic> serviceList;

  Map<String, dynamic> get stylistRef {
    return {'tid': tid, 'saloonName': saloonName, 'stylistName': stylistName};
  }

  String get stylistId => tid;

  set stylistRef(Map<String, dynamic> data) {
    saloonName = data['saloonName'];
    serviceList = data['serviceList'];
    imgUrl = data['imgUrl'];
    tid = data['tid'];
    stylistName = data['stylistName'];
  }
}


class Service {

  Service(this.duration, this.price, this.title);
  
  String title;
  double price;
  String duration;

  

  Map<String, dynamic> get serviceRef {
    return {'price': price, 'title': title};
  }

  set serviceRef(dynamic data) {
    title = data['title'];
    price = data['price'].toDouble();
    duration = data['duration'];
  }
}
