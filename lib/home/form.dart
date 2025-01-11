import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // for image picker
import 'package:pmt_trust/Language/languageservices.dart';

class FormPage extends StatefulWidget {
  final String lang;
  const FormPage({required this.lang});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  List<String> appbartitle = ["Membership Joining form"];
  final languageService = LanguageService();
  bool _isLoading = true; // To track loading state
  late TextEditingController _nameController;
  late TextEditingController _fatherNameController;
  late TextEditingController _voterIdController;
  late TextEditingController _aadharController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  String? _selectedPanchayat;
  String? _selectedWard;
  XFile? _image; // for profile image

  final List<String> panchayatList = ['Panchayat 1', 'Panchayat 2', 'Panchayat 3']; // Example Panchayat list
  final List<String> wardList = ['Ward 1', 'Ward 2', 'Ward 3']; // Example Ward list

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _fatherNameController = TextEditingController();
    _voterIdController = TextEditingController();
    _aadharController = TextEditingController();
    _contactController = TextEditingController();
    _addressController = TextEditingController();
    _changeLanguageLabel(widget.lang); // Directly call the async method
  }

  _changeLanguageLabel(String lang) async {
    try {
      Map<String, String> translatedTexts = await languageService.translateText(appbartitle, lang);
      setState(() {
        appbartitle[0] = translatedTexts[appbartitle[0]] ?? appbartitle[0];
        _isLoading = false;
      });
    } catch (error) {
      print("Error translating labels: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _isLoading
            ? CircularProgressIndicator()
            : Text(
                appbartitle[0],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _image == null ? null : FileImage(File(_image!.path)),
                  child: _image == null
                      ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                      : null,
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildTextField("Name", _nameController),
            _buildTextField("Father's Name", _fatherNameController),
            _buildDropdown("Panchayat", _selectedPanchayat, panchayatList),
            _buildDropdown("Ward", _selectedWard, wardList),
            _buildTextField("Voter ID Number", _voterIdController),
            _buildTextField("Aadhar Number", _aadharController),
            _buildTextField("Contact Number", _contactController),
            _buildTextField("Address", _addressController, maxLines: 3),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle form submission
              },
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildDropdown(String label, String? selectedValue, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedValue = newValue;
          });
        },
      ),
    );
  }
}
