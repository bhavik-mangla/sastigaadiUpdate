//to input a listing

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/models/listing.dart';
import '/services/database.dart';
import 'package:provider/provider.dart';
import 'package:date_field/date_field.dart';

import 'package:firebase_auth/firebase_auth.dart';

class EditRide extends StatefulWidget {
  final String location;
  final DateTime date;
  final DateTime time;
  final String phone;
  final String college;

  const EditRide(
      {Key? key,
      required this.location,
      required this.date,
      required this.time,
      required this.phone,
      required this.college})
      : super(key: key);

  @override
  State<EditRide> createState() =>
      _EditRideState(location, date, time, phone, college);
}

class _EditRideState extends State<EditRide> {
  final String location;
  final DateTime date;
  final DateTime time;
  final String phone;
  final String college;
  _EditRideState(this.location, this.date, this.time, this.phone, this.college);

  final _formKey = GlobalKey<FormState>();
  final List<String> locations = [
    'Manipal to Mangalore Airport',
    'Mangalore Airport to Manipal'
  ];
  String? _currentLocation;
  DateTime? _currentDate;
  DateTime? _currentTime;
  final List<String> colleges = [
    'Manipal Institute of Technology',
    'Kasturba Medical College',
    'WGSHA Manipal',
    'Manipal Academy of Higher Education',
    'Manipal College of Pharmaceutical Sciences',
    'Manipal College of Dental Sciences',
    'Manipal College of Nursing',
    'Manipal College of Allied Health Sciences',
  ];
  String? _currentCollege;
  String? _currentPhone;
  User? uid = FirebaseAuth.instance.currentUser;

  User get user => uid!;

  String? _name;

  @override
  Widget build(BuildContext context) {
    final String name =
        DatabaseService().nameFromLearnerID(user.email ?? "Anonymous");

    return StreamProvider<List<Listing>?>.value(
      value: DatabaseService(uid: 'uid').listings,
      initialData: null,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Edit a Ride'),
          backgroundColor: Colors.red[900],
          elevation: 0.0,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 30.0),
                  DropdownButtonFormField(
                    hint: const Text('Select Location'),
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    value: _currentLocation ?? location,
                    items: locations.map((location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Text('$location'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _currentLocation = val),
                  ),
                  const SizedBox(height: 30.0),
                  DateTimeField(
                      decoration: const InputDecoration(
                        labelText: 'Date of flight',
                        hintText: 'Date of flight',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      selectedDate: _currentDate ?? date,
                      mode: DateTimeFieldPickerMode.date,
                      onDateSelected: (DateTime value) {
                        setState(() {
                          _currentDate = value;
                        });
                      }),
                  SizedBox(
                    height: 30,
                  ),
                  DateTimeField(
                      decoration: const InputDecoration(
                        labelText: 'Time of flight arrival/departure',
                        hintText: 'Time of flight arrival/departure',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      selectedDate: _currentTime ?? time,
                      mode: DateTimeFieldPickerMode.time,
                      onDateSelected: (DateTime value) {
                        setState(() {
                          _currentTime = value;
                        });
                      }),
                  SizedBox(
                    height: 30,
                  ),
                  DropdownButtonFormField(
                    hint: const Text('Select College'),
                    decoration: const InputDecoration(
                      labelText: 'College',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    value: _currentCollege ?? college,
                    items: colleges.map((college) {
                      return DropdownMenuItem(
                        value: college,
                        child: Text('$college'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _currentCollege = val),
                  ),
                  const SizedBox(height: 20.0),
                  //phone number field

                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Phone Number(10 digits)',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    initialValue: phone,
                    validator: (val) => val?.length != 10
                        ? 'Please enter a 10 digit phone number'
                        : null,
                    onChanged: (val) => setState(() => _currentPhone = val),
                  ),
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter your name' : null,
                    onChanged: (val) => setState(() => _name = val),
                  ),

                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red[900],
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      _currentLocation = _currentLocation ?? location;
                      _currentCollege = _currentCollege ?? college;
                      _currentPhone = _currentPhone ?? phone;
                      _currentDate = _currentDate ?? date;
                      _currentTime = _currentTime ?? time;
                      _name = _name ?? name;

                      String date1 = _currentDate.toString().substring(0, 10) +
                          ' ' +
                          _currentTime.toString().substring(
                                11,
                              );
                      DateTime tempDate = DateTime.parse(date1);

                      if (_currentDate != null &&
                          _currentLocation != null &&
                          _currentTime != null &&
                          _currentCollege != null &&
                          _currentPhone != null) {
                        if (_formKey.currentState!.validate() &&
                            tempDate!.isAfter(DateTime.now())) {
                          await DatabaseService(uid: user.uid).updateUserData(
                              _name ?? "Anonymous",
                              _currentLocation ?? location,
                              _currentDate.toString().substring(0, 10) ??
                                  date.toString().substring(0, 10),
                              _currentTime.toString().substring(11, 16) ??
                                  time.toString().substring(11, 16),
                              _currentCollege ?? college,
                              _currentPhone ?? phone);
                          //show Fluttertoast
                          Fluttertoast.showToast(msg: "Ride updated");
                          Navigator.pop(context);
                          Navigator.pop(context);
                        } else if (tempDate!.isBefore(DateTime.now())) {
                          Fluttertoast.showToast(
                              msg: "Please enter a valid date&time");
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: "Please fill all the fields");
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//info page
//book a ride
//internships
