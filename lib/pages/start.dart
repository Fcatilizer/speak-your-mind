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
  final StringBuffer _speechTextBuffer = StringBuffer();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

void _listen() async {
  if (!_isListening) {
    bool available = await _speech.initialize(
      onError: (val) {
        print('Error: $val');
        if (mounted) { 
          setState(() {
            _isListening = false;
          });
        }
      },
      onStatus: (val) {
        print('Status: $val');
        if (mounted) { 
          if (val == "not listening" || val == "done") {
            setState(() {
              _isListening = false;
            });
            _navigateToNextPage();
          }
        }
      },
    );
    if (available) {
      if (mounted) { 
        setState(() {
          _isListening = true;
        });
      }
      _startListening();
    }
  } else {
    if (mounted) { 
      setState(() {
        _isListening = false;
      });
    }
    await _speech.stop();
    _navigateToNextPage();
  }
}

void _startListening() {
  _speech.listen(onResult: (result) {
    if (mounted) { 
      if (result.finalResult) {
        setState(() {
          _recordedText = result.recognizedWords;
          _speechTextBuffer.write("$_recordedText ");
        });
      } else {
        setState(() {
          _recordedText = result.recognizedWords;
        });
      }
    }
  });
}

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }


  void _navigateToNextPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(records: _speechTextBuffer),
      ),
      (route) => false,
    );
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
        onPressed: _listen,
        child: Icon(_isListening ? Icons.pause : Icons.mic),
        tooltip: 'Record Audio',
      ),
    );
  }
}
