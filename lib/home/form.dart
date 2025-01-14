import 'package:flutter/material.dart';
import 'package:pmt_trust/Language/languageservices.dart';
import 'package:pmt_trust/apiservices/apiservice.dart';
import 'package:toastification/toastification.dart';

class FormPage extends StatefulWidget {
  final String lang;
  final int userID;
  final int memberId;

  const FormPage({
    required this.lang,
    required this.userID,
    required this.memberId,
  });

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final apiservices = ApiService();
  final languageService = LanguageService();

  final List<String> appbarTitles = ["Membership Joining Form"];
  final List<String> fieldLabels = [
    "Name",
    "Father's Name",
    "Panchayat",
    "Ward Number",
    "Voter ID Number",
    "Aadhar Number",
    "Address",
    "Designation",
    "Occupation",
    "Submit",
    "Update"
  ];
  final List<String> fieldHints = [
    "Enter your full name",
    "Enter your father's name",
    "Enter your panchayat",
    "Enter your ward number",
    "Enter your voter ID number",
    "Enter your Aadhar number",
    "Enter your address",
    "Enter your designation",
    "Enter your occupation"
  ];

  late TextEditingController _nameController;
  late TextEditingController _fatherNameController;
  late TextEditingController _voterIdController;
  late TextEditingController _aadharController;
  late TextEditingController _addressController;
  late TextEditingController _designationController;
  late TextEditingController _occupationController;

  String selectedPanchayat = '';
  String selectedWard = '';

  final List<String> panchayatList = ['namakkal', 'salem', 'thiruvarur'];
  final List<String> wardList = ['56', '36', '45'];

  late Map<String, String> translations = {};

  @override
  void initState() {
    super.initState();
    print("Member ID: ${widget.memberId}");
    _nameController = TextEditingController();
    _fatherNameController = TextEditingController();
    _voterIdController = TextEditingController();
    _aadharController = TextEditingController();
    _addressController = TextEditingController();
    _designationController = TextEditingController();
    _occupationController = TextEditingController();
    selectedPanchayat = panchayatList[0];
    selectedWard = wardList[0];
    // Initialize text controllers
    if (widget.memberId != 0) {
      CheckMemberDetail();
    }

    // Fetch translations
    fetchTranslations();
  }

  void CheckMemberDetail() async {
    var memberData =
        await apiservices.getmemberlist("/getMember", widget.memberId);
    print(memberData); // Debug log to check the fetched data

    if (memberData != 0) {
      var member = memberData['data'][0];
      print(member['panjayathu']);
      if (panchayatList.contains(member['panjayathu'])) {
        selectedPanchayat = member['panjayathu'];
      }
      if (wardList.contains(member['ward_num'])) {
        selectedWard = member['ward_num'];
      }
      _nameController.text = member['name'] ?? '';
      _fatherNameController.text = member['father_name'] ?? '';
      _voterIdController.text = member['voter_id'] ?? '';
      _aadharController.text = member['adhar_num'] ?? '';
      _addressController.text = member['address'] ?? '';
      _designationController.text = member['designation'] ?? '';
      _occupationController.text = member['occupation'] ?? '';
    }
  }

  Future<void> fetchTranslations() async {
    // Combine all text fields into a single list
    List<String> textsToTranslate = [
      ...appbarTitles,
      ...fieldLabels,
      ...fieldHints,
    ];

    // Get translations for all the texts at once
    translations =
        await languageService.translateText(textsToTranslate, widget.lang);
    if (mounted) {
      setState(() {}); // Update the UI after fetching translations
    }
  }

  @override
  void dispose() {
    // Dispose text controllers
    // _nameController.dispose();
    // _fatherNameController.dispose();
    // _voterIdController.dispose();
    // _aadharController.dispose();
    // _addressController.dispose();
    // _designationController.dispose();
    // _occupationController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildFormData() {
    return {
      "user_id": widget.userID,
      "name": _nameController.text,
      "father_name": _fatherNameController.text,
      "panjayathu": selectedPanchayat,
      "ward_num": selectedWard,
      "voter_id": _voterIdController.text,
      "adhar_num": _aadharController.text,
      "address": _addressController.text,
      "designation": _designationController.text,
      "occupation": _occupationController.text,
    };
  }

  void _handleSubmit() async {
    var formData = _buildFormData();
    var response = await apiservices.savemember("/createMember", formData);
    print("Submit Response: $response");
    toastification.show(
      context: context,
      title: Text(response['message']),
      autoCloseDuration: const Duration(seconds: 3),
      foregroundColor: Colors.black,
    );
  }

