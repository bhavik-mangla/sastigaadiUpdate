//listing database

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../models/buysell.dart';
import '../models/lostfound.dart';
import '../models/news.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '/models/listing.dart';

import '../authentication/auth.dart';

class DatabaseService {
  final String uid;

  DatabaseService({this.uid = ''});

  //collection reference
  final CollectionReference listingCollection = FirebaseFirestore.instance
      .collection('listings'); //collection name is listings

  Future updateUserData(String name, String location, String date, String time,
      String college, String phone) async {
    return await listingCollection.doc(uid).set({
      'name': name ?? nameFromLearnerID(getEmailFromUid()),
      'location': location,
      'date': date,
      'time': time,
      'college': college,
      'phone': phone,
      'uid': uid,
    });
  }

  //listing list from snapshot
  List<Listing> _listingListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Listing.fromFirestore(doc);
    }).toList();
  }

  Stream<List<Listing>> get listings {
    return listingCollection.snapshots().map(_listingListFromSnapshot);
  }

  //get email from uid firebase authentication

  String getEmailFromUid() {
    String email = '';
    //get user from uid
    AuthService authService = AuthService();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      email = user.email!;
    }
    return email;
  }

  String nameFromLearnerID(String s) {
    String s1 = "";
    s1 = s[0].toUpperCase();
    for (int i = 1; i < s.length; i++) {
      if (s[i] == ".") {
        s1 += " ";
        s1 += s[i + 1].toUpperCase();
        i += 1;
      } else if (isNumeric(s[i]) || s[i] == "@") {
        break;
      } else {
        s1 += s[i];
      }
    }
    return s1;
  }

  bool isNumeric(String s) {
    if (s == "") {
      return false;
    }
    return double.tryParse(s) != null;
  }

  //filter stream listings by location and date
  Stream<List<Listing>> filterListings(String location, String date) {
    return listingCollection
        .where('date', isEqualTo: date)
        .where('location', isEqualTo: location)
        .orderBy('time', descending: false)
        .snapshots()
        .map(_listingListFromSnapshot);
  }

  //count of all listings with date and location

  Future<int> countListings(String date, String location) async {
    int count = 0;
    await listingCollection
        .where('date', isEqualTo: date)
        .where('location', isEqualTo: location)
        .orderBy('time', descending: false)
        .get()
        .then((value) {
      count = value.docs.length;
    });
    return count;
  }

  //count all listings
  Future<int> countAllListings() async {
    int count = 0;
    await listingCollection.get().then((value) {
      count = value.docs.length;
    });

    return count;
  }

  //delete listing

  Future<void> deleteListing() async {
    await listingCollection
        .doc(uid)
        .delete()
        .then((_) => print('Deleted'))
        .catchError((error) => print('Delete failed: $error'));
    ;
  }

  //sort listings by date
  Stream<List<Listing>> sortListingsByDate() {
    return listingCollection
        .orderBy('date', descending: false)
        .snapshots()
        .map(_listingListFromSnapshot);
  }

  //user's listing

  Stream<List<Listing>> userListing() {
    return listingCollection
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map(_listingListFromSnapshot);
  }

  //get index 0 listing from stream of listings

  Future<Listing> getUserListing() async {
    Listing listing = Listing(
        uid: '',
        name: '',
        location: '',
        date: '',
        time: '',
        college: '',
        phone: '');
    try {
      await listingCollection
          .where('uid', isEqualTo: uid)
          .get()
          .then((value) => listing = Listing.fromFirestore(value.docs[0]));
    } catch (e) {
      print(e);
    }

    return listing;
  }

  //.................................

  final CollectionReference listingCollection1 = FirebaseFirestore.instance
      .collection('ItemsReport'); //collection name is listings

  //listing list from snapshot
  List<Listinglf> _listingListFromSnapshot1(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Listinglf.fromFirestore(doc);
    }).toList();
  }

  Future updateUserData1(
      String mainCategory,
      String name,
      String description,
      String itemId,
      String location,
      String date,
      String phone,
      String uId,
      String photo) async {
    try {
      // Create a reference to the Firestore collection
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection('ItemsReport');

      // Create a new document with a unique ID
      DocumentReference docRef = collectionRef.doc();

      // Set the data you want to add to the document
      Map<String, dynamic> data = {
        'mainCategory': mainCategory,
        'name': name.toLowerCase(),
        'description': description.toLowerCase(),
        'itemId': itemId,
        'location': location,
        'date': date,
        'phone': phone,
        'uId': uId,
        'photo': photo,
      };

      // Add the data to the document without overwriting old data
      await docRef.set(data, SetOptions(merge: true));

      print('Data added successfully!');
    } catch (e) {
      print('Error adding data: $e');
    }
  }

  Future<void> deleteListing1(String name, String date) async {
    await listingCollection1
        .where('name', isEqualTo: name) // add condition for name
        .where('date', isEqualTo: date) // add condition for date
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        document.reference
            .delete()
            .then((_) => print('Deleted'))
            .catchError((error) => print('Delete failed: $error'));
      });
    });
    // Check if the previous image exists before deleting it
    final storage = firebase_storage.FirebaseStorage.instance;
    String s = uid + name + '_' + date;
    final oldImageRef = storage.ref().child('lostfound/$s');
    print(s);

    try {
      // Get the download URL, which will throw an error if the object does not exist
      await oldImageRef.getDownloadURL();

      // Delete the previous image
      await oldImageRef.delete();
    } catch (e) {
      // Handle the error if the object does not exist
      print('Previous image does not exist');
    }
  }

  Future<List<Listinglf>> sortListingsByDate1() {
    return listingCollection1
        .orderBy('date', descending: true)
        .get()
        .then((value) => _listingListFromSnapshot1(value));
  }

  Future<List<Listinglf>> getSearchListing(String search) async {
    search = search.toLowerCase();
    var a = listingCollection1
        .orderBy('date', descending: true)
        .where('name', isEqualTo: search)
        .get()
        .then((value) => _listingListFromSnapshot1(value));
    var b = listingCollection1
        .orderBy('date', descending: true)
        .where('description', isEqualTo: search)
        .get()
        .then((value) => _listingListFromSnapshot1(value));

    List<Listinglf> resultsA = await a;
    List<Listinglf> resultsB = await b;

    List<Listinglf> combinedResults = [...resultsA, ...resultsB];

    return combinedResults;
  }

