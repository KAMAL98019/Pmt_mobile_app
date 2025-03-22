import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pmt_trust/Language/languageservices.dart';
import 'package:pmt_trust/apiservices/apiservice.dart';
import 'package:pmt_trust/util/permission_handler.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FormPage extends StatefulWidget {
  final String lang;
  final int userID;
  final int memberId;
  final VoidCallback sethomeindex;

  const FormPage(
      {required this.lang,
      required this.userID,
      required this.memberId,
      required this.sethomeindex});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();
  final TextEditingController _voterIdController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final apiservices = ApiService();
  bool? _isloading = true;
  String? selectedDistrict;
  String? selectedConstituency;
  String? selectedDesignation;
  List<String> districtList = [];
  List<String> constituencyList = [];
  List<String> designationlist = [];
  Map<String, List<String>> districtConstituencies = {};
  String? _fileLocation;
  XFile? _selectedImage;
  List<Map<String, dynamic>> _designationData = [];
  List<Map<String, dynamic>> _districtData = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    if (widget.memberId == 0) {
      setState(() {
        _isloading = false;
      });
    }
  }

  void _loadInitialData() async {
    // Fetch data and store it in variables
    await Future.wait([
      _fetchDesignationList(),
      _fetchDistricts(),
      // ignore: unnecessary_null_comparison
      if (widget.memberId != 0 && widget.memberId != null)
        _fetchMemberDetailsWithRetry(),
    ]);
  }

  Future<void> _fetchDesignationList() async {
    int maxRetries = 3;
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        var data = await apiservices.getDesignationList("/designationList");

        if (data != null && data['data'] is List) {
          setState(() {
            _designationData = List<Map<String, dynamic>>.from(data['data']);
            designationlist = widget.lang == 'en'
                ? _designationData
                    .map<String>((d) => d['designation_en'].toString())
                    .toList()
                : _designationData
                    .map<String>((d) => d['designation_ta'].toString())
                    .toList();
          });
          return;
        }
      } catch (e) {
        print("Error fetching designation list: $e");
      }
      attempt++;
      if (attempt < maxRetries) {
        await Future.delayed(Duration(milliseconds: 500));
      }
    }
    print("Failed to fetch designation list after $maxRetries attempts");
  }

  Future<void> _fetchDistricts() async {
    int maxRetries = 3;
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        var data = await apiservices.getdistricts("/prepopsMemberCreation");

        if (data != null && data['data'] is List) {
          setState(() {
            _districtData = List<Map<String, dynamic>>.from(data['data']);
            districtList = _districtData
                .map<String>((d) => d['dist_name'].toString())
                .toList();
          });
          return;
        }
      } catch (e) {
        print("Error fetching district list: $e");
      }
      attempt++;
      if (attempt < maxRetries) {
        await Future.delayed(Duration(milliseconds: 500));
      }
    }
    print("Failed to fetch district list after $maxRetries attempts");
  }

  void updateConstituencies(String districtName) {
    if (!mounted) return; // Prevent setState if widget is disposed

    // Ensure the district exists in the stored data
    var selectedDistrict = _districtData.firstWhere(
      (d) => d['dist_name'] == districtName,
      orElse: () => <String, dynamic>{},
    );

    if (selectedDistrict != null) {
      List<String> constituencies = (selectedDistrict["consti"] as List)
          .map<String>((c) => c["const_name"].toString())
          .toList();

      setState(() {
        selectedConstituency = null;
        constituencyList = constituencies;
        districtConstituencies[districtName] = constituencies;
      });
    } else {
      setState(() {
        selectedConstituency = null;
        constituencyList = [];
      });
    }
  }

  Future<void> _fetchMemberDetailsWithRetry() async {
    int attempts = 0;

    while (attempts < 3) {
      bool success = await CheckMemberDetail();
      if (success) break; // Exit loop early if successful

      print("Retry attempt: ${attempts + 1}");
      attempts++;
      await Future.delayed(Duration(milliseconds: 200)); // Prevent API spamming
    }
  }

  Future<Map<String, dynamic>> _buildFormData() async {
    String? updatedFileLocation = _fileLocation;
    print(updatedFileLocation);

    // Use stored data instead of calling APIs again
    var selectedDistrictData = _districtData.firstWhere(
      (i) => i['dist_name'] == selectedDistrict,
      orElse: () => <String, dynamic>{},
    );
    var selectedDistrictId = selectedDistrictData?["dist_id"];

    var selectedConstituencyData = selectedDistrictData?["consti"]?.firstWhere(
      (i) => i['const_name'] == selectedConstituency,
      orElse: () => null,
    );
    var selectedConstituencyId = selectedConstituencyData?["const_id"];

    var selectedDesignationId = _designationData.firstWhere(
      (d) => widget.lang == 'en'
          ? d['designation_en'] == selectedDesignation
          : d['designation_ta'] == selectedDesignation,
      orElse: () => <String, dynamic>{},
    )?['desig_id'];

    return {
      "user_id": widget.userID,
      "name": _nameController.text,
      "father_name": _fatherNameController.text,
      "district_id": selectedDistrictId ?? "",
      "constituency_id": selectedConstituencyId ?? "",
      "ward_num": int.tryParse(_wardController.text) ?? "",
      "voter_id": _voterIdController.text,
      "adhar_num": _aadharController.text,
      "address": _addressController.text,
      "designation": selectedDesignationId ?? "",
      "occupation": _occupationController.text,
      "fileBuffer": updatedFileLocation
    };
  }

  Future<bool> CheckMemberDetail() async {
    try {
      setState(() =>
          _isloading = true); // Ensure loading state is set at the beginning

      var memberData =
          await apiservices.getmemberlist("/getMember", widget.memberId);
      print(memberData);

      if (memberData != null && memberData != 0 && memberData['data'] != null) {
        var member = memberData['data'][0];

        // Ensure all values are converted properly
        _nameController.text = member['name']?.toString() ?? '';
        _fatherNameController.text = member['father_name']?.toString() ?? '';
        _wardController.text = member['ward_num'] ?? 0;
        _voterIdController.text = member['voter_id']?.toString() ?? '';
        _aadharController.text = member['adhar_num']?.toString() ?? '';
        _addressController.text = member['address']?.toString() ?? '';
        _designationController.text =
            member['designation_en']?.toString() ?? '';
        _occupationController.text = member['occupation']?.toString() ?? '';

        if (!mounted) return false; // Prevent updates if widget is disposed

        setState(() {
          selectedDistrict = member['dist_name']?.toString() ?? '';
          selectedConstituency = member["const_name"]?.toString() ?? '';
          selectedDesignation = widget.lang == 'en'
              ? member['designation_en']?.toString() ?? ''
              : member['designation_ta']?.toString() ?? '';
          _fileLocation = member['file_location'] != null
              ? '${member['file_location']}?t=${DateTime.now().millisecondsSinceEpoch}'
              : null;
          _isloading = false;
        });

        print(member["const_name"]);
        return true; // Success
      } else {
        setState(() => _isloading = false);
        return false; // Failed, may retry
      }
    } catch (e) {
      print("Error in CheckMemberDetail: $e");

      if (!mounted) return false; // Ensure widget is still available

      setState(() => _isloading = false);
      return false; // Failed
    }
  }

