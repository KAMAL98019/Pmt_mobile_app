import 'package:flutter/material.dart';
import 'package:pmt_trust/Language/languageservices.dart';
import 'package:pmt_trust/home/form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  final String lang;
  final int userID;
  final int memberId;

  const HomePage(
      {required this.lang, required this.userID, required this.memberId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> labels = ["Join Now"]; // Default label
  final languageService = LanguageService();
  bool _isLoading = true; // To handle loading state

  @override
  void initState() {
    super.initState();
    // _translateLabels(); // Call the method to fetch translations
  }

  // Future<void> _translateLabels() async {
  //   try {
  //     Map<String, String> translatedTexts =
  //         await languageService.translateText(labels, widget.lang);

  //     // Check if the widget is still mounted before calling setState
  //     if (mounted) {
  //       setState(() {
  //         // Update labels with translated values
  //         labels =
  //             labels.map((label) => translatedTexts[label] ?? label).toList();
  //         _isLoading = false; // Stop loading state
  //       });
  //     }
  //   } catch (error) {
  //     print("Error translating labels: $error");

  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false; // Stop loading even if there's an error
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Localizations.override(
        context: context,
        locale: Locale(widget.lang),
        child: Builder(builder: (context) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Responsive Banner Image with BoxFit.contain
                  Center(
                    child: Container(
                      width: double
                          .infinity, // Make it responsive across screen sizes
                      height: MediaQuery.of(context).size.height *
                          0.3, // Adjust the height to be responsive
                      child: Image.asset(
                        'assets/topbarimage.png',
                        fit: BoxFit
                            .contain, // Ensure the image fits without cropping
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to JoinFormPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FormPage(
                                    lang: widget.lang,
                                    userID: widget.userID,
                                    memberId: widget.memberId,
                                  )),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(239, 7, 3, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        minimumSize: Size(0, 50.0),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!
                            .joinnow, // Display the translated label
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
