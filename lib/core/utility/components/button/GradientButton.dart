import 'package:flutter/material.dart';
import 'package:outline_gradient_button/outline_gradient_button.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed; // Yeni geri çağırma işlevi eklendi

  const GradientButton({
    super.key,
    required this.text,
    required this.icon,
    required this.isSelected,
    required this.onPressed, // Yeni geri çağırma işlevi eklendi
  });

  @override
  _GradientButtonState createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed, // Tıklandığında geri çağırma işlevi çalıştırılacak
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 200,
          minHeight: 60,
          maxWidth: 375,
          maxHeight: 60,
        ),
        child: OutlineGradientButton(
          gradient: LinearGradient(
            colors: widget.isSelected
                ? List.generate(360, (h) => HSLColor.fromAHSL(1, h.toDouble(), 1, 0.5).toColor())
                : [Colors.grey, Colors.grey],
          ),
          strokeWidth: 2,
          radius: const Radius.circular(8),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(4),
                child: Icon(
                  widget.icon,
                  color: widget.isSelected ? Colors.black : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.isSelected ? Colors.white : Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
