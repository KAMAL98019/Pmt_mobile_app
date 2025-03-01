import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pmt_trust/apiservices/apiservice.dart';
import 'package:pmt_trust/languageselect.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:toastification/toastification.dart';

class OtpPage extends StatefulWidget {
  final String data;

  const OtpPage({required this.data});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late Map<String, dynamic> jsonResponse;
  final apiService = ApiService();
  var _code = "";
  var validate = "";
  bool canPop = false; // Initially, back navigation is disabled

  @override
  void initState() {
    super.initState();
    jsonResponse = jsonDecode(widget.data);
    validate = jsonResponse['verificationId'];

    // Set a timer to enable back navigation after 60 seconds
    Timer(Duration(seconds: 60), () {
      setState(() {
        canPop = true;
      });
    });
  }

  void resendOtp() async {
    var res = await apiService.PostMobileNumber(
        "/sendOTP", jsonResponse['mobileNumber']);
    validate = res['data']['verificationId'];
  }

  void ValidateOtp() async {
  var res = await apiService.OtpValidate("/validateOTP", _code, validate);
  debugPrint(jsonEncode(res));

  if (res['data'] != null && res['data']['responseCode'] == "200") {
    // Show success toast before navigating
    // toastification.show(
    //   context: context,
    //   type: ToastificationType.success,
    //   autoCloseDuration: const Duration(seconds: 3),
    //   title: const Text(
    //     "Welcome! We're excited to have you here.",
    //     style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    //   ),
    //   alignment: Alignment.bottomCenter,
    //   animationDuration: const Duration(milliseconds: 300),
    // );

    Fluttertoast.showToast(msg:"Welcome! We're excited to have you here.", 
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.green,
    textColor: Colors.white,
    fontSize: 16.0
    );

    // Navigate after a short delay to ensure toast is visible
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final Map<String, dynamic> data = {
          "mobileNumber": res["data"]["mobileNumber"],
          "userId": res["data"]["userId"],
          "verificationStatus": res["data"]["verificationStatus"]
        };
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LanguageSelectPage(
              data: jsonEncode(data),
            ),
          ),
        );
      }
    });
  } else {
    // Show error toast
    // toastification.show(
    //   context: context,
    //   type: ToastificationType.error,
    //   autoCloseDuration: const Duration(seconds: 3),
    //   title: Text(
    //     '${res["message"]}',
    //     style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    //   ),
    //   alignment: Alignment.bottomCenter,
    //   animationDuration: const Duration(milliseconds: 300),
    // );
    Fluttertoast.showToast(msg:"${res["message"]}", 
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final String timeout = jsonResponse['timeout'];
    double? timeoutDouble = double.tryParse(timeout);
    int timeoutDuration = timeoutDouble != null ? timeoutDouble.toInt() : 60;

    return PopScope(
      canPop: canPop, // Allow back navigation after 60 seconds
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, 
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent, 
              statusBarIconBrightness: Brightness.dark),
          toolbarHeight: 180.2,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/topbarimage.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(22.6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enter 5 digit verification code \nSent to your phone number",
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(34, 34, 34, 1)),
                    ),
                    SizedBox(height: 20),
                    VerificationCode(
                      textStyle: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      underlineColor: Color.fromRGBO(239, 7, 3, 1),
                      length: 5,
                      cursorColor: Colors.blue,
                      onCompleted: (String value) {
                        setState(() {
                          _code = value;
                        });
                      },
                      onEditing: (bool value) {
                        print('Edited');
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          "Didn’t get the Code? ",
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Color.fromRGBO(51, 50, 50, 0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        OtpTimerButton(
                            onPressed: resendOtp,
                            text: Text(
                              'Resend',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Color.fromRGBO(239, 7, 3, 1),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            buttonType: ButtonType.text_button,
                            duration: timeoutDuration),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: ValidateOtp,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(239, 7, 3, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            minimumSize: Size(0, 50.0)),
                        child: const Text(
                          'Verify',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
