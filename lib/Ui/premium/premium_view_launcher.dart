import 'package:flutter/material.dart';
import 'package:sound_app/Ui/premium/premium_view.dart';

class PremiumViewLauncher extends StatelessWidget {
  const PremiumViewLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    // PremiumView sayfasını animasyonlu bir geçişle açıyoruz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(_createPremiumViewRoute());
    });

    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFF6100FF)], // Başlangıç ve bitiş renkleri
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(child: CircularProgressIndicator())), // Yüklenme göstergesi
    );
  }

  PageRouteBuilder _createPremiumViewRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const PremiumView(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0); // Sayfanın başlangıç pozisyonu
        const end = Offset.zero; // Sayfanın bitiş pozisyonu
        const curve = Curves.easeInOut; // Animasyon eğrisi

        var tween = Tween(begin: begin, end: end); // Tween ile animasyon aralığını tanımlıyoruz
        var curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        var offsetAnimation = tween.animate(curvedAnimation);

        return SlideTransition(position: offsetAnimation, child: child); // Sayfanın kayma animasyonunu uyguluyoruz
      },
    );
  }
}
