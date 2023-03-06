import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/error_page.dart';
import 'CustomFonts/weather_icons_icons.dart' as weather_icons;

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
const BoxDecoration clearBackground = BoxDecoration(
    gradient: LinearGradient(
        colors: [Color(0xFF29B2DD), Color(0xFF33AADD), Color(0xFF2DC8EA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight));

const String apiKeyForWeather = "288215c433ffb3a0177d455c0c0b2375";

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
  List<Placemark> placemarks =
      await placemarkFromCoordinates(myLocation.latitude, myLocation.longitude);
  Placemark place = placemarks[0];
  return place.administrativeArea!;
}

getUserCity(void Function(String val) successFunction,
    void Function(Object? error, StackTrace stackTrace) errorFunction) {
  Geolocator.getCurrentPosition()
      .then((value) => getUserLocation(value).then((value) {
            successFunction(value);
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
        return const ErrorPage();
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
