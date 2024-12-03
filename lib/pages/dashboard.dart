// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../utils/sensor_box.dart';
import '../detail_pages/detail_temperature.dart';
import '../detail_pages/detail_humidity.dart';
import '../detail_pages/detail_soil.dart';
import '../detail_pages/detail_ph.dart';
import '../detail_pages/detail_ppm.dart';
import '../detail_pages/detail_sensor.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  bool _isLoading = false;
  String _errorMessage = "";
  String _recommendation = "";

  double latestTemperature = 0.0;
  double latestHumidity = 0.0;
  double latestSoil = 0.0;
  double phValue = 0.0;
  double ppmValue = 0.0;
  String latestTimestamp = "";

  Timer? _timer; // Add Timer to manage periodic refresh

  @override
  void initState() {
    super.initState();
    _fetchLatestData();

    // Set up the timer to refresh data every 5 minutes (300 seconds)
    _timer = Timer.periodic(const Duration(minutes: 3), (timer) {
      _fetchLatestData();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to avoid memory leaks
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLatestData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = ""; // Clear previous error
      _recommendation = ""; // Clear recommendation
    });

    try {
      // Check for internet connection before fetching data
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        setState(() {
          _isLoading = false;
          _errorMessage = "No Internet Connection. Please check your network.";
        });
        return; // Early exit if no connection
      }

      double temperature = 0.0;
      double humidity = 0.0;
      double soil = 0.0;
      double ph = 0.0;
      double ppm = 0.0;

      // Fetch data from `sensor_data_1`
      final sensor1Snapshot = await _databaseRef
          .child('sensor_data_1')
          .orderByKey()
          .limitToLast(1)
          .once();
      String sensor1Timestamp = "";
      if (sensor1Snapshot.snapshot.value != null) {
        final latestSensor1 =
            (sensor1Snapshot.snapshot.value as Map).values.first;
        temperature += (latestSensor1['temperature'] ?? 0).toDouble();
        humidity += (latestSensor1['humidity'] ?? 0).toDouble();
        soil += (latestSensor1['soil_moisture'] ?? 0).toDouble();
        sensor1Timestamp = latestSensor1['timestamp'] ?? "";
      }

      // Fetch data from `sensor_data_2`
      final sensor2Snapshot = await _databaseRef
          .child('sensor_data_2')
          .orderByKey()
          .limitToLast(1)
          .once();
      String sensor2Timestamp = "";
      if (sensor2Snapshot.snapshot.value != null) {
        final latestSensor2 =
            (sensor2Snapshot.snapshot.value as Map).values.first;
        temperature += (latestSensor2['temperature'] ?? 0).toDouble();
        humidity += (latestSensor2['humidity'] ?? 0).toDouble();
        soil += (latestSensor2['soil_moisture'] ?? 0).toDouble();
        sensor2Timestamp = latestSensor2['timestamp'] ?? "";
      }

      // Fetch data from `sensor_data_3`
      final sensor3Snapshot = await _databaseRef
          .child('sensor_data_3')
          .orderByKey()
          .limitToLast(1)
          .once();
      String sensor3Timestamp = "";
      if (sensor3Snapshot.snapshot.value != null) {
        final latestSensor3 =
            (sensor3Snapshot.snapshot.value as Map).values.first;
        ph += (latestSensor3['pH'] ?? 0).toDouble();
        ppm += (latestSensor3['TDS'] ?? 0).toDouble();
        sensor3Timestamp = latestSensor3['timestamp'] ?? "";
      }

      // Determine the most recent timestamp
      latestTimestamp = _getLatestTimestamp(
        sensor1Timestamp,
        sensor2Timestamp,
        sensor3Timestamp,
      );

      // Fetch DSS recommendation from API
      _recommendation = await ApiService.fetchRecommendation(
        temperature: temperature / 2,
        humidity: humidity / 2,
        soilMoisture: soil / 2,
        ph: ph,
        tds: ppm,
      );

      // Update Newest Data
      setState(() {
        _isLoading = false;

        latestTemperature = temperature / 2;
        latestHumidity = humidity / 2;
        latestSoil = soil / 2;
        phValue = ph;
        ppmValue = ppm;
        latestTimestamp = latestTimestamp; // Update latest timestamp
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: $e";
      });
    }
  }

  String _getLatestTimestamp(String t1, String t2, String t3) {
    // Parse timestamps into DateTime objects
    DateTime? dt1 = t1.isNotEmpty ? DateTime.parse(t1) : null;
    DateTime? dt2 = t2.isNotEmpty ? DateTime.parse(t2) : null;
    DateTime? dt3 = t3.isNotEmpty ? DateTime.parse(t3) : null;

    // Find the most recent DateTime
    DateTime? latest = [dt1, dt2, dt3]
        .where((dt) => dt != null)
        .reduce((a, b) => (a!.isAfter(b!)) ? a : b);

    // Format the timestamp as DD/MM/YYYY | HH:mm
    if (latest != null) {
      return "${latest.day.toString().padLeft(2, '0')}/"
          "${latest.month.toString().padLeft(2, '0')}/"
          "${latest.year} | "
          "${latest.hour.toString().padLeft(2, '0')}:"
          "${latest.minute.toString().padLeft(2, '0')}";
    }

    return "No timestamp available";
  }

  List mySensors = [
    [
      "Temperature",
      "assets/icons/temperature.png",
      "30",
      "°C",
      "assets/icons/detail.png",
      const DetailTemperature(),
    ],
    [
      "Humidity",
      "assets/icons/humidity.png",
      "70",
      "%",
      "assets/icons/detail.png",
      const DetailHumidity(),
    ],
    [
      "Soil Moisture",
      "assets/icons/soil.png",
      "70",
      "%",
      "assets/icons/detail.png",
      const DetailSoil(),
    ],
    [
      "PH Water",
      "assets/icons/pH.png",
      "7",
      "pH",
      "assets/icons/detail.png",
      const DetailPH(),
    ],
    [
      "PPM",
      "assets/icons/ppm.png",
      "130",
      "mg/L",
      "assets/icons/detail.png",
      const DetailPPM(),
    ],
    [
      "Information",
      "assets/icons/sensor.png",
      "Sensor",
      "",
      "assets/icons/detail.png",
      const DetailSensor(),
    ],
  ];

  void navigateToDetail(Widget detailScreen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => detailScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 245, 245),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: Colors.black,
                size: 55,
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      ElevatedButton(
                        onPressed: _fetchLatestData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 246, 245, 245),
                        ),
                        child: const Text(
                          "Try Again",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchLatestData,
                  color: Colors.black,
                  backgroundColor: const Color.fromARGB(255, 246, 245, 245),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome !",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                "Smart Screen House",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            "Smart Sensors",
                            style: TextStyle(
                              fontSize: 25,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            bottom: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Decision Support System :",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                _recommendation.isNotEmpty
                                    ? "*$_recommendation"
                                    : "Loading recommendation...",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Spacer(),
                                  Text(
                                    "Updated At",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'Poppins',
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Spacer(),
                                  Text(
                                    latestTimestamp,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontFamily: 'Poppins',
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GridView.builder(
                          itemCount: mySensors.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.9,
                          ),
                          itemBuilder: (context, index) {
                            String sensorName = mySensors[index][0];
                            String value = '';

                            // Dynamic condition to assign sensor values
                            if (sensorName == "Temperature") {
                              value = latestTemperature.toStringAsFixed(1);
                            } else if (sensorName == "Humidity") {
                              value = latestHumidity.toStringAsFixed(1);
                            } else if (sensorName == "Soil Moisture") {
                              value = latestSoil.toStringAsFixed(1);
                            } else if (sensorName == "PH Water") {
                              value = phValue.toStringAsFixed(1);
                            } else if (sensorName == "PPM") {
                              value = ppmValue.toStringAsFixed(0);
                            } else if (sensorName == "Information") {
                              value = "Tools";
                            }

                            return SensorBox(
                              sensorName: sensorName,
                              pathIcon: mySensors[index][1],
                              valueSensor: value,
                              unitSensor: mySensors[index][3],
                              buttonDetail: mySensors[index][4],
                              onDetailButtonPressed: () =>
                                  navigateToDetail(mySensors[index][5]),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
