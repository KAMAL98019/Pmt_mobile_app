import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

Future<bool> requestStoragePermissions() async {
  bool permissionGranted = false;

  while (!permissionGranted) {
    if (await Permission.storage.isGranted ||   // ✅ For Android 10 and below
        await Permission.photos.isGranted) {    // ✅ For Android 11+
      return true;  // ✅ Permission granted
    }

    // 👉 Check Android version
    var status = (await Permission.storage.request());  
    if (await Permission.photos.isDenied) {  // For Android 11+
      status = await Permission.photos.request();
    }

    // ✅ Handle granted permission
    if (status.isGranted) {
      return true;
    }

    // ❌ Handle denied cases
    if (status.isDenied) {
      Fluttertoast.showToast(
        msg: "Storage access denied. Please allow access.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      continue;  
    }

    if (status.isPermanentlyDenied) {
      Fluttertoast.showToast(
        msg: "Storage access permanently denied. Open settings.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      openAppSettings();  // Open settings manually
      return false;
    }

    break;
  }

  return false;
}
