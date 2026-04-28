import 'package:flutter/material.dart';

class AssetIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color color;
  final IconData fallback;

  const AssetIcon({
    super.key,
    required this.assetPath,
    required this.size,
    required this.color,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => Icon(
        fallback,
        size: size,
        color: color,
      ),
    );
  }
}
