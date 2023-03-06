import 'package:flutter/material.dart';
import 'package:weather_app/permission_handling_page.dart';
import 'global.dart' as global;
import 'package:intl/intl.dart';

void main() {
  // DartPluginRegistrant.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PermissionHandlingPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String city;
  bool gotUserLocation = false;
  @override
  void initState() {
    super.initState();
    global.getUserCity((value) {
      setState(() {
        gotUserLocation = !gotUserLocation;
        city = value;
      });
    }, (error, stackTrace) {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: global.clearBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar(),
        body: body(),
      ),
    );
  }

  Widget body() {
    if (!gotUserLocation) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "retreiving your location please wait !",
              style: TextStyle(
                  fontFamily: "SF Pro Display",
                  fontSize: 20,
                  color: Colors.white),
            ),
            Icon(
              Icons.cached,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      );
    }
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
          Container(child: global.sun),
          _temperature(),
          _metaData(),
          _todayForecast()
        ]));
  }

  Widget _todayForecast() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color: Color(0xFF298BC2),
      ),
      width: MediaQuery.of(context).size.width / 1.1,
      height: MediaQuery.of(context).size.height / 3,
      child: Column(children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          width: MediaQuery.of(context).size.width / 1.3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today",
                style: global.semiBoldFont(17),
              ),
              Text(
                '${DateFormat('EEEE').format(DateTime.now())},${DateTime.now().day.toString()}',
                style: global.semiBoldFont(17),
              )
            ],
          ),
        )
      ]),
    );
  }

  Widget _metaData() {
    return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          color: Color(0xFF298BC2),
        ),
        width: MediaQuery.of(context).size.width / 1.1,
        height: MediaQuery.of(context).size.height / 15,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _metaDataObject(global.rain, "18%", 20, 70),
            _metaDataObject(global.temperature, "67%", 25, 70),
            _metaDataObject(global.wind, "25Km/h", 17, 100),
          ],
        ));
  }

  Widget _metaDataObject(
      IconData icon, String data, double size, double width) {
    return SizedBox(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: size,
          ),
          Text(
            data,
            style: global.regularFont(19),
          )
        ],
      ),
    );
  }

  Widget _temperature() {
    return Column(
      children: [
        Text(
          "30°",
          style: global.semiBoldFont(65),
        ),
        Text(
          "Precipitations",
          style: global.regularFont(19),
        ),
        Text(
          "Max:34° Min:28°",
          style: global.regularFont(19),
        )
      ],
    );
  }

  PreferredSizeWidget? appBar() {
    if (gotUserLocation) {
      return AppBar(
        titleSpacing: 0,
        title: Text(gotUserLocation ? city : "Waiting for Data"),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: const Icon(global.location),
        actions: [
          Container(
              margin: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width / 2.1),
              child: const Icon(Icons.keyboard_arrow_down)),
          const Icon(global.newNotification)
        ],
        titleTextStyle:
            const TextStyle(fontFamily: "SF Pro Display", fontSize: 20),
      );
    } else {
      return null;
    }
  }
}