// Function to reset form fields
// void _resetForm() {
//   if (!mounted) return; // Prevent setting text on disposed controllers

//   _nameController.text = '';
//   _fatherNameController.text = '';
//   _wardController.text = '';
//   _voterIdController.text = '';
//   _aadharController.text = '';
//   _addressController.text = '';
//   _designationController.text = '';
//   _occupationController.text = '';

//   setState(() {
//     selectedDistrict = '';
//     selectedConstituency = '';
//     selectedDesignation = '';
//     _fileLocation = null;
//     _isloading = false;
//   });
// }

  void _handleSubmit() async {
    int retryCount = 0;
    const int maxRetries = 3;
    const int delayBetweenRetries = 150; // Delay of 150ms per retry

    while (retryCount < maxRetries) {
      try {
        var formData = await _buildFormData();
        print("Attempt ${retryCount + 1}: Sending request...");
        print(formData);
        var response = await apiservices.savemember("/createMember", formData);

        // ✅ If we get a response (even with an error), don't retry
        if (response != null) {
          if (response['error'] == true) {
            var msg = response['message'];
            if (msg == "District ID must be a number.")
              msg = "District is required";
            if (msg == "Constituency ID must be a number.")
              msg = "Constituency is required";
            if (msg == "Designation ID must be a number.")
              msg = "Designation is required";
            if (msg == "Invalid ward number") msg = "Ward is required";

            Fluttertoast.showToast(
              msg: msg,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 14.0,
            );
            return; // ✅ Stop retrying if we got a response
          } else {
            if (mounted) {
              Fluttertoast.showToast(
                msg: "Member created successfully!",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 14.0,
              );
            }

            _fetchMemberDetailsWithRetry();
            widget.sethomeindex();
            return; // ✅ Stop retrying if the request is successful
          }
        }
      } catch (e) {
        print("Exception: $e");
      }

      retryCount++; // Increase retry count only if there is an exception or no response

      // ✅ Add delay between retries to ensure all retries happen within 500ms
      if (retryCount < maxRetries) {
        await Future.delayed(Duration(milliseconds: delayBetweenRetries));
      }
    }

    // ✅ If no response after all retries, show failure message
    Fluttertoast.showToast(
      msg: "Failed to create member after multiple attempts.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  void _handleUpdate() async {
    setState(() => _isloading = true); // ✅ Show loading indicator

    try {
      var formData = await _buildFormData();
      print("Updating Member with Data: $formData");

      var response = await apiservices.updatemember(
        "/updateMember",
        widget.memberId,
        formData,
      );

      print("API Response: $response");

      if (response["error"] == "false") {
        // ✅ Success Case
        Fluttertoast.showToast(
          msg: response["message"] ?? "Member updated successfully!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14.0,
        );

        _fetchMemberDetailsWithRetry();
        widget.sethomeindex();
      } else {
        print("error part");

        var msg =
            response?["message"] ?? "Something went wrong. Please try again.";

        if (msg == "District ID must be a number.") {
          msg = "District is required";
        } else if (msg == "Constituency ID must be a number.") {
          msg = "Constituency is required";
        } else if (msg == "Designation ID must be a number.") {
          msg = "Designation is required";
        } else if (msg == "Invalid ward number") {
          msg = "Ward is required";
        }

        Fluttertoast.showToast(
          msg: msg,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }
    } catch (e) {
      // ✅ Exception Handling
      Fluttertoast.showToast(
        msg: "Error: ${e.toString().replaceAll("Exception: ", "")}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } finally {
      if (mounted)
        setState(() => _isloading = false); // ✅ Hide loading indicator safely
    }
  }

 Future<void> _pickImage() async {
   bool checkstatus = await requestStoragePermissions();  // Request location permissions before picking image

    if(checkstatus == false){
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (mounted) {
        setState(() {
          _selectedImage = image;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _wardController.dispose();
    _voterIdController.dispose();
    _aadharController.dispose();
    _addressController.dispose();
    _designationController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (translations.isEmpty) {
    //   return const Scaffold(
    //     body: Center(
    //       child: CircularProgressIndicator(),
    //     ),
    //   );
    // }

    return Localizations.override(
      context: context,
      locale: Locale(widget.lang),
      child: Builder(builder: (context) {
        return Scaffold(
          extendBodyBehindAppBar: true, // Ensure content behind the app bar

          appBar: AppBar(
            centerTitle: true,
            leadingWidth: 40, // Reduce default width of back button
            automaticallyImplyLeading: false,
            title: Text(
              AppLocalizations.of(context)?.membershipjoiningform ?? "",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          body: _isloading == true
              ? Center(
                  child: CircularProgressIndicator(
                  color: Colors.blue,
                ))
              : SafeArea(
                  child: RefreshIndicator(
                    onRefresh: _fetchMemberDetailsWithRetry,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // upload image
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
                              // Name Field
                              Text(
                                AppLocalizations.of(context)?.name ?? "",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText:
                                      AppLocalizations.of(context)?.nameHint ??
                                          "",
                                  hintStyle: TextStyle(
                                    fontSize:
                                        14, // Adjust the font size as needed
                                    fontWeight: FontWeight
                                        .w400, // Adjust the font weight as needed
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // Rounded corners
                                    borderSide: const BorderSide(
                                      color:
                                          Colors.grey, // Default border color
                                      width: 1.0, // Default border width
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color:
                                          Colors.grey, // Color when not focused
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
                                    vertical:
                                        8, // Vertical padding inside the field
                                    horizontal:
                                        12, // Horizontal padding inside the field
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Father's Name Field
                              Text(
                                AppLocalizations.of(context)?.fathersName ?? "",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                controller: _fatherNameController,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)
                                          ?.fathersNameHint ??
                                      "",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // Rounded corners
                                    borderSide: const BorderSide(
                                      color:
                                          Colors.grey, // Default border color
                                      width: 1.0, // Default border width
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color:
                                          Colors.grey, // Color when not focused
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
                                    vertical:
                                        8, // Vertical padding inside the field
                                    horizontal:
                                        12, // Horizontal padding inside the field
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              Text(
                                AppLocalizations.of(context)?.district ?? "",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width:
                                    double.infinity, // Full width of the parent

                                child: DropdownSearch<String>(
                                  dropdownDecoratorProps:
                                      DropDownDecoratorProps(
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color:
                                            Colors.blue, // Color when focused
                                        width: 2.0,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          8), // Rounded corners
                                      borderSide: const BorderSide(
                                        color:
                                            Colors.grey, // Default border color
                                        width: 1.0, // Default border width
                                      ),
                                    ),
                                  )),
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true, // Enables search box
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        labelText: "Search...",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              8), // Rounded corners
                                          borderSide: const BorderSide(
                                            color: Colors
                                                .grey, // Default border color
                                            width: 1.0, // Default border width
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Colors
                                                .grey, // Color when not focused
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Colors
                                                .blue, // Color when focused
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  items: districtList, // Your list of items
                                  selectedItem: selectedDistrict == ""
                                      ? null
                                      : selectedDistrict,

                                  dropdownBuilder: (context, selectedItem) {
                                    return Text(
                                      selectedItem ??
                                          AppLocalizations.of(context)
                                              ?.selectdistrict ??
                                          "",
                                      style: TextStyle(
                                        color: selectedItem == null
                                            ? const Color.fromARGB(
                                                255, 30, 29, 29)
                                            : Colors.black,
                                        fontSize: 16,
                                      ),
                                    );
                                  },

                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedDistrict = newValue ??
                                          ""; // Update the selected district
                                      selectedDistrict =
                                          newValue ?? ""; // Handle null case
                                      if (newValue != null) {
                                        updateConstituencies(newValue);
                                      }
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Panchayat Dropdown
                              Text(
                                AppLocalizations.of(context)
                                        ?.legislativeassembly ??
                                    "",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: DropdownSearch<String>(
                                  dropdownDecoratorProps:
                                      DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color:
                                              Colors.blue, // Color when focused
                                          width: 2.0,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    constraints: BoxConstraints(
                                      maxHeight: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.3, // Adjust max height dynamically
                                    ),
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        labelText: "Search...",
                                        suffixIcon: Icon(Icons
                                            .arrow_drop_down), // Downward Indicator
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Colors.grey,
                                            width: 1.0,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Colors.grey,
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Colors.blue,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  items: constituencyList,
                                  selectedItem: selectedConstituency != ""
                                      ? selectedConstituency
                                      : null,
                                  enabled: constituencyList
                                      .isNotEmpty, // Disable when empty
                                  dropdownBuilder: (context, selectedItem) {
                                    return Text(
                                      selectedItem ??
                                          (constituencyList.isEmpty
                                              ? AppLocalizations.of(context)
                                                      ?.firstselectthedistrict ??
                                                  ""
                                              : AppLocalizations.of(context)
                                                      ?.legislativeassembly ??
                                                  ""),
                                      style: TextStyle(
                                        color: (selectedItem == null ||
                                                constituencyList.isEmpty)
                                            ? const Color.fromARGB(
                                                255, 30, 29, 29)
                                            : Colors.black,
                                        fontSize: 16,
                                      ),
                                    );
                                  },
                                  onChanged: (String? newValue) {
                                    if (mounted) {
                                      setState(() {
                                        selectedConstituency = newValue ?? "";
                                      });
                                    }
                                  },
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Ward Number Dropdown
                              Text(
                                AppLocalizations.of(context)?.wardNumber ?? "",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                controller: _wardController,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)
                                          ?.wardNumberHint ??
                                      "",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // Rounded corners
                                    borderSide: const BorderSide(
                                      color:
                                          Colors.grey, // Default border color
                                      width: 1.0, // Default border width
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color:
                                          Colors.grey, // Color when not focused
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
                                    vertical:
                                        8, // Vertical padding inside the field
                                    horizontal:
                                        12, // Horizontal padding inside the field
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Voter ID Field
                              Text(
                                AppLocalizations.of(context)?.voterId ?? "",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                controller: _voterIdController,
                                decoration: InputDecoration(
                                    hintText:
                                        AppLocalizations.of(context)?.voterId ??
                                            "",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          8), // Rounded corners
                                      borderSide: const BorderSide(
                                        color:
                                            Colors.grey, // Default border color
                                        width: 1.0, // Default border width
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors
                                            .grey, // Color when not focused
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color:
                                            Colors.blue, // Color when focused
                                        width: 2.0,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical:
                                          8, // Vertical padding inside the field
                                      horizontal:
                                          12, // Horizontal padding inside the field
                                    )),
                              ),
                              const SizedBox(height: 16),

                              // Aadhar Number Field
                              Text(
                                AppLocalizations.of(context)?.aadharNumber ??
                                    "",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                controller: _aadharController,
                                decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)
                                            ?.aadharNumberHint ??
                                        "",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          8), // Rounded corners
                                      borderSide: const BorderSide(
                                        color:
                                            Colors.grey, // Default border color
                                        width: 1.0, // Default border width
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors
                                            .grey, // Color when not focused
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color:
                                            Colors.blue, // Color when focused
                                        width: 2.0,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical:
                                          8, // Vertical padding inside the field
                                      horizontal:
                                          12, // Horizontal padding inside the field
                                    )),
                              ),
                              const SizedBox(height: 16),

                              // Address Field
                              Text(
                                AppLocalizations.of(context)?.address ?? "",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                controller: _addressController,
                                decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)
                                            ?.addressHint ??
                                        "",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          8), // Rounded corners
                                      borderSide: const BorderSide(
                                        color:
                                            Colors.grey, // Default border color
                                        width: 1.0, // Default border width
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors
                                            .grey, // Color when not focused
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color:
                                            Colors.blue, // Color when focused
                                        width: 2.0,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical:
                                          8, // Vertical padding inside the field
                                      horizontal:
                                          12, // Horizontal padding inside the field
                                    )),
                              ),
                              const SizedBox(height: 16),

                              // Designation Field
                              Text(
                                AppLocalizations.of(context)?.designation ?? "",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width:
                                    double.infinity, // Full width of the parent

                                child: DropdownSearch<String>(
                                  dropdownDecoratorProps:
                                      DropDownDecoratorProps(
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color:
                                            Colors.blue, // Color when focused
                                        width: 2.0,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          8), // Rounded corners
                                      borderSide: const BorderSide(
                                        color:
                                            Colors.grey, // Default border color
                                        width: 1.0, // Default border width
                                      ),
                                    ),
                                  )),
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true, // Enables search box
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        labelText: "Search...",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              8), // Rounded corners
                                          borderSide: const BorderSide(
                                            color: Colors
                                                .grey, // Default border color
                                            width: 1.0, // Default border width
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Colors
                                                .grey, // Color when not focused
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Colors
                                                .blue, // Color when focused
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  items: designationlist, // Your list of items
                                  selectedItem: selectedDesignation == ""
                                      ? null
                                      : selectedDesignation,

                                  dropdownBuilder: (context, selectedItem) {
                                    return Text(
                                      selectedItem ??
                                          AppLocalizations.of(context)
                                              ?.designation ??
                                          "",
                                      style: TextStyle(
                                        color: selectedItem == null
                                            ? const Color.fromARGB(
                                                255, 30, 29, 29)
                                            : Colors.black,
                                        fontSize: 16,
                                      ),
                                    );
                                  },

                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedDesignation = newValue ??
                                          ""; // Update the selected district
                                      selectedDesignation =
                                          newValue ?? ""; // Handle null case
                                    });
                                  },
                                ),
                              ),

                              // TextField(
                              //   controller: _designationController,
                              //   decoration: InputDecoration(
                              //       hintText: AppLocalizations.of(context)
                              //               ?.designationHint ??
                              //           "",
                              //       border: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(
                              //             8), // Rounded corners
                              //         borderSide: const BorderSide(
                              //           color: Colors.grey, // Default border color
                              //           width: 1.0, // Default border width
                              //         ),
                              //       ),
                              //       enabledBorder: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(8),
                              //         borderSide: const BorderSide(
                              //           color:
                              //               Colors.grey, // Color when not focused
                              //           width: 1.0,
                              //         ),
                              //       ),
                              //       focusedBorder: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(8),
                              //         borderSide: const BorderSide(
                              //           color: Colors.blue, // Color when focused
                              //           width: 2.0,
                              //         ),
                              //       ),
                              //       contentPadding: const EdgeInsets.symmetric(
                              //         vertical:
                              //             8, // Vertical padding inside the field
                              //         horizontal:
                              //             12, // Horizontal padding inside the field
                              //       )),
                              // ),
                              const SizedBox(height: 16),

                              // Occupation Field
                              Text(
                                AppLocalizations.of(context)?.occupation ?? "",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                controller: _occupationController,
                                decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)
                                            ?.occupationHint ??
                                        "",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          8), // Rounded corners
                                      borderSide: const BorderSide(
                                        color:
                                            Colors.grey, // Default border color
                                        width: 1.0, // Default border width
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors
                                            .grey, // Color when not focused
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color:
                                            Colors.blue, // Color when focused
                                        width: 2.0,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical:
                                          8, // Vertical padding inside the field
                                      horizontal:
                                          12, // Horizontal padding inside the field
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
                                    backgroundColor:
                                        Color.fromRGBO(239, 7, 3, 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    minimumSize: Size(0, 50.0),
                                  ),
                                  child: Text(
                                    widget.memberId == 0
                                        ? AppLocalizations.of(context)
                                                ?.submit ??
                                            "" // "Submit"
                                        : AppLocalizations.of(context)!.update,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      }),
    );
  }
}
