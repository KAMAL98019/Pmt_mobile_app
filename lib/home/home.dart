import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pmt_trust/Language/languageservices.dart';
import 'package:pmt_trust/apiservices/apiservice.dart';
import 'package:pmt_trust/home/form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toastification/toastification.dart';

class HomePage extends StatefulWidget {
  final String lang;
  final int userID;
  final int memberId;
  final int isactive;
  final int ismember;
  final VoidCallback refreshCallback;
  final VoidCallback setformindex;

  const HomePage(
      {required this.lang,
      required this.userID,
      required this.memberId,
      required this.isactive,
      required this.ismember,
      required this.refreshCallback,
      required this.setformindex});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> labels = ["Join Now"]; // Default label
  final languageService = LanguageService();
  bool _isLoading = true; // To handle loading state
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();
  final TextEditingController _voterIdController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _mobilecontroller = TextEditingController();
  late Uint8List _imageFile;
  final time = DateTime.now()
      .toIso8601String()
      .replaceAll(".", "-")
      .replaceAll(":", '-');
  //Create an instance of ScreenshotController
  ScreenshotController _screenshotController = ScreenshotController();
  final apiservices = ApiService();
  bool? _isloading = false;
  String? selectedDistrict;
  String? selectedConstituency;
  String? selectedDesignation;

