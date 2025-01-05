import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pmt_trust/apiservices/apiservice.dart';
import 'package:pmt_trust/home/form.dart';
import 'package:pmt_trust/home/home.dart';
import 'package:pmt_trust/home/profile.dart';
import 'package:toastification/toastification.dart';
import 'package:translator/translator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Index extends StatefulWidget {
  final int userId;
  final String lang;

  const Index({required this.userId, required this.lang});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  final List<Widget> _pages = [HomePage(), FormPage(), ProfilePage()];

  int _currentIndex = 0;
  final apiService = ApiService();
  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    // print(widget.userId);
    // print(widget.lang);
    updateLanguage(widget.userId, widget.lang);
  }

  // setState(() {
  //   _pages[0] = HomePage(userId: userId, lang: lang);
  //   _pages[1] = FormPage(userId: userId, lang: lang);
  //   _pages[2] = ProfilePage(userId: userId, lang: lang);
  // });

  // initially trigger update language

  void updateLanguage(int userId, String lang) async {
    print("updated language: $lang");
    print("UserId: $userId");
    var res = await apiService.updateLanguage("/updateLanguage", userId, lang);
    if (res != null) {
      // Access specific fields from the response
      String message =
          res["message"]; // e.g., "language updated successfully !"
      bool error =
          res["error"] == "true"; // Convert "true"/"false" string to bool
      String userId = res["userId"]; // e.g., 51

      // Handle the response status
      if (!error) {
        toastification.show(
          context: context,
          title: Text(message),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 5),
        );
      } else {
        toastification.show(
          context: context,
          title: Text(message),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
    } else {
      print("No response from the server.");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // Update the selected page index
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      
      appBar: AppBar(),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26, // Shadow color
              offset: Offset(0, -1), // Position of shadow (above)
              blurRadius: 3, // Blur radius for the shadow
              spreadRadius: 0, // Spread radius for the shadow
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          selectedItemColor: Color.fromRGBO(239, 7, 3, 1),
          selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16), // Smaller font size for selected label
          unselectedLabelStyle:
              TextStyle(fontSize: 12), // Smaller font size for unselected label
          iconSize: 24, // Smaller icon size,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Ionicons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Ionicons.newspaper),
              label: 'Form',
            ),
            BottomNavigationBarItem(
              icon: Icon(Ionicons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

