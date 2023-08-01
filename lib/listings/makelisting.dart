//to input a listing

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:fluttertoast/fluttertoast.dart';
import '/models/listing.dart';
import '/services/database.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class MakeListing extends StatefulWidget {
  const MakeListing({
    Key? key,
  }) : super(key: key);

  @override
  State<MakeListing> createState() => _MakeListingState();
}

class _MakeListingState extends State<MakeListing> {
  final _formKey = GlobalKey<FormState>();
  final List<String> type = ['Found', 'Lost'];
  String? _type;

  DateTime? _currentDate = DateTime.now();
  String? description;
  String? location;
  String? _currentPhone;
  String? _name;
  String? photo;
  Uint8List webImage = Uint8List(10);
  File? _image;

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
                DropdownButtonFormField(
                  hint: const Text('Select Type'),
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  value: _type ?? "Found",
                  items: type.map((location) {
                    return DropdownMenuItem(
                      value: location,
                      child: Text('$location'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _type = val),
                ),
                const SizedBox(height: 30.0),
                TextFormField(
                  onTap: () {
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true, onChanged: (date) {
                      setState(() {
                        _currentDate = date;
                      });
                    }, onConfirm: (date) {
                      setState(() {
                        _currentDate = date;
                      });
                      print('confirm $date');
                    }, currentTime: DateTime.now(), locale: LocaleType.en);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Date&Time when lost/found',
                    hintText: 'Date&Time when lost/found',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  controller: TextEditingController(
                    text: _currentDate.toString().substring(0, 16),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Please enter a date' : null,
                ),
                SizedBox(
                  height: 30,
                ),
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
                    labelText: 'Location',
                    hintText: 'Location',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Please enter a location' : null,
                  onChanged: (val) => setState(() => location = val),
                ),
                SizedBox(
                  height: 20,
                ),
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

                const SizedBox(height: 20.0),
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
                          location = location ?? "Found";
                          _currentPhone = _currentPhone ?? "0000000000";
                          _currentDate = _currentDate ?? DateTime.now();
                          _name = _name ?? "item name";

                          if (_currentDate != null &&
                              location != null &&
                              _currentPhone != null &&
                              _name != null) {
                            if (_formKey.currentState!.validate()) {
                              _handleButtonClick();
                              if (_image != null) {
                                // Check if the previous image exists before deleting it
                                final storage =
                                    firebase_storage.FirebaseStorage.instance;

                                // Upload the new image to Firebase Storage
                                final imageName = uid.uid +
                                    _name.toString() +
                                    '_' +
                                    _currentDate.toString();

                                final storageRef =
                                    storage.ref().child('lostfound/$imageName');

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
                                  .updateUserData1(
                                _type ?? "Found",
                                _name ?? "Object",
                                description ?? "Description",
                                _name ?? "Object" + "101",
                                location ?? "MIT",
                                _currentDate.toString() ??
                                    DateTime.now().toString(),
                                _currentPhone ?? "0000000000",
                                user.uid.toString(),
                                photo ?? "",
                              );
                              //show Fluttertoast
                              Fluttertoast.showToast(msg: "Item listed");
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, 'homeLF');
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
