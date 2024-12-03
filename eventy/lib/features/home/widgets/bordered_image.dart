import 'package:flutter/material.dart';


class BorderedImage extends StatelessWidget {
  final String imagePath;
  final double borderRadius;

  const BorderedImage({super.key, 
    required this.imagePath,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Image.asset(imagePath),
      ),
    );
  }
}