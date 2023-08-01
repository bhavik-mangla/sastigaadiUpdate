//to display a listing

// Path: lib/pages/cab_listings.dart
// Compare this snippet from lib/pages/cab_listings.dart:
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/listings/makeride.dart';
import '/models/listing.dart';
import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '/services/database.dart';
import '../listings/bookride.dart';

class CabListings extends StatefulWidget {
  final String location, date;
  DateTime time;
  CabListings(
      {Key? key,
      required this.location,
      required this.date,
      required this.time})
      : super(key: key);

  @override
  State<CabListings> createState() => _CabListingsState(location, date, time);
}

class _CabListingsState extends State<CabListings> {
  final String location, date;
  DateTime time;

  _CabListingsState(this.location, this.date, this.time);

  @override
  Widget build(BuildContext context) {
    DateTime now =
        DateTime.now().isUtc ? DateTime.now() : DateTime.now().toUtc();

    final User? uid = FirebaseAuth.instance.currentUser;
    final User user = uid!;
    Stream<List<Listing>> listings = DatabaseService().sortListingsByDate();
    Stream<List<Listing>> filteredListings =
        DatabaseService().filterListings(location, date);
    Stream<List<Listing>> myListing =
        DatabaseService(uid: user.uid).userListing();
    // Stream<List<Listing>> filteredListings1 =
    //     StreamGroup.merge([filteredListings, myListing]);
    //
    DatabaseService db = DatabaseService();

    //listings based on date and time

    //use method countListings
    job() async {
      int count = await db.countListings(date, location);

      // int count2 = await db.countAllListings();
      if (count == 0) {
        Fluttertoast.showToast(
            msg: "No listings found on this date",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        filteredListings = listings;
      } else {
        Fluttertoast.showToast(
            msg: count.toString() + " listings found on this date",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }

    job();

    return StreamProvider<List<Listing>?>.value(
        value: filteredListings,
        initialData: null,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('Cab Listings'),
            backgroundColor: Colors.red[900],
            elevation: 0.0,
            //option to make listings
            actions: [
              IconButton(
                onPressed: () {
                  String tdate = date.toString().substring(0, 10) +
                      ' ' +
                      time.toString().substring(
                            11,
                          );
                  DateTime tempDate = DateTime.parse(tdate);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MakeRide(
                        location: location,
                        date: tempDate,
                        time: time,
                        college: "Manipal Institute of Technology",
                        phone: "",
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          body: Column(
            children: [
              TextButton(
                onPressed: () {
                  String tdate = date.toString().substring(0, 10) +
                      ' ' +
                      time.toString().substring(
                            11,
                          );
                  DateTime tempDate = DateTime.parse(tdate);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MakeRide(
                        location: location,
                        date: tempDate,
                        time: time,
                        college: "Manipal Institute of Technology",
                        phone: "",
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Couldn't find a ride? Make one!",
                ),
              ),
              Expanded(
                child: Container(
                  child: StreamBuilder<List<Listing>>(
                    stream: filteredListings,
                    builder: (context, snapshot) {
                      print(snapshot.data);
                      if (snapshot.hasData) {
                        return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              if (DateTime.parse((snapshot.data![index].date +
                                      ' ' +
                                      (snapshot.data![index].time)))
                                  .isAfter(now)) {
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Colors.white70, width: 1),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: ListTile(
                                    tileColor: Colors.black,
                                    hoverColor: Colors.red[500],
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BookRide(
                                            listing: snapshot.data![index],
                                          ),
                                        ),
                                      );
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    dense: true,
                                    visualDensity: VisualDensity(vertical: 2.5),
                                    leading: const Icon(Icons.directions_car),
                                    title: Text(
                                        snapshot.data![index].time +
                                            "   " +
                                            snapshot.data![index].date,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15)),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data![index].college ??
                                              "MIT",
                                        ),
                                        Text(
                                          snapshot.data![index].name ??
                                              "Anonymous",
                                          textAlign: TextAlign.end,
                                        ),
                                      ],
                                    ),
                                    //trailing phone icon
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.info_sharp,
                                          ),
                                          onPressed: () {
                                            if (mounted) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BookRide(
                                                    listing:
                                                        snapshot.data![index],
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        if (snapshot.data![index].uid ==
                                            user.uid)
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              //are you sure you want to delete prompt
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "Delete Listing"),
                                                    content: const Text(
                                                        "Are you sure you want to delete this listing?"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                            "Cancel"),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          DatabaseService(
                                                                  uid: user.uid)
                                                              .deleteListing();

                                                          Navigator.of(context)
                                                              .pop();
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Ride deleted");
                                                        },
                                                        child: const Text(
                                                            "Delete"),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                //delete listing
                                DatabaseService(uid: snapshot.data![index].uid)
                                    .deleteListing();
                                return const SizedBox(
                                  height: 0,
                                );
                              }
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
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              String tdate = date.toString().substring(0, 10) +
                  ' ' +
                  time.toString().substring(
                        11,
                      );
              DateTime tempDate = DateTime.parse(tdate);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MakeRide(
                    location: location,
                    date: tempDate,
                    time: time,
                    college: "Manipal Institute of Technology",
                    phone: "",
                  ),
                ),
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
            backgroundColor: Colors.red[900],
          ),
        ));
  }
}
