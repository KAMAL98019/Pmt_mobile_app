import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pmt_trust/Language/languageservices.dart';
import 'package:pmt_trust/apiservices/apiservice.dart';
import 'package:toastification/toastification.dart';

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

  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  bool _isLoading = true;
  bool _isLanguageChanging = false;
  XFile? _selectedImage;

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
    _fetchProfileDetails();
    _translateLabels();
  }

  Future<void> _translateLabels() async {
    setState(() {
      _isLanguageChanging = true;
    });

    List<String> labels = [
      "Name",
      "Email",
      "Gender",
      "Enter your name",
      "Enter your email",
      "Select Gender",
      "Update Profile",
    ];

    var translations = await languageService.translateText(labels, widget.lang);
    if (mounted) {
      setState(() {
        translatedLabels = translations;
        _isLanguageChanging = false;
      });
    }
  }

  Future<void> _fetchProfileDetails() async {
    try {
      var profileResponse =
          await apiservices.GetProfile("/getProfile", widget.userId);
      if (profileResponse != null && profileResponse['data'] != null) {
        var profileData = profileResponse['data'][0];
        if (mounted) {
          setState(() {
            _nameController.text = profileData['name'] ?? '';
            _emailController.text = profileData['email'] ?? '';
            _selectedGender = profileData['gender'];
            _fileLocation = profileData['file_location'] != null
                ? '${profileData['file_location']}?t=${DateTime.now().millisecondsSinceEpoch}'
                : null;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        print("No profile data found.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching profile details: $e");
    }
  }

  Future<void> _updateProfile() async {
    try {
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

      if (result != null) {
        print("Profile updated successfully: $result");

        // Refresh profile details after update
        await _fetchProfileDetails();

        toastification.show(
          context: context,
          title: Text('Profile updated successfully'),
          autoCloseDuration: const Duration(seconds: 3),
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
        );
      } else {
        throw Exception("Profile update failed");
      }
    } catch (e) {
      print("Error updating profile: $e");

      toastification.show(
        context: context,
        title: Text('Profile update failed'),
        autoCloseDuration: const Duration(seconds: 3),
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _fileLocation = image.path; // Update with selected image path
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLanguageChanging
            ? const Center()
            : Text(translatedLabels["Update Profile"] ?? "Update Profile"),
        centerTitle: true,
      ),
      body: _isLanguageChanging
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                    translatedLabels["Name"] ?? "Name",
                    translatedLabels["Enter your name"] ?? "Enter your name",
                    _nameController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    translatedLabels["Email"] ?? "Email",
                    translatedLabels["Enter your email"] ?? "Enter your email",
                    _emailController,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    translatedLabels["Gender"] ?? "Gender",
                    translatedLabels["Select Gender"] ?? "Select Gender",
                    _selectedGender,
                    genderOptions,
                    (value) {
                      setState(() {
                        _selectedGender = value;
                      });
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
                      translatedLabels["Update Profile"] ?? "Update Profile",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
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
              borderRadius: BorderRadius.circular(18.0),
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
              borderRadius: BorderRadius.circular(18.0),
            ),
          ),
        ),
      ],
    );
  }
}
