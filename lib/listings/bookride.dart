//display details of a listing and book it by opening whatsapp using phone number with text message

// Path: lib/pages/bookride.dart

// Compare this snippet from lib/pages/bookride.dart:

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/models/listing.dart';
import '/services/database.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'editride.dart';
import 'makeride.dart';

class BookRide extends StatefulWidget {
  final Listing listing;
  const BookRide({Key? key, required this.listing}) : super(key: key);

  @override
  State<BookRide> createState() => _BookRideState(listing);
}

class _BookRideState extends State<BookRide> {
  final Listing listing;
  _BookRideState(this.listing);
  @override
  Widget build(BuildContext context) {
    final User? uid = FirebaseAuth.instance.currentUser;
    final User user = uid!;

    launchWhatsapp() async {
      var whatsapp = listing.phone.toString();
      var cc = '+91'.toString();
      var androidUrl =
          "whatsapp://send?phone=$cc$whatsapp&text=Hey, I want to share a ride with you";
      var iosUrl =
          "https://wa.me/$cc$whatsapp?text=${Uri.parse('Hey, I want to share a ride with you')}";
      try {
        if (kIsWeb) {
          await launch(iosUrl);
        } else if (Platform.isAndroid) {
          await launch(androidUrl);
        } else if (Platform.isIOS) {
          await launch(iosUrl);
        }
      } on Exception {
        Fluttertoast.showToast(msg: "Whatsapp not installed");
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Book Ride'),
        backgroundColor: Colors.red[900],
        //button to edit ride details
        actions: [
          Row(
            children: [
              if (listing.uid == user.uid)
                IconButton(
                  onPressed: () {
                    String tdate = listing.date.toString() +
                        ' ' +
                        DateTime.now().toString().substring(
                              11,
                            );
                    DateTime tempDate = DateTime.parse(tdate);
                    String time = DateTime.now().toString().substring(0, 10) +
                        ' ' +
                        listing.time.toString();
                    DateTime tempTime = DateTime.parse(time);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditRide(
                          location: listing.location ??
                              "Mangalore Airport to Manipal",
                          date: tempDate,
                          time: tempTime,
                          college: listing.college ??
                              "Manipal Institute of Technology",
                          phone: listing.phone ?? "",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                ),
              if (listing.uid == user.uid)
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Delete Listing"),
                          content: const Text(
                              "Are you sure you want to delete this listing?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                DatabaseService(uid: user.uid).deleteListing();

                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                Fluttertoast.showToast(msg: "Ride deleted");
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.delete),
                ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              //display location
              listing.location,
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              //display location
              listing.college.toString(),
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red[900]!,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    //display date
                    "   " + listing.date.toString() + "   ",
                    style: const TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    //display time
                    listing.time.toString(),
                    style: const TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    //display phone number
                    listing.phone.toString(),
                    style: const TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red[900],
              ),
              onPressed: () {
                if (listing.uid != user.uid) {
                  launchWhatsapp();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("You cannot share with yourself 💀"),
                    ),
                  );
                }
              },
              child: const Text(
                'Share Ride',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              //display phone number
              "with " + listing.name.toString(),
              style: const TextStyle(
                fontSize: 18.0,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text.rich(
              TextSpan(
                text: 'By continuing, you agree to our ',
                style: TextStyle(fontSize: 16, color: Colors.white),
                children: <TextSpan>[
                  TextSpan(
                      text: 'Rules',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          var url = Uri.parse(
                              'https://drive.google.com/file/d/1yUFKbFQHJfN95oEasdeeQgLE-d4AtYJW/view?usp=sharing');
                          await launchUrl(url);
                        }),
                  TextSpan(
                    text: ' and ',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  TextSpan(
                      text: 'T&C',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          var url = Uri.parse(
                              'https://sites.google.com/view/sastigaadi/tnc');
                          await launchUrl(url);
                        }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
