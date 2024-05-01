import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quranicversee/settings.dart';
import 'constant.dart';
import 'surah_builder.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;

class MyDrawer extends StatefulWidget {
  const MyDrawer({
    Key? key,
  }) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _text = "";
  bool _isListening = false;
  Map<String, int> arabicToInteger = {
    "الأولى":   1,
    "الثانيه": 2,
    "ثانيه" :2,
    "الثانية": 2,
    "ثانية": 2,
    "الثالثة": 3,
    "ثالثة" :3,
    "ثالثه":3,
    "الثالثه":3,
    "الرابعه": 4,
    "الرابعة": 4,
    "رابعه": 4,
    "رابعة": 4,
    "الخامسه": 5,
    "الخامسة": 5,
    "خمسه": 5,
    "خمسة": 5,
    "السادسه": 6,
    "السادسة": 6,
    "سادسه": 6,
    "سادسة": 6,
    "السابعه": 7,
    "السابعة": 7,
    "سبعه": 7,
    "سبعة": 7,
    "الثامنه": 8,
    "الثامنة": 8,
    "ثامنة": 8,
    "ثامنه": 8,
    "التاسعه": 9,
    "التاسعة": 9,
    "تسعه": 9,
    "تسعة": 9,
    "العاشره": 10,
    "العاشرة": 10,
    "عشره": 10,
    "عشرة": 10
  };

 Map<String, String> text_to_text = {
  "الأية": "الايه",
  "الآية": "الايه",
  "آية": "الايه",
  "أيه": "الايه",
  "ايه": "الايه",
  "الالايه":"الايه",
  "ياسين": "يس"
};



  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('status: $status');
      },
      onError: (error) {
        print('error: $error');
      },
    );

    if (!available) {
      print('Speech recognition not available');
    }
  }

  void _listen(BuildContext context) async {
    if (!_isListening) {
      setState(() {
        _isListening = true;
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
            arabicToInteger.forEach((key, value) {
              _text = _text.replaceAll(key, value.toString());
            });
            text_to_text.forEach((key, value) {
              _text = _text.replaceAll(key, value);
            });

            print(_text);
           // navigateToQuranVerse(context, 18, _text); // Navigate with recognized text
          });
        },
        localeId: 'ar', // Setting locale to Arabic (Egypt)
      );
    } else {
      setState(() {
        _isListening = false;
      });
      _speech.stop();
    }
  }


  List<String> get_surah_and_ayah(String t) {

    RegExp numberRegex = RegExp(r'\b\d+\b');
    String number = "-1";
    Match? numberMatch = numberRegex.firstMatch(t);
    if (numberMatch != null) {
      number = numberMatch.group(0)!;
    }

    List<String> words = t.split(' ');
    String surahWord = '';

    for (int i = 0; i < words.length; i++) {
      String word = words[i];

      if (word.contains('سورة')||word.contains('سوره')||word.contains('صوره')) {
        // Check if the next word exists and is not 'ال'
        if (i + 1 < words.length && words[i + 1] == 'ال') {
          if (i + 2 < words.length && words[i + 2] == 'عمران') {
            surahWord = 'آل عمران';
          }
        }
        else{
          surahWord = words[i+1];

        }
        break;
      }
    }

    print("Extracted Number: $number");
    print("Extracted Word  : $surahWord");

    return [number, surahWord];
  }

  List<String> searchVerses()  {

  List<String> res = get_surah_and_ayah(_text);

  return res;
}

  void _showMicDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                _listen(context);
              },
              icon: Icon(Icons.mic),
              color: _isListening ? Colors.red : Colors.blue,
              iconSize: 50,
            ),
            SizedBox(height: 10), // Add spacing between the mic button and search button
            ElevatedButton(
              onPressed: () async {
                // Handle search button press
                List<String> res  = searchVerses();
                Navigator.pop(context);
                navigateToQuranVerse(context,int.parse(res[0]) , res[1]);
              },
              child: Text('Search'),
            ),
          ],
        ),
      );
    },
  );

  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 204, 204, 0),
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/ic_launcher.png',
                  height: 80,
                ),
                const Text(
                  'Al Quran',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.settings,
            ),
            title: const Text(
              'Settings',
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Settings()));
            },
          ),

          ListTile(
            leading: IconButton(
              icon: Icon(Icons.mic),
              onPressed: () {
                // Call _showMicDialog function when mic button is pressed
              },
            ),
            title: const Text(
              'Search by voice',
            ),
            onTap: () {
              _showMicDialog(context);
            },
          ),
        ],
      ),
    );
  }
}