//.................................

  final CollectionReference listingCollection2 = FirebaseFirestore.instance
      .collection('BuySell'); //collection name is listings

  //listing list from snapshot
  List<Listingbs> _listingListFromSnapshot2(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Listingbs.fromFirestore(doc);
    }).toList();
  }

  Future updateUserData2(
      String oprice,
      String date,
      String name,
      String description,
      String itemId,
      String price,
      String phone,
      String uId,
      String photo) async {
    try {
      // Create a reference to the Firestore collection
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection('BuySell');

      // Create a new document with a unique ID
      DocumentReference docRef = collectionRef.doc();

      // Set the data you want to add to the document
      Map<String, dynamic> data = {
        'oprice': oprice,
        'name': name.toLowerCase(),
        'date': date,
        'description': description.toLowerCase(),
        'itemId': itemId,
        'price': price,
        'phone': phone,
        'uId': uId,
        'photo': photo,
      };

      // Add the data to the document without overwriting old data
      await docRef.set(data, SetOptions(merge: true));

      print('Data added successfully!');
    } catch (e) {
      print('Error adding data: $e');
    }
  }

  Future<void> deleteListing2(String name, String date) async {
    await listingCollection2
        .where('name', isEqualTo: name) // add condition for name
        .where('date', isEqualTo: date) // add condition for date
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        document.reference
            .delete()
            .then((_) => print('Deleted'))
            .catchError((error) => print('Delete failed: $error'));
      });
    });
    final storage = firebase_storage.FirebaseStorage.instance;
    String s = uid + name + '_' + date;
    final oldImageRef = storage.ref().child('buysell/$s');

    try {
      // Get the download URL, which will throw an error if the object does not exist
      await oldImageRef.getDownloadURL();

      // Delete the previous image
      await oldImageRef.delete();
    } catch (e) {
      // Handle the error if the object does not exist
      print('Previous image does not exist');
    }
  }

  Future<List<Listingbs>> sortListingsByDate2() {
    return listingCollection2
        .orderBy('date', descending: true)
        .get()
        .then((value) => _listingListFromSnapshot2(value));
  }

  Future<List<Listingbs>> getSearchListing2(String search) async {
    search = search.toLowerCase();
    var a = listingCollection2
        .orderBy('date', descending: true)
        .where('name', isEqualTo: search)
        .get()
        .then((value) => _listingListFromSnapshot2(value));
    var b = listingCollection2
        .orderBy('date', descending: true)
        .where('description', isEqualTo: search)
        .get()
        .then((value) => _listingListFromSnapshot2(value));

    List<Listingbs> resultsA = await a;
    List<Listingbs> resultsB = await b;

    List<Listingbs> combinedResults = [...resultsA, ...resultsB];

    return combinedResults;
  }

