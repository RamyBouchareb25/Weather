import 'package:flutter/material.dart';
import 'package:weather_app/permission_handling_page.dart';
import 'global.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
// import './models/weather_models.dart';

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
    getUserCity((value) {
      setState(() {
        gotUserLocation = !gotUserLocation;
        city = value;
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
          Container(child: sun),
          _temperature(),
          _metaData(),
          _todayForecast(),
          test()
        ]));
  }

  Widget test() {
    return FutureBuilder(
      // future: ,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Waiting");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Text("done");
        } else {
          return Text("else");
        }
      },
    );
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
