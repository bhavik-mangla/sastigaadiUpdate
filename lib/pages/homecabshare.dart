import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:date_field/date_field.dart';
import '/services/database.dart';
import '../authentication/auth.dart';
import '/models/listing.dart';
import 'cab_listings.dart';

class HomeCabScreen extends StatefulWidget {
  const HomeCabScreen({Key? key}) : super(key: key);

  @override
  State<HomeCabScreen> createState() => _HomeCabScreenState();
}

class _HomeCabScreenState extends State<HomeCabScreen> {
  String? _currentLocation;
  DateTime? selectedDate;
  DateTime? selectedTime;

  final List<String> locations = [
    'Manipal to Mangalore Airport',
    'Mangalore Airport to Manipal'
  ];

  @override
  Widget build(BuildContext context) {
    AuthService authService = AuthService();
    final User? uid = FirebaseAuth.instance.currentUser;
    final User user = uid!;
    TextEditingController name = TextEditingController(
        text: DatabaseService().nameFromLearnerID(user.email ?? ""));
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Share Cab"),
        backgroundColor: Colors.red[900],
        elevation: 0.0,
        actions: [
          //add a side navigation bar
          IconButton(
            onPressed: () {
              //are you sure you want to logout? dialog box
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Sign Out"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          authService.signOut();
                          Fluttertoast.showToast(
                              msg: "Logged Out",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            'signin',
                            (route) => false,
                          );
                        },
                        child: const Text("Sign Out"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                //book a cab
                SizedBox(
                  height: 25,
                ),
                Text(
                  "Looking for a ride?",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 100,
                ),
                Text(
                  "Where to?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                DropdownButtonFormField(
                  hint: const Text('Select Location'),
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  value: _currentLocation,
                  items: locations.map((location) {
                    return DropdownMenuItem(
                      value: location,
                      child: Text('$location'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _currentLocation = val),
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  "Date?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                DateTimeField(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: 'Please select date of flight',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    selectedDate: selectedDate,
                    mode: DateTimeFieldPickerMode.date,
                    onDateSelected: (DateTime value) {
                      setState(() {
                        selectedDate = value;
                      });
                    }),
                SizedBox(
                  height: 25,
                ),
                Text(
                  "Time?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                DateTimeField(
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      labelStyle: TextStyle(color: Colors.white),
                      hintText:
                          'Please select time of flight arrival/departure',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    selectedDate: selectedTime,
                    mode: DateTimeFieldPickerMode.time,
                    onDateSelected: (DateTime value) {
                      setState(() {
                        selectedTime = value;
                      });
                    }),
                SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  //blue color button
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900]),
                  onPressed: () async {
                    if (_currentLocation == null) {
                      Fluttertoast.showToast(
                          msg: "Please select a destination",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    } else if (selectedDate == null) {
                      Fluttertoast.showToast(
                          msg: "Please select a date",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    } else if (selectedTime == null) {
                      Fluttertoast.showToast(
                          msg: "Please select a time",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    } else {
                      //check for any listings

                      // Stream<List<Listing>> listings = Provider.of<List<Listing>>(context, listen: false).where('location', isEqualTo: _cnt.dropDownValue).where('date', isEqualTo: selectedDate).where('time', isEqualTo: selectedTime).snapshots().map(listingFromSnapshot);

                      //get all listings
                      Stream<List<Listing>> listings =
                          DatabaseService().listings;
                      DatabaseService db = DatabaseService();

                      int count2 = await db.countAllListings();
                      if (count2 == 0) {
                        //create a new listing
                        Fluttertoast.showToast(
                            msg: "No listings found, create a new one",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                        Navigator.pushNamed(context, 'makeride');
                      } else {
                        //check if any listings match the user's requirements
                        //if yes, show the listings
                        //if no, create a new listing

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CabListings(
                                    location: _currentLocation.toString(),
                                    date: selectedDate
                                        .toString()
                                        .substring(0, 10),
                                    time: selectedTime ?? DateTime.now())));
                      }
                    }
                  },
                  child: Text("Search"),
                ),
                SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
