import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stylist_customer/auth/auth.dart';
import 'package:stylist_customer/auth/stylist.dart';
import 'package:stylist_customer/auth/userData.dart';
import 'package:stylist_customer/widgets/rounded-button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stylist_customer/widgets/text-field-input.dart';
import 'package:provider/provider.dart';

class BookingScreen extends StatefulWidget {
  BookingScreen({Key? key}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  CollectionReference bookList =
      FirebaseFirestore.instance.collection('booklist');
  CollectionReference bookTimeList =
      FirebaseFirestore.instance.collection('bookdate');
  final ImagePicker _picker = ImagePicker();
  late final collectData;
  late DateTime bookDate;
  String time = 'select one';
  String stylistName = '';
  // String hostelName = '';
  String cusName = '';
  bool _loadImage = false;
  bool _check = false;
  String imgUrl = '';

  List<String> _workingTime = [
    'select one',
    '6:00',
    '8:00',
    '10:00',
    '12:00',
    '14:00',
    '16:00',
    '18:00',
    '20:00'
  ];

  static String toDate(DateTime dateTime) {
    final date = DateFormat.yMMMEd().format(dateTime);
    return '$date';
  }

  static String toTime(DateTime dateTime) {
    final time = DateFormat.Hm().format(dateTime);
    return '$time';
  }

  Future _loadStylistAvailableTimeSlot() async {
    final stylistClass = Provider.of<Stylist>(context, listen: false);
    final stylistId = stylistClass.tid;
    print('stylist id before ' + stylistId);
    print('tid here @ ');
    print(stylistClass.stylistRef);
    await bookTimeList.doc(stylistId).get().then((query) {
      Map<String, dynamic> data = query.data() as Map<String, dynamic>;
      List<dynamic> booktime = data[toDate(bookDate)];
      print(booktime);
      if (booktime.isNotEmpty) {
        booktime.forEach((timeTaken) {
          if (_workingTime.contains(timeTaken)) {
            setState(() {
              _workingTime.remove(timeTaken);
            });
          } else
            return;
        });
      } else
        return;
    });
  }

  void _validateAndBook() {
    final errorResult = _validate();
    if (errorResult['status']) {
      addToBookedList();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorResult['message'])));
    }
  }

  _validate() {
    Map errorHandler = {'status': false, 'message': ''};
    // if (hostelName.isEmpty || hostelName.length < 5) {
    //   errorHandler['message'] =
    //       'Hostel should not be empty or less than 5 characters';
    //   return errorHandler;
    // } else
     if (time == 'select one') {
      errorHandler['message'] = 'Please select time';
      return errorHandler;
    } else {
      errorHandler['status'] = true;
      return errorHandler;
    }
  }

  @override
  void initState() {
    final stylistClass = Provider.of<Stylist>(context, listen:  false);
    collectData = stylistClass.stylistRef;
    super.initState();
    bookDate = DateTime.now();
    _loadData();
  }

  void _loadData() async {
    await _loadStylistAvailableTimeSlot();
  }

  Future<void> addToBookedList() async {
    final authClass = Provider.of<AuthClass>(context, listen: false);
    final stylist = Provider.of<Stylist>(context, listen: false);
    final userData = Provider.of<UserData>(context, listen: false);
    final userId = authClass.auth.currentUser!.uid;
    final stylistId = stylist.tid;
    print('About to go down');
    print(stylistId);
    cusName = userData.userName;
    stylistName = stylist.stylistName;
    List bookItem = [];
    bookItem.add(toMap(userData.tel));
    List<String> ids = [];
    print(bookItem);
    await FirebaseFirestore.instance
        .collection('booklist')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        ids.add(doc.id);
      });
    });
    if (ids.contains(userId)) {
      await bookList.doc(userId).update(
          {'bookedList': FieldValue.arrayUnion(bookItem)}).then((value) {
        _addToBookDateList();
        Navigator.pushNamed(context, 'BookList');
      }).catchError((error) {
        print("Failed to book: $error");
      });
    } else {
      await bookList
          .doc(userId)
          .set({'bookedList': FieldValue.arrayUnion(bookItem)}).then((value) {
        _addToBookDateList();
        Navigator.pushNamed(context, 'BookList');
      }).catchError((error) {
        print("Failed to book: $error");
      });
    }
  }

  Map<String, dynamic> toMap(String userTel) {
    final serviceIns = Provider.of<Service>(context, listen: false);
    final stylistClass = Provider.of<Stylist>(context, listen: false);
    final stylistId = stylistClass.tid;
    final ano = collectData['tid'];
    print('coll tid ' + ano);
    return {
      'cusName': cusName,
      'price': serviceIns.serviceRef['price'],
      'title': serviceIns.serviceRef['title'],
      'tid': stylistId,
      'stylistName': stylistName,
      'tel': userTel,
      'imgUrl': imgUrl,
      'time': time,
      'date': toDate(bookDate),
      'status': 'pending'
    };
  }

  void _addToBookDateList() async {
    final stylistClass = Provider.of<Stylist>(context, listen: false);
    final stylistIdIn = stylistClass.tid;
    List<String> bookTime = [];
    bookTime.add(time);
    List<String> ids = [];
    await FirebaseFirestore.instance
        .collection('bookdate')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        ids.add(doc.id);
      });
    });
    if (ids.contains(stylistIdIn)) {
      await bookTimeList
          .doc(stylistIdIn)
          .update({'${toDate(bookDate)}': FieldValue.arrayUnion(bookTime)});
    } else {
      await bookTimeList
          .doc(stylistIdIn)
          .set({'${toDate(bookDate)}': FieldValue.arrayUnion(bookTime)});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
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
                        onPressed: () => Navigator.pop(context)),
                    IconButton(
                      icon: Icon(
                        Icons.save,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
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
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                      ),
                      Center(
                        child: Text(
                          'Booking Date and Time',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                          'Check the below box to upload your own service style image',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                            fontSize: 18,
                          )),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Checkbox(
                            activeColor: Colors.green,
                            value: _check,
                            onChanged: (bool? value) {
                              setState(() {
                                _check = value!;
                              });
                            }),
                      ),
                      _check == true
                          ? Center(
                              child: Container(

                                padding: EdgeInsets.all(5.0),
                                width: MediaQuery.of(context).size.width / 2,
                                height: MediaQuery.of(context).size.width / 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: _loadImage == false
                                      ? FadeInImage.assetNetwork(
                                          placeholder:
                                              'assets/images/no_picture.png',
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
                            )
                          : SizedBox(height: 0),
                      _check == true
                          ? Padding(
                              padding:
                                  EdgeInsets.only(bottom: 2, left: 185, top: 0),
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  onPressed: _getServiceImage,
                                ),
                              ),
                            )
                          : SizedBox(height: 0),

                      SizedBox(height: 5.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Date',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          // Expanded(
                          //   flex: 1,
                          //   child: Text(
                          //     'Time',
                          //     style: TextStyle(
                          //       fontWeight: FontWeight.bold,
                          //       fontSize: 24,
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: buildDropDown(
                                text: toDate(bookDate),
                                onClicked: () => pickBookDate(pickDate: true)),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Available time',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      _workingTime.length > 1
                          ? Row(
                              children: [
                                Expanded(
                                  child: DropdownButton(
                                    value: time,
                                    items:
                                        _workingTime.map((String workingDay) {
                                      return DropdownMenuItem(
                                        value: workingDay,
                                        child: Text(workingDay),
                                      );
                                    }).toList(),
                                    hint: Text('Choose working time'),
                                    dropdownColor: Colors.white,
                                    icon: Icon(Icons.arrow_drop_down),
                                    iconSize: 25,
                                    isExpanded: true,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22,
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        time = newValue!;
                                      });
                                    },
                                  ),
                                )
                              ],
                            )
                          : Center(
                              child: Text(
                                'Sorry!! All the available Time slots for this particular stylist on this day have been taken.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                      SizedBox(height: 50),
                      // TextInputField(
                      //   icon: Icons.phone,
                      //   hint: 'Tel..',
                      //   inputType: TextInputType.number,
                      //   inputAction: TextInputAction.next,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       tel = value;
                      //     });
                      //   },
                      // ),
                      // TextInputField(
                      //   icon: Icons.home,
                      //   hint: 'hostel name',
                      //   inputType: TextInputType.text,
                      //   inputAction: TextInputAction.next,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       hostelName = value;
                      //     });
                      //   },
                      // ),

                      RoundedButton(
                        buttonName: 'Book',
                        action: _validateAndBook,
                      ),
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

  Widget buildDropDown({
    required String text,
    required VoidCallback onClicked,
  }) =>
      ListTile(
        title: Text(text),
        trailing: Icon(Icons.arrow_drop_down),
        onTap: onClicked,
      );

  Future pickBookDate({required bool pickDate}) async {
    final date = await pickDateTime(
      bookDate,
      pickDate: pickDate,
      firstDate: pickDate ? bookDate : null,
    );
    if (date == null) return;
    setState(() {
      bookDate = date;
    });
    // load available time for this particular sytlist when bookDate changes
    await _loadStylistAvailableTimeSlot();
  }

  // method showing calendar to be picking the date and time from by using the switches
  Future<DateTime?> pickDateTime(
    DateTime initialDate, {
    required bool pickDate,
    DateTime? firstDate,
  }) async {
    if (pickDate) {
      final date = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(2020),
        lastDate: DateTime(2101),
      );
      if (date == null) return null;

      final time =
          Duration(hours: initialDate.hour, minutes: initialDate.minute);
      print(date);
      return date.add(time);
    } else {
      final timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      if (timeOfDay == null) return null;

      final date =
          DateTime(initialDate.year, initialDate.month, initialDate.day);
      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);
      return date.add(time);
    }
  }

  Future _getServiceImage() async {
    late File image;
    // String tid = userData.userRef['uid'];
    final img = await _picker.pickImage(source: ImageSource.gallery);
    _loadImage = true;
    File file = File(img!.path);
    setState(() {
      image = file;
    });
    var storeImage = FirebaseStorage.instance.ref().child(image.path);
    var task = await storeImage.putFile(image);
    var serviceImgUrl = await storeImage.getDownloadURL();
    setState(() {
      imgUrl = serviceImgUrl;
      _loadImage = false;
    });
  }
}
