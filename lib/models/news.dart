//listing model

import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  final String uId;
  final String newsId;
  final String category;
  final String photo;
  final String description;
  final String title;
  final String link;
  final String approved;
  final String date;

  News({
    required this.uId,
    required this.newsId,
    required this.category,
    required this.photo,
    required this.description,
    required this.title,
    required this.link,
    required this.date,
    required this.approved,
  });
  //get all listings from database

  factory News.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return News(
      uId: data['uId'],
      newsId: data['newsId'],
      category: data['category'],
      photo: data['photo'],
      description: data['description'],
      title: data['title'],
      link: data['link'],
      date: data['date'],
      approved: data['approved'],
    );
  }
  //initialize listing

  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'newsId': newsId,
      'category': category,
      'photo': photo,
      'description': description,
      'title': title,
      'link': link,
      'date': date,
      'approved': approved,
    };
  }

//add one listing to array of listings
}
