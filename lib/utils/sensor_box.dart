import 'package:flutter/material.dart';

class SensorBox extends StatelessWidget {
  final String sensorName;
  final String pathIcon;
  final String valueSensor;
  final String unitSensor;
  final String buttonDetail;
  final VoidCallback onDetailButtonPressed;

  const SensorBox({
    super.key,
    required this.sensorName,
    required this.pathIcon,
    required this.valueSensor,
    required this.unitSensor,
    required this.buttonDetail,
    required this.onDetailButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sensorName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: onDetailButtonPressed,
                    child: Image.asset(
                      buttonDetail,
                      height: 15,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 120,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 40,
                  ),
                  child: Text(
                    valueSensor,
                    style: const TextStyle(
                      fontSize: 55,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  top: 22,
                  right: 27,
                  child: Text(
                    unitSensor,
                    style: const TextStyle(
                      fontSize: 25,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 0,
                  child: Image.asset(
                    pathIcon,
                    height: 25,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
