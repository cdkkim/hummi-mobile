import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  RecordPageState createState() => RecordPageState();
}

class RecordPageState extends State<RecordPage> {
  FlutterSoundRecorder? _recorder;
  bool isRecording = false;
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;
  Timer? _durationTimer;
  Duration _currentDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
  }

  Future<void> toggleRecording() async {
    if (!isRecording) {
      try {
        var status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          throw RecordingPermissionException(
            'Microphone permission not granted',
          );
        }

        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now();
        final fileName =
            'recording_${DateFormat('yyyyMMdd_HHmmss').format(timestamp)}.aac';
        _currentRecordingPath = '${directory.path}/$fileName';

        await _recorder!.startRecorder(
          toFile: _currentRecordingPath,
          codec: Codec.aacADTS,
        );

        setState(() {
          isRecording = true;
          _recordingStartTime = timestamp;
          _currentDuration = Duration.zero;
        });

        _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _currentDuration += const Duration(seconds: 1);
          });
        });
      } catch (e) {
        print('Error starting recording: $e');
      }
    } else {
      try {
        await _recorder!.stopRecorder();
        _durationTimer?.cancel();

        setState(() {
          isRecording = false;
          _currentRecordingPath = null;
          _recordingStartTime = null;
        });
      } catch (e) {
        print('Error stopping recording: $e');
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _recorder!.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isRecording)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  const Text(
                    'Recording in progress',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDuration(_currentDuration),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: const Text(
                'Tap the button to start recording',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
