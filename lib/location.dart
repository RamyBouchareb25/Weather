import 'package:flutter/material.dart';
import 'package:weather_app/main.dart';

import 'global.dart';

class LocationGetter extends StatefulWidget {
  const LocationGetter({super.key});

  @override
  State<LocationGetter> createState() => _LocationGetterState();
}

class _LocationGetterState extends State<LocationGetter> {
  @override
  void initState() {
    super.initState();
    getUserCity((cityName, position) {
      setState(() {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(
                  latitude: position.latitude,
                  longitude: position.longitude,
                  city: cityName),
            ));
      });
    }, (error, stackTrace) {});
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text("Getting your location please wait"),
    );
  }
}
