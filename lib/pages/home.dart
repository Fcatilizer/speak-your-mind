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
  String _text = 'Press the button and start speaking your mind!';

  late AnimationController _animationController;
  late Animation<double> _fabPositionAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabPositionAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _animationController.forward();
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      } else {
        setState(() {
          _text = 'Speech recognition is not available on this device.';
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speak your Mind')),
      body: Padding(
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
                              color: Theme.of(context).colorScheme.secondary,
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
                      color: Theme.of(context).colorScheme.secondary, width: 2),
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
      floatingActionButton: AnimatedBuilder(
        animation: _fabPositionAnimation,
        builder: (context, child) {
          return Align(
            alignment: Alignment(_fabPositionAnimation.value, 1.0),
            child: SizedBox(
              width: _isListening ? 80 : 56,
              height: _isListening ? 80 : 56,
              child: FloatingActionButton(
                onPressed: _listen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  _isListening ? Icons.pause : Icons.mic,
                  size: _isListening ? 36 : 24,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
