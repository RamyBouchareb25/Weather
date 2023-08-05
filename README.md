# Flutter Weather App with OpenWeatherAPI

![App Screenshot](screenshot.png)

This is a simple weather application built using Flutter and the OpenWeatherAPI. The app allows users to get current weather information for a specific location and displays it in a user-friendly manner. With this app, users can easily check the weather conditions for any desired location.

## Features

- View current weather information based on the user's location or a manually entered city name.
- Display of essential weather data such as temperature, humidity, wind speed, and weather condition.
- Refresh button to update the weather data instantly.
- Beautiful and intuitive user interface.

## Prerequisites

Before running the application, make sure you have the following:

- Flutter SDK installed on your machine. You can download it from [here](https://flutter.dev/docs/get-started/install).
- An OpenWeatherAPI key. You can obtain one by signing up at [OpenWeatherAPI](https://openweathermap.org/appid).

## Installation

1. Clone the repository to your local machine:

```
git clone https://github.com/your_username/your_flutter_weather_app.git
```

2. Navigate to the project directory:

```
cd your_flutter_weather_app
```

3. Add your OpenWeatherAPI key to the `lib/utils/api_key.dart` file:

```dart
const String openWeatherAPIKey = 'YOUR_API_KEY';
```

4. Install the required dependencies:

```
flutter pub get
```

5. Run the app:

```
flutter run
```

## How to Use the App

1. Upon launching the app, the user will see the current weather information based on their device's location (if location services are enabled).

2. To search for weather in a different location, tap on the search bar, enter the desired city name, and press the "Search" button.

3. The app will retrieve weather data from the OpenWeatherAPI and display it on the screen.

4. To refresh the weather information, simply press the "Refresh" button.

## Dependencies

The app utilizes the following dependencies:

- `flutter_bloc`: For state management using the BLoC pattern.
- `http`: For making HTTP requests to the OpenWeatherAPI.
- `geolocator`: For accessing the device's location.
- `fluttertoast`: For displaying toast messages in the app.

All the dependencies are listed in the `pubspec.yaml` file and will be automatically installed when running `flutter pub get`.

## Contributing

Contributions to the project are welcome. If you find any issues or have ideas for improvements, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- The Flutter team for creating an amazing framework for building cross-platform apps.
- OpenWeatherAPI for providing weather data.
- The open-source community for valuable contributions and inspirations.

---
Have fun exploring the weather with our Flutter Weather App! If you have any questions or need assistance, feel free to contact us at ramybouchareb@outlook.com.

Enjoy the weather! ☀️🌧️❄️
