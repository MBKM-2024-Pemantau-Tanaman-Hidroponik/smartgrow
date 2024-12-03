import 'package:flutter/material.dart';

class DetailSensor extends StatelessWidget {
  const DetailSensor({super.key});

  @override
  Widget build(BuildContext context) {
    // List of sensors with descriptions and uses
    final List<Map<String, String>> sensors = [
      {
        'name': 'DHT11',
        'description': 'Measures temperature and humidity.',
        'use':
            'Used in monitoring weather and greenhouse conditions in agriculture.',
      },
      {
        'name': 'Soil Moisture Sensor',
        'description': 'Measures the moisture content in soil.',
        'use':
            'Helps farmers optimize irrigation schedules to prevent overwatering or drought.',
      },
      {
        'name': 'TDS Sensor',
        'description': 'Measures the total dissolved solids in water.',
        'use': 'Ensures water quality for plant irrigation and aquaculture.',
      },
      {
        'name': 'pH Sensor',
        'description': 'Measures the acidity or alkalinity of soil or water.',
        'use': 'Helps determine the suitability of soil for specific crops.',
      },
      {
        'name': 'Arduino Uno',
        'description':
            'A microcontroller board used for control and data processing.',
        'use': 'Acts as the main controller for IoT agricultural systems.',
      },
      {
        'name': 'ESP32',
        'description': 'A microcontroller with built-in WiFi and Bluetooth.',
        'use': 'Enables wireless connectivity in smart farming systems.',
      },
      {
        'name': 'Wemos Mini 8266',
        'description': 'A compact WiFi-enabled microcontroller.',
        'use': 'Used for data transmission in IoT systems.',
      },
      {
        'name': 'LCD',
        'description': 'Displays data visually.',
        'use': 'Shows sensor readings and system status to users.',
      },
      {
        'name': 'Fan Exhaust',
        'description': 'Ventilation equipment to regulate air circulation.',
        'use':
            'Used in greenhouses to maintain optimal temperature and humidity.',
      },
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 245, 245),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 246, 245, 245),
        title: const Text(
          'Sensor Information',
        ),
      ),
      body: ListView.builder(
        itemCount: sensors.length,
        itemBuilder: (context, index) {
          final sensor = sensors[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(sensor['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description: ${sensor['description']}'),
                  Text('Use: ${sensor['use']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
