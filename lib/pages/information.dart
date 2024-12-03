import 'package:flutter/material.dart';

class Information extends StatefulWidget {
  const Information({super.key});

  @override
  State<Information> createState() => _InformationState();
}

class _InformationState extends State<Information> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 245, 245),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'About SmartGrow',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SmartGrow',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Developed by: TEAM MBKM JTI 2024',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Version: 1.0.0',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
            const Divider(height: 30, thickness: 1.0),
            const Text(
              'About the App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'SmartGrow is an advanced plant monitoring system that utilizes IoT '
              'technology to help farmers and enthusiasts optimize their plant care routines. '
              'The app integrates sensors for monitoring temperature, humidity, soil moisture, pH, '
              'and TDS levels, providing real-time data and actionable insights.\n\n'
              'Additionally, SmartGrow includes a Decision Support System (DSS) powered by fuzzy logic, '
              'which offers intelligent recommendations based on sensor readings to ensure plants are '
              'always in optimal conditions. This makes SmartGrow an ideal solution for precision agriculture '
              'and sustainable farming practices in Indonesia.',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.eco,
                  color: Colors.green[700],
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Smart Farming, Smarter Future',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
