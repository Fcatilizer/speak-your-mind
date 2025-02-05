import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomePage extends StatefulWidget {
  final StringBuffer records;

  const HomePage({super.key, required this.records});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recordedText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          setState(() {
            _isListening = val == 'listening';
          });
        },
        onError: (val) {
          print('onError: $val');
          setState(() => _isListening = false);
        },
      );
      if (available) {
        _startListening();
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _startListening() {
    _speech.listen(onResult: (result) {
      if (result.finalResult) {
        setState(() {
          _recordedText = result.recognizedWords;
          widget.records.write("$_recordedText ");
        });
      } else {
        setState(() {
          _recordedText = result.recognizedWords;
        });
      }
    });
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speak your Mind')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _isListening ? 'Recording...' : 'Not Recording',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 15.0,
                    ),
                  ),
                ),
                Flexible(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 50.0,
                          maxHeight: constraints.maxHeight * 0.6,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Text(
                                  widget.records.toString(),
                                  style: const TextStyle(fontSize: 20.0),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Hello World",
                          style: TextStyle(fontSize: 20.0),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            left: _isListening
                ? MediaQuery.of(context).size.width / 2 - 40
                : null,
            right: _isListening ? null : 16,
            bottom:
                _isListening ? MediaQuery.of(context).size.height / 2 - 40 : 16,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: _isListening ? 80.0 : 56.0,
              height: _isListening ? 80.0 : 56.0,
              child: FloatingActionButton(
                onPressed: _listen,
                child: Icon(
                  _isListening ? Icons.pause : Icons.mic,
                  size: _isListening ? 40 : 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
