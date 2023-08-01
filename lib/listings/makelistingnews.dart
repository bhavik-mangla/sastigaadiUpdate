//to input a listing

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/models/listing.dart';
import '/services/database.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

class MakeListingNews extends StatefulWidget {
  const MakeListingNews({
    Key? key,
  }) : super(key: key);

  @override
  State<MakeListingNews> createState() => _MakeListingNewsState();
}

class _MakeListingNewsState extends State<MakeListingNews> {
  final _formKey = GlobalKey<FormState>();
  String? title;
  String? description;
  String? link;
  String? approved = 'false';
  String? category;
  String? date;
  String? newsId;
  String? photo;
  File? _image; // Add this line
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
                    labelText: 'Title of News',
                    hintText: 'Keep it short and sweet',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Please enter News Title' : null,
                  onChanged: (val) => setState(() => title = val),
                ),
                const SizedBox(height: 30.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Description',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  maxLines: null, // Allow multiple lines
                  validator: (val) =>
                      val!.isEmpty ? 'Please enter a Description' : null,
                  onChanged: (val) => setState(() => description = val),
                ),
                const SizedBox(height: 30.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Please enter news category' : null,
                  onChanged: (val) => setState(() => category = val),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Attach any Links if any',
                    hintText: 'Attach any Links if any',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  onChanged: (val) => setState(() => link = val),
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
                  child: Text('Add Image'),
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
                          date = DateTime.now().toString();
                          if (title != null &&
                              description != null &&
                              category != null) {
                            if (_formKey.currentState!.validate()) {
                              _handleButtonClick();
                              if (_image != null) {
                                // Check if the previous image exists before deleting it
                                final storage =
                                    firebase_storage.FirebaseStorage.instance;

                                // Upload the new image to Firebase Storage
                                final imageName = uid.uid +
                                    title.toString() +
                                    '_' +
                                    date.toString();
                                final storageRef =
                                    storage.ref().child('News/$imageName');
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

                              newsId = title.toString() + '_' + date.toString();

                              await DatabaseService(uid: user.uid)
                                  .updateUserData4(
                                title ?? "",
                                description ?? "",
                                photo ?? "",
                                date ?? DateTime.now().toString(),
                                newsId,
                                category ?? "",
                                link ?? "",
                                approved ?? "false",
                              );
                              //show Fluttertoast
                              Fluttertoast.showToast(
                                msg: "News listed, Please wait for Approval!",
                                timeInSecForIosWeb: 5,
                              );
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, 'home');
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
