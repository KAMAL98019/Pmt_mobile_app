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

 Future<dynamic> updateProfile(
    String endpoint, int userId, Map<String, dynamic> updatedData) async {
  final url = Uri.parse('$baseUrl$endpoint/$userId');
  print("API URL: $url");

  try {
    // Create a multipart request
    var request = http.MultipartRequest('PUT', url);

    // Add text fields (e.g., name, email, gender)
    request.fields['name'] = updatedData['name'] ?? '';
    request.fields['email'] = updatedData['email'] ?? '';
    request.fields['gender'] = updatedData['gender'] ?? '';

    // Handle fileBuffer
    if (updatedData['fileBuffer'] != null) {
      var fileBuffer = updatedData['fileBuffer'];

      if (fileBuffer.startsWith('http')) {
        // If it's a URL, send it as a field
        request.fields['fileBuffer'] = fileBuffer;
      } else {
        // If it's a local file path, send it as a file
        var file = await http.MultipartFile.fromPath(
          'fileBuffer', // Field name expected by the API
          fileBuffer,
        );
        request.files.add(file);
      }
    }

    // Send the request
    var response = await request.send();

    // Handle response
    if (response.statusCode == 200) {
      // Successfully updated
      return jsonDecode(await response.stream.bytesToString());
    } else {
      // Handle error response
      print(
          "Error: ${response.statusCode} - ${await response.stream.bytesToString()}");
      return null;
    }
  } catch (e) {
    // Handle exceptions
    print("Error: $e");
    return null;
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
        print("Error: ${response.body}");
        return jsonDecode(response.body);
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
        print("Error: ${response.body}");
        return jsonDecode(response.body);
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
      return null;
    }
  }

  Future<dynamic> getmemberlist(String endpoint, int userId) async {
    // Construct the URL with query parameters
    final url = Uri.parse('$baseUrl$endpoint/$userId');
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
        print("Error: ${response.body}");
        return jsonDecode(response.body);
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
      return null;
    }
  }

  Future<dynamic> savemember(String endpoint, Map<String, dynamic> data) async {
    // Construct the URL
    final url = Uri.parse('$baseUrl$endpoint');
    print("API URL: $url");

    try {
      // Make the HTTP POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      // Check for a successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Decode and return the JSON response
        return jsonDecode(response.body);
      } else {
        // Handle errors
        print("Error: ${response.body}");
        return jsonDecode(response.body);
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
      return null;
    }
  }

  Future<dynamic> updatemember(
      String endpoint, int param, Map<String, dynamic> data) async {
    // Construct the URL
    final url = Uri.parse('$baseUrl$endpoint/$param');
    print("API URL: $url");

    try {
      // Make the HTTP PUT request
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      // Check for a successful response
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Decode and return the JSON response, if any
        return response.body.isNotEmpty
            ? jsonDecode(response.body)
            : "Update successful";
      } else {
        // Handle errors
        print("Error:${response.body}");
        return jsonDecode(response.body);
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
      return null;
    }
  }

  Future<dynamic> extractmemberID(String endpoint, int memberid) async {
    final url = Uri.parse('$baseUrl$endpoint/$memberid');
    print("API URL: $url");

    try {
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        // Parse and return the JSON response
        final jsonData = json.decode(response.body);
        print("Response Data: $jsonData");
        return jsonData;
      } else {
        // Handle errors
        print("Error: ${response.statusCode}, ${response.body}");
        return {
          "error": "Failed to fetch data. Status code: ${response.statusCode}"
        };
      }
    } catch (e) {
      // Handle exceptions
      print("Exception occurred: $e");
      return {"error": "An exception occurred: $e"};
    }
  }
}
