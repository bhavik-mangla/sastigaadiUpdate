import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:sastigaadi/models/lostfound.dart';
import '../listings/makelisting.dart';
import '../models/constantWidgets.dart';
import '/services/database.dart';
import '../authentication/auth.dart';
import 'package:flutter/foundation.dart';

class HomeScreenLF extends StatefulWidget {
  const HomeScreenLF({Key? key}) : super(key: key);

  @override
  State<HomeScreenLF> createState() => _HomeScreenLFState();
}

class _HomeScreenLFState extends State<HomeScreenLF> {
  Future<List<Listinglf>> listings = DatabaseService().sortListingsByDate1();
  TextEditingController _searchController = TextEditingController();
  int a = 2;

  @override
  void initState() {
    super.initState();
    listings = DatabaseService().sortListingsByDate1();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows) {
      setState(() {
        a = 3;
      });
    }
    AuthService authService = AuthService();
    final User? uid = FirebaseAuth.instance.currentUser;
    final User user = uid!;
    DatabaseService db = DatabaseService();
    //GET user image from supabase
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: AnimSearchBar(
          color: Colors.red[700],
          searchIconColor: Colors.white,
          rtl: true,
          width: width * 0.8,
          textController: _searchController,
          onSubmitted: (String) async {
            setState(() {
              _searchController.text = String;
            });

            var searchResult = await DatabaseService().getSearchListing(String);

            if (searchResult.isEmpty) {
              Fluttertoast.showToast(
                  msg: "No results found",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red[900],
                  textColor: Colors.white,
                  fontSize: 16.0);
              setState(() {
                listings = DatabaseService().sortListingsByDate1();
              });
            } else {
              setState(() {
                listings = Future.value(searchResult);
              });
            }
          },
          onSuffixTap: () {
            setState(() {
              _searchController.clear();
              listings = DatabaseService().sortListingsByDate1();
            });
          },
        ),
        backgroundColor: Colors.red[900],
        elevation: 0.0,
        actions: [
          //add a side navigation bar
          IconButton(
            onPressed: () {
              //are you sure you want to logout? dialog box
              showDialog(
                context: context, //user context
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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            listings = DatabaseService().sortListingsByDate1();
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: FutureBuilder<List<Listinglf>>(
              future: listings,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return MasonryGridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(0),
                      itemCount: snapshot.data!.length,
                      crossAxisCount: a,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 10,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ProductTile1(
                            image: snapshot.data![index].photo ?? "",
                            name: snapshot.data![index].name,
                            location: snapshot.data![index].location ?? "MIT",
                            description:
                                snapshot.data![index].description ?? "",
                            phone: snapshot.data![index].phone ?? "",
                            uid: snapshot.data![index].uId ?? "",
                            categ: snapshot.data![index].mainCategory ?? "",
                            date: snapshot.data![index].date ?? "",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductTileBig(
                                    uid: snapshot.data![index].uId ?? "",
                                    image: snapshot.data![index].photo ?? "",
                                    name: snapshot.data![index].name,
                                    location:
                                        snapshot.data![index].location ?? "MIT",
                                    description:
                                        snapshot.data![index].description ?? "",
                                    phone: snapshot.data![index].phone ?? "",
                                    date: snapshot.data![index].date ?? "",
                                    onTap: () {},
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                        //
                      });
                } else {
                  //circle progress indicator
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            // coouldn't find desired listing, make one
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MakeListing(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.red[900],
      ),
    );
  }
}
