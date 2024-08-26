import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sound_app/Ui/home/video_player/video_processor.dart';
import 'package:uuid/uuid.dart';

class VideoPlayerView extends StatefulWidget {
  final String videoFilePath;
  final Function(String) onVideoSaved;

  const VideoPlayerView({
    Key? key,
    required this.videoFilePath,
    required this.onVideoSaved,
  }) : super(key: key);

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  double _volume = 1.0; // Başlangıçta ses seviyesi %10
  double _bassLevel = 1.0;
  bool _isVolumeControlVisible = true;
  bool _isBassControlVisible = true;
  Timer? _volumeChangeTimer;
  int _currentIndex = 0; // Seçili item index'i

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.videoFilePath))
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            autoPlay: true,
            looping: true,
            aspectRatio: _videoPlayerController.value.aspectRatio,
          );
          _videoPlayerController.setVolume(_volume / 10); // Başlangıçta %10 ses seviyesi
        });
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    _volumeChangeTimer?.cancel();
    super.dispose();
  }

  void _changeVolume(double volume) {
    setState(() {
      _volume = volume;
      _videoPlayerController.setVolume(_volume / 10); // Ses seviyesini 0-1 aralığında ayarlayın
    });
  }

  Future<void> _saveAndProcessVideo() async {
    try {
      print('Video işleme başladı');

      final videoProcessor = VideoProcessor();
      final outputFileName = '${const Uuid().v4()}.mp4';

      final adjustedVideoPath = await videoProcessor.adjustAudio(
        inputPath: widget.videoFilePath,
        volumeMultiplier: _volume,
        bassMultiplier: _bassLevel,
        outputFileName: outputFileName,
        smoothTransition: true,
      );

      if (adjustedVideoPath != null) {
        print('İşlenmiş video yolu: $adjustedVideoPath');

        final result = await GallerySaver.saveVideo(adjustedVideoPath, albumName: "MyAppVideos");
        print('GallerySaver result: $result');

        if (result == true) {
          print('Video başarıyla kaydedildi');
          Fluttertoast.showToast(msg: 'Video başarıyla kaydedildi');
          widget.onVideoSaved(adjustedVideoPath);
        } else {
          print('Video galeriye kaydedilemedi');
          Fluttertoast.showToast(msg: 'Video galeriye kaydedilemedi');
        }
      } else {
        print('Video işlenemedi');
        Fluttertoast.showToast(msg: 'Video işlenemedi');
      }
    } catch (e) {
      print('Error in processing video: $e');
      Fluttertoast.showToast(msg: 'Video işlenirken bir hata oluştu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _saveAndProcessVideo,
            icon: const Icon(Icons.save, color: Colors.white),
          ),
        ],
        backgroundColor: Colors.black45,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: _chewieController != null
                ? Chewie(
                    controller: _chewieController!,
                  )
                : const Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
          ),
          if (_isVolumeControlVisible || _isBassControlVisible)
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  if (_isVolumeControlVisible) _buildVolumeBars(),
                  if (_isBassControlVisible) _buildBassBars(),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black45,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.white,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.volume_up),
            label: 'Ses Seviyesi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Bas Seviyesi',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 0) {
              _isVolumeControlVisible = !_isVolumeControlVisible;
            } else if (index == 1) {
              _isBassControlVisible = !_isBassControlVisible;
            }
          });
        },
      ),
    );
  }

  Widget _buildVolumeBars() {
    return GestureDetector(
      onPanUpdate: (details) {
        const stepSize = 0.3; // Her adımın büyüklüğü
        final volumeStep = (details.localPosition.dy / 100).clamp(-stepSize, stepSize);
        setState(() {
          _volume = (_volume + volumeStep).clamp(0.0, 10.0);
          _changeVolume(_volume);
        });
      },
      child: _buildBars(
        label: 'Ses Seviyesi',
        level: _volume,
        colors: [Colors.blue, Colors.lightBlueAccent, Colors.cyan],
        onChanged: (value) {
          setState(() {
            _volume = value;
            _changeVolume(value);
          });
        },
      ),
    );
  }

  Widget _buildBassBars() {
    return GestureDetector(
      onPanUpdate: (details) {
        const stepSize = 0.3; // Her adımın büyüklüğü
        final bassStep = (details.localPosition.dy / 100).clamp(-stepSize, stepSize);
        setState(() {
          _bassLevel = (_bassLevel + bassStep).clamp(0.0, 10.0);
        });
      },
      child: _buildBars(
        label: 'Bas Seviyesi',
        level: _bassLevel,
        colors: [Colors.orange, Colors.deepOrangeAccent, Colors.redAccent],
        onChanged: (value) {
          setState(() {
            _bassLevel = value;
          });
        },
      ),
    );
  }

  Widget _buildBars({
    required String label,
    required double level,
    required List<Color> colors,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(10, (index) {
            final barHeight = (index + 1) * 10.0;
            final isActive = level >= (index + 1).toDouble();
            return GestureDetector(
              onTap: () {
                onChanged(index + 1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24,
                height: barHeight,
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                decoration: BoxDecoration(
                  color: isActive ? colors[index % colors.length] : Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: colors[index % colors.length].withOpacity(0.6),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
