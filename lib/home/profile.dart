import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pmt_trust/Language/languageservices.dart';
import 'package:pmt_trust/apiservices/apiservice.dart';
import 'package:pmt_trust/login.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  final String lang;

  const ProfilePage({required this.userId, required this.lang});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final apiservices = ApiService();
  final languageService = LanguageService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String? _selectedGender;
  String? _fileLocation;

  final List<String> genderOptions = ['Male', 'Female', 'TransGender'];

  bool _isLoading = true;
  bool _isLanguageChanging = false;
  XFile? _selectedImage;

  final storage = FlutterSecureStorage();

  Map<String, String> translatedLabels = {
    "Name": "Name",
    "Email": "Email",
    "Gender": "Gender",
    "Enter your name": "Enter your name",
    "Enter your email": "Enter your email",
    "Select Gender": "Select Gender",
    "Update Profile": "Update Profile",
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    if (widget.userId != 0) {
      _fetchProfileDetails();
    } else {
      setState(() {
        _isLoading = false;
      });
    }

    // _translateLabels();
  }

  // Future<void> _translateLabels() async {
  //   setState(() {
  //     _isLanguageChanging = true;
  //   });

  //   List<String> labels = [
  //     "Name",
  //     "Email",
  //     "Gender",
  //     "Enter your name",
  //     "Enter your email",
  //     "Select Gender",
  //     "Update Profile",
  //   ];

  //   var translations = await languageService.translateText(labels, widget.lang);
  //   if (mounted) {
  //     setState(() {
  //       translatedLabels = translations;
  //       _isLanguageChanging = false;
  //     });
  //   }
  // }

  Future<void> _fetchProfileDetails() async {
    int attempts = 0;
    const int maxAttempts = 3;
    const Duration retryDelay = Duration(seconds: 500);

    _nameController = TextEditingController();
    _emailController = TextEditingController();

    while (attempts < maxAttempts) {
      try {
        var profileResponse =
            await apiservices.GetProfile("/getProfile", widget.userId);
        print("Profile Response: $profileResponse");
        if (profileResponse != null && profileResponse['data'] != null) {
          var profileData = profileResponse['data'][0];

          _nameController.text = profileData['name'] ?? '';
          _emailController.text = profileData['email'] ?? '';

          setState(() {
            _selectedGender = profileData['gender'];
            _fileLocation = profileData['file_location'] != null
                ? '${profileData['file_location']}?t=${DateTime.now().millisecondsSinceEpoch}'
                : null;
            _isLoading = false;
          });

          return; // Exit function if successful
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        print("Attempt ${attempts + 1}: Error fetching profile details: $e");
      }

      attempts++;
      if (attempts < maxAttempts) {
        await Future.delayed(retryDelay);
      }
    }

    // If all attempts fail
    setState(() {
      _isLoading = false;
    });

    // toastification.show(
    //   context: context,
    //   title: Text("Failed to load profile details. Please try again."),
    //   autoCloseDuration: Duration(seconds: 3),
    //   foregroundColor: Colors.red,
    // );
  }

  Future<void> _updateProfile() async {
    try {
      // setState(() {
      //   _isLoading = true;
      // });
      String? updatedFileLocation = _fileLocation;

      // Prepare updated profile data
      Map<String, dynamic> updatedData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'gender': _selectedGender,
        'fileBuffer': updatedFileLocation,
      };

      final result = await apiservices.updateProfile(
        "/updateProfile",
        widget.userId,
        updatedData,
      );

      print(result);
      if (result["error"] == true) {
        Fluttertoast.showToast(
            msg: result["message"],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }else{
        Fluttertoast.showToast(msg: result["message"],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }

      // if (result != null) {
      //   print("Profile updated successfully: $result");
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   // Refresh profile details after update
      //   await _fetchProfileDetails();

      //   if (mounted) {
      //     // toastification.show(
      //     //   context: context,
      //     //   title: Text('Profile updated successfully'),
      //     //   autoCloseDuration: const Duration(seconds: 3),
      //     //   type: ToastificationType.success,
      //     //   style: ToastificationStyle.flatColored,
      //     // );
      //     Fluttertoast.showToast(
      //         msg: "Profile updated successfully",
      //         toastLength: Toast.LENGTH_SHORT,
      //         gravity: ToastGravity.BOTTOM,
      //         timeInSecForIosWeb: 1,
      //         backgroundColor: Colors.green,
      //         textColor: Colors.white,
      //         fontSize: 16.0);
      //   }
      // } else {
      //   throw Exception("Profile update failed");
      // }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        // toastification.show(
        //   context: context,
        //   title: Text('Profile update failed'),
        //   autoCloseDuration: const Duration(seconds: 3),
        //   type: ToastificationType.error,
        //   style: ToastificationStyle.flatColored,
        // );
        // Fluttertoast.showToast(
        //     msg: e.toString(),
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Colors.red,
        //     textColor: Colors.white,
        //     fontSize: 16.0);
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (mounted) {
        setState(() {
          _selectedImage = image;
          _fileLocation = image.path; // Update with selected image path
        });
      }
    }
  }

  // Function to log out the user
  void _logout() async {
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout Confirmation"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No, cancel logout
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Yes, confirm logout
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      await storage.delete(key: 'userId');
      await storage.delete(key: 'lang');
      await storage.delete(key: 'langcheck');

      Fluttertoast.showToast(
        msg: "You have successfully logged out",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    // Dispose of controllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: Locale(widget.lang),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(AppLocalizations.of(context)!.updateProfile,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                )),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: _logout,
              ),
            ],
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchProfileDetails,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: _fileLocation != null
                                    ? (_fileLocation!.startsWith('http')
                                        ? NetworkImage(_fileLocation!)
                                        : FileImage(File(_fileLocation!)))
                                    : null,
                                child: _fileLocation == null
                                    ? const Icon(Icons.camera_alt,
                                        size: 40, color: Colors.white)
                                    : null,
                              ),
                              GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(4.0),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          AppLocalizations.of(context)!.name,
                          AppLocalizations.of(context)!.enterYourName ??
                              "Enter your name",
                          _nameController,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          AppLocalizations.of(context)!.email,
                          AppLocalizations.of(context)!.enterYourEmail ??
                              "Enter your email",
                          _emailController,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          AppLocalizations.of(context)!.gender ?? "Gender",
                          AppLocalizations.of(context)!.selectGender ??
                              "Select Gender",
                          _selectedGender,
                          genderOptions,
                          (value) {
                            if (mounted) {
                              setState(() {
                                _selectedGender = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                            backgroundColor: const Color.fromRGBO(239, 7, 3, 1),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.updateProfile ??
                                "Update Profile",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      }),
    );
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), // Rounded corners
              borderSide: const BorderSide(
                color: Colors.grey, // Default border color
                width: 1.0, // Default border width
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String hint, String? selectedValue,
      List<String> options, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          hint: Text(hint),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), // Rounded corners
              borderSide: const BorderSide(
                color: Colors.grey, // Default border color
                width: 1.0, // Default border width
              ),
            ),
          ),
        ),
      ],
    );
  }
}
