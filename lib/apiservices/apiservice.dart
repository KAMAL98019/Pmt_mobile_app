import "dart:convert";
import "package:flutter/widgets.dart";
import "package:http/http.dart" as http;

class ApiService {
  static const String baseUrl = 'http://13.201.166.103:4000/pmt';

  // Mobile number Send Post Resquest for OTP

  Future<dynamic> PostMobileNumber(String endpoint, String data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{"mobile": data}),
      );
      // print(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      print("error: $e");
    }
  }

  Future<dynamic> OtpValidate(
      String endpoint, String code, String verificationId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            <String, String>{"code": code, "verificationId": verificationId}),
      );
      // print(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      print("error: $e");
    }
  }

  Future<dynamic> GetProfile(String endpoint, int userid) async {
    print("$baseUrl$endpoint/$userid");
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint/$userid'),
        headers: {'Content-Type': 'application/json'},
      );
      // print(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      print("error: $e");
    }
  }

  Future<dynamic> updateLanguage(
      String endpoint, int userId, String language) async {
        print("userId: $userId, language: $language");
    // Construct the URL with query parameters
    final url = Uri.parse('$baseUrl$endpoint/$userId?language=$language');
    print("API URL: $url");

    try {
      // Make the HTTP GET request
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      // Check for a successful response
      if (response.statusCode == 200) {
        // Decode and return the JSON response
        return jsonDecode(response.body);
      } else {
        // Handle errors
        print("Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
      return null;
    }
  }

  Future<dynamic> getBanner(
    String endpoint, String userId, String name, String email) async {
  // Construct the URL with query parameters
  final url = Uri.parse('$baseUrl$endpoint/$userId?name=$name&email=$email');
  print("API URL: $url");

  try {
    // Make the HTTP GET request
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    // Check for a successful response
    if (response.statusCode == 200) {
      // Decode and return the JSON response
      return jsonDecode(response.body);
    } else {
      // Handle errors
      print("Error: ${response.statusCode} - ${response.body}");
      return null;
    }
  } catch (e) {
    // Handle exceptions
    print("Error: $e");
    return null;
  }
}

  

}
