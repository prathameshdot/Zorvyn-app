import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double size;
  final BoxFit fit;
  final bool? useDarkAsset;

  const BrandLogo({
    super.key,
    this.size = 96,
    this.fit = BoxFit.contain,
    this.useDarkAsset,
  });

  String _assetForTheme(BuildContext context) {
    final shouldUseDarkAsset =
        useDarkAsset ??
        Theme.of(context).brightness == Brightness.dark;
    return shouldUseDarkAsset ? 'logo_dark.png' : 'logo_light.png';
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetForTheme(context),
      width: size,
      height: size,
      fit: fit,
      filterQuality: FilterQuality.high,
    );
  }
}
