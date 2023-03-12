import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/permission_handling_page.dart';
import 'global.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import './models/weather_models.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

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
  bool doneLoading2 = false;
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
      decoration: loading == ConnectionState.done
          ? clearBackground
          : loading == ConnectionState.waiting
              ? loadingBackground
              : darkBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar(),
        body: LiquidPullToRefresh(
          onRefresh: _handleRefresh,
          child: ListView(children: [
            body(MediaQuery.of(context).size.height,
                MediaQuery.of(context).size.width),
          ]),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() {
    return getHourlyForecastWeatherApi(_position.latitude, _position.longitude);
  }

  void refresh(ConnectionState load) {
    Future.delayed(
      const Duration(microseconds: 1),
      () {
        if (!doneLoading) {
          setState(() {
            loading = load;
            doneLoading = true;
          });
        }
        if (!doneLoading2 && load == ConnectionState.done) {
          loading = load;
          setState(() {
            doneLoading2 = true;
          });
        }
      },
    );
  }

  Widget body(double deviceHeight, double deviceWidth) {
    if (!gotUserLocation) {
      return Center(child: _loadingScreen(deviceHeight, deviceWidth));
    }
    // getTodayforecast(_position.latitude, _position.longitude),
    // getHourlyForecastWeatherBit(_position.latitude, _position.longitude),
    return Center(
        child: FutureBuilder(
      future:
          getHourlyForecastWeatherApi(_position.latitude, _position.longitude),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          refresh(snapshot.connectionState);
          double deviceHeight = MediaQuery.of(context).size.height;
          double deviceWidth = MediaQuery.of(context).size.width;
          return _loadingScreen(deviceHeight, deviceWidth);
        } else if (snapshot.connectionState == ConnectionState.done) {
          dynamic jsonData = jsonDecode(snapshot.data.toString());
          double temperature = jsonData["current"]["temp_c"];
          double wind = jsonData["current"]["wind_kph"];
          double precipitation =
              jsonData["forecast"]["forecastday"][0]["day"]["totalprecip_mm"];
          int humidity = jsonData["current"]["humidity"];
          refresh(snapshot.connectionState);
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              sun,
              _temperature(temperature.round(), temperature.round() - 1,
                  temperature.round() + 1),
              _metaData(precipitation, wind.round(), humidity),
              _todayForecast(jsonData),
            ],
          );
        } else {
          loading = ConnectionState.none;
          return const Text('error');
        }
      },
    ));
  }

  Widget _loadingScreen(double deviceHeight, double deviceWidth) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      const SizedBox(
        width: 100,
        height: 100,
        child: CircularProgressIndicator(
          color: Color(0xFFe0e0e0),
          strokeWidth: 10,
        ),
      ),
      _lazyLoad(deviceHeight / 5, deviceWidth / 2.5),
      _lazyLoad(deviceHeight / 15, deviceWidth / 1.1),
      _lazyLoad(deviceHeight / 3, deviceWidth / 1.1),
    ]);
  }

  Widget _lazyLoad(double height, double width) {
    return Shimmer.fromColors(
        baseColor: const Color(0xFFe0e0e0),
        highlightColor: Colors.white,
        child: Container(
          height: height,
          width: width,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              color: Colors.white),
        ));
  }

  Widget _todayForecast(dynamic temperatures) {
    return Container(
      decoration: const BoxDecoration(
          color: Color(0xFF298BC2),
          borderRadius: BorderRadius.all(Radius.circular(25))),
      width: MediaQuery.of(context).size.width / 1.1,
      height: MediaQuery.of(context).size.height / 3,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        SizedBox(
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
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [
        //     _hourlyTemperature("31°", Icons.cloud, "15.00"),
        //     _hourlyTemperature("30°", Icons.cloud, "16.00"),
        //     _hourlyTemperature("28°", Icons.cloud, "17.00"),
        //     _hourlyTemperature("28°", Icons.cloud, "18.00  "),
        //   ],
        // )
        Container(
          width: 1000,
          height: 200,
          margin: const EdgeInsets.only(left: 20, right: 22),
          child: ListView.builder(
            itemCount: 24,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              String imageUrl = temperatures["forecast"]["forecastday"][0]
                  ["hour"][index]["condition"]["icon"];
              imageUrl = imageUrl.split("//")[1];
              double temperature = temperatures["forecast"]["forecastday"][0]
                  ["hour"][index]["temp_c"];
              String hour = index < 10 ? '0$index' : '$index';
              return _hourlyTemperature("${temperature.toInt()}°", imageUrl,
                  '$hour.00', index == DateTime.now().hour ? true : false);
            },
          ),
        )
      ]),
    );
  }

  Widget _metaData(double precipitation, int windSpeed, int humidity) {
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
            _metaDataObject(rain, "${precipitation}mm", 20, 100),
            _metaDataObject(temperature, "${humidity}%", 25, 70),
            _metaDataObject(wind, "${windSpeed}Km/h", 17, 100),
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

  Widget _hourlyTemperature(
      String temperature, String iconUrl, String hour, bool active) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: active ? const Color(0xFF65C0FF) : Colors.transparent,
            width: 2),
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
          Image.network('http://$iconUrl'),
          Text(
            hour,
            style: regularFont(20),
          ),
        ],
      ),
    );
  }

  Widget _temperature(int temperature, int maxTemp, int minTemp) {
    return Column(
      children: [
        Text(
          "$temperature°",
          style: semiBoldFont(65),
        ),
        Text(
          "Precipitations",
          style: regularFont(19),
        ),
        Text(
          "Max:$maxTemp° Min:$minTemp°",
          style: regularFont(19),
        )
      ],
    );
  }

  PreferredSizeWidget? appBar() {
    if (loading == ConnectionState.done && doneLoading2) {
      return AppBar(
        titleSpacing: 0,
        title: Text(gotUserLocation ? city : "Waiting for Data"),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: const Icon(location),
        actions: [
          Container(
              margin: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width / 2.7),
              child: const Icon(Icons.keyboard_arrow_down)),
          const Icon(newNotification)
        ],
        titleTextStyle:
            const TextStyle(fontFamily: "SF Pro Display", fontSize: 20),
      );
    } else {
      return AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 15),
              child: _lazyLoad(MediaQuery.of(context).size.height / 1.1,
                  MediaQuery.of(context).size.width / 1.1),
            ),
          ]);
    }
  }
}
