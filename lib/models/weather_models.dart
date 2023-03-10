import 'package:dio/dio.dart';
import 'dart:convert';
import '../global.dart' as global;

int zipcode = 16018;

Future<Response<dynamic>> getTodayforecast(double lat, double lon) async {
  var response = await Dio().get(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=288215c433ffb3a0177d455c0c0b2375&units=metric');
  return response;
}

Future<Response<dynamic>> getHourlyForecast() async {
  var response = await Dio().get(
      "https://pro.openweathermap.org/data/2.5/forecast/hourly?lat=36.7920&lon=2.9033&appid=288215c433ffb3a0177d455c0c0b2375&units=metric");
  return response;
}

Future<Response<dynamic>> getHourlyForecastWeatherBit(
    double lat, double lon) async {
  var response = await Dio().get(
      'https://api.weatherbit.io/v2.0/forecast/hourly?lat=$lat&lon=$lon&key=${global.apiKeyWeatherBitFreeLimited}&hours=5');
  return response;
}

Future<Response<dynamic>> getHourlyForecastWeatherApi(
    double lat, double lon) async {
  var response = await Dio().get(
      'http://api.weatherapi.com/v1/forecast.json?key=82f75908511d41dc8bb154417231003&q=$lat,$lon&days=1&aqi=no&alerts=no');
  return response;
}

void main() {
  getHourlyForecastWeatherBit(36.7928294172451, 2.9177744354370265)
      .then((value) {
    dynamic jsonData = jsonDecode(value.toString());
    print(jsonData['data'][3]['temp']);
  });
}
