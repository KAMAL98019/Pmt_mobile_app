import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:translator/translator.dart';

class LanguageService {
  final translator = GoogleTranslator();

  // Function to translate a list of strings to the selected language with retries
  Future<Map<String, String>> translateText(List<String> texts, String lang) async {
    Map<String, String> translatedTexts = {};
    int attempts = 3;  // Number of retry attempts

    for (String text in texts) {
      bool success = false;
      int attemptCount = 0;

      while (attemptCount < attempts && !success) {
        try {
          var translated = await translator.translate(text, to: lang);
          translatedTexts[text] = translated.text; // Store the translated text
          success = true;  // Mark as successful
        } catch (e) {
          attemptCount++;
          if (attemptCount == attempts) {
            translatedTexts[text] = "Error translating";  // Placeholder for failed translations
            print("Error translating '$text': $e");
            toastification.show(
              context: null,
              title: Text('Error translating'),
              description: Text(e.toString()),
              type: ToastificationType.error,
              style: ToastificationStyle.flat,
              alignment: Alignment.topCenter,
              autoCloseDuration: const Duration(seconds: 5),
            );
          } else {
            await Future.delayed(Duration(seconds: 2));  // Retry delay
          }
        }
      }
    }

    return translatedTexts;
  }
}
