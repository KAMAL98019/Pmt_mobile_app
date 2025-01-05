import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pmt_trust/apiservices/apiservice.dart';
import 'package:pmt_trust/home/index.dart';

class LanguageSelectPage extends StatefulWidget {
  final String data;

  const LanguageSelectPage({required this.data});

  @override
  State<LanguageSelectPage> createState() => _LanguageSelectPageState();
}

class _LanguageSelectPageState extends State<LanguageSelectPage> {
  List<bool> isSelected = [true, false];
  var Selectedlang = "";
  late Map<String, dynamic> jsonResponse;
  var validate = "";
  final apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Decode the JSON data from the widget's passed data
    jsonResponse = jsonDecode(widget.data);
    fetchData();
    Selectedlang = isSelected[0] ? "ta" : "en";
  }

  Future<void> fetchData() async {
    print(jsonResponse["userId"]);
    try {
      // Await the API call to get the profile
      var res =
          await apiService.GetProfile("/getProfile", jsonResponse["userId"]);

      // Print the actual response after it's fetched
      print(jsonEncode(res["data"][0]["language"]));
      setState(() {
        // Update isSelected based on the language
        if (res["data"][0]["language"] == "en") {
          isSelected = [false, true]; // English selected
        } else {
          isSelected = [true, false]; // Tamil selected
        }
      });
    } catch (e) {
      // Handle any errors
      print('Error: $e');
    }
  }

  void _selectLanguage(int index, String lang) {
    debugPrint("Selected language index: $index => $lang");
    setState(() {
      Selectedlang = lang;
    });
    setState(() {
      for (int i = 0; i < isSelected.length; i++) {
        isSelected[i] = i == index;
      }
    });
    print("selected lang : $Selectedlang");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(34, 34, 34, 1),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _selectLanguage(0, "ta"),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected[0]
                            ? Color.fromRGBO(239, 7, 3, 1) // Active color
                            : Colors.white, // Inactive color
                        side: BorderSide(
                          color: Color.fromRGBO(239, 7, 3, 1), // Border color
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        minimumSize: Size(0, 50.0),
                      ),
                      child: Text(
                        "Tamil",
                        style: TextStyle(
                          color: isSelected[0] ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _selectLanguage(1, "en"),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected[1]
                            ? Color.fromRGBO(239, 7, 3, 1) // Active color
                            : Colors.white, // Inactive color
                        side: BorderSide(
                          color: Color.fromRGBO(239, 7, 3, 1), // Border color
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        minimumSize: Size(0, 50.0),
                      ),
                      child: Text(
                        "English",
                        style: TextStyle(
                          color: isSelected[1] ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Index(
                                userId: jsonResponse["userId"],
                                lang: Selectedlang)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(239, 7, 3, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: Size(0, 50.0),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
