import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:avatar_glow/avatar_glow.dart';
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
  String responseText = '';
  String? cleanedText;
  String? predictedEmotion;
  late Future<Map<String, String>>? _futureResponse;
  final StringBuffer _speechTextBuffer = StringBuffer();

  Future<Map<String, String>> getEmotionPrediction(String text) async {
    final url = Uri.parse(dotenv.env["API_URL"]!);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _speechTextBuffer.write(data["cleaned_text"]);
        return {
          "cleaned_text": data["cleaned_text"],
          "predicted_emotion": data["predicted_emotion"]
        };
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        return {"cleaned_text": "", "predicted_emotion": "Error"};
      }
    } catch (e) {
      print("Exception: $e");
      return {"cleaned_text": "", "predicted_emotion": "Exception"};
    }
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _futureResponse = getEmotionPrediction(widget.records.toString());
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
        onStatus: (val) async {
          print('Status: $val');
          if (mounted) {
            if (val == "not listening" || val == "done") {
              setState(() {
                _isListening = false;
              });

              final response =
                  await getEmotionPrediction(widget.records.toString());

              setState(() {
                cleanedText = response["cleaned_text"];
                predictedEmotion = response["predicted_emotion"];
              });

              print(widget.records.toString());
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

      final response = await getEmotionPrediction(widget.records.toString());

      setState(() {
        cleanedText = response["cleaned_text"];
        predictedEmotion = response["predicted_emotion"];
      });

      print(widget.records.toString());
    }
  }

  void _startListening() {
    _speech.listen(onResult: (result) {
      if (mounted) {
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
    final screenWidth = MediaQuery.of(context).size.width;
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
                                  _speechTextBuffer.toString(),
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
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FutureBuilder<Map<String, String>>(
                          future: _futureResponse,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            } else if (!snapshot.hasData ||
                                snapshot.data == null) {
                              return Text("No response");
                            } else {
                              final data = snapshot.data!;
                              return Column(
                                children: [
                                  Text(data["predicted_emotion"] ??
                                      "Predicted Emotion: N/A"),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            bottom: 30,
            right: _isListening ? screenWidth / 2 - 30 : 30,
            child: AvatarGlow(
              animate: _isListening,
              glowColor: Theme.of(context).primaryColor,
              duration: const Duration(milliseconds: 2000),
              repeat: true,
              child: GestureDetector(
                onTap: _listen,
                child: FloatingActionButton(
                  onPressed: _listen,
                  child: Icon(_isListening ? Icons.pause : Icons.mic),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
