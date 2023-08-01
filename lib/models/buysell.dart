//listing model

import 'package:cloud_firestore/cloud_firestore.dart';

class Listingbs {
  final String price;
  final String oprice;
  final String name;
  final String date;
  final String description;
  final String? itemId;
  final String? phone;
  final String? uId;
  final String? photo;

  Listingbs(
    this.name,
    this.oprice,
    this.date,
    this.description,
    this.itemId,
    this.price,
    this.phone,
    this.uId,
    this.photo,
  );

  //get all listings from database

  factory Listingbs.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Listingbs(
      data['name'] ?? '',
      data['date'] ?? '',
      data['oprice'] ?? '',
      data['description'] ?? '',
      data['itemId'] ?? '',
      data['price'] ?? '',
      data['phone'] ?? '',
      data['uId'] ?? '',
      data['photo'] ?? '',
    );
  }

  //initialize listing

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date,
      'description': description,
      'itemId': itemId,
      'oprice': oprice,
      'price': price,
      'phone': phone,
      'uId': uId,
      'photo': photo,
    };
  }

//add one listing to array of listings
}
