//list comntaining images page

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '/sidebar_info/agencydatabase.dart';
import '../authentication/auth.dart';

class AgencyList extends StatefulWidget {
  const AgencyList({Key? key}) : super(key: key);

  @override
  State<AgencyList> createState() => _AgencyListState();
}

class _AgencyListState extends State<AgencyList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agencies'),
        backgroundColor: Colors.red[900],
      ),
      body: FutureBuilder(
        future: FireStoreDataBase().getImages(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text(
              "Something went wrong",
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            final agencies = snapshot.data;
            return ListView.builder(
              itemCount: agencies!.length,
              itemBuilder: (context, index) {
                final agency = agencies[index];

                return Container(
                  child: FutureBuilder(
                    future: agency.getDownloadURL(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                          "Something went wrong",
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.done) {
                        final url = snapshot.data;
                        return Image.network(
                          url.toString(),
                          fit: BoxFit.cover,
                        );
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
