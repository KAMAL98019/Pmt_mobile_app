import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pmt_trust/home/form.dart';
import 'package:pmt_trust/home/home.dart';
import 'package:pmt_trust/home/profile.dart';



class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  final List<Widget> _pages = [HomePage(), FormPage(), ProfilePage()];

  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // Update the selected page index
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      
      ),
      body: _pages[_currentIndex],

      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26, // Shadow color
              offset: Offset(0, -1), // Position of shadow (above)
              blurRadius: 12, // Blur radius for the shadow
              spreadRadius: 0, // Spread radius for the shadow
            ),
          ],
          
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          selectedItemColor: Color.fromRGBO(239, 7, 3, 1),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), // Smaller font size for selected label
          unselectedLabelStyle: TextStyle(fontSize: 12), // Smaller font size for unselected label
          iconSize: 24, // Smaller icon size,
          items: const <BottomNavigationBarItem> [
            
            BottomNavigationBarItem(
              icon: Icon(Ionicons.home),
              label: 'Home',
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
