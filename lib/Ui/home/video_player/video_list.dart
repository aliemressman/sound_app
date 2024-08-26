import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_app/Ui/home/home_screen/home_view.dart';
import 'package:sound_app/Ui/home/video_player/video_player_view.dart';
import 'package:sound_app/core/utility/extension/string_extension.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoList extends StatefulWidget {
  const VideoList({super.key});

  @override
  State<VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  final List<File> _files = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? videoPaths = prefs.getStringList('saved_videos');
    if (videoPaths != null) {
      setState(() {
        _files.addAll(videoPaths.map((path) => File(path)).toList());
      });
    }
  }

  void _onVideoSaved(String videoPath) {
    setState(() {
      _files.add(File(videoPath));
      _saveVideoPath(videoPath);
    });
  }

  Future<void> _saveVideoPath(String videoPath) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? videoList = prefs.getStringList('saved_videos');
    videoList ??= [];
    videoList.add(videoPath);
    await prefs.setStringList('saved_videos', videoList);
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
            const SizedBox(height: 10), // Başlık ve liste arasındaki boşluğu ayarlayın
            Text(
              VideoListString.videos,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 10), // Başlık ve liste arasındaki boşluğu ayarlayın
            Expanded(
              child: ListView.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: file.path.endsWith('.mp4') || file.path.endsWith('.mov')
                          ? FutureBuilder<Uint8List?>(
                              future: _getThumbnail(file.path),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return const Icon(Icons.error, color: Colors.red);
                                } else if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return const Icon(Icons.video_library, color: Colors.white);
                                }
                              },
                            )
                          : const Icon(Icons.music_note, color: Colors.white),
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
                      onTap: () {}, // Burayı boş bırakıyoruz
                    ),
                  );
                },
              ),
            )
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
          onPressed: _showMediaPickerOptions,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.video_library),
        ),
      ),
    );
  }

  void _showMediaPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 150,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(fromGallery: true);
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image, size: 50),
                    Text(
                      'Galeriden Seç',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickMedia({required bool fromGallery}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.single.path != null) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerView(
            videoFilePath: result.files.single.path!,
            onVideoSaved: (newPath) {
              _onVideoSaved(newPath);
            },
          ),
        ),
      );
    } else {
      print('No video selected');
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
                    builder: (context) => VideoPlayerView(
                      videoFilePath: _files[index].path,
                      onVideoSaved: _onVideoSaved,
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
                await _deleteVideo(index);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteVideo(int index) async {
    final file = _files[index];
    await file.delete();
    final prefs = await SharedPreferences.getInstance();
    List<String>? videoList = prefs.getStringList('saved_videos');
    videoList?.remove(file.path);
    await prefs.setStringList('saved_videos', videoList ?? []);
    setState(() {
      _files.removeAt(index);
    });
  }
}

Future<Uint8List?> _getThumbnail(String videoPath) async {
  try {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 75,
    );
    return uint8list;
  } catch (e) {
    print('Thumbnail oluşturulurken bir hata oluştu: $e');
    return null;
  }
}
