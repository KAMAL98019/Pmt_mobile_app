import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
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

  @override
  void initState() {
    super.initState();
    // Decode the JSON data from the widget's passed data
    jsonResponse = jsonDecode(widget.data);
    print(jsonResponse);
    validate = jsonResponse['verificationId'];
  }

  void resendOtp() async {
    var res = await apiService.PostMobileNumber(
        "/sendOTP", jsonResponse['mobileNumber']);
    // debugPrint(jsonEncode(res)["verificationId"]);
    validate = res['data']['verificationId'];
  }

  void ValidateOtp() async {
    // print("$_code,${jsonResponse['verificationId']}");
    var res = await apiService.OtpValidate("/validateOTP", _code, validate);
    debugPrint(jsonEncode(res));
    if (res['data'] != null && res['data']['responseCode'] == "200") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final Map<String, dynamic> data = {
          "mobileNumber": res["data"]["mobileNumber"],
          "userId": res["data"]["userId"],
          "verificationStatus": res["data"]["verificationStatus"]
        };
        print(data);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LanguageSelectPage(
                      data: jsonEncode(data),
                    )));
      });
    } else {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
        title: Text(
          '${res["message"]}',
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          overflow:
              TextOverflow.visible, // Ensures text wraps or is fully shown
        ),
        alignment: Alignment.bottomCenter,
        direction: TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String timeout = jsonResponse['timeout'];
    double? timeoutDouble = double.tryParse(timeout);
    int timeoutDuration = timeoutDouble != null
        ? timeoutDouble.toInt()
        : 60; // Default fallback to 60

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable the default back button
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Color.fromRGBO(255, 248, 0, 1), // Status bar
            statusBarIconBrightness: Brightness.dark),
        toolbarHeight: 180.2,
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow from the AppBar
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
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(22.6),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enter 5 digit verification code \nSent to your phone number",
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(34, 34, 34, 1)),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    VerificationCode(
                      textStyle: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w600,
                          color: Colors
                              .black), // Customize the text style as needed
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      underlineColor: Color.fromRGBO(239, 7, 3,
                          1), // Customize the underline color as needed
                      length: 5,
                      cursorColor:
                          Colors.blue, // Customize the cursor color as needed
                      // Clear out the background properties, as the code below is set

                      onCompleted: (String value) {
                        setState(() {
                          _code = value;
                        });
                      },
                      onEditing: (bool value) {
                        setState(() {
                          // _onEditing = value;
                        });
                        print('Edited');
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
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
                    const SizedBox(
                      height: 20.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: ValidateOtp
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => LanguageSelectPage()));
                        ,
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
              ),
            )
          ],
        ),
      ),
    );
  }
}
