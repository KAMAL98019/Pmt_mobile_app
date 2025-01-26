import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pmt_trust/home/index.dart';
import 'package:pmt_trust/login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = FlutterSecureStorage();

    Future<int?> getUserId() async {
      try {
        int? value = int.tryParse(await storage.read(key: "userId") ?? "");
        print("Stored user ID: $value");
        return value;
      } catch (e) {
        print("Error retrieving user ID: $e");
      }
    }

    Future<String?> getLang() async {
      try {
        String? value = await storage.read(key: "lang");
        print("Stored user language: $value");
        return value;
      } catch (e) {
        print("Error retrieving language: $e");
      }
    }

    return FutureBuilder(
      future: Future.wait([getUserId(), getLang()]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "PMT Trust",
            home: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "PMT Trust",
            home: Center(child: Text('Error loading data')),
          );
        }

        final userID = snapshot.data?[0] as int?;
        final lang = snapshot.data?[1] as String?;

        // bool isLoggedIn = userID != null && lang != null;
        bool isLoggedIn = false;
        if (userID != 0 && lang != null || userID != null) {
          isLoggedIn = true;
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "PMT Trust",
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('ta'), // Tamil
          ],
          home: isLoggedIn
              ? Index(userId: userID ?? 0, lang: lang ?? "")
              : const LoginPage(),
        );
      },
    );
  }
}
