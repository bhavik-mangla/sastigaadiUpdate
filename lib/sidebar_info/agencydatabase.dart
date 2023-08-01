import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class FireStoreDataBase {
  Future<List<Reference>> getImages() async {
    final storageRef =
        FirebaseStorage.instance.ref().child("agencies").child('manipal');

    final listResult = await storageRef.listAll();

    return listResult.items;
  }
}
