import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../services/database.dart';

class ProductTile1 extends StatefulWidget {
  ProductTile1({
    required this.image,
    required this.name,
    required this.location,
    required this.uid,
    required this.phone,
    required this.description,
    required this.categ,
    required this.date,
    required this.onTap,
    Key? key,
  }) : super(key: key);
  final String image;
  final String name;
  final String location;
  final String uid;
  final String phone;
  final String description;
  final String categ;
  final String date;

  final Function onTap;

  @override
  State<ProductTile1> createState() => _ProductTile1State();
}

class _ProductTile1State extends State<ProductTile1> {
  @override
  Widget build(BuildContext context) {
    final User? uid = FirebaseAuth.instance.currentUser;
    final User user = uid!;

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: SingleChildScrollView(
        child: Container(
          color: Colors.black,
          child: Column(
            children: <Widget>[
              Stack(
                children: [
                  ImageHeroWidget(image: widget.image),
                  Positioned(
                    top: 5.0, // Adjust the top position as needed
                    left: 5.0, // Adjust the left position as needed
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      color: widget.categ == 'Lost'
                          ? Colors.red.withOpacity(0.6)
                          : Colors.green.withOpacity(0.6),
                      child: Text(
                        widget.categ,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductTileBig extends StatefulWidget {
  ProductTileBig({
    required this.image,
    required this.name,
    required this.uid,
    required this.location,
    required this.phone,
    required this.date,
    required this.description,
    required this.onTap,
    Key? key,
  }) : super(key: key);
  final String image;
  final String name;
  final String location;
  final String phone;
  final String uid;
  final String date;
  final String description;

  final Function onTap;

  @override
  State<ProductTileBig> createState() => _ProductTileBigState();
}

class _ProductTileBigState extends State<ProductTileBig> {
  @override
  Widget build(BuildContext context) {
    final User? uid = FirebaseAuth.instance.currentUser;
    final User user = uid!;

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Item Details'),
        backgroundColor: Colors.red[900],
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ImageHeroWidget(image: widget.image),
              //card containing name, price and like button
              Container(
                height: height * 0.07,
                width: width,
                child: ListTile(
                  visualDensity: VisualDensity(horizontal: -4),
                  title: Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    widget.location,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {
                            launchWhatsapp(widget.phone);
                          },
                          icon: Icon(
                            Icons.message,
                          )),
                      if (widget.uid == user.uid ||
                          user.uid == "zHhIgl14Yde0QmSpi2w3Gw1qnh12" ||
                          user.uid == "admin")
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            //are you sure you want to delete prompt
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Delete Listing"),
                                  content: const Text(
                                      "Are you sure you want to delete this listing?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        DatabaseService(uid: user.uid)
                                            .deleteListing1(
                                                widget.name, widget.date);

                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();

                                        Fluttertoast.showToast(
                                            msg:
                                                "Item deleted, Please refresh");
                                      },
                                      child: const Text("Delete"),
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
              ),
              SizedBox(
                height: height * 0.02,
              ),
              //description
              Container(
                width: width,
                child: Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              //item found lost date and time
              SizedBox(
                height: height * 0.02,
              ),
              Container(
                width: width,
                child: Text(
                  "Found/Lost on " + widget.date.substring(0, 16),
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

launchWhatsapp(String phone) async {
  var whatsapp = phone.toString();
  var cc = '+91'.toString();
  var androidUrl =
      "whatsapp://send?phone=$cc$whatsapp&text=Hey, I wanted to know about the item you posted on the Sastigaadi app.";
  var iosUrl =
      "https://wa.me/$cc$whatsapp?text=${Uri.parse('Hey, I wanted to know about the item you posted on the Sastigaadi app')}";
  try {
    if (kIsWeb) {
      await launch(iosUrl);
    } else if (Platform.isAndroid) {
      await launch(androidUrl);
    } else if (Platform.isIOS) {
      await launch(iosUrl);
    }
  } on Exception {
    Fluttertoast.showToast(msg: "Whatsapp not installed");
  }
}

class ProductTilebs extends StatefulWidget {
  ProductTilebs({
    required this.image,
    required this.date,
    required this.name,
    required this.price,
    required this.uid,
    required this.phone,
    required this.description,
    required this.oprice,
    required this.onTap,
    Key? key,
  }) : super(key: key);
  final String image;
  final String name;
  final String date;
  final String price;
  final String uid;
  final String phone;
  final String description;
  final String oprice;
  final Function onTap;

  @override
  State<ProductTilebs> createState() => _ProductTilebsState();
}

class _ProductTilebsState extends State<ProductTilebs> {
  @override
  Widget build(BuildContext context) {
    final User? uid = FirebaseAuth.instance.currentUser;
    final User user = uid!;

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    int disc = 0;
    try {
      if (widget.oprice != '' || widget.price != '') {
        disc = (int.parse(widget.oprice) - int.parse(widget.price)) *
            100 ~/
            int.parse(widget.oprice);
      }
    } catch (e) {
      print(e);
    }
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: SingleChildScrollView(
        child: Container(
          color: Colors.black,
          child: Column(
            children: <Widget>[
              Stack(
                children: [
                  ImageHeroWidget(image: widget.image),
                  Positioned(
                    top: 5.0, // Adjust the top position as needed
                    left: 5.0, // Adjust the left position as needed
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      color: Colors.green.withOpacity(0.6),
                      child: Text(
                        disc.toString() + '% off',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductTileBigbs extends StatefulWidget {
  ProductTileBigbs({
    required this.image,
    required this.name,
    required this.price,
    required this.uid,
    required this.phone,
    required this.description,
    required this.oprice,
    required this.onTap,
    required this.date,
    Key? key,
  }) : super(key: key);
  final String image;
  final String name;
  final String price;
  final String uid;
  final String phone;
  final String description;
  final String oprice;
  final String date;

  final Function onTap;

  @override
  State<ProductTileBigbs> createState() => _ProductTileBigbsState();
}

class _ProductTileBigbsState extends State<ProductTileBigbs> {
  @override
  Widget build(BuildContext context) {
    final User? uid = FirebaseAuth.instance.currentUser;
    final User user = uid!;

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Item Details'),
        backgroundColor: Colors.red[900],
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ImageHeroWidget(image: widget.image),
              //card containing name, price and like button
              Container(
                height: height * 0.07,
                width: width,
                child: ListTile(
                  visualDensity: VisualDensity(horizontal: -4),
                  title: Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Selling Price ₹" + widget.price,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.message_sharp,
                        ),
                        onPressed: () {
                          launchWhatsapp(widget.phone);
                        },
                      ),
                      if (widget.uid == user.uid ||
                          user.uid == "zHhIgl14Yde0QmSpi2w3Gw1qnh12" ||
                          user.uid == "admin")
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            //are you sure you want to delete prompt
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Delete Listing"),
                                  content: const Text(
                                      "Are you sure you want to delete this listing?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        DatabaseService(uid: user.uid)
                                            .deleteListing2(
                                                widget.name, widget.date);

                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        Fluttertoast.showToast(
                                            msg:
                                                "Item deleted, Please refresh ");
                                      },
                                      child: const Text("Delete"),
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
              ),
              SizedBox(
                height: height * 0.02,
              ),
              //description
              Container(
                width: width,
                child: Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              //item found lost date and time
              SizedBox(
                height: height * 0.02,
              ),
              Container(
                width: width,
                child: Text(
                  "Original Price ₹" + widget.oprice,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductTileNews extends StatefulWidget {
  ProductTileNews({
    required this.title,
    required this.photo,
    required this.uid,
    required this.link,
    required this.description,
    required this.category,
    required this.date,
    required this.newsId,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final String title;
  final String photo;
  final String uid;
  final String link;
  final String newsId;
  final String description;
  final String category;
  final String date;
  final Function onTap;

  @override
  State<ProductTileNews> createState() => _ProductTileNewsState();
}

class _ProductTileNewsState extends State<ProductTileNews> {
  @override
  Widget build(BuildContext context) {
    final User? uid = FirebaseAuth.instance.currentUser;
    final User user = uid!;

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: [
                ImageHeroWidget(image: widget.photo),
                Positioned(
                  bottom: 5.0, // Adjust the top position as needed
                  left: 5.0, // Adjust the left position as needed
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    color: Colors.black.withOpacity(0.30),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontFamily: 'Times New Roman',
                      ),
                    ),
                  ),
                ),
                if (user.uid == "zHhIgl14Yde0QmSpi2w3Gw1qnh12" ||
                    user.uid == "admin")
                  Positioned(
                    top: 5.0, // Adjust the top position as needed
                    right: 5.0, // Adjust the left position as needed
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            String approved = "true";
                            await DatabaseService(uid: widget.uid)
                                .updateUserData5(
                              widget.title,
                              widget.description,
                              widget.photo,
                              widget.date,
                              widget.newsId,
                              widget.category,
                              widget.link ?? "",
                              approved,
                            );
                            Fluttertoast.showToast(
                                msg: "News Approved",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red[900],
                                textColor: Colors.white,
                                fontSize: 16.0);
                          },
                          icon: Icon(
                            Icons.approval_rounded,
                            color: Colors.red[900],
                            size: 30.0,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            String approved = "false";
                            await DatabaseService(uid: widget.uid)
                                .updateUserData5(
                              widget.title,
                              widget.description,
                              widget.photo,
                              widget.date,
                              widget.newsId,
                              widget.category,
                              widget.link ?? "",
                              approved,
                            );
                            Fluttertoast.showToast(
                                msg: "News UnApproved",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red[900],
                                textColor: Colors.white,
                                fontSize: 16.0);
                          },
                          icon: Icon(
                            Icons.not_accessible,
                            color: Colors.red[900],
                            size: 30.0,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductTileBigNews extends StatefulWidget {
  ProductTileBigNews({
    required this.newsId,
    required this.title,
    required this.photo,
    required this.uid,
    required this.link,
    required this.description,
    required this.category,
    required this.date,
    required this.onTap,
    Key? key,
  }) : super(key: key);
  final String newsId;
  final String title;
  final String photo;
  final String uid;
  final String link;
  final String description;
  final String category;
  final String date;
  final Function onTap;

  @override
  State<ProductTileBigNews> createState() => _ProductTileBigNewsState();
}

class _ProductTileBigNewsState extends State<ProductTileBigNews> {
  @override
  Widget build(BuildContext context) {
    final User? uid = FirebaseAuth.instance.currentUser;
    final User user = uid!;

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final dateTime = DateTime.parse(widget.date);
    String formattedDate =
        DateFormat("MMMM d'\$suffix' h:mma").format(dateTime);

    // Determine the appropriate suffix for the day
    String suffix;
    if (dateTime.day >= 11 && dateTime.day <= 13) {
      suffix = "th";
    } else {
      switch (dateTime.day % 10) {
        case 1:
          suffix = "st";
          break;
        case 2:
          suffix = "nd";
          break;
        case 3:
          suffix = "rd";
          break;
        default:
          suffix = "th";
          break;
      }
    }

    // Replace the 'suffix' placeholder in the formatted string
    formattedDate = formattedDate.replaceAll('\$suffix', suffix);
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('News Details'),
          backgroundColor: Colors.red[900],
          elevation: 0.0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Stack(
                  children: [
                    ImageHeroWidget(image: widget.photo),
                    //news article under photo
                  ],
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                //links;description,category,date in a beautiful card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  shadowColor: Colors.black,
                  elevation: 10,
                  child: Container(
                    width: width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: height * 0.02,
                          ),
                          //links
                          Container(
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    widget.description,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //item found lost date and time
                          SizedBox(
                            height: height * 0.02,
                          ),
                          Container(
                            width: width,
                            child: Column(
                              children: [
                                SelectableLinkify(
                                    onOpen: _onOpen, text: widget.link),
                                SizedBox(
                                  height: height * 0.02,
                                ),
                                // Output: June 5th 4:25
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    formattedDate,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //description
                          SizedBox(
                            height: height * 0.02,
                          ),

                          //date at the end of page
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.uid == user.uid ||
                    user.uid == "zHhIgl14Yde0QmSpi2w3Gw1qnh12" ||
                    user.uid == "admin")
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      //are you sure you want to delete prompt
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Delete Listing"),
                            content: const Text(
                                "Are you sure you want to delete this listing?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  DatabaseService(uid: user.uid)
                                      .deleteListing4(widget.newsId);

                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  Fluttertoast.showToast(
                                      msg: "Item deleted, Please refresh");
                                },
                                child: const Text("Delete"),
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
        ));
  }
}

class ProductTile0 extends StatefulWidget {
  ProductTile0({
    required this.image,
    required this.pimage,
    required this.name,
    required this.price_loc,
    required this.onTap,
    required this.clicked,
    Key? key,
  }) : super(key: key);
  final String image;
  final String pimage;
  final String name;
  final String price_loc;
  final Function onTap;
  String clicked;

  @override
  State<ProductTile0> createState() => _ProductTile0State();
}

class _ProductTile0State extends State<ProductTile0> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ImageHeroWidget(image: widget.image),
            Container(
              //cool border

              height: height * 0.07,
              width: width * 0.5,
              child: ListTile(
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(widget.pimage),
                ),
                title: Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: width * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  widget.price_loc,
                  style: TextStyle(
                    fontSize: width * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    CupertinoIcons.heart_fill,
                    color: widget.clicked.toLowerCase() == 'true'
                        ? Colors.red
                        : Colors.black,
                    size: width * 0.05,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.clicked.toLowerCase() == 'true'
                          ? widget.clicked = 'false'
                          : widget.clicked = 'true';
                    });
                    Fluttertoast.showToast(
                        msg: widget.clicked.toLowerCase() == 'true'
                            ? "Added to Wishlist"
                            : "Removed from Wishlist",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _onOpen(LinkableElement link) async {
  var url = link.url;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class ImageHeroWidget extends StatelessWidget {
  final String image;
  final double width;
  final double height;

  const ImageHeroWidget({
    required this.image,
    this.width = 0.0,
    this.height = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: image,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: FadeInImage(
          placeholder: const AssetImage('assets/cash/img.png'),
          image: NetworkImage(image ?? ''),
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/cash/img_1.png',
              width: width != 0.0 ? width : null,
              height: height != 0.0 ? height : null,
            );
          },
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
