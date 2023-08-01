import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:date_field/date_field.dart';
import '../listings/bookride.dart';
import '../listings/makelistingnews.dart';
import '../models/constantWidgets.dart';
import '../models/lostfound.dart';
import '../models/news.dart';
import '/services/database.dart';
import 'package:url_launcher/url_launcher.dart';
import '../authentication/auth.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import '/models/listing.dart';
import 'package:provider/provider.dart';

import '../providers/sign.dart';
import 'cab_listings.dart';
import 'package:flutter/foundation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int a = 1;
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows) {
      setState(() {
        a = 2;
      });
    }
    AuthService authService = AuthService();
    final data = Provider.of<SignInOrRegister>(context, listen: false);
    final User? uid = FirebaseAuth.instance.currentUser;
    final User user = uid!;
    var users = DatabaseService(uid: user.uid).getUserDetails();
    DatabaseService db = DatabaseService();
    Future<List<News>> listings = DatabaseService().sortListingsByDate4();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Wassup"),
        backgroundColor: Colors.red[900],
        elevation: 0.0,
        actions: [
          //add a side navigation bar
          IconButton(
            onPressed: () {
              //are you sure you want to logout? dialog box
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Sign Out"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          authService.signOut();
                          Fluttertoast.showToast(
                              msg: "Logged Out",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            'signin',
                            (route) => false,
                          );
                        },
                        child: const Text("Sign Out"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FutureBuilder<Users>(
                      future: users,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.photo != "")
                            return CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  NetworkImage(snapshot.data!.photo.toString()),
                            );
                          else
                            return CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  AssetImage('assets/images/user.png'),
                            );
                        } else {
                          return const CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('assets/images/user.png'),
                          );
                        }
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      user.email ?? "Anonymous",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(color: Colors.red[900]),
            ),
            SizedBox(
              height: 20,
            ),
            ListTile(
              leading: Icon(
                Icons.directions_car,
                size: 28,
              ),
              visualDensity: VisualDensity(horizontal: -4, vertical: 0),
              title: Text('Share cab', style: TextStyle(fontSize: 20)),
              onTap: () {
                Navigator.pushNamed(context, 'homeshare');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.search,
                size: 28,
              ),
              visualDensity: VisualDensity(horizontal: -4, vertical: 0),
              title: Text('Lost Found', style: TextStyle(fontSize: 20)),
              onTap: () {
                Navigator.pushNamed(context, 'homeLF');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.attach_money,
                size: 28,
              ),
              visualDensity: VisualDensity(horizontal: -4, vertical: 0),
              title: Text('Buy Sell', style: TextStyle(fontSize: 20)),
              onTap: () {
                Navigator.pushNamed(context, 'homeBS');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.person_2_outlined,
                size: 28,
              ),
              visualDensity: VisualDensity(horizontal: -4, vertical: 0),
              title: Text('Profile', style: TextStyle(fontSize: 20)),
              onTap: () {
                Navigator.pushNamed(context, 'profile');
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            listings = DatabaseService().sortListingsByDate4();
          });
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: FutureBuilder<List<News>>(
                future: listings,
                builder: (context, snapshot1) {
                  if (snapshot1.hasData) {
                    print(snapshot1.data!);
                    return MasonryGridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(0),
                        itemCount: snapshot1.data!.length,
                        crossAxisCount: a,
                        mainAxisSpacing: 0,
                        crossAxisSpacing: 10,
                        itemBuilder: (context, index) {
                          if (snapshot1.data![index].approved == "true" ||
                              user.uid == snapshot1.data![index].uId ||
                              user.uid == "zHhIgl14Yde0QmSpi2w3Gw1qnh12" ||
                              user.uid == "admin") {
                            return Card(
                              color: Colors.black,
                              shape: RoundedRectangleBorder(),
                              child: ProductTileNews(
                                photo: snapshot1.data![index].photo ?? "",
                                title: snapshot1.data![index].title ?? "",
                                description:
                                    snapshot1.data![index].description ?? "",
                                date: snapshot1.data![index].date ?? "",
                                link: snapshot1.data![index].link ?? "",
                                category: snapshot1.data![index].category ?? "",
                                newsId: snapshot1.data![index].newsId ?? "",
                                uid: snapshot1.data![index].uId ?? "",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductTileBigNews(
                                        newsId: snapshot1.data![index].newsId,
                                        photo:
                                            snapshot1.data![index].photo ?? "",
                                        title:
                                            snapshot1.data![index].title ?? "",
                                        description: snapshot1
                                                .data![index].description ??
                                            "",
                                        date: snapshot1.data![index].date ?? "",
                                        link: snapshot1.data![index].link ?? "",
                                        category:
                                            snapshot1.data![index].category ??
                                                "",
                                        uid: snapshot1.data![index].uId ?? "",
                                        onTap: () {},
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                            //
                          } else {
                            return Container();
                          }
                        });
                  } else {
                    //circle progress indicator
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MakeListingNews(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.red[900],
      ),
    );
  }
}
