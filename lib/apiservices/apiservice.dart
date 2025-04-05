import "dart:async";
import "dart:convert";
import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:fluttertoast/fluttertoast.dart";
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
    } on TimeoutException catch (_) {
      print("Error: Request timed out. Please try again later.");
    } on SocketException catch (_) {
      print("Error: No internet connection or server is unreachable.");
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
    final url = Uri.parse('$baseUrl$endpoint/$userid');
    print("API URL: $url");

    const int maxAttempts = 3; // Retry up to 3 times
    const Duration timeoutDuration =
        Duration(seconds: 5); // Timeout after 5 seconds
    const Duration retryDelay =
        Duration(seconds: 2); // Wait 2 seconds before retrying
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final response = await http.get(url, headers: {
          'Content-Type': 'application/json'
        }).timeout(timeoutDuration);

        if (response.statusCode == 200) {
          print("Profile fetched successfully.");
          return jsonDecode(response.body);
        } else {
          print("Error ${response.statusCode}: ${response.body}");
          return null;
        }
      } on TimeoutException catch (_) {
        print("Attempt ${attempts + 1}: Request timed out.");
      } on SocketException catch (_) {
        print(
            "Attempt ${attempts + 1}: No internet connection or server is unreachable.");
      } catch (e) {
        print("Attempt ${attempts + 1}: Error - $e");
      }

      attempts++;
      if (attempts < maxAttempts) {
        print("Retrying in ${retryDelay.inSeconds} seconds...");
        await Future.delayed(retryDelay);
      }
    }

    print("Failed to fetch profile after $maxAttempts attempts.");
    return null;
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
          print(fileBuffer);
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
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Handle response
      if (response.statusCode == 200) {
        // Successfully updated
        return jsonDecode(response.body);
      } else {
        // Handle error response

        return jsonDecode(await response.body);
      }
    } on TimeoutException catch (_) {
      print("Error: Request timed out. Please try again later.");
    } on SocketException catch (_) {
      print("Error: No internet connection or server is unreachable.");
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
    } on TimeoutException catch (_) {
      print("Error: Request timed out. Please try again later.");
    } on SocketException catch (_) {
      print("Error: No internet connection or server is unreachable.");
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
    } on TimeoutException catch (_) {
      print("Error: Request timed out. Please try again later.");
    } on SocketException catch (_) {
      print("Error: No internet connection or server is unreachable.");
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
      return null;
    }
  }

  Future<dynamic> getmemberlist(String endpoint, int userId) async {
    final url = Uri.parse('$baseUrl$endpoint/$userId');
    print("API URL: $url");

    const int maxAttempts = 3;
    const Duration timeoutDuration = Duration(seconds: 5); // Set a timeout
    const Duration retryDelay = Duration(seconds: 2);
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        // Make the HTTP GET request with a timeout
        final response = await http.get(
          url,
          headers: {'Content-Type': 'application/json'},
        ).timeout(timeoutDuration);

        // Check for a successful response
        if (response.statusCode == 200) {
          print("Response received successfully.");
          return jsonDecode(response.body);
        } else {
          print("Error: ${response.body}");
          return jsonDecode(response.body);
        }
      } on TimeoutException catch (_) {
        print("Attempt ${attempts + 1}: Request timed out.");
      } on SocketException catch (_) {
        print(
            "Attempt ${attempts + 1}: No internet connection or server is unreachable.");
      } catch (e) {
        print("Attempt ${attempts + 1}: Error - $e");
      }

      attempts++;
      if (attempts < maxAttempts) {
        print("Retrying in ${retryDelay.inSeconds} seconds...");
        await Future.delayed(retryDelay);
      }
    }

    print("Failed to fetch data after $maxAttempts attempts.");
    return null;
  }

  Future<dynamic> savemember(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print("API URL: $url");
    try {
      var request = http.MultipartRequest('POST', url);
      print(request.fields['blood_group']);

      request.fields['user_id'] = data["user_id"].toString();
      request.fields['name'] = data['name'].toString();
      request.fields['father_name'] = data['father_name'].toString();
      request.fields['district_id'] = data['district_id'].toString();
      request.fields['constituency_id'] = data['constituency_id'].toString();
      request.fields['ward_num'] = data['ward_num']!.toString();
      request.fields['voter_id'] = data['voter_id'].toString();
      request.fields['adhar_num'] = data['adhar_num'].toString();
      request.fields['address'] = data['address'].toString();
      request.fields['designation'] = data['designation'].toString();
      request.fields['occupation'] = data['occupation'].toString();
      // Add regular form fields
      data.forEach((key, value) {
        if (key != 'fileBuffer') {
          // Exclude file key
          request.fields[key] = value.toString();
        }
      });
      request.fields['blood_group'] = data["blood_group"].toString();
      // Handle file upload
      if (data['fileBuffer'] != null) {
        var filePath = data['fileBuffer'];

        if (filePath.startsWith('http')) {
          // If it's a URL, send it as a field
          request.fields['fileBuffer'] = filePath;
        } else {
          // If it's a local file path, upload as a file
          var file = await http.MultipartFile.fromPath(
            'fileBuffer', // ✅ Ensure this matches the API's expected file key
            filePath,
          );
          request.files.add(file);
        }
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("Error: ${response.body}");

        return jsonDecode(response.body);
      }
    } on TimeoutException catch (_) {
      print("Error: Request timed out. Please try again later.");
    } on SocketException catch (_) {
      print("Error: No internet connection or server is unreachable.");
    } catch (e) {
      // print("Error: $e");
      Fluttertoast.showToast(
        msg: "Error: ${e.toString().replaceAll("Exception: ", "")}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }

    return null;
  }

  Future<dynamic> updatemember(
      String endpoint, int param, Map<String, dynamic> data) async {
    print(data);
    print(param);

    try {
      final url = Uri.parse('$baseUrl$endpoint/$param');
      print("API URL: $url");

      var request = http.MultipartRequest('PUT', url);

      // Add text fields
      data.forEach((key, value) {
        if (value != null && key != "fileBuffer") {
          request.fields[key] =
              value.toString(); // Ensure value is converted to String
        }
      });

      // Add specific fields (ensure they are converted to strings)
      request.fields['user_id'] = data["user_id"].toString();
      request.fields['name'] = data['name']?.toString() ?? '';
      request.fields['father_name'] = data['father_name']?.toString() ?? '';
      request.fields['district_id'] = data['district_id'].toString();
      request.fields['constituency_id'] = data['constituency_id'].toString();
      request.fields['ward_num'] = data['ward_num'].toString();
      request.fields['voter_id'] = data['voter_id']?.toString() ?? '';
      request.fields['adhar_num'] = data['adhar_num']?.toString() ?? '';
      request.fields['address'] = data['address']?.toString() ?? '';
      request.fields['designation'] = data['designation']?.toString() ?? '';
      request.fields['occupation'] = data['occupation']?.toString() ?? '';

      // Handle file upload
      if (data['fileBuffer'] != null) {
        var fileBuffer = data['fileBuffer'];
        print(fileBuffer);
        if (fileBuffer.startsWith('http')) {
          print("aws");
          request.fields['fileBuffer'] =
              fileBuffer.toString(); // URL is already a string
        } else {
          var file =
              await http.MultipartFile.fromPath('fileBuffer', fileBuffer);
          request.files.add(file);
        }
      }
      request.fields['blood_group'] = data["blood_group"].toString();
      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.body.isNotEmpty
            ? jsonDecode(response.body)
            : "Update successful";
      } else {
        print("Error: ${response.body}");
        return jsonDecode(response.body);
      }
    } on TimeoutException catch (_) {
      print("Error: Request timed out. Please try again later.");
      return {"error": "Request timed out"};
    } on SocketException catch (_) {
      print("Error: No internet connection or server is unreachable.");
      return {"error": "No internet connection"};
    } catch (e) {
      print("Error: $e");
      return {"error": e.toString()};
    }
  }

  Future<dynamic> extractmemberID(String endpoint, int memberid) async {
    final url = Uri.parse('$baseUrl$endpoint/$memberid');
    print("API URL: $url");

    int maxAttempts = 3;
    int attempt = 0;

    while (attempt < maxAttempts) {
      try {
        final response = await http.get(url, headers: {
          "Content-Type": "application/json",
        }).timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          print("Response Data: $jsonData");
          return jsonData;
        } else {
          print("Error: ${response.statusCode}, ${response.body}");
          return jsonDecode(response.body);
        }
      } on TimeoutException catch (_) {
        print("Attempt ${attempt + 1}: Request timed out.");
      } on SocketException catch (_) {
        print(
            "Attempt ${attempt + 1}: No internet connection or server is unreachable.");
      } catch (e) {
        print("Attempt ${attempt + 1}: Exception occurred: $e");
      }

      attempt++;
      if (attempt < maxAttempts) {
        await Future.delayed(
            const Duration(milliseconds: 500)); // Wait before retrying
        print("Retrying... Attempt $attempt");
      }
    }

    return {"error": "Failed to fetch data after $maxAttempts attempts."};
  }

  Future<dynamic> getdistricts(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print("API URL: $url");

    int maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final response = await http.get(url, headers: {
          "Content-Type": "application/json",
        });

        if (response.statusCode == 200) {
          // Parse and return the JSON response
          final jsonData = json.decode(response.body);
          return jsonData;
        } else {
          // Handle errors
          print(
              "Attempt ${attempt + 1}: Error ${response.statusCode}, ${response.body}");
          attempt++;
        }
      } on TimeoutException catch (_) {
        print("Attempt ${attempt + 1}: Request timed out. Retrying...");
        attempt++;
      } on SocketException catch (_) {
        print(
            "Attempt ${attempt + 1}: No internet connection or server unreachable. Retrying...");
        attempt++;
      } catch (e) {
        // Handle other exceptions
        print("Attempt ${attempt + 1}: Exception occurred: $e");
        return {"error": "An exception occurred: $e"};
      }

      if (attempt < maxRetries) {
        await Future.delayed(
            Duration(seconds: 2)); // Small delay before retrying
      }
    }

    return {"error": "Failed to fetch data after $maxRetries attempts"};
  }

  Future<dynamic> getDesignationList(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print("API URL: $url");

    int maxRetries = 3;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await http.get(url, headers: {
          "Content-Type": "application/json",
        });

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          print("Error: ${response.statusCode}, ${response.body}");
        }
      } on TimeoutException {
        print("Attempt $attempt: Request timed out.");
      } on SocketException {
        print(
            "Attempt $attempt: No internet connection or server is unreachable.");
      } catch (e) {
        print("Attempt $attempt: Exception occurred: $e");
      }

      if (attempt < maxRetries) {
        await Future.delayed(Duration(seconds: 2)); // Wait before retrying
        print("Retrying... (Attempt ${attempt + 1})");
      }
    }

    return {"error": "Failed to fetch data after $maxRetries attempts"};
  }
}
