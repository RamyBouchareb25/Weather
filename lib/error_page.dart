import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/global.dart';
import 'package:weather_app/main.dart';
import 'permission_handling_page.dart' as p;

enum GettingData { retreiving, retreived, failedToRetreive }

class ErrorPage extends StatefulWidget {
  const ErrorPage({super.key});

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  static Permission currentPermission =
      p.PermissionHandlingPageState.currentPermission;
  GettingData dataGathering = GettingData.failedToRetreive;
  final String failedMessage =
      "Failed to get your location please try again and verify your connection and location is activated";
  final String retreivingMessage = "Retreiving your Location please wait ...";
  final String retreivedMessage = "Redirecting please wait ...";
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: darkBackground,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(dataGathering == GettingData.failedToRetreive
                  ? failedMessage
                  : dataGathering == GettingData.retreiving
                      ? retreivingMessage
                      : retreivedMessage),
              ElevatedButton(
                  onPressed: () async {
                    bool locationEnabled =
                        await Geolocator.isLocationServiceEnabled();
                    setState(() {
                      locationEnabled
                          ? dataGathering = GettingData.retreiving
                          : dataGathering = GettingData.failedToRetreive;
                      if (locationEnabled) {
                        handleLocationPermission(context)
                            .then((value) => getUserCity((val, val2) {
                                  dataGathering = GettingData.retreived;
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return const MyApp();
                                    },
                                  ));
                                }, (error, stackTrace) {
                                  dataGathering = GettingData.failedToRetreive;
                                }));
                      }
                    });
                  },
                  child: const Text("Retry"))
            ]),
          )),
    );
  }
}
