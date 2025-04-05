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
import 'package:pmt_trust/util/permission_handler.dart';
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
  String? selectedBloodGroup;
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
          selectedBloodGroup = member["blood_group"]?.toString() ?? '';

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
    // Permission.storage.request();
    // Request storage permission
    bool checkstatus =
        await requestStoragePermissions(); // Request location permissions before picking image

    if (checkstatus == false) {
      return;
    }
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
            width: 50,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft, // Align label to right
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 18, color: Color.fromRGBO(48, 52, 52, 1)),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildcard() {
    return Container(
      width: double.infinity, // Adjust width as needed
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  color: const Color.fromRGBO(
                      246, 248, 10, 1), // Top Yellow Section
                ),
                padding: EdgeInsets.all(20),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.yellow, Colors.red],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.5, 0.5], // 50% for each color
                    ).createShader(bounds),
                    child: Stack(
                      children: [
                        // Text Border (Outlined Effect)
                        Text(
                          "PMT மக்கள் பாதுகாப்பு இயக்கம்",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2.5 // Adjust thickness
                              ..color = Colors.black, // Border color
                          ),
                        ),

                        // Main Text (Foreground)
                        Text(
                          "PMT மக்கள் பாதுகாப்பு இயக்கம்",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Colors.white, // Text color
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: const Color.fromRGBO(246, 0, 0, 1), // Red section
                padding: EdgeInsets.all(12),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Member",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "  PMT மக்கள் பாதுகாப்பு இயக்கம்",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Profile picture
              Container(
                padding: EdgeInsets.all(4), // Border padding
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(255, 248, 10, 1),
                      Color.fromRGBO(246, 0, 0, 1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.5, 0.5], // 50% for each color
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _fileLocation != null
                          ? NetworkImage(_fileLocation!)
                          : AssetImage("assets/profile_placeholder.jpg")
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  width: 100, // Adjust size as needed
                  height: 100, // Adjust size as needed
                ),
              ),
              SizedBox(height: 8),
              Text(
                "${_nameController.text}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.all(8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildDetailRow("Name", _nameController.text),
                      buildDetailRow("Father Name", _fatherNameController.text),
                      buildDetailRow("District", selectedDistrict ?? ""),
                      buildDetailRow(
                          "Constituency", selectedConstituency ?? ""),
                      buildDetailRow("Aadhar ID", _aadharController.text),
                      // buildDetailRow("Voter ID", _voterIdController.text),
                      buildDetailRow(
                          "Designation", _designationController.text),
                      buildDetailRow("Blood Group", selectedBloodGroup ?? ""),
                      buildDetailRow("Mobile", _mobilecontroller.text)
                    ],
                  ),
                ),
              ),
              SizedBox(height: 26),
              // Signature
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Image.asset(
                        "assets/sign.png",
                        width: 120, // Adjust width
                        height: 60, // Adjust height
                        fit: BoxFit.contain,
                      ),

                      // Text(
                      //   "A. Sriram...",
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //     fontStyle: FontStyle.italic,
                      //     fontWeight: FontWeight.w500,
                      //     color: Colors.green,
                      //   ),
                      // ),
                      SizedBox(height: 1),
                      Text(
                        "நிறுவனர்.தலைவர்",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Colors.yellow, Colors.red],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.5, 0.5], // 50% for each color
                        ).createShader(bounds),
                        child: Stack(
                          children: [
                            // Text Border (Outlined Effect)
                            Text(
                              "K.N. இசக்கிராஜாதேவர்",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 2.5 // Adjust thickness
                                  ..color = Colors.black, // Border color
                              ),
                            ),

                            // Main Text (Foreground)
                            Text(
                              "K.N. இசக்கிராஜாதேவர்",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: Colors.white, // Text color
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 42),
            ],
          ),
          // Bottom Curve Design
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  colors: [Color(0xFFF60000), Color(0xFFFFF80A)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          )
        ],
      ),
    );
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
    return _isLoading == true
        ? CircularProgressIndicator()
        : Scaffold(
            extendBodyBehindAppBar: true, // Ensure content behind the app bar

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
                  child: ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
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
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(20.0),
                                    ),
                                  ),
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
                                      backgroundColor:
                                          Color.fromRGBO(239, 7, 3, 1),
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
                                child: widget.ismember != 0 ||
                                        widget.isactive != 0
                                    ? Icon(
                                        widget.ismember == 1 &&
                                                widget.isactive == 0
                                            ? Ionicons.time_outline
                                            : null,
                                        color: widget.ismember == 1 &&
                                                widget.isactive == 0
                                            ? Color.fromRGBO(230, 174, 64, 1)
                                            : null,
                                        size: 30.0,
                                      )
                                    : Icon(null),
                              ),
                              widget.ismember != 0 || widget.isactive != 0
                                  ? Text(
                                      widget.isactive == 0
                                          ? AppLocalizations.of(context)!
                                              .yourregistrationiscurrentlyunderverification
                                          : "",
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        await _screenshotController
                                            .captureFromWidget(buildcard())
                                            .then((bytes) {
                                          saveImage(bytes);
                                        }).catchError((onerror) {});
                                      },
                                      icon: Icon(Icons.download,
                                          color: Colors.blue),
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
                                            await Share.shareXFiles(
                                                [XFile(imagePath)],
                                                text: 'Check out this card!');
                                          },
                                        ).catchError((error) {
                                          print("Error sharing image: $error");
                                          Fluttertoast.showToast(
                                              msg: "Failed to share image");
                                        });
                                      },
                                      icon: Icon(Icons.share,
                                          color: Colors.green),
                                      tooltip: "Share",
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        widget.setformindex();
                                      },
                                      icon: Icon(Icons.edit,
                                          color: Colors.orange),
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
