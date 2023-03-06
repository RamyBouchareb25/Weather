import 'package:dio/dio.dart';
import 'dart:convert';

int zipcode = 16018;

Future<Response<dynamic>> getHttp() async {
  var response = await Dio().get(
      'https://api.openweathermap.org/data/2.5/weather?zip=$zipcode,dz&appid=288215c433ffb3a0177d455c0c0b2375&units=metric');
  return response;
}

void main() {
  Future response = getHttp();
  response.then((value) {
    dynamic parsedJson = jsonDecode(value.toString());
    print(parsedJson);
  });
}
