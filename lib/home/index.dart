import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pmt_trust/Language/languageservices.dart';
import 'package:pmt_trust/apiservices/apiservice.dart';
import 'package:pmt_trust/home/form.dart';
import 'package:pmt_trust/home/home.dart';
import 'package:pmt_trust/home/profile.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Index extends StatefulWidget {
  final int userId;
  final String lang;

  const Index({required this.userId, required this.lang});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  late List<Widget> _pages = [];
  int _currentIndex = 0;
  final apiService = ApiService();
  final languageService = LanguageService();
  int memberid = 0;
  int isactive = 0;
  int ismember = 0;
  List<String> _labels = ["Home", "Form", "Profile"];
  bool _isLoading = true;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    storeUserIdAndValue(widget.userId, widget.lang);
    updateLanguage(widget.userId, widget.lang);
    _fetchMemberIdWithRetry(widget.userId);
    // _initializePages(widget.lang, widget.userId);
  }

  void storeUserIdAndValue(int userId, String lang) async {
    await storage.write(key: 'userId', value: userId.toString());
    await storage.write(key: 'lang', value: lang);
  }

  Future<void> _fetchMemberIdWithRetry(int userId) async {
    int maxRetries = 3;
    int attempts = 0;
    bool success = false;

    while (attempts < maxRetries && !success) {
      success = await getMemberId(userId);
      if (!success) {
        attempts++;
        if (attempts < maxRetries) {
          print("Retrying getMemberId... attempt $attempts");
          await Future.delayed(Duration(milliseconds: 500));
        }
      }
    }

    if (!success) {
      print("Failed to fetch member ID after $maxRetries attempts.");
    }
    _initializePages(
        widget.lang, widget.userId); // Initialize after getting member ID
  }

  void clearCache() async {
    await DefaultCacheManager().emptyCache();
  }

  void sethomeindex() {
    // _initializePages(widget.lang, widget.userId);
    _fetchMemberIdWithRetry(widget.userId);

    setState(() {
      _currentIndex = 0;
    });
  }

  void setformindex() {
    // _initializePages(widget.lang, widget.userId);
    _fetchMemberIdWithRetry(widget.userId);
    setState(() {
      _currentIndex = 1;
    });
  }

  Future<bool> getMemberId(int id) async {
    try {
      dynamic response =
          await apiService.extractmemberID("/getHomePage/user", id);
      if (response != null &&
          response['data'] != null &&
          response['data']['member_id'] != null) {
        int fetchedMemberId = response['data']['member_id'];
        int fetchisactive = response['data']['is_active'];
        int fetchismember = response['data']['is_member'];
        print("Extracted Member ID: $fetchedMemberId");

        if (memberid != fetchedMemberId) {
          setState(() {
            memberid = fetchedMemberId;
            isactive = fetchisactive;
            ismember = fetchismember;
            _initializePages(
                widget.lang, widget.userId); // Update pages dynamically
          });
        } else {
          setState(() {
            memberid = fetchedMemberId;
            isactive = fetchisactive;
            ismember = fetchismember;
            _initializePages(
                widget.lang, widget.userId); // Update pages dynamically
          });
        }
        return true;
      } else {
        int fetchedMemberId = response['data']['member_id'];
        int fetchisactive = response['data']['is_active'];
        int fetchismember = response['data']['is_member'];
        setState(() {
          memberid = fetchedMemberId;
          isactive = fetchisactive;
          ismember = fetchismember;
          _initializePages(
              widget.lang, widget.userId); // Update pages dynamically
        });
        print("Error: Response does not contain member_id.");
        return false;
      }
    } catch (e) {
      print("Error fetching member ID: $e");
      return false;
    }
  }

  void _refrehIDS() async {
    clearCache();
    await _fetchMemberIdWithRetry(widget.userId);
    setState(() {
      _initializePages(widget.lang, widget.userId);
    });
    print(memberid);
    print("active: $isactive");
    print("member $ismember");
  }

  void _initializePages(String lang, int userID) {
    setState(() {
      _pages = [
        HomePage(
          lang: lang,
          userID: userID,
          memberId: memberid,
          isactive: isactive,
          ismember: ismember,
          refreshCallback: _refrehIDS,
          setformindex: setformindex,
        ),
        FormPage(
          lang: lang,
          userID: userID,
          memberId: memberid,
          sethomeindex: sethomeindex,
        ),
        ProfilePage(userId: userID, lang: lang)
      ];
    });
  }

  void updateLanguage(int userId, String lang) async {
    setState(() => _isLoading = true);
    String? langCheck = await storage.read(key: "langcheck");
    if (langCheck == "true") {
      return;
    }
    var res = await apiService.updateLanguage("/updateLanguage", userId, lang);

    if (res != null) {
      String message = res["message"];
      bool error = res["error"] == "true";

      if (!error) {
        List<String> originalLabels = ["Home", "Form", "Profile"];

        Map<String, String> translatedTexts =
            await languageService.translateText(originalLabels, lang);

        if (lang == 'ta') {
          translatedTexts["Form"] = "படிவம்";
        }

        if (mounted) {
          setState(() {
            _labels =
                originalLabels.map((label) => translatedTexts[label]!).toList();
            _isLoading = false;
            _initializePages(lang, userId); // Ensure pages update instantly
          });
        }
        await storage.write(key: 'langcheck', value: "true");
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        setState(() => _isLoading = false);

        Fluttertoast.showToast(
          msg: message,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      print("No response from the server.");
    }
  }

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void handleback() {
    print("handle back $_currentIndex");
    if (_currentIndex == 2) {
      setState(() {
        _currentIndex = 1;
      });
    } else if (_currentIndex == 1) {
      setState(() {
        _currentIndex = 0;
      });
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: ((didpop) {
        if (didpop) {
          return;
        }
        handleback();
      }),
      child: Scaffold(
        extendBodyBehindAppBar: true, // Ensure content behind the app bar

        body: _pages.isNotEmpty
            ? _pages[_currentIndex]
            : Center(
                child: CircularProgressIndicator(
                color: Colors.blue,
              )),
        bottomNavigationBar: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, -1),
                blurRadius: 3,
              ),
            ],
          ),
          child: Localizations.override(
            context: context,
            locale: Locale(widget.lang),
            child: Builder(builder: (context) {
              return BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onItemTapped,
                selectedItemColor: Color.fromRGBO(239, 7, 3, 1),
                selectedLabelStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                unselectedLabelStyle: TextStyle(fontSize: 12),
                iconSize: 24,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Ionicons.home),
                    label: AppLocalizations.of(context)?.home ?? "",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Ionicons.newspaper),
                    label: AppLocalizations.of(context)?.form ?? "",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Ionicons.person),
                    label: AppLocalizations.of(context)?.profile ?? "",
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
