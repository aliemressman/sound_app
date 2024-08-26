import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_app/Ui/home/home_screen/home_view.dart';
import 'package:sound_app/Ui/home/voice_player/audio_player_view.dart';
import 'package:sound_app/core/utility/extension/string_extension.dart';

class AudioList extends StatefulWidget {
  const AudioList({super.key});

  @override
  State<AudioList> createState() => _AudioListState();
}

class _AudioListState extends State<AudioList> {
  final List<File> _files = [];

  @override
  void initState() {
    super.initState();
    _loadSavedAudios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4C4FB),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 30),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeView()));
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      iconSize: 30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AudioListString.videos,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: const Icon(Icons.music_note, color: Colors.white),
                      title: Text(file.path.split('/').last, style: const TextStyle(color: Colors.white)),
                      tileColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {
                          _showOptions(context, index);
                        },
                      ),
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Colors.purple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.6),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _pickAudio,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.audiotrack),
        ),
      ),
    );
  }

  Future<void> _loadSavedAudios() async {
    final prefs = await SharedPreferences.getInstance();
    final audioList = prefs.getStringList('saved_audios') ?? [];
    setState(() {
      _files.clear();
      _files.addAll(audioList.map((path) => File(path)));
    });
  }

  void _addAudioToList(String newPath) {
    setState(() {
      _files.add(File(newPath));
    });
  }

  void _saveAudioPath(String newPath) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? audioList = prefs.getStringList('saved_audios');
    audioList ??= [];
    audioList.add(newPath);
    await prefs.setStringList('saved_audios', audioList);

    // Audio listesine ekle
    _addAudioToList(newPath);
  }

  Future<void> _deleteAudio(int index) async {
    final file = _files[index];
    await file.delete();
    final prefs = await SharedPreferences.getInstance();
    List<String>? audioList = prefs.getStringList('saved_audios');
    audioList?.remove(file.path);
    await prefs.setStringList('saved_audios', audioList ?? []);
    setState(() {
      _files.removeAt(index);
    });
  }

  void _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio, // Ses dosyalarını seçmek için FileType.audio kullanılır
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.single.path != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioPlayerView(
            audioFilePath: result.files.single.path!,
            onAudioSaved: (newPath) {
              _saveAudioPath(newPath);
            },
          ),
        ),
      );
    } else {
      print('No audio selected');
    }
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Düzenle'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AudioPlayerView(
                      audioFilePath: _files[index].path,
                      onAudioSaved: (newPath) {
                        _saveAudioPath(newPath);
                      },
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Sil'),
              onTap: () async {
                Navigator.pop(context);
                await _deleteAudio(index);
              },
            ),
          ],
        );
      },
    );
  }
}
