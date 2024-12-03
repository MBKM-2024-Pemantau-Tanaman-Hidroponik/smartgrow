import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class DetailTemperature extends StatefulWidget {
  const DetailTemperature({super.key});

  @override
  State<DetailTemperature> createState() => _DetailTemperatureState();
}

class _DetailTemperatureState extends State<DetailTemperature> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  List<Map<String, dynamic>> _sensor1Data = [];
  List<Map<String, dynamic>> _sensor2Data = [];
  List<Map<String, dynamic>> _filteredData = [];
  bool _ascending = false; // Default to newest first
  String _selectedSensor = 'sensor_data_1'; // Default selection

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Fetch sensor_data_1
    final sensor1Snapshot = await _database.child('sensor_data_1').get();
    if (sensor1Snapshot.exists) {
      final data = sensor1Snapshot.value as Map<dynamic, dynamic>;
      _sensor1Data = _parseSensorData(data);
    }

    // Fetch sensor_data_2
    final sensor2Snapshot = await _database.child('sensor_data_2').get();
    if (sensor2Snapshot.exists) {
      final data = sensor2Snapshot.value as Map<dynamic, dynamic>;
      _sensor2Data = _parseSensorData(data);
    }

    // Set initial filtered data to sensor_data_1 and sort by newest
    setState(() {
      _filteredData = _sensor1Data;
      _sortData(initialSort: true);
    });
  }

  List<Map<String, dynamic>> _parseSensorData(Map<dynamic, dynamic> data) {
    return data.entries
        .where((entry) => entry.value.containsKey('temperature'))
        .map((entry) {
      return {
        'id': entry.key,
        'temperature': entry.value['temperature'],
        'timestamp': entry.value['timestamp'],
      };
    }).toList();
  }

  void _onSensorChange(String? sensor) {
    if (sensor == null) return; // Handle null safely
    setState(() {
      _selectedSensor = sensor;
      _filteredData = sensor == 'sensor_data_1' ? _sensor1Data : _sensor2Data;
      _sortData(initialSort: true); // Sort again on sensor change
    });
  }

  void _sortData({bool initialSort = false}) {
    setState(() {
      _filteredData.sort((a, b) {
        try {
          final dateA = DateTime.parse(a['timestamp']);
          final dateB = DateTime.parse(b['timestamp']);
          return (_ascending || initialSort)
              ? dateB.compareTo(dateA)
              : dateA.compareTo(dateB);
        } catch (e) {
          debugPrint('Error parsing date for sorting. Error: $e');
          return 0; // Treat invalid dates as equal to avoid sorting errors
        }
      });
      if (!initialSort) {
        _ascending = !_ascending; // Toggle sorting order only if not initial
      }
    });
  }

  void _filterData(String query) {
    setState(() {
      final source =
          _selectedSensor == 'sensor_data_1' ? _sensor1Data : _sensor2Data;
      _filteredData = source.where((entry) {
        return entry['timestamp'].contains(query);
      }).toList();
    });
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime =
          DateTime.parse(timestamp); // Attempt to parse the timestamp
      return DateFormat('dd-MM-yyyy | HH:mm:ss').format(dateTime);
    } catch (e) {
      debugPrint('Invalid date format: $timestamp. Error: $e');
      return 'Invalid Date'; // Fallback value for invalid timestamps
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 245, 245),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 246, 245, 245),
        title: const Text('Temperature Detail'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: Colors.black,
        backgroundColor: const Color.fromARGB(255, 246, 245, 245),
        child: Column(
          children: [
            // Sensor selection dropdown
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              child: DropdownButton<String>(
                dropdownColor: const Color.fromARGB(255, 246, 245, 245),
                value: _selectedSensor,
                items: const [
                  DropdownMenuItem(
                      value: 'sensor_data_1', child: Text('Sensor Ke-1')),
                  DropdownMenuItem(
                      value: 'sensor_data_2', child: Text('Sensor Ke-2')),
                ],
                onChanged: _onSensorChange,
              ),
            ),
            // Search field
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              child: TextField(
                cursorColor: Colors.black,
                decoration: const InputDecoration(
                  labelText: 'Search by Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10,
                      ),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  focusColor: Colors.black,
                  hoverColor: Colors.black,
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                onChanged: _filterData,
              ),
            ),

            Expanded(
              child: Column(
                children: [
                  Container(
                    color: Colors.grey[300],
                    width: 330,
                    child: DataTable(
                      headingTextStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                      headingRowHeight: 50,
                      columns: const [
                        DataColumn(
                          label: Text('Timestamp'),
                          headingRowAlignment: MainAxisAlignment.center,
                        ),
                        DataColumn(
                          label: Text('Temperature (°C)'),
                          headingRowAlignment: MainAxisAlignment.center,
                        ),
                      ],
                      rows: const [], // No rows needed in the header
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        width: 330,
                        child: DataTable(
                          dataTextStyle: const TextStyle(
                            fontFamily: 'Poppins',
                          ),
                          headingRowHeight: 0.0,
                          columns: const [
                            // Empty to match header layout
                            DataColumn(label: Text('')),
                            DataColumn(
                              label: Text(''),
                            ),
                          ],
                          rows: _filteredData
                              .map((data) => DataRow(cells: [
                                    DataCell(Text(
                                        _formatTimestamp(data['timestamp']))),
                                    DataCell(Text("${data['temperature']} °C")),
                                  ]))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
