import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your API base URL
  static const String _baseURL = "http://192.168.18.22:80"; 

  // Fetch DSS recommendation based on sensor data
  static Future<String> fetchRecommendation({
    required double temperature,
    required double humidity,
    required double soilMoisture,
    required double ph,
    required double tds,
  }) async {
    const String endpoint = "/recommendation";
    const String apiUrl = '$_baseURL$endpoint';

    try {
      // Prepare sensor data for POST request
      final sensorData = {
        "suhu": temperature,
        "kelembapan_udara": humidity,
        "kelembapan_tanah": soilMoisture,
        "ph_air": ph,
        "tds": tds,
      };

      // Send POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(sensorData),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['recommendation'] ?? "No Recommendation";
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception("$e");
    }
  }
}
