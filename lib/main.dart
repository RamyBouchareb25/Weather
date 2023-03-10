import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/permission_handling_page.dart';
import 'global.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import './models/weather_models.dart';

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
  late Position _position;
  late ConnectionState loading;
  bool doneLoading = false;
  bool gotUserLocation = false;
  @override
  void initState() {
    super.initState();
    loading = ConnectionState.waiting;
    getUserCity((cityName, position) {
      setState(() {
        gotUserLocation = !gotUserLocation;
        city = cityName;
        _position = position;
      });
    }, (error, stackTrace) {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          loading == ConnectionState.done ? clearBackground : loadingBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar(),
        body: body(),
      ),
    );
  }

  void refresh() {
    Future.delayed(
      const Duration(microseconds: 1),
      () {
        if (!doneLoading) {
          doneLoading = true;
          setState(() {});
        }
      },
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
        child: FutureBuilder(
      future:
          getHourlyForecastWeatherBit(_position.latitude, _position.longitude),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          loading = ConnectionState.done;
          refresh();
          double deviceHeight = MediaQuery.of(context).size.height;
          double deviceWidth = MediaQuery.of(context).size.width;
          return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 10,
                  ),
                ),
                _lazyLoad(deviceHeight / 5, deviceWidth / 2.5),
                _lazyLoad(deviceHeight / 15, deviceWidth / 1.1),
                _lazyLoad(deviceHeight / 3, deviceWidth / 1.1),
              ]);
        } else if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              sun,
              _temperature(),
              _metaData(),
              _todayForecast(),
            ],
          );
        } else {
          loading = ConnectionState.none;
          return const Text('error');
        }
      },
    ));
  }

  Widget _lazyLoad(double height, double width) {
    return Shimmer.fromColors(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              color: Colors.white),
        ),
        baseColor: const Color(0xFFe0e0e0),
        highlightColor: Colors.white);
  }

  Widget _todayForecast() {
    return Container(
      decoration: const BoxDecoration(
          color: Color(0xFF298BC2),
          borderRadius: BorderRadius.all(Radius.circular(25))),
      width: MediaQuery.of(context).size.width / 1.1,
      height: MediaQuery.of(context).size.height / 3,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Container(
          width: MediaQuery.of(context).size.width / 1.3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today",
                style: semiBoldFont(17),
              ),
              Text(
                '${DateFormat('EEEE').format(DateTime.now())},${DateTime.now().day.toString()}',
                style: semiBoldFont(17),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _hourlyTemperature("31°", Icons.cloud, "15.00"),
            _hourlyTemperature("30°", Icons.cloud, "16.00"),
            _hourlyTemperature("28°", Icons.cloud, "17.00"),
            _hourlyTemperature("28°", Icons.cloud, "18.00  "),
          ],
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
            _metaDataObject(rain, "18%", 20, 70),
            _metaDataObject(temperature, "67%", 25, 70),
            _metaDataObject(wind, "25Km/h", 17, 100),
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
            style: regularFont(19),
          )
        ],
      ),
    );
  }

  Widget _hourlyTemperature(String temperature, IconData icon, String hour) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF65C0FF), width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(25)),
      ),
      height: MediaQuery.of(context).size.height / 5,
      width: MediaQuery.of(context).size.width / 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            temperature,
            style: regularFont(20),
          ),
          Icon(
            icon,
            color: Colors.white,
          ),
          Text(
            hour,
            style: regularFont(20),
          ),
        ],
      ),
    );
  }

  Widget _temperature() {
    return Column(
      children: [
        Text(
          "30°",
          style: semiBoldFont(65),
        ),
        Text(
          "Precipitations",
          style: regularFont(19),
        ),
        Text(
          "Max:34° Min:28°",
          style: regularFont(19),
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
        leading: const Icon(location),
        actions: [
          Container(
              margin: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width / 2.1),
              child: const Icon(Icons.keyboard_arrow_down)),
          const Icon(newNotification)
        ],
        titleTextStyle:
            const TextStyle(fontFamily: "SF Pro Display", fontSize: 20),
      );
    } else {
      return null;
    }
  }
}
