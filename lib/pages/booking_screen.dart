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
  CollectionReference bookList = FirebaseFirestore.instance.collection('booklist');
  CollectionReference bookTimeList = FirebaseFirestore.instance.collection('bookdate');

  late DateTime bookDate;
  String time = '';
  String stylistId = '';
  String stylistName = '';
  String tel = '';
  String hostelName = '';
  String cusName = '';

   List<String> _workingTime = [
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
  stylistId = stylistClass.tid;
  await bookTimeList.doc(stylistId).get().then((query) {
    Map<String, dynamic> data = query.data() as Map<String, dynamic>;
     List<String> booktime = data[toDate(bookDate)];
    booktime.forEach((timeTaken) { 
      if(_workingTime.contains(timeTaken)){
          _workingTime.remove(timeTaken);
      }else return;
     });
  });
}


  @override
  void initState() {
    super.initState();
    bookDate = DateTime.now();
  _loadStylistAvailableTimeSlot();
  }

  Future<void> addToBookedList() async {
    final authClass = Provider.of<AuthClass>(context, listen: false);
    final stylist = Provider.of<Stylist>(context, listen: false);
    final userData = Provider.of<UserData>(context, listen: false);
    final userId = authClass.auth.currentUser!.uid;
    cusName = userData.userName;
    stylistId = stylist.tid;
    stylistName = stylist.stylistName;
    List bookItem = [];
    bookItem.add(toMap());
    List<String> ids = [];
    await FirebaseFirestore.instance
        .collection('booklist')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        ids.add(doc.id);
      });
    });
    if (ids.contains(userId)) {
      await bookList
          .doc(userId)
          .update({'bookedList': FieldValue.arrayUnion(bookItem)})
          .then((value){
            _addToBookDateList();
          Navigator.pushNamed(context, 'BookList');
          } 
          ) 
          .catchError((error) {
            print("Failed to book: $error");
          });
    } else {
      await bookList
          .doc(userId)
          .set({'bookedList': FieldValue.arrayUnion(bookItem)})
          .then((value){
            _addToBookDateList();
          Navigator.pushNamed(context, 'BookList');
          } 
          )
          .catchError((error) {
            print("Failed to book: $error");
          });
    }
  }

  Map<String, dynamic> toMap() {
  final serviceIns = Provider.of<Service>(context, listen: false);
    return {
      'cusName': cusName,
      'price': serviceIns.serviceRef['price'],
      'title': serviceIns.serviceRef['title'],
      'hostelName': hostelName,
      'tid': stylistId,
      'stylistName': stylistName,
      'tel': tel,
      'time': toTime(bookDate),
      'date': toDate(bookDate),
      'status': 'pending'
    };
  }

void _addToBookDateList() async {
  final stylistClass = Provider.of<Stylist>(context,listen: false);
  stylistId = stylistClass.tid;
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
     if (ids.contains(stylistId)) {
      await bookTimeList.doc(stylistId).update({
      '${toDate(bookDate)}' : FieldValue.arrayUnion(bookTime)
     });

     }else {
       await bookTimeList.doc(stylistId).set({
         '${toDate(bookDate)}' : FieldValue.arrayUnion(bookTime)
       });
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
                height: MediaQuery.of(context).size.height,
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
                        'Booking Date and Time',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Date',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Time',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          )
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
                          Expanded(child: DropdownButton(
                              value: time,
                              onChanged: (String? newValue) {
                                setState(() {
                                  time = newValue!;
                                });
                              },
                              items: _workingTime.map((workingDay) {
                                return DropdownMenuItem(
                                  value: workingDay,
                                  child: Text(workingDay),
                                );
                              }).toList(),
                              hint: Text('Choose working days'),
                              dropdownColor: Colors.white,
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 36,
                              isExpanded: true,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                              ),
                            ),)

                         // TODO  return some message to the customer if there's not available time
                        ],
                      ),
                      SizedBox(height: 30),
                      TextInputField(
                        icon: Icons.phone,
                        hint: 'Tel..',
                        inputType: TextInputType.number,
                        inputAction: TextInputAction.next,
                        onChanged: (value) {
                          setState(() {
                            tel = value;
                          });
                        },
                      ),

                      TextInputField(
                        icon: Icons.home,
                        hint: 'hostel name',
                        inputType: TextInputType.text,
                        inputAction: TextInputAction.next,
                        onChanged: (value) {
                          setState(() {
                            hostelName = value;
                          });
                        },
                      ),
                     
                      RoundedButton(
                        buttonName: 'Book',
                        action: addToBookedList,
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
    setState(() async {
      bookDate = date;
     await _loadStylistAvailableTimeSlot();
    });
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
          // _loadStylistAvailableTimeSlot();
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
      // _loadStylistAvailableTimeSlot();
      return date.add(time);
    }
  }
}
