import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:weatherapp/components/additional_info_item.dart';
import 'package:weatherapp/components/hourly_forecast_item.dart';
import 'package:weatherapp/components/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String? _currentAddress;
  Position? _currentPosition;
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
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

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = "Mumbai";
      final res = await http.get(
        Uri.parse(
            "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&units=metric&APPID=$openWeatherAPIKey"),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != "200") {
        throw "An unexpected error occured";
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 14, 33, 160),
        title: Text(
          "Weather App",
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(
              Icons.refresh,
              size: 25,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(10.0),
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          DateTime currentDateTime = DateTime.now();
          const months = <String>[
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          const weekdays = <String>[
            'Sun',
            'Mon',
            'Tue',
            'Wed',
            'Thu',
            'Fri',
            'Sat',
          ];
          final data = snapshot.data!;
          final currentWeatherdata = data['list'][0];
          final currentTemp = currentWeatherdata['main']['temp'];
          final currentSky = currentWeatherdata['weather'][0]['main'];
          final currentPressure = currentWeatherdata['main']['pressure'];
          final currentWindSpeed = currentWeatherdata['wind']['speed'];
          final currentHumidity = currentWeatherdata['main']['humidity'];
          return Container(
            color: const Color.fromARGB(255, 14, 33, 160),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main card
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: const Color.fromARGB(60, 255, 255, 255),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      elevation: 10,
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Today
                                  Text(
                                    "Today",
                                    style: GoogleFonts.poppins(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                  // Date
                                  Text(
                                    "${weekdays[currentDateTime.weekday]}, ${currentDateTime.day} ${months[currentDateTime.month]}",
                                    style: GoogleFonts.poppins(
                                        fontSize: 12, color: Colors.white),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${currentTemp.toString()} °C",
                                    style: GoogleFonts.poppins(
                                      fontSize: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: SizedBox(
                                      width: 80,
                                      height: 80,
                                      child: Image.asset(
                                        currentSky == "Clouds" ||
                                                currentSky == "Rain"
                                            ? 'lib/assets/vecteezy_3d-icon-cloudy-thunderstrom-heavy-rain-weather-forecast_24683626_990.png'
                                            : 'lib/assets/vecteezy_3d-sun-emoji-happy-sun-funny-cute-character_21430060_520.png',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  Text("Mumbai",
                                      style: GoogleFonts.poppins(
                                          color: Colors.white, fontSize: 25)),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Hourly Forecast
                  Card(
                    elevation: 10,
                    color: const Color.fromARGB(255, 14, 33, 160),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Hourly forecast",
                                style: GoogleFonts.poppins(
                                    color: Colors.yellowAccent, fontSize: 25)),
                            const SizedBox(
                              height: 8,
                            ),
                            SizedBox(
                              height: 165,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 5,
                                  itemBuilder: (context, index) {
                                    final hourlyForecast =
                                        data['list'][index + 1];
                                    final hourlySky = data['list'][index + 1]
                                        ['weather'][0]['main'];
                                    final hourlyTemp = hourlyForecast['main']
                                            ['temp']
                                        .toString();
                                    final weatherStatus = data['list']
                                            [index + 1]['weather'][0]
                                        ['description'];
                                    final time = DateTime.parse(
                                        hourlyForecast['dt_txt']);
                                    return HourlyForecastItem(
                                      time: DateFormat.j().format(time),
                                      icon: hourlySky == "Clouds" ||
                                              hourlySky == "Rain"
                                          ? Icons.cloud
                                          : Icons.sunny,
                                      value: hourlyTemp,
                                      weatherStatus: weatherStatus,
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Additional information
                  Card(
                    elevation: 10,
                    color: const Color.fromARGB(255, 14, 33, 160),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Additional information",
                                style: GoogleFonts.poppins(
                                  fontSize: 25,
                                  color: Colors.yellowAccent,
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  AdditionalInfoItem(
                                    icon: Icons.water_drop,
                                    lable: Text(
                                      "Humidity",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                    value: Text(
                                      "${currentHumidity.toString()} %",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  AdditionalInfoItem(
                                    icon: Icons.air,
                                    lable: Text(
                                      "Wind Speed",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                    value: Text(
                                      "${currentWindSpeed.toString()} km/hr",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  AdditionalInfoItem(
                                    icon: Icons.beach_access,
                                    lable: Text(
                                      "Pressure",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                    value: Text(
                                      "${currentPressure.toString()} atm",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        )),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
