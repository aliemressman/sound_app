import 'package:flutter/material.dart';
import 'package:sound_app/Ui/home/home_screen/home_view.dart';
import 'package:sound_app/core/utility/components/Image/premium_image.dart';
import 'package:sound_app/core/utility/components/button/GradientButton.dart';
import 'package:sound_app/core/utility/extension/context_extension.dart';

class PremiumView extends StatefulWidget {
  const PremiumView({super.key});

  @override
  State<PremiumView> createState() => _PremiumViewState();
}

class _PremiumViewState extends State<PremiumView> {
  int selectedButton = 0; // Hangi düğmenin seçili olduğunu takip ediyoruz

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFF6100FF)], // Başlangıç ve bitiş renkleri
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _closePremium(),
                CircleAvatar(
                  maxRadius: MediaQuery.of(context).size.width * 0.3, // Ekran genişliğine göre ayarlanır
                  backgroundImage: NetworkImage(PremiumImage().circleImage),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03), // Ekran yüksekliğine göre ayarlanır
                Text(
                  "Try Premium For Free",
                  style: context.theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _rowOne(),
                _rowTwo(),
                _rowThree(),
                const SizedBox(height: 25),
                _gradientButton1(),
                const SizedBox(height: 25),
                _gradientButton2(),
                const SizedBox(height: 25),
                _continueButton(),
                const SizedBox(height: 25),
                _warningRow(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GradientButton _gradientButton1() {
    return GradientButton(
      text: "3 days free trial, then \$4.99/week",
      icon: Icons.star,
      isSelected: selectedButton == 0,
      onPressed: () {
        setState(() {
          selectedButton = 0;
        });
      },
    );
  }

  GradientButton _gradientButton2() {
    return GradientButton(
      text: "\$49.99/year",
      icon: Icons.star,
      isSelected: selectedButton == 1,
      onPressed: () {
        setState(() {
          selectedButton = 1;
        });
      },
    );
  }

  GestureDetector _warningRow(BuildContext context) {
    return GestureDetector(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Restore | ",
            style: context.theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 15),
          ),
          Text(
            "Privacy | ",
            style: context.theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 15),
          ),
          Text(
            "Terms",
            style: context.theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Row _closePremium() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(_createPageRoute(HomeView()));
          },
          icon: const Icon(Icons.close, color: Colors.grey),
        ),
      ],
    );
  }

  ElevatedButton _continueButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.yellowAccent,
        minimumSize: Size(MediaQuery.of(context).size.width * 0.5, 60),
        maximumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Continue"),
          SizedBox(width: 10),
          Icon(Icons.arrow_forward),
        ],
      ),
    );
  }

  Row _rowThree() {
    return Row(
      children: [
        const Icon(Icons.check),
        const SizedBox(width: 5),
        Text(
          "Compatible with All Files",
          style: context.theme.textTheme.titleLarge,
        ),
      ],
    );
  }

  Row _rowTwo() {
    return Row(
      children: [
        const Icon(Icons.check),
        const SizedBox(width: 5),
        Text(
          "Save Unlimited Music & Videos",
          style: context.theme.textTheme.titleLarge,
        ),
      ],
    );
  }

  Row _rowOne() {
    return Row(
      children: [
        const Icon(Icons.check),
        const SizedBox(width: 5),
        Text(
          "Boost Volume Up to 1000%",
          style: context.theme.textTheme.titleLarge,
        ),
      ],
    );
  }

  PageRouteBuilder _createPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0); // Sayfanın altından yukarıya gelmesi
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end);
        var offsetAnimation = animation.drive(tween.chain(CurveTween(curve: curve)));
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300), // Animasyon süresi
    );
  }
}
