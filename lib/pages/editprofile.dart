//edit profile

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:sastigaadi/pages/profile.dart';
import '../models/lostfound.dart';
import '/services/database.dart';

class EditProfile extends StatefulWidget {
  EditProfile({
    Key? key,
  }) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  String? _name;
  String? _phone;
  String? _img;
  String? address;
  String? college;
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
    DatabaseService db = DatabaseService(uid: _auth.currentUser!.uid);
    final details = db.getUserDetails();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.red[900],
      ),
      body: FutureBuilder(
        future: details,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: snapshot.data!.name,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _name = value;
                          });
                        },
                      ),
                      TextFormField(
                        initialValue: snapshot.data!.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _phone = value;
                          });
                        },
                      ),
                      //image picker here

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
                        child: Text('Add/Update Profile Image'),
                      ),
                      // Display the selected image
                      (_image != null)
                          ? (kIsWeb)
                              ? Image.memory(webImage)
                              : Image.file(_image!)
                          : Text('No image selected.'),

                      TextFormField(
                        initialValue: snapshot.data!.college,
                        decoration: const InputDecoration(
                          labelText: 'College',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your College';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            college = value;
                          });
                        },
                      ),
                      TextFormField(
                        initialValue: snapshot.data!.address,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Address';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            address = value;
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: _isButtonEnabled
                            ? () async {
                                _handleButtonClick();
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  try {
                                    final user = _auth.currentUser;
                                    final uid = user!.uid;

                                    if (_image != null) {
                                      // Check if the previous image exists before deleting it
                                      final storage = firebase_storage
                                          .FirebaseStorage.instance;
                                      final oldImageRef =
                                          storage.ref().child('images/$uid');

                                      try {
                                        // Get the download URL, which will throw an error if the object does not exist
                                        await oldImageRef.getDownloadURL();

                                        // Delete the previous image
                                        await oldImageRef.delete();
                                      } catch (e) {
                                        // Handle the error if the object does not exist
                                        print('Previous image does not exist');
                                      }

                                      // Upload the new image to Firebase Storage
                                      final imageName = uid;
                                      final storageRef = storage
                                          .ref()
                                          .child('images/$imageName');
                                      if (kIsWeb) {
                                        final uploadTask =
                                            storageRef.putData(await webImage);
                                        await uploadTask
                                            .whenComplete(() => null);
                                      } else {
                                        final uploadTask =
                                            storageRef.putFile(_image!);
                                        await uploadTask
                                            .whenComplete(() => null);
                                      }
                                      final downloadURL =
                                          await storageRef.getDownloadURL();

                                      _img = downloadURL;
                                    }
                                    await db.updateUserData3(
                                      name: _name ?? snapshot.data!.name,
                                      phone: _phone ?? snapshot.data!.phone,
                                      photo: _img ?? snapshot.data!.photo,
                                      address:
                                          address ?? snapshot.data!.address,
                                      college:
                                          college ?? snapshot.data!.college,
                                      email: user.email,
                                    );

                                    Fluttertoast.showToast(
                                        msg: "Profile Updated",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red[900],
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    Navigator.pop(context);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Profile()));
                                  } catch (e) {
                                    print(e);
                                  }
                                }
                              }
                            : null,
                        child: const Text('Update'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _name = value;
                          });
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _phone = value;
                          });
                        },
                      ),
                      //image picker here

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
                        child: Text('Add/Update Profile Image'),
                      ),
                      // Display the selected image
                      (_image != null)
                          ? (kIsWeb)
                              ? Image.memory(webImage)
                              : Image.file(_image!)
                          : Text('No image selected.'),

                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'College',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your College';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            college = value;
                          });
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Address',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Address';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            address = value;
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: _isButtonEnabled
                            ? () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  try {
                                    final user = _auth.currentUser;
                                    final uid = user!.uid;

                                    if (_image != null) {
                                      // Check if the previous image exists before deleting it
                                      final storage = firebase_storage
                                          .FirebaseStorage.instance;
                                      final oldImageRef =
                                          storage.ref().child('images/$uid');

                                      try {
                                        // Get the download URL, which will throw an error if the object does not exist
                                        await oldImageRef.getDownloadURL();

                                        // Delete the previous image
                                        await oldImageRef.delete();
                                      } catch (e) {
                                        // Handle the error if the object does not exist
                                        print('Previous image does not exist');
                                      }

                                      // Upload the new image to Firebase Storage
                                      final imageName = uid;
                                      final storageRef = storage
                                          .ref()
                                          .child('images/$imageName');
                                      if (kIsWeb) {
                                        final uploadTask =
                                            storageRef.putData(await webImage);
                                        await uploadTask
                                            .whenComplete(() => null);
                                      } else {
                                        final uploadTask =
                                            storageRef.putFile(_image!);
                                        await uploadTask
                                            .whenComplete(() => null);
                                      }
                                      final downloadURL =
                                          await storageRef.getDownloadURL();

                                      _img = downloadURL;
                                    }
                                    await db.updateUserData3(
                                      name: _name,
                                      phone: _phone,
                                      photo: _img,
                                      address: address,
                                      college: college,
                                      email: user.email,
                                    );

                                    Fluttertoast.showToast(
                                        msg: "Profile Updated",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red[900],
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    Navigator.pop(context);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Profile()));
                                  } catch (e) {
                                    print(e);
                                  }
                                }
                              }
                            : null,
                        child: const Text('Update'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