  void _handleUpdate() async {
    var formData = _buildFormData();
    var response = await apiservices.updatemember(
        "/updateMember", widget.memberId, formData);

    if (response['error'] != null && response['error'] == 'true') {
      // Handle the error, show error message
      print("Error: ${response['message']}");
      toastification.show(
        context: context,
        title: Text(response['message'] ?? "Unknown error"),
        autoCloseDuration: const Duration(seconds: 3),
        foregroundColor: Colors.black,
      );
    } else {
      // Successful response
      print("Update Response: $response");
      toastification.show(
        context: context,
        title: Text(response['message'] ?? "Member updated successfully!"),
        autoCloseDuration: const Duration(seconds: 3),
        foregroundColor: Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (translations.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            translations[appbarTitles[0]] ?? appbarTitles[0],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              Text(
                translations[fieldLabels[0]] ?? fieldLabels[0],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: translations[fieldHints[0]] ?? fieldHints[0],
                  hintStyle: TextStyle(
                    fontSize: 14, // Adjust the font size as needed
                    fontWeight:
                        FontWeight.w400, // Adjust the font weight as needed
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                    borderSide: const BorderSide(
                      color: Colors.grey, // Default border color
                      width: 1.0, // Default border width
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.grey, // Color when not focused
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.blue, // Color when focused
                      width: 2.0,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8, // Vertical padding inside the field
                    horizontal: 12, // Horizontal padding inside the field
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Father's Name Field
              Text(
                translations[fieldLabels[1]] ?? fieldLabels[1],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _fatherNameController,
                decoration: InputDecoration(
                  hintText: translations[fieldHints[1]] ?? fieldHints[1],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                    borderSide: const BorderSide(
                      color: Colors.grey, // Default border color
                      width: 1.0, // Default border width
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.grey, // Color when not focused
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.blue, // Color when focused
                      width: 2.0,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8, // Vertical padding inside the field
                    horizontal: 12, // Horizontal padding inside the field
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Panchayat Dropdown
              Text(
                translations[fieldLabels[2]] ?? fieldLabels[2],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity, // Full width of the parent
                padding: const EdgeInsets.symmetric(
                    horizontal: 12), // Optional padding
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey, // Border color
                    width: 1.0, // Border width
                  ),
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: DropdownButton<String>(
                  value: selectedPanchayat,
                  isExpanded: true, // Makes the dropdown expand to full width
                  underline: const SizedBox(), // Removes the default underline
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPanchayat = newValue!;
                    });
                  },
                  items: panchayatList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Ward Number Dropdown
              Text(
                translations[fieldLabels[3]] ?? fieldLabels[3],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity, // Full width of the parent
                padding: const EdgeInsets.symmetric(
                    horizontal: 12), // Optional padding
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey, // Border color
                    width: 1.0, // Border width
                  ),
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: DropdownButton<String>(
                  value: selectedWard,
                  isExpanded: true, // Makes the dropdown expand to full width
                  underline: const SizedBox(), // Removes the default underline
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedWard = newValue!;
                    });
                  },
                  items: wardList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Voter ID Field
              Text(
                translations[fieldLabels[4]] ?? fieldLabels[4],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _voterIdController,
                decoration: InputDecoration(
                    hintText: translations[fieldHints[4]] ?? fieldHints[4],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      borderSide: const BorderSide(
                        color: Colors.grey, // Default border color
                        width: 1.0, // Default border width
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey, // Color when not focused
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.blue, // Color when focused
                        width: 2.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8, // Vertical padding inside the field
                      horizontal: 12, // Horizontal padding inside the field
                    )),
              ),
              const SizedBox(height: 16),

              // Aadhar Number Field
              Text(
                translations[fieldLabels[5]] ?? fieldLabels[5],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _aadharController,
                decoration: InputDecoration(
                    hintText: translations[fieldHints[5]] ?? fieldHints[5],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      borderSide: const BorderSide(
                        color: Colors.grey, // Default border color
                        width: 1.0, // Default border width
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey, // Color when not focused
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.blue, // Color when focused
                        width: 2.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8, // Vertical padding inside the field
                      horizontal: 12, // Horizontal padding inside the field
                    )),
              ),
              const SizedBox(height: 16),

              // Address Field
              Text(
                translations[fieldLabels[6]] ?? fieldLabels[6],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                    hintText: translations[fieldHints[6]] ?? fieldHints[6],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      borderSide: const BorderSide(
                        color: Colors.grey, // Default border color
                        width: 1.0, // Default border width
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey, // Color when not focused
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.blue, // Color when focused
                        width: 2.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8, // Vertical padding inside the field
                      horizontal: 12, // Horizontal padding inside the field
                    )),
              ),
              const SizedBox(height: 16),

              // Designation Field
              Text(
                translations[fieldLabels[7]] ?? fieldLabels[7],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _designationController,
                decoration: InputDecoration(
                    hintText: translations[fieldHints[7]] ?? fieldHints[7],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      borderSide: const BorderSide(
                        color: Colors.grey, // Default border color
                        width: 1.0, // Default border width
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey, // Color when not focused
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.blue, // Color when focused
                        width: 2.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8, // Vertical padding inside the field
                      horizontal: 12, // Horizontal padding inside the field
                    )),
              ),
              const SizedBox(height: 16),

              // Occupation Field
              Text(
                translations[fieldLabels[8]] ?? fieldLabels[8],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _occupationController,
                decoration: InputDecoration(
                    hintText: translations[fieldHints[8]] ?? fieldHints[8],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      borderSide: const BorderSide(
                        color: Colors.grey, // Default border color
                        width: 1.0, // Default border width
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey, // Color when not focused
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.blue, // Color when focused
                        width: 2.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8, // Vertical padding inside the field
                      horizontal: 12, // Horizontal padding inside the field
                    )),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.memberId == 0) {
                      _handleSubmit();
                    } else {
                      // Call the Update method when memberId is not 0
                      _handleUpdate();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(239, 7, 3, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: Size(0, 50.0),
                  ),
                  child: Text(
                    widget.memberId == 0
                        ? translations[fieldLabels[9]] ??
                            fieldLabels[9] // "Submit"
                        : translations[fieldLabels[10]] ??
                            fieldLabels[10], // "Update"
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
