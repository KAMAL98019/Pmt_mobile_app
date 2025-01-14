import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pmt_trust/apiservices/apiservice.dart';
import 'package:pmt_trust/otp.dart';
import 'package:toastification/toastification.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _controller = TextEditingController();
  final apiService = ApiService();

  void _On_Submit() async {
    // print(_controller.text);
    if (_controller.text.isEmpty) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 5),
        title: Text(
          'Enter The Phone Number',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        alignment: Alignment.bottomCenter,
        direction: TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),
      );
    } else if (_controller.text.length != 10) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 5),
        title: Text(
          'Enter The Valid Phone Number',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        alignment: Alignment.bottomCenter,
        direction: TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),
      );
    } else {
      try {
        final res = await apiService.PostMobileNumber(
            "/sendOTP", _controller.text.toString());
        debugPrint(jsonEncode(res));
        if (res['data']['responseCode'] == "200") {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final Map<String, dynamic> data = {
              "mobileNumber": res["data"]["mobileNumber"],
              "timeout": res["data"]["timeout"],
              "verificationId": res["data"]["verificationId"]
            };
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OtpPage(
                          data: jsonEncode(data),
                        )));
          });
        } else {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 3),
            title: Text(
              '${res["message"] ?? "An error occurred"}. Retry After 60 seconds',
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              overflow:
                  TextOverflow.visible, // Ensures text wraps or is fully shown
            ),
            alignment: Alignment.bottomCenter,
            direction: TextDirection.ltr,
            animationDuration: const Duration(milliseconds: 300),
          );
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 150,
              ),
              Padding(
                padding: const EdgeInsets.all(22.6),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Enter Your Mobile Number",
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(34, 34, 34, 1)),
                      ),
                      Text(
                        "We will send you a 4 digit verification code",
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Color.fromRGBO(51, 50, 50, 0.7),
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      Text(
                        "Phone Number",
                        style: TextStyle(
                            fontSize: 13.0,
                            color: Color.fromRGBO(51, 50, 50, 1),
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      IntlPhoneField(
                        controller: _controller,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(12.5),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(0, 0, 0,
                                  0.7), // Set color for the bottom border of the input field
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(0, 0, 0,
                                  0.7), // Set color for the bottom border when not focused
                            ),
                          ),
                        ),
                        dropdownDecoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors
                                  .transparent, // Make the dropdown's bottom border transparent
                            ),
                          ),
                        ),
                        initialCountryCode: 'IN',
                        onChanged: (phone) {
                          print(phone.completeNumber);
                        },
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _On_Submit,
                          // onPressed: () {
                          //   Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => OtpPage()));
                          // },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(239, 7, 3, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              minimumSize: Size(0, 50.0)),
                          child: const Text(
                            'Continue',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
