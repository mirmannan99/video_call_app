import 'package:flutter/material.dart';
import 'package:video_call_app/constants/app_images.dart';

class PrimaryAppLogo extends StatelessWidget {
  const PrimaryAppLogo({
    super.key,
    this.size = 256,
    this.isCircular = true,
    this.borderRadius,
    this.backgroundColor,
    this.padding,
    this.fit = BoxFit.contain,
  });

  final double size;
  final bool isCircular;
  final double? borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      width: size,
      height: size,
      color: backgroundColor,
      padding: padding,
      child: Image.asset(
        AppImages.logo,
        fit: fit,
        filterQuality: FilterQuality.high,
      ),
    );

    if (isCircular) {
      return ClipOval(child: content);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? size * 0.2),
      child: content,
    );
  }
}
