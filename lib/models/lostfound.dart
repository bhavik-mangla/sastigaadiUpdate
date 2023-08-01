//listing model

import 'package:cloud_firestore/cloud_firestore.dart';

class Listinglf {
  final String reporttype;
  final String mainCategory;
  final String name;
  final String description;
  final String? itemId;
  final String? reportStatus;
  final String? location;
  final String? date;
  final String? phone;
  final String? uId;
  final String? photo;

  Listinglf(
    this.reporttype,
    this.mainCategory,
    this.name,
    this.description,
    this.itemId,
    this.reportStatus,
    this.location,
    this.date,
    this.phone,
    this.uId,
    this.photo,
  );

  //get all listings from database

  factory Listinglf.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Listinglf(
      data['reporttype'] ?? '',
      data['mainCategory'] ?? '',
      data['name'] ?? '',
      data['description'] ?? '',
      data['itemId'] ?? '',
      data['reportStatus'] ?? '',
      data['location'] ?? '',
      data['date'] ?? '',
      data['phone'] ?? '',
      data['uId'] ?? '',
      data['photo'] ?? '',
    );
  }

  //initialize listing

  Map<String, dynamic> toMap() {
    return {
      'reporttype': reporttype,
      'mainCategory': mainCategory,
      'name': name,
      'description': description,
      'itemId': itemId,
      'reportStatus': reportStatus,
      'location': location,
      'date': date,
      'phone': phone,
      'uId': uId,
      'photo': photo,
    };
  }

//add one listing to array of listings
}

class Users {
  final String? uid;
  final String? name;
  final String? email;
  final String? phone;
  final String? photo;
  final String? address;
  final String? college;

  Users(
    this.uid,
    this.name,
    this.email,
    this.phone,
    this.photo,
    this.address,
    this.college,
  );

  factory Users.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Users(
      data['uid'] ?? '',
      data['name'] ?? '',
      data['email'] ?? '',
      data['phone'] ?? '',
      data['photo'] ?? '',
      data['address'] ?? '',
      data['college'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'photo': photo,
      'address': address,
      'college': college,
    };
  }
}
