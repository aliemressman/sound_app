import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class AudioPlayerView extends StatefulWidget {
  final String audioFilePath;
  final Function(String) onAudioSaved;

  const AudioPlayerView({
    Key? key,
    required this.audioFilePath,
    required this.onAudioSaved,
  }) : super(key: key);

  @override
  State<AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  double _volume = 1.0;
  double _bassLevel = 1.0;
  bool _showVolumeControl = true;
  bool _showBassControl = true;
  Timer? _volumeChangeTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setVolume(_volume);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _volumeChangeTimer?.cancel();
    super.dispose();
  }

  void _playPauseAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(widget.audioFilePath));
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _changeVolume(double volume) {
    setState(() {
      _volume = volume;
      _audioPlayer.setVolume(_volume / 10);
    });
  }

  Future<void> _saveAndProcessAudio() async {
    try {
      final originalFile = File(widget.audioFilePath);
      final extension = p.extension(originalFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
      final directory = await getExternalStorageDirectory();
      final targetDirectory = Directory(p.join(directory!.path, 'PublicMusic'));

      if (!await targetDirectory.exists()) {
        await targetDirectory.create(recursive: true);
      }

      final savedFilePath = p.join(targetDirectory.path, fileName);
      await originalFile.copy(savedFilePath);

      widget.onAudioSaved(savedFilePath);

      Fluttertoast.showToast(
        msg: 'Ses başarıyla kaydedildi. $savedFilePath yolundan erişebilirsiniz.',
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Ses işlenirken bir hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _saveAndProcessAudio,
            icon: const Icon(Icons.save),
          ),
        ],
        backgroundColor: Colors.black45,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 4,
            child: Center(
              child: Image.asset(
                "asset/audio_player.png",
                fit: BoxFit.fitWidth,
                width: 300,
                height: 300,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: _buildVolumeAndBassControls(),
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
              _showVolumeControl = !_showVolumeControl;
            } else if (index == 1) {
              _showBassControl = !_showBassControl;
            }
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _playPauseAudio,
        backgroundColor: Colors.pink,
        elevation: 6.0,
        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildVolumeAndBassControls() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showVolumeControl)
            Flexible(
              child: _buildVolumeBars(),
            ),
          if (_showBassControl)
            Flexible(
              child: _buildBassBars(),
            ),
        ],
      ),
    );
  }

  Widget _buildVolumeBars() {
    return GestureDetector(
      onPanUpdate: (details) {
        const stepSize = 0.3;
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
        const stepSize = 0.3;
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
