import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/error_page.dart';
import 'package:weather_app/search_bar_test.dart';
import 'CustomFonts/weather_icons_icons.dart' as weather_icons;
import 'package:localstorage/localstorage.dart';
import './main.dart';

Image sunRain = Image.asset("Images/Sun_cloud_angled_rain.png");
Image sun = Image.asset("Images/Sun_cloud.png");

TextStyle semiBoldFont(double? size) {
  return TextStyle(
      color: Colors.white, fontFamily: "SF Pro Display", fontSize: size);
}

TextStyle regularFont(double? size) {
  return TextStyle(
      color: Colors.white,
      fontFamily: "SF Pro Display Regular",
      fontSize: size);
}

const BoxDecoration darkBackground = BoxDecoration(
    gradient: LinearGradient(
        colors: [Color(0xFF08244F), Color(0xFF134CB5), Color(0xFF0B42AB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight));
const BoxDecoration loadingBackground = BoxDecoration(
  color: blueBackground,
);

const BoxDecoration clearBackground = BoxDecoration(
    gradient: LinearGradient(
        colors: [Color(0xFF29B2DD), Color(0xFF33AADD), Color(0xFF2DC8EA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight));

const Color blueBackground = Color(0xFF298BC2);
const Color clearBlue = Color(0xFF65C0FF);

const String apiKeyWeatherApi = "82f75908511d41dc8bb154417231003";
const String apiKeyGoogleAndroid = "AIzaSyB-pRwCDO_KGDFr55kbliM0eyYDjeyJ5KQ";
const String apiKeyGoogleIos = "AIzaSyA0JdCvkl1ZY2PN4nzLxUf5DkUafBsH9sE";

const IconData location = weather_icons.WeatherIcons.location;
const IconData calendar = weather_icons.WeatherIcons.calendar;
const IconData newNotification = weather_icons.WeatherIcons.newnotif;
const IconData notification = weather_icons.WeatherIcons.notif;
const IconData rain = weather_icons.WeatherIcons.rain;
const IconData temperature = weather_icons.WeatherIcons.temperature;
const IconData wind = weather_icons.WeatherIcons.wind;

enum Permission {
  waiting,
  accepted,
  denied,
  deniedForever,
}

Future<String> getUserLocation(Position myLocation) async {
  LocalStorage storage = MyHomePage.getLocalStorage();
  await storage.ready;
  MyHomePage.getLocalStorage().getItem("Location") == null
      ? MyHomePage.setFirstTimeLoading(true)
      : MyHomePage.setFirstTimeLoading(false);
  if (MyHomePage.getFirstTimeLoading()) {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        myLocation.latitude, myLocation.longitude);
    Placemark place = placemarks[0];
    storage.setItem("Location", place.administrativeArea);
    return place.administrativeArea!;
  }
  return storage.getItem("Location");
}

getUserCity(void Function(String cityName, Position position) successFunction,
    void Function(Object? error, StackTrace stackTrace) errorFunction) {
  Geolocator.getCurrentPosition()
      .then((value) => getUserLocation(value).then((value2) {
            successFunction(value2, value);
          }))
      .onError((error, stackTrace) {
    errorFunction(error, stackTrace);
  });
}

Future<bool> handleLocationPermission(BuildContext context) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Location services are disabled. Please enable the services')));
    await Future.delayed(const Duration(seconds: 5));
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return const Search();
      },
    ));
    return false;
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')));
      return false;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Location permissions are permanently denied, we cannot request permissions.')));
    return false;
  }
  return true;
}
