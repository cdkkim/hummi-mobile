import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class RecordingItem {
  final String path;
  final DateTime timestamp;
  final Duration duration;

  RecordingItem({
    required this.path,
    required this.timestamp,
    required this.duration,
  });

  String get formattedTimestamp {
    return DateFormat('MMM d, y HH:mm').format(timestamp);
  }

  String get fileName {
    return path.split('/').last;
  }
}

class RecordingsPage extends StatefulWidget {
  const RecordingsPage({super.key});

  @override
  State<RecordingsPage> createState() => _RecordingsPageState();
}

class _RecordingsPageState extends State<RecordingsPage> {
  FlutterSoundPlayer? _player;
  List<RecordingItem> _recordings = [];
  int? _playingIndex;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _loadRecordings();
  }

  Future<void> _initPlayer() async {
    _player = FlutterSoundPlayer();
    await _player!.openPlayer();
  }

  Future<void> _loadRecordings() async {
    final directory = await getApplicationDocumentsDirectory();
    final files =
        directory.listSync().where((file) => file.path.endsWith('.aac')).map((
          file,
        ) {
          final stats = File(file.path).statSync();
          return RecordingItem(
            path: file.path,
            timestamp: stats.modified,
            duration: const Duration(seconds: 0),
          );
        }).toList();

    setState(() {
      _recordings = files;
      _recordings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  Future<void> _togglePlayback(int index) async {
    if (_playingIndex == index) {
      await _player!.stopPlayer();
      setState(() => _playingIndex = null);
    } else {
      if (_playingIndex != null) {
        await _player!.stopPlayer();
      }

      try {
        await _player!.startPlayer(
          fromURI: _recordings[index].path,
          whenFinished: () {
            setState(() => _playingIndex = null);
          },
        );
        setState(() => _playingIndex = index);
      } catch (e) {
        print('Error playing recording: $e');
      }
    }
  }

  Future<void> _deleteRecording(int index) async {
    if (_playingIndex == index) {
      await _player!.stopPlayer();
    }

    final recording = _recordings[index];
    final file = File(recording.path);
    if (await file.exists()) {
      await file.delete();
      setState(() {
        _recordings.removeAt(index);
        if (_playingIndex == index) {
          _playingIndex = null;
        }
      });
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
    _player!.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _recordings.length,
      itemBuilder: (context, index) {
        final recording = _recordings[index];
        final isPlaying = _playingIndex == index;

        return Dismissible(
          key: Key(recording.path),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _deleteRecording(index),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: IconButton(
                icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow, size: 20),
                onPressed: () => _togglePlayback(index),
              ),
            ),
            title: Text(
              'Recording ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(recording.formattedTimestamp),
            trailing: Text(_formatDuration(recording.duration)),
          ),
        );
      },
    );
  }
}
