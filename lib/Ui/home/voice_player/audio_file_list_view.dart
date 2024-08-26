import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'audio_player_view.dart'; // Ses oynatıcı ekranı

class AudioFileListView extends StatefulWidget {
  const AudioFileListView({Key? key}) : super(key: key);

  @override
  State<AudioFileListView> createState() => _AudioFileListViewState();
}

class _AudioFileListViewState extends State<AudioFileListView> {
  List<FileSystemEntity> _audioFiles = [];

  @override
  void initState() {
    super.initState();
    _loadAudioFiles();
  }

  Future<void> _loadAudioFiles() async {
    final directory = await getExternalStorageDirectory();
    final dirPath = directory?.path ?? '';
    final audioFiles = Directory(dirPath).listSync().where((file) => file.path.endsWith('.mp3')).toList();
    setState(() {
      _audioFiles = audioFiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ses Dosyaları'),
      ),
      body: ListView.builder(
        itemCount: _audioFiles.length,
        itemBuilder: (context, index) {
          final file = _audioFiles[index];
          return ListTile(
            title: Text(path.basename(file.path)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AudioPlayerView(
                    audioFilePath: file.path,
                    onAudioSaved: (path) {
                      // Kaydedilen dosyalar için işlem yapılabilir
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
