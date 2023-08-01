//listing model

import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  final String uid;
  final String location;
  final String date;
  final String time;
  final String? college;
  final String? phone;
  final String? name;

  Listing(
      {required this.uid,
      required this.location,
      required this.date,
      required this.time,
      required this.college,
      required this.phone,
      required this.name});

  //get all listings from database
  factory Listing.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Listing(
      uid: data['uid'] ?? '',
      location: data['location'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      college: data['college'] ?? '',
      phone: data['phone'] ?? '',
      name: data['name'] ?? 'Anonymous',
    );
  }

  //initialize listing

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'location': location,
      'date': date,
      'time': time,
      'college': college,
      'phone': phone,
      'name': name,
    };
  }

//add one listing to array of listings
}
