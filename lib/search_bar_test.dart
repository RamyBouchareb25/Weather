import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import './global.dart';

class Search extends StatelessWidget {
  const Search({super.key});
  Future<Prediction?> searchApi(BuildContext context) async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: apiKeyGoogleAndroid,
        mode: Mode.overlay, // Mode.fullscreen
        language: "fr",
        components: [Component(Component.country, "fr")]);
    return p;
  }
  // List<String> _getAutuFill() {
    
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 30),
        child: Column(
          children: [
            TextFormField(
              decoration:
                  const InputDecoration(hintText: "Select Your Location"),
            ),
            Expanded(child: ListView.builder(
              itemBuilder: (context, index) {
                return ListTile();
              },
            ))
          ],
        ),
      ),
    );
  }
}
