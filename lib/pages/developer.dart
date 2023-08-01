//about developer page

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDeveloper extends StatelessWidget {
  const AboutDeveloper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: Colors.red[900],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),

              Image.asset(
                'assets/images/img.png',
                height: 200,
                width: 200,
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: const Text(
                  'We understand that coordinating transportation can be a hassle, especially when you\'re trying to catch a flight.'
                  ' Our mission is to make it easy for students to coordinate rides with their peers when traveling to and from the airport. '
                  'Students can sign up, create a ride, and find other students to save money and reduce their carbon footprint by sharing a cab ride.'
                  ' We are constantly working to improve our app and make it more user-friendly. We are proud to be a part of this community.'
                  ' Thank you for choosing our app, and happy travels!',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              //follow me here
              Text(
                "Follow us here",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: FaIcon(
                      FontAwesomeIcons.instagram,
                      size: 40.0,
                    ),
                    onTap: () async {
                      //link instagram
                      var url =
                          Uri.parse('https://www.instagram.com/sastigaadi_/');
                      await launchUrl(url);
                    },
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  InkWell(
                    child: FaIcon(
                      FontAwesomeIcons.linkedin,
                      size: 40.0,
                    ),
                    onTap: () async {
                      //link linkedin
                      var url = Uri.parse(
                          'https://www.linkedin.com/in/bhavik-mangla-117420144/');
                      await launchUrl(url);
                    },
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  InkWell(
                    child: FaIcon(
                      FontAwesomeIcons.github,
                      size: 40.0,
                    ),
                    onTap: () async {
                      //link github
                      var url = Uri.parse('https://github.com/bhavik-mangla');
                      await launchUrl(url);
                    },
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(child: Icon(Icons.email, size: 40.0)),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    children: [
                      SelectableLinkify(
                          onOpen: _onOpen,
                          text: "contact.sastigaadi@gmail.com"),
                      SizedBox(
                        height: 10,
                      ),
                      SelectableLinkify(
                          onOpen: _onOpen, text: "bhavikmangla1234@gmail.com"),
                    ],
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

Future<void> _onOpen(LinkableElement link) async {
  final Uri params = Uri(
    scheme: 'mailto',
    path: link.text.toString(),
    query: 'subject=App Feedback&body=Hey', //add subject and body here
  );

  var url = params.toString();
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
