import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPPM extends StatefulWidget {
  const DetailPPM({super.key});

  @override
  State<DetailPPM> createState() => _DetailPPMState();
}

class _DetailPPMState extends State<DetailPPM> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  List<Map<String, dynamic>> _phData = [];
  List<Map<String, dynamic>> _filteredData = [];
  bool _ascending = false; // Default to newest first

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Fetch data from sensor_data_3
    final snapshot = await _database.child('sensor_data_3').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _phData = _parseSensorData(data);
        _filteredData = List.from(_phData); // Initialize filtered data
        _sortData(initialSort: true);
      });
    }
  }

  List<Map<String, dynamic>> _parseSensorData(Map<dynamic, dynamic> data) {
    return data.entries
        .where((entry) => entry.value.containsKey('TDS')) // Filter only pH data
        .map((entry) {
      return {
        'id': entry.key,
        'TDS': entry.value['TDS'], // Extract pH value
        'timestamp': entry.value['timestamp'], // Extract timestamp
      };
    }).toList();
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
      _filteredData = _phData.where((entry) {
        return entry['timestamp'].contains(query);
      }).toList();
    });
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('dd-MM-yyyy | HH:mm:ss').format(dateTime);
    } catch (e) {
      debugPrint('Invalid date format: $timestamp. Error: $e');
      return 'Invalid Date'; // Fallback for invalid timestamps
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 245, 245),
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 246, 245, 245),
          title: const Text('PPM Water Detail')),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: Colors.black,
        backgroundColor: const Color.fromARGB(255, 246, 245, 245),
        child: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: TextField(
                cursorColor: Colors.black,
                decoration: const InputDecoration(
                  labelText: 'Search by Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  labelStyle:
                      TextStyle(color: Colors.black, fontFamily: 'Poppins'),
                ),
                onChanged: _filterData,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  // Table header
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
                          label: Text('TDS (PPM)'),
                          headingRowAlignment: MainAxisAlignment.center,
                        ),
                      ],
                      rows: const [], // No rows needed in the header
                    ),
                  ),
                  // Table data
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
                            DataColumn(
                                label: Text('')), // Empty for data layout
                            DataColumn(label: Text('')),
                          ],
                          rows: _filteredData
                              .map((data) => DataRow(cells: [
                                    DataCell(Text(
                                        _formatTimestamp(data['timestamp']))),
                                    DataCell(Text("${data['TDS']}")),
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
