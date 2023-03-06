import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/main.dart';
import 'global.dart';
import 'package:app_settings/app_settings.dart';

class PermissionHandlingPage extends StatefulWidget {
  const PermissionHandlingPage({super.key});

  @override
  State<PermissionHandlingPage> createState() => PermissionHandlingPageState();
}

class PermissionHandlingPageState extends State<PermissionHandlingPage> {
  Permission p = Permission.waiting;
  @override
  void initState() {
    super.initState();
    if (p == Permission.accepted) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return const MyHomePage();
        },
      ));
    } else {
      handleLocationPermission(context).then((value) {
        if (value) {
          p = Permission.accepted;
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return const MyHomePage();
            },
          ));
        } else {
          p = Permission.denied;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: clearBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
                onPressed: () {
                  if (p == Permission.denied) {
                    setState(() {
                      handleLocationPermission(context).then((value) {
                        if (value) {
                          p = Permission.accepted;
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const MyHomePage();
                            },
                          ));
                        } else {
                          p = Permission.deniedForever;
                          setState(() {});
                        }
                      });
                    });
                  } else if (p == Permission.deniedForever) {
                    AppSettings.openAppSettings();
                  }
                },
                child: Text(p == Permission.denied
                    ? "Request Permission Again !"
                    : p == Permission.deniedForever
                        ? "Please Change Permission from the settings"
                        : ""))
          ]),
        ),
      ),
    );
  }
}
