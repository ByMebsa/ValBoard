import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class GlitchLogo extends StatelessWidget {
  final double size;
  final String text;

  const GlitchLogo({
    super.key,
    this.size = 100,
    this.text = 'VALBOARD',
  });

  @override
  Widget build(BuildContext context) {
    final double fontSize = size * 0.5;

    TextStyle baseStyle = Theme.of(context).textTheme.displayLarge!.copyWith(
          fontSize: fontSize,
          height: 1.0,
          fontFamily: 'Valorant', 
        );

    // DÜZELTME: Genişlik (width) kısıtlamasını kaldırıp softWrap: false yaptık.
    return SizedBox(
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(text, softWrap: false, style: baseStyle.copyWith(color: CodePalette.cyanAccent.withOpacity(0.7)))
              .animate(onPlay: (controller) => controller.repeat())
              .moveX(begin: 2, end: -2, duration: 100.ms, curve: Curves.easeInOut)
              .then().moveX(begin: -2, end: 2, duration: 2000.ms).fade(duration: 2000.ms, begin: 0.5, end: 0.8),

          Text(text, softWrap: false, style: baseStyle.copyWith(color: CodePalette.primary.withOpacity(0.7)))
              .animate(onPlay: (controller) => controller.repeat())
              .moveX(begin: -2, end: 2, duration: 120.ms, curve: Curves.easeInOut)
              .then().moveX(begin: 2, end: -2, duration: 2100.ms).fade(duration: 2100.ms, begin: 0.5, end: 0.8),

          Text(text, softWrap: false, style: baseStyle.copyWith(color: CodePalette.white)),
        ],
      ),
    );
  }
}