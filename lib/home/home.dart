import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Responsive Banner Image with BoxFit.contain
            Center(
              child: Container(
                width:
                    double.infinity, // Make it responsive across screen sizes
                height: MediaQuery.of(context).size.height *
                    0.3, // Adjust the height to be responsive
                child: Image.asset(
                  'assets/topbarimage.png',
                  fit: BoxFit.contain, // Ensure the image fits without cropping
                ),
              ),
            ),
            SizedBox(height: 5),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(239, 7, 3, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: Size(0, 50.0)),
                child: const Text(
                  'Join Now',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
