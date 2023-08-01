import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sastigaadi/models/lostfound.dart';
import '/services/database.dart';
import '../authentication/auth.dart';
import 'editprofile.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthService authService = AuthService();
    final User? uid = FirebaseAuth.instance.currentUser;
    final User user = uid!;
    var users = DatabaseService(uid: user.uid).getUserDetails();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.red[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: FutureBuilder<Users>(
              future: users,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      //edit profile
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProfile()));
                            },
                            icon: const Icon(Icons.edit),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      if (snapshot.data!.photo != "")
                        CircleAvatar(
                          radius: 100.0,
                          backgroundImage: NetworkImage(
                              snapshot.data!.photo.toString() ?? ""),
                        )
                      else
                        const CircleAvatar(
                          radius: 100.0,
                          backgroundImage: AssetImage('assets/images/user.png'),
                        ),
                      const SizedBox(height: 20.0),
                      Text(
                        snapshot.data!.name ?? "",
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        snapshot.data!.email ?? "",
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        snapshot.data!.phone ?? "",
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        snapshot.data!.address ?? "",
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        snapshot.data!.college ?? "",
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    // add your code here.
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => EditProfile()));
                  });

                  print(snapshot.error);
                  return const Text('Something went wrong');
                } else {
                  return const CircularProgressIndicator();
                }
              }),
        ),
      ),
    );
  }
}
