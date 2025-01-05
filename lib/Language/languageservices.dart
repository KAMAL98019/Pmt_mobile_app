import 'package:translator/translator.dart';

class LanguageService {
  final translator = GoogleTranslator();

  // Function to translate a list of strings to the selected language
  Future<Map<String, String>> translateText(List<String> texts, String lang) async {
    Map<String, String> translatedTexts = {};

    for (String text in texts) {
      var translated = await translator.translate(text, to: lang);
      translatedTexts[text] = translated.text; // Store the translated text
    }

    return translatedTexts;
  }
}