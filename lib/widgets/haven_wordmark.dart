import 'package:flutter/material.dart';

class HavenWordmark extends StatelessWidget {
  const HavenWordmark({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/haven_wordmark.png',
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}
