import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';

int zipcode = 16018;

Future<Response<dynamic>> getTodayforecast() async {
  var response = await Dio().get(
      'https://api.openweathermap.org/data/2.5/weather?zip=$zipcode,dz&appid=288215c433ffb3a0177d455c0c0b2375&units=metric');
  return response;
}

Future<Response<dynamic>> getHourlyForecast() async {
  var response = await Dio().get(
      "https://pro.openweathermap.org/data/2.5/forecast/hourly?lat=36.7920&lon=2.9033&appid=288215c433ffb3a0177d455c0c0b2375&units=metric");
  return response;
}

Future<Response<dynamic>> getHourlyForecastWeatherBit(
    String lat, String lon) async {
  var response = await Dio().get(
      'https://api.weatherbit.io/v2.0/forecast/hourly?lat=$lat&lon=$lon&key=089633a29e41407fb4ec076bd8b62740&hours=5');
  return response;
}

void main() {
  getHourlyForecastWeatherBit("38.123", "-78.543").then((value) {
    dynamic jsonData = jsonDecode(value.toString());
    print(jsonData['data'][3]);
  });
}
