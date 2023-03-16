import 'dart:ffi';

import 'package:dio/dio.dart';

Future<Response<dynamic>> getHourlyForecastWeatherApi(
    double lat, double lon) async {
  var response = await Dio().get(
      'http://api.weatherapi.com/v1/forecast.json?key=82f75908511d41dc8bb154417231003&q=$lat,$lon&days=1&aqi=no&alerts=no');
  return response;
}

Future<Response<dynamic>> getDaylyForecastWeatherApi(
    double lat, double lon, int day) async {
  bool future;
  future = DateTime.now().weekday < day ? true : false;
  Response<dynamic> response;
  final nowDate = DateTime.now().toString().split(" ")[0];
  int newDay = int.parse(nowDate.split("-")[2]) + day - DateTime.now().weekday;
  final newDate = "${nowDate.split("-")[0]}-${nowDate.split("-")[1]}-$newDay";
  print(newDate);
  if (future) {
    response = await Dio().get(
        "api.openweathermap.org/data/2.5/forecast/daily?lat=$lat&lon=$lon&cnt=7&appid=288215c433ffb3a0177d455c0c0b2375");
  } else {
    response = await Dio().get(
        "http://api.weatherapi.com/v1/history.json?key=82f75908511d41dc8bb154417231003&q=$lat,$lon&dt=$newDate");
  }
  return response;
}

void main() {
  getDaylyForecastWeatherApi(36.795059, 2.920257, 3)
      .then((value) => print(value));
  // print(DateTime.now());
}
