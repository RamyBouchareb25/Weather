import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:weather_app/main.dart';
import './global.dart';

class Search extends StatefulWidget {
  const Search({super.key});
  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late String querry;
  late BuildContext ctx;
  Future<dynamic> getPredictions(String querry) async {
    var response = await Dio().get(
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$querry&key=AIzaSyA7YbcfZHHiA80T-wbB656ql4r6lC3cJRE");
    return response.data;
  }

  @override
  void initState() {
    super.initState();
    querry = "";
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Scaffold(
      body: Container(
        decoration: clearBackground,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 60),
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    querry = value;
                  });
                },
                decoration: const InputDecoration(
                    fillColor: Colors.grey,
                    icon: Icon(Icons.search),
                    hintText: "Select Your Location",
                    contentPadding: EdgeInsets.only(left: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)))),
              ),
            ),
            Expanded(
                child: FutureBuilder(
                    future: getPredictions(querry),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return ListView.builder(
                          itemCount: snapshot.data["predictions"].length,
                          itemBuilder: (context, index) {
                            var prediction = snapshot.data["predictions"][index]
                                ["description"];
                            return InkWell(
                              onTap: () {
                                Navigator.pop(ctx);
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return MyHomePage();
                                  },
                                ));
                              },
                              child: ListTile(
                                title: Text(prediction),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Text("Searching for places ...");
                      }
                    }))
          ],
        ),
      ),
    );
  }
}
