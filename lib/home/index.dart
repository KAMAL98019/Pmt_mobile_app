import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pmt_trust/Language/languageservices.dart';
import 'package:pmt_trust/apiservices/apiservice.dart';
import 'package:pmt_trust/home/form.dart';
import 'package:pmt_trust/home/home.dart';
import 'package:pmt_trust/home/profile.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Index extends StatefulWidget {
  final int userId;
  final String lang;

  const Index({required this.userId, required this.lang});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  late List<Widget> _pages;
  int _currentIndex = 0;
  final apiService = ApiService();
  final languageService = LanguageService();
  int memberid = 0;

  List<String> _labels = ["Home", "Form", "Profile"];
  bool _isLoading = true;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _initializePages(
        widget.lang, widget.userId); // Initialize pages with the provided lang
    updateLanguage(widget.userId, widget.lang);

    getmemberid(widget.userId);
    storeuserIdandValue(widget.userId, widget.lang);
    // print(widget.lang);
  }

  void storeuserIdandValue(int userId, String lang) async {
    await storage.write(key: 'userId', value: userId.toString());
    await storage.write(key: 'lang', value: lang);
  }

  void getmemberid(int id) async {
    try {
      // Call the API to extract member ID
      dynamic response =
          await apiService.extractmemberID("/getHomePage/user", id);

      // Check if the response contains the expected data structure
      if (response != null &&
          response['data'] != null &&
          response['data']['member_id'] != null) {
        int memberId = response['data']['member_id'];
        setState(() {
          memberid = memberId;
        });
        print("Extracted Member ID: $memberId");
      } else {
        print("Error: Response does not contain member_id.");
        setState(() {
          memberid = 0;
        });
      }
    } catch (e) {
      // Handle any exceptions
      print("Error fetching member ID: $e");
    }
  }

  void _initializePages(String lang, int userID) {
    _pages = [
      HomePage(lang: lang, userID: userID, memberId: memberid),
      FormPage(
        lang: lang,
        userID: userID,
        memberId: memberid,
      ),
      ProfilePage(userId: userID, lang: lang)
    ];
  }

  void updateLanguage(int userId, String lang) async {
    setState(() {
      _isLoading = true;
    });

    var res = await apiService.updateLanguage("/updateLanguage", userId, lang);
    if (res != null) {
      String message = res["message"];
      bool error = res["error"] == "true";

      if (!error) {
        List<String> originalLabels = ["Home", "Form", "Profile"];
        Map<String, String> translatedTexts =
            await languageService.translateText(originalLabels, lang);
// Manually update "Form" to "படிவம்" if the language is Tamil
        if (lang == 'ta') {
          translatedTexts["Form"] = "படிவம்";
        }
        setState(() {
          _labels =
              originalLabels.map((label) => translatedTexts[label]!).toList();
          _isLoading = false;
        });

        _initializePages(lang, userId); // Reinitialize pages with updated lang

        toastification.show(
          context: context,
          title: Text(message),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 5),
        );
      } else {
        setState(() {
          _isLoading = false;
        });

        toastification.show(
          context: context,
          title: Text(message),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });

      print("No response from the server.");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        
        body: _pages[_currentIndex],
        bottomNavigationBar: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, -1),
                blurRadius: 3,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Localizations.override(
            context: context,
            locale:  Locale(widget.lang),
            child: Builder(builder: (context) {
              return BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onItemTapped,
                selectedItemColor: const Color.fromRGBO(239, 7, 3, 1),
                selectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                iconSize: 24,
                // items: List.generate(
                //   _labels.length,
                //   (index) => BottomNavigationBarItem(
                //     icon: Icon(
                //       [
                //         Ionicons.home,
                //         Ionicons.newspaper,
                //         Ionicons.person
                //       ][index],
                //     ),
                //     label: "Home",
      
                //   ),
                // ),
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Ionicons.home),
                    label: AppLocalizations.of(context)!.home ??
                        "Home", // Label for Home
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Ionicons.newspaper),
                    label: AppLocalizations.of(context)!.form ??
                        "Form", // Label for Form
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Ionicons.person),
                    label: AppLocalizations.of(context)!.profile ??
                        "Profile", // Label for Profile
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
