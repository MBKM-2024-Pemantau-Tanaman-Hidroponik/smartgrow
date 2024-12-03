// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SensorData {
  final String timestamp;
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final double pH;
  final double tds;

  SensorData({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.pH,
    required this.tds,
  });
}

class Record extends StatefulWidget {
  const Record({super.key});

  @override
  State<Record> createState() => _RecordState();
}

class _RecordState extends State<Record> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  bool _isLoading = true;
  String _errorMessage = "";
  DateTime? latestUpdateTime;

  Timer? _timer; // Add Timer to manage periodic refresh

  // Chart data
  List<SensorData> sensor1Data = [];
  List<SensorData> sensor2Data = [];
  List<SensorData> sensor3Data = [];

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
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = ""; // Clear any previous error messages
      });

      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception("No Internet Connection");
      }

      DateTime? latestTime; // To track the latest timestamp

      // Fetch data for Sensor 1
      final sensor1Snapshot = await _databaseRef
          .child('sensor_data_1')
          .orderByKey()
          .limitToLast(5) // Fetch last 5 data points
          .once();
      if (sensor1Snapshot.snapshot.value != null) {
        final sensor1Map =
            (sensor1Snapshot.snapshot.value as Map).values.toList();
        sensor1Data = sensor1Map.map<SensorData>((data) {
          return SensorData(
            timestamp: data['timestamp'] ?? '',
            temperature: (data['temperature'] ?? 0).toDouble(),
            humidity: (data['humidity'] ?? 0).toDouble(),
            soilMoisture: (data['soil_moisture'] ?? 0).toDouble(),
            pH: 0, // Not applicable
            tds: 0, // Not applicable
          );
        }).toList();

        // Get the latest timestamp for Sensor 1
        final latestTimestamp = sensor1Map.last['timestamp'] ?? '';
        final parsedTimestamp = DateTime.tryParse(latestTimestamp);
        if (parsedTimestamp != null) {
          latestTime =
              (latestTime == null || parsedTimestamp.isAfter(latestTime))
                  ? parsedTimestamp
                  : latestTime;
        }
      }

      // Repeat for Sensor 2
      final sensor2Snapshot = await _databaseRef
          .child('sensor_data_2')
          .orderByKey()
          .limitToLast(5)
          .once();
      if (sensor2Snapshot.snapshot.value != null) {
        final sensor2Map =
            (sensor2Snapshot.snapshot.value as Map).values.toList();
        sensor2Data = sensor2Map.map<SensorData>((data) {
          return SensorData(
            timestamp: data['timestamp'] ?? '',
            temperature: (data['temperature'] ?? 0).toDouble(),
            humidity: (data['humidity'] ?? 0).toDouble(),
            soilMoisture: (data['soil_moisture'] ?? 0).toDouble(),
            pH: 0, // Not applicable
            tds: 0, // Not applicable
          );
        }).toList();

        final latestTimestamp = sensor2Map.last['timestamp'] ?? '';
        final parsedTimestamp = DateTime.tryParse(latestTimestamp);
        if (parsedTimestamp != null) {
          latestTime =
              (latestTime == null || parsedTimestamp.isAfter(latestTime))
                  ? parsedTimestamp
                  : latestTime;
        }
      }

      // Repeat for Sensor 3
      final sensor3Snapshot = await _databaseRef
          .child('sensor_data_3')
          .orderByKey()
          .limitToLast(5)
          .once();
      if (sensor3Snapshot.snapshot.value != null) {
        final sensor3Map =
            (sensor3Snapshot.snapshot.value as Map).values.toList();
        sensor3Data = sensor3Map.map<SensorData>((data) {
          return SensorData(
            timestamp: data['timestamp'] ?? '',
            temperature: 0, // Not applicable
            humidity: 0, // Not applicable
            soilMoisture: 0, // Not applicable
            pH: (data['pH'] ?? 0).toDouble(),
            tds: (data['TDS'] ?? 0).toDouble(),
          );
        }).toList();

        final latestTimestamp = sensor3Map.last['timestamp'] ?? '';
        final parsedTimestamp = DateTime.tryParse(latestTimestamp);
        if (parsedTimestamp != null) {
          latestTime =
              (latestTime == null || parsedTimestamp.isAfter(latestTime))
                  ? parsedTimestamp
                  : latestTime;
        }
      }

      setState(() {
        _isLoading = false;
        latestUpdateTime = latestTime;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (e.toString().contains("No Internet Connection")) {
          _errorMessage = "No Internet Connection. Please check your network.";
        } else {
          _errorMessage = "Failed to load data: $e"; // Other errors
        }
      });
    }
  }

  Widget buildSensorChart(
    String title,
    List<SensorData> data,
    List<String> parameters,
  ) {
    // Zoom and Trackball configurations
    final ZoomPanBehavior zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      zoomMode: ZoomMode.x, // Enable zooming on X-axis
    );

    final TrackballBehavior trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.longPress,
      tooltipSettings: const InteractiveTooltip(
        enable: true,
        format: 'point.x : point.y',
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SfCartesianChart(
        title: ChartTitle(
          text: title,
          alignment: ChartAlignment.near,
          textStyle: const TextStyle(
            fontSize: 17,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        legend: const Legend(isVisible: true),
        primaryXAxis: const CategoryAxis(
          title: AxisTitle(text: 'Record Time'),
        ),
        primaryYAxis: const NumericAxis(
          title: AxisTitle(text: 'Value'),
        ),
        series: parameters.map((parameter) {
          return SplineSeries<SensorData, String>(
            name: parameter,
            dataSource: data,
            xValueMapper: (SensorData sensorData, _) {
              try {
                DateTime dateTime = DateTime.parse(sensorData.timestamp);
                return DateFormat.Hm().format(dateTime);
              } catch (e) {
                return sensorData.timestamp;
              }
            },
            yValueMapper: (SensorData sensorData, _) {
              switch (parameter) {
                case 'Temperature':
                  return sensorData.temperature;
                case 'Humidity':
                  return sensorData.humidity;
                case 'Soil Moisture':
                  return sensorData.soilMoisture;
                case 'pH':
                  return sensorData.pH;
                case 'TDS':
                  return sensorData.tds;
                default:
                  return 0;
              }
            },
            markerSettings: const MarkerSettings(isVisible: false),
          );
        }).toList(),
        zoomPanBehavior: zoomPanBehavior, // Add zoom behavior
        trackballBehavior: trackballBehavior, // Add trackball behavior
      ),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Record Chart Data of Sensors",
                            style: TextStyle(
                              fontSize: 23,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Updated At:",
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            latestUpdateTime != null
                                ? DateFormat('dd/MM/yyyy | HH:mm')
                                    .format(latestUpdateTime!)
                                : 'Loading...',
                            style: TextStyle(
                              fontSize: 17,
                              fontFamily: 'Poppins',
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 10),
                          buildSensorChart(
                            'Sensor 1',
                            sensor1Data,
                            ['Temperature', 'Humidity', 'Soil Moisture'],
                          ),
                          buildSensorChart(
                            'Sensor 2',
                            sensor2Data,
                            ['Temperature', 'Humidity', 'Soil Moisture'],
                          ),
                          buildSensorChart(
                            'Sensor 3',
                            sensor3Data,
                            ['pH', 'PPM'],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
