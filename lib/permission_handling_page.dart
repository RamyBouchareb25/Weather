import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/location.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/search_bar_test.dart';
import 'global.dart';
import 'package:app_settings/app_settings.dart';

class PermissionHandlingPage extends StatefulWidget {
  const PermissionHandlingPage({super.key});

  @override
  State<PermissionHandlingPage> createState() => PermissionHandlingPageState();
}

class PermissionHandlingPageState extends State<PermissionHandlingPage> {
  static Permission currentPermission = Permission.waiting;
  @override
  void initState() {
    super.initState();
    if (currentPermission == Permission.accepted) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return const LocationGetter();
        },
      ));
    } else {
      handleLocationPermission(context).then((value) {
        if (value) {
          currentPermission = Permission.accepted;
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return const LocationGetter();
            },
          ));
        } else {
          currentPermission = Permission.denied;
        }
      });
    }
  }

  late BuildContext ctx;
  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Container(
      decoration: clearBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
                onPressed: () {
                  if (currentPermission == Permission.denied) {
                    setState(() {
                      handleLocationPermission(context).then((value) {
                        if (value) {
                          currentPermission = Permission.accepted;
                          Navigator.pop(ctx);
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const LocationGetter();
                            },
                          ));
                        } else {
                          currentPermission = Permission.deniedForever;
                          Navigator.pop(ctx);
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const Search();
                            },
                          ));
                        }
                      });
                    });
                  } else if (currentPermission == Permission.deniedForever) {
                    AppSettings.openAppSettings();
                  }
                },
                child: Text(currentPermission == Permission.denied
                    ? "Request Permission Again !"
                    : currentPermission == Permission.deniedForever
                        ? "Please Change Permission from the settings"
                        : ""))
          ]),
        ),
      ),
    );
  }
}
