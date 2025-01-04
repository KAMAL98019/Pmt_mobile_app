import "dart:convert";
import "package:flutter/widgets.dart";
import "package:http/http.dart" as http;


class ApiService{
    static const String baseUrl = 'http://13.201.166.103:4000/pmt';

    // Mobile number Send Post Resquest for OTP

    Future<dynamic> PostMobileNumber(String endpoint, String data) async {

      try{
        final response = await http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(<String, String>{"mobile": data}),
        );
        // print(response.body);
        return jsonDecode(response.body);
      }catch(e){
        print("error: $e");
      }
    }

      
    Future<dynamic> OtpValidate(String endpoint, String code,String verificationId) async{
      try{
        final response = await http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(<String, String>{"code": code,"verificationId":verificationId}),
        );
        // print(response.body);
        return jsonDecode(response.body);
      }catch(e){
        print("error: $e");
      }
    }

}





