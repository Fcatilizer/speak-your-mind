import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'home.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key});

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recordedText = 'Press the button and start speaking';
  List<String> records = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _toggleListening() async {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(records: records),
        ),
      );
    } else {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          setState(() {
            _recordedText = result.recognizedWords;
            records.add(_recordedText);
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speak your Mind'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _recordedText,
              style: TextStyle(fontSize: 30.0),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.large(
        onPressed: _toggleListening,
        child: Icon(_isListening ? Icons.pause : Icons.mic),
        tooltip: 'Record Audio',
      ),
    );
  }
}