//.................................

  final CollectionReference listingCollection3 = FirebaseFirestore.instance
      .collection('Users'); //collection name is listings

  List<Users> _listingListFromSnapshot3(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Users.fromFirestore(doc);
    }).toList();
  }

//get current user details  from firestore
  Future<Users> getUserDetails() async {
    return listingCollection3
        .where('uid', isEqualTo: uid)
        .get()
        .then((value) => _listingListFromSnapshot3(value)[0]);
  }

  Future updateUserData3(
      {String? name,
      String? location,
      String? college,
      String? email,
      String? photo,
      String? phone,
      String? address}) async {
    return await listingCollection3.doc(uid).set({
      'uid': uid,
      'name': name,
      'college': college,
      'phone': phone,
      'photo': photo,
      'email': email,
      'address': address,
    });
  }

  Future<void> deleteListing3(String email) async {
    await listingCollection3
        .where('email', isEqualTo: email) // add condition for date
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        document.reference
            .delete()
            .then((_) => print('Deleted'))
            .catchError((error) => print('Delete failed: $error'));
      });
    });
    // delete user
    // await FirebaseAuth.instance.currentUser!.delete();
    //
  }

  final CollectionReference listingCollection4 = FirebaseFirestore.instance
      .collection('News'); //collection name is listings

  List<News> _listingListFromSnapshot4(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return News.fromFirestore(doc);
    }).toList();
  }

  Future<List<News>> sortListingsByDate4() {
    return listingCollection4
        .orderBy('date', descending: true)
        .get()
        .then((value) => _listingListFromSnapshot4(value));
  }

  Future updateUserData4(
    String? title,
    String? description,
    String? photo,
    String? date,
    String? newsId,
    String? category,
    String? link,
    String? approved,
  ) async {
    try {
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection('News');

      // Create a new document with a unique ID
      DocumentReference docRef = collectionRef.doc();

      Map<String, dynamic> data = {
        'uId': uid,
        'title': title,
        'description': description,
        'photo': photo,
        'date': date,
        'newsId': newsId,
        'category': category,
        'link': link,
        'approved': approved,
      };

      await docRef.set(data, SetOptions(merge: true));
      print('Data added successfully!');
    } catch (e) {
      print('Error adding data: $e');
    }
  }

  //get document id of news
  Future<String> getMultipleDocumentIDs(String newsId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('News')
        .where('newsId', isEqualTo: newsId) // add condition for date
        .get();
    return snapshot.docs.first.id;
  }

  Future updateUserData5(
    String? title,
    String? description,
    String? photo,
    String? date,
    String newsId,
    String? category,
    String? link,
    String? approved,
  ) async {
    String did = await getMultipleDocumentIDs(newsId);
    return await listingCollection4.doc(did).set({
      'uId': uid,
      'title': title,
      'description': description,
      'photo': photo,
      'date': date,
      'newsId': newsId,
      'category': category,
      'link': link,
      'approved': approved,
    });
  }

  Future<void> deleteListing4(String newsId) async {
    await listingCollection4
        .where('newsId', isEqualTo: newsId) // add condition for date
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        document.reference
            .delete()
            .then((_) => print('Deleted'))
            .catchError((error) => print('Delete failed: $error'));
      });
    });
    final storage = firebase_storage.FirebaseStorage.instance;
    String s = uid + newsId;
    final oldImageRef = storage.ref().child('News/$s');

    try {
      // Get the download URL, which will throw an error if the object does not exist
      await oldImageRef.getDownloadURL();

      // Delete the previous image
      await oldImageRef.delete();
    } catch (e) {
      // Handle the error if the object does not exist
      print('Previous image does not exist');
    }
  }

//name from getUserDetails
}
