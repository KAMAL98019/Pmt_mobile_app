import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pmt_trust/Language/languageservices.dart';
import 'package:pmt_trust/apiservices/apiservice.dart';
import 'package:pmt_trust/home/form.dart';
import 'package:pmt_trust/home/home.dart';
import 'package:pmt_trust/home/profile.dart';
import 'package:toastification/toastification.dart';

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

  List<String> _labels = ["Home", "Form", "Profile"];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePages(widget.lang); // Initialize pages with the provided lang
    updateLanguage(widget.userId, widget.lang);
    // print(widget.lang);
  }

  void _initializePages(String lang) {
    _pages = [
      HomePage(lang: lang),
      FormPage(lang: lang),
      ProfilePage(),
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

        setState(() {
          _labels = originalLabels.map((label) => translatedTexts[label]!).toList();
          _isLoading = false;
        });

        _initializePages(lang); // Reinitialize pages with updated lang

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
    return Scaffold(
     
      body: _pages[_currentIndex],
      bottomNavigationBar: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onItemTapped,
                selectedItemColor: const Color.fromRGBO(239, 7, 3, 1),
                selectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                iconSize: 24,
                items: List.generate(
                  _labels.length,
                  (index) => BottomNavigationBarItem(
                    icon: Icon(
                      [Ionicons.home, Ionicons.newspaper, Ionicons.person][index],
                    ),
                    label: _labels[index],
                  ),
                ),
              ),
            ),
    );
  }
}
