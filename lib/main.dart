import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localstorage/localstorage.dart';
import 'package:weather_app/connectivity_test.dart';
import 'package:weather_app/internet_status.dart';
import 'package:weather_app/search_bar_test.dart';
import 'global.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import './models/weather_models.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:weather_app/permission_handling_page.dart';
// import 'package:weather_app/search_bar_test.dart';
// import 'package:flutter_google_places/flutter_google_places.dart';

void main() {
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
      home: const Search(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  static late bool _firstTimeLoading;
  static late bool _getFromStorage;
  static LocalStorage _localStorage = LocalStorage("Storage.json");

  static bool getFirstTimeLoading() {
    return _firstTimeLoading;
  }

  static LocalStorage getLocalStorage() {
    return _localStorage;
  }

  static void setLocalStorage(LocalStorage value) {
    _localStorage = value;
  }

  static void setFirstTimeLoading(bool value) {
    _firstTimeLoading = value;
  }

  final double latitude;
  final double longitude;
  final String city;
  const MyHomePage(
      {super.key, required this.latitude, required this.longitude,required this.city});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String city;
  late Position _position;
  late ConnectionState loading;
  late String? googleApiKey;
  late DateTime oldDate;
  late InternetStatus currentInternetStatus;
  bool doneLoading = false;
  bool doneLoading2 = false;
  bool gotUserLocation = false;
  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;
  late String connectionStatus;
  @override
  void initState() {
    super.initState();
    _networkConnectivity.initialise();
    _networkConnectivity.myStream.listen((event) {
      _source = event;
      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.mobile:
          connectionStatus =
              _source.values.toList()[0] ? 'Mobile: Online' : 'Mobile: Offline';
          currentInternetStatus = _source.values.toList()[0]
              ? InternetStatus.mobileOnline
              : InternetStatus.mobileOffline;
          break;
        case ConnectivityResult.wifi:
          connectionStatus =
              _source.values.toList()[0] ? 'WiFi: Online' : 'WiFi: Offline';
          currentInternetStatus = _source.values.toList()[0]
              ? InternetStatus.wifiOnline
              : InternetStatus.wifiOffline;
          break;
        case ConnectivityResult.none:
        default:
          connectionStatus = 'Offline';
          currentInternetStatus = InternetStatus.offline;
      }
    });
    googleApiKey = defaultTargetPlatform == TargetPlatform.android
        ? apiKeyGoogleAndroid
        : defaultTargetPlatform == TargetPlatform.iOS
            ? apiKeyGoogleIos
            : null;
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
      decoration: clearBackground,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar(),
          body: body(MediaQuery.of(context).size.height,
              MediaQuery.of(context).size.width)),
    );
  }

  Future<void> _handleRefresh() {
    if (currentInternetStatus == InternetStatus.mobileOnline ||
        currentInternetStatus == InternetStatus.wifiOnline) {
      return getHourlyForecastWeatherApi(
          _position.latitude, _position.longitude);
    } else {
      showSnackBar("No connection Available");
      return Future.delayed(Duration.zero);
    }
  }

  void showSnackBar(String data) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data)));
  }

  Future<String> _getWeatherData(double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();
    MyHomePage._getFromStorage =
        prefs.getString("Weather") == null ? false : true;
    if (!MyHomePage._getFromStorage) {
      Response<dynamic> response = await getHourlyForecastWeatherApi(lat, lon);
      prefs.setString("Weather", response.toString());
      oldDate = DateTime.now();
      prefs.setString("TimeRefresh", DateTime.now().toString());
      MyHomePage.setFirstTimeLoading(false);
      return response.toString();
    }
    oldDate = DateTime.parse(prefs.getString("TimeRefresh")!);
    if (oldDate.difference(DateTime.now()).inHours >= 2) {
      showSnackBar("Data Expired");
    }
    return prefs.getString("Weather")!;
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
    return Center(
        child: FutureBuilder(
      future: _getWeatherData(_position.latitude, _position.longitude),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          refresh(snapshot.connectionState);
          double deviceHeight = MediaQuery.of(context).size.height;
          double deviceWidth = MediaQuery.of(context).size.width;
          return _loadingScreen(deviceHeight, deviceWidth);
        } else if (snapshot.connectionState == ConnectionState.done) {
          dynamic jsonData = jsonDecode(snapshot.data!);
          double temperature = jsonData["current"]["temp_c"];
          double wind = jsonData["current"]["wind_kph"];
          double precipitation =
              jsonData["forecast"]["forecastday"][0]["day"]["totalprecip_mm"];
          int humidity = jsonData["current"]["humidity"];
          refresh(snapshot.connectionState);
          List<Widget> bodyList = [
            sun,
            _temperature(temperature.round(), temperature.round() - 1,
                temperature.round() + 1),
            _metaData(precipitation, wind.round(), humidity),
            _todayForecast(jsonData),
            _nextForecast()
          ];
          return LiquidPullToRefresh(
            springAnimationDurationInMilliseconds: 700,
            animSpeedFactor: 10,
            onRefresh: _handleRefresh,
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: bodyList.length,
              itemBuilder: (context, index) {
                return Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: bodyList[index]);
              },
            ),
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
          color: clearBlue,
          backgroundColor: blueBackground,
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
        baseColor: blueBackground,
        highlightColor: clearBlue,
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
          color: blueBackground,
          borderRadius: BorderRadius.all(Radius.circular(25))),
      width: MediaQuery.of(context).size.width / 1,
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
                '${DateFormat('MMMM').format(DateTime.now())},${DateTime.now().day.toString()}',
                style: semiBoldFont(17),
              ),
            ],
          ),
        ),
        Container(
          width: 1000,
          height: 200,
          margin: const EdgeInsets.only(left: 20, right: 22),
          child: ListView.builder(
            itemCount: 24,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              double temperature = temperatures["forecast"]["forecastday"][0]
                  ["hour"][index]["temp_c"];
              String hour = index < 10 ? '0$index' : '$index';
              var iconUrl = temperatures["forecast"]["forecastday"][0]["hour"]
                      [index]["condition"]["icon"]
                  .split("//")[1];

              return _hourlyTemperature("${temperature.toInt()}°", iconUrl,
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
          color: blueBackground,
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
          CachedNetworkImage(
            imageUrl: "http://$iconUrl",
          ),
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

  Widget _nextForecast() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 1.8,
        color: blueBackground,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Next Forecast",
                    style: semiBoldFont(25),
                  ),
                  const Icon(
                    calendar,
                    size: 25,
                    color: Colors.white,
                  )
                ],
              ),
            ),
            _nextForecastDetails("Monday", 10),
            _nextForecastDetails("Tuesday", 10),
            _nextForecastDetails("Wednesday", 10),
            _nextForecastDetails("Thirsday", 10),
            _nextForecastDetails("Friday", 10),
            _nextForecastDetails("Saturday", 10),
            _nextForecastDetails("Sunday", 10),
          ],
        ),
      ),
    );
  }

  Widget _nextForecastDetails(String day, int temperature) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      width: MediaQuery.of(context).size.width / 1.2,
      height: MediaQuery.of(context).size.height / 15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: semiBoldFont(20),
          ),
          Text(
            '$temperature°',
            style: semiBoldFont(15),
          )
        ],
      ),
    );
  }
}
