import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SplitEarApp());
}

class SplitEarApp extends StatelessWidget {
  const SplitEarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Split-Ear',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7)),
        useMaterial3: true,
      ),
      home: const SplitEarHome(),
    );
  }
}

class SplitEarHome extends StatefulWidget {
  const SplitEarHome({super.key});

  @override
  State<SplitEarHome> createState() => _SplitEarHomeState();
}

class _SplitEarHomeState extends State<SplitEarHome> {
  Player? _left;
  Player? _right;
  bool _playing = false;

  final String urlLeft  = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
  final String urlRight = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';

  @override
  void initState() {
    super.initState();
    _left  = Player();
    _right = Player();
  }

  @override
  void dispose() {
    _left?.dispose();
    _right?.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    try {
      await _left!.open(Media(urlLeft), play: false);
      await _right!.open(Media(urlRight), play: false);

      await _left!.setProperty('af', 'lavfi=[pan=stereo|c0=1*c0|c1=0*c0]');
      await _right!.setProperty('af', 'lavfi=[pan=stereo|c0=0*c0|c1=1*c0]');

      await _left!.play();
      await Future.delayed(const Duration(milliseconds: 50));
      await _right!.play();

      setState(() => _playing = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _stop() async {
    await _left?.stop();
    await _right?.stop();
    setState(() => _playing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Split-Ear (One Button)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tap Start → Left ear plays Track A, Right ear plays Track B.\n'
                'Make sure Accessibility → Hearing → Mono audio = OFF.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                icon: Icon(_playing ? Icons.stop : Icons.play_arrow),
                label: Text(_playing ? 'Stop' : 'Start'),
                onPressed: _playing ? _stop : _start,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
