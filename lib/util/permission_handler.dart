import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

/// Request only photos permission with retry logic
Future<bool> requestStoragePermissions() async {
  bool permissionGranted = false;

  while (!permissionGranted) {
    // ✅ Check if photos permission is already granted
    if (await Permission.photos.isGranted) {
      return true;  // ✅ Permission granted
    }

    // 👉 Request photos-only permission
    var status = await Permission.photos.request();

    if (status.isGranted) {
      return true;  // ✅ Permission granted
    }

    // ❌ Handle denied cases
    if (status.isDenied) {
      Fluttertoast.showToast(
        msg: "Photos access denied. Please allow access.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      continue;  
    }

    // ❌ Handle permanently denied cases
    if (status.isPermanentlyDenied) {
      Fluttertoast.showToast(
        msg: "Photos access permanently denied. Open settings.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      openAppSettings();  // Open settings manually
      return false;
    }

    // Break the loop if no permission is granted
    break;
  }

  return false;  // ❌ Return false if permission is denied or not granted
}
