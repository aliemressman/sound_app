import 'package:flutter/material.dart';
import 'package:sound_app/Ui/home/home_screen/settings_view.dart';
import 'package:sound_app/Ui/home/video_player/video_list.dart';
import 'package:sound_app/Ui/home/voice_player/audio_list.dart';
import 'package:sound_app/core/utility/components/Image/audio_background.dart';
import 'package:sound_app/core/utility/components/Image/video_background.dart';
import 'package:sound_app/core/utility/extension/string_extension.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  HomeString homeString = HomeString();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4C4FB),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        SettingsView.showSettingsSheet(context);
                      },
                      icon: const Icon(Icons.list, color: Colors.white),
                      iconSize: 30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              HomeString.libraryTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VideoList()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(VideoBackground().videoBackgroundImage), // Arka plan resmi
                      fit: BoxFit.cover,
                      colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.darken), // Renk filtre
                    ),
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.blue], // Gradient renkleri
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.6), // Gölge rengi ve opaklık
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 3), // Gölgenin yatay ve dikey uzaklığı
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    HomeString.videosTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AudioList()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(AudioBackground().audioBackgroundImage), // Arka plan resmi
                      fit: BoxFit.cover,
                      colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.darken), // Renk filtre
                    ),
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.red], // Gradient renkleri
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.6), // Gölge rengi ve opaklık
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 3), // Gölgenin yatay ve dikey uzaklığı
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    HomeString.audiosTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