  String? _fileLocation;
  XFile? _selectedImage;
  @override
  void initState() {
    super.initState();

    widget.ismember;
    widget.isactive;
    widget.memberId;
    // _translateLabels(); // Call the method to fetch translations
    // ignore: unnecessary_null_comparison
    if (widget.memberId != 0 && widget.memberId != null) {
      _fetchMemberDetailsWithRetry();
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMemberDetailsWithRetry() async {
    int attempts = 0;
    bool success = false;

    while (attempts < 3 && !success) {
      success = await CheckMemberDetail();
      print("call again");
      if (!success) {
        attempts++;
        await Future.delayed(Duration(milliseconds: 500)); // Reduce API spam
      }
    }
  }

  Future<bool> CheckMemberDetail() async {
    try {
      var memberData =
          await apiservices.getmemberlist("/getMember", widget.memberId);

      if (memberData != null && memberData != 0 && memberData['data'] != null) {
        var member = memberData['data'][0];

        // Assigning values to controllers
        _nameController.text = member['name']?.toString() ?? '';
        _fatherNameController.text = member['father_name']?.toString() ?? '';
        _wardController.text = member['ward_num'] ?? 0;
        _voterIdController.text = member['voter_id']?.toString() ?? '';
        _aadharController.text = member['adhar_num']?.toString() ?? '';
        _addressController.text = member['address']?.toString() ?? '';
        _designationController.text =
            member['designation_en']?.toString() ?? '';
        _occupationController.text = member['occupation']?.toString() ?? '';
        _mobilecontroller.text = member['mobile'] ?? '';
        setState(() {
          selectedDistrict = member['dist_name']?.toString() ?? '';
          selectedConstituency = member["const_name"]?.toString() ?? '';
          selectedDesignation = member['designation_en']?.toString() ?? '';
          _fileLocation = member['file_location'] != null
              ? '${member['file_location']}?t=${DateTime.now().millisecondsSinceEpoch}'
              : null;
          _isloading = false;
        });

        print(member["file_location"]);
        return true; // Success
      } else {
        setState(() {
          _isloading = false;
        });

        return false; // Failed, may retry
      }
    } catch (e) {
      print("Error in CheckMemberDetail: $e");

      // toastification.show(
      //   context: context,
      //   title: Text("Error: $e"),
      //   autoCloseDuration: Duration(seconds: 3),
      //   foregroundColor: Colors.red,
      // );
      return false; // Failed
    }
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

  Future<void> saveImage(Uint8List bytes) async {
    final time = DateTime.now().millisecondsSinceEpoch;
    final name = "cardimage_$time.png";
    Permission.storage.request();
    // Request storage permission
    final res = await ImageGallerySaverPlus.saveImage(bytes, name: name);

    // Check if image saved successfully
    if (res['isSuccess'] == true) {
      Fluttertoast.showToast(
        msg: "Card Image saved in gallery",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Failed to save image",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  /// Helper Function for Row Alignment
  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Keep everything centered
        children: [
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft, // Align label to right
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ),
          ),
          SizedBox(width: 20), // Space between label and value
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft, // Align value to left
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildcard() {
    return (Card(
      borderOnForeground: false,
      semanticContainer: false,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(width: 6.5, color: Color.fromRGBO(242, 242, 247, 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center align column items
          children: [
            // Profile Container
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(242, 242, 247, 1),
                borderRadius: BorderRadius.all(Radius.circular(19)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.grey.shade300, width: 2),
                        image: DecorationImage(
                          image: _fileLocation != null
                              ? NetworkImage(_fileLocation!)
                              : AssetImage("assets/profile_placeholder.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),

                    // Name & Status
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameController.text,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _designationController.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 4),
                          // Status Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 3),
                            decoration: BoxDecoration(
                              color:
                                  widget.ismember == 1 && widget.isactive == 0
                                      ? Color.fromRGBO(230, 174, 64, 1)
                                      : Color.fromRGBO(103, 230, 64, 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.ismember == 1 && widget.isactive == 0
                                  ? "Pending"
                                  : "Accepted",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            buildDetailRow("Name", _nameController.text),
            buildDetailRow("Father Name", _fatherNameController.text),
            buildDetailRow("District", selectedDistrict ?? ""),
            buildDetailRow("constituency", selectedConstituency ?? ""),
            buildDetailRow("Aaadhar ID", _aadharController.text),
            buildDetailRow("voter ID", _voterIdController.text),
            buildDetailRow("Designation", _designationController.text),
            buildDetailRow("mobile", _mobilecontroller.text)
          ],
        ),
      ),
    ));
  }

  // @override
  // void dispose() {
  //   _nameController.dispose();
  //   _fatherNameController.dispose();
  //   _wardController.dispose();
  //   _voterIdController.dispose();
  //   _aadharController.dispose();
  //   _addressController.dispose();
  //   _designationController.dispose();
  //   _occupationController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: Localizations.override(
        context: context,
        locale: Locale(widget.lang),
        child: Builder(builder: (context) {
          return RefreshIndicator(
            onRefresh: () async {
              await _fetchMemberDetailsWithRetry();
              widget.refreshCallback();
            },
            child:
                ListView(physics: AlwaysScrollableScrollPhysics(), children: [
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Responsive Banner Image with BoxFit.contain
                    Center(
                      child: Container(
                        width: double
                            .infinity, // Make it responsive across screen sizes
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40)),
                        height: MediaQuery.of(context).size.height *
                            0.3, // Adjust the height to be responsive
                        child: Image.asset(
                          'assets/topbarimage.png',
                          fit: BoxFit
                              .contain, // Ensure the image fits without cropping
                        ),
                      ),
                    ),
                    // SizedBox(height: 5),
                    if (widget.ismember == 0)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to JoinFormPage
                            widget.setformindex();
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

                    Center(
                      child: widget.ismember != 0 || widget.isactive != 0
                          ? Icon(
                              widget.ismember == 1 && widget.isactive == 0
                                  ? Ionicons.time_outline
                                  : Ionicons.checkmark_circle_outline,
                              color:
                                  widget.ismember == 1 && widget.isactive == 0
                                      ? Color.fromRGBO(230, 174, 64, 1)
                                      : Color.fromRGBO(103, 230, 64, 1),
                              size: 30.0,
                            )
                          : Icon(null),
                    ),
                    widget.ismember != 0 || widget.isactive != 0
                        ? Text(
                            widget.isactive == 0
                                ? AppLocalizations.of(context)!
                                    .yourregistrationiscurrentlyunderverification
                                : AppLocalizations.of(context)!
                                    .verifiedsuccessfully,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : Text(""),
                    SizedBox(height: 30),

                    // Landscape ID Card UI with Square Avatar
                    if (widget.ismember == 1 && widget.isactive == 1)
                      buildcard(),
                    SizedBox(height: 5),
                    if (widget.ismember == 1 && widget.isactive == 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () async {
                              await _screenshotController
                                  .captureFromWidget(buildcard())
                                  .then((bytes) {
                                saveImage(bytes);
                              }).catchError((onerror) {});
                            },
                            icon: Icon(Icons.download, color: Colors.blue),
                            tooltip: "Download",
                          ),
                          IconButton(
                            onPressed: () async {
                              await _screenshotController
                                  .captureFromWidget(buildcard())
                                  .then(
                                (bytes) async {
                                  final directory =
                                      await getTemporaryDirectory();
                                  final imagePath =
                                      '${directory.path}/shared_card.png';
                                  final imageFile = File(imagePath);
                                  await imageFile.writeAsBytes(bytes);

                                  // Share the image
                                  await Share.shareXFiles([XFile(imagePath)],
                                      text: 'Check out this card!');
                                },
                              ).catchError((error) {
                                print("Error sharing image: $error");
                                Fluttertoast.showToast(
                                    msg: "Failed to share image");
                              });
                            },
                            icon: Icon(Icons.share, color: Colors.green),
                            tooltip: "Share",
                          ),
                          IconButton(
                            onPressed: () {
                              widget.setformindex();
                            },
                            icon: Icon(Icons.edit, color: Colors.orange),
                            tooltip: "Edit",
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ]),
          );
        }),
      ),
    );
  }
}
