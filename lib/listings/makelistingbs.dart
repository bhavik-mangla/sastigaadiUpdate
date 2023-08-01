//to input a listing

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/buysell.dart';
import '/models/listing.dart';
import '/services/database.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

class MakeListingBS extends StatefulWidget {
  const MakeListingBS({
    Key? key,
  }) : super(key: key);

  @override
  State<MakeListingBS> createState() => _MakeListingBSState();
}

class _MakeListingBSState extends State<MakeListingBS> {
  final _formKey = GlobalKey<FormState>();
  String? oprice;
  String? description;
  String? price;
  String? _currentPhone;
  String? _name;
  String? photo;
  File? _image; // Add this line
  String? cdate;
  Uint8List webImage = Uint8List(10);
  bool _isButtonEnabled = true;
  void _handleButtonClick() {
    // Perform your button click logic here

    // Disable the button after the first click
    setState(() {
      _isButtonEnabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? uid = FirebaseAuth.instance.currentUser;
    final User user = uid!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Make a Listing'),
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
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Original Price',
                    hintText: 'Original Price',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (val) => (val!.isEmpty && isNumeric(val))
                      ? 'Please enter valid Original price'
                      : null,
                  onChanged: (val) => setState(() => oprice = val),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Phone Number',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Please enter a phone number' : null,
                  onChanged: (val) => setState(() => _currentPhone = val),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
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
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Description',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Please enter a description' : null,
                  onChanged: (val) => setState(() => description = val),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Selling Price',
                    hintText: 'Selling Price',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (val) => (val!.isEmpty && isNumeric(val))
                      ? 'Please enter valid selling price'
                      : null,
                  onChanged: (val) => setState(() => price = val),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    if (kIsWeb) {
                      final pickedImage = await ImagePicker().pickImage(
                          source: ImageSource.gallery, imageQuality: 50);
                      if (pickedImage != null) {
                        var f = await pickedImage.readAsBytes();
                        setState(() {
                          _image = File("a");
                          webImage = f;
                        });
                      } else {
                        print('No image selected.');
                      }
                    } else {
                      final pickedImage = await ImagePicker().pickImage(
                          source: ImageSource.gallery, imageQuality: 50);
                      if (pickedImage != null) {
                        setState(() {
                          _image = File(pickedImage.path);
                        });
                      }
                    }
                  },
                  child: Text('Add Item Image'),
                ),
                // Display the selected image
                (_image != null)
                    ? (kIsWeb)
                        ? Image.memory(webImage)
                        : Image.file(_image!)
                    : Text('No image selected.'),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red[900],
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _isButtonEnabled
                      ? () async {
                          _handleButtonClick();
                          cdate = DateTime.now().toString();
                          price = price ?? '0';
                          _currentPhone = _currentPhone ?? "0000000000";
                          _name = _name ?? "item name";

                          if (price != null &&
                              oprice != null &&
                              _currentPhone != null &&
                              _name != null) {
                            if (_formKey.currentState!.validate()) {
                              if (_image != null) {
                                // Check if the previous image exists before deleting it
                                final storage =
                                    firebase_storage.FirebaseStorage.instance;

                                // Upload the new image to Firebase Storage
                                final imageName = uid.uid +
                                    _name.toString() +
                                    '_' +
                                    cdate.toString();
                                final storageRef =
                                    storage.ref().child('buysell/$imageName');
                                if (kIsWeb) {
                                  final uploadTask =
                                      storageRef.putData(await webImage);
                                  await uploadTask.whenComplete(() => null);
                                } else {
                                  final uploadTask =
                                      storageRef.putFile(_image!);
                                  await uploadTask.whenComplete(() => null);
                                }
                                final downloadURL =
                                    await storageRef.getDownloadURL();

                                photo = downloadURL;
                              }
                              await DatabaseService(uid: user.uid)
                                  .updateUserData2(
                                oprice ?? "0",
                                cdate ?? "",
                                _name ?? "Object",
                                description ?? "Description",
                                _name ?? "Object" + "202",
                                price ?? "0",
                                _currentPhone ?? "0000000000",
                                user.uid.toString(),
                                photo ?? "",
                              );
                              //show Fluttertoast
                              Fluttertoast.showToast(msg: "Item listed");
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, 'homeBS');
                            }
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please fill all the fields");
                          }
                        }
                      : null,
                ),
              ],
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
bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}
