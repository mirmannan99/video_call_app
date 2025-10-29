import 'package:flutter/material.dart';
import 'package:video_call_app/style/app_color.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.filled,
    this.size = ButtonSize.medium,
    this.color,
    this.foregroundColor,
    this.radius,
    this.elevation,
    this.fullWidth = false,
    this.isLoading = false,
    this.showLabelWhileLoading = true,
    this.icon,
    this.leading,
    this.trailing,
    this.padding,
  });

  final String label;

  final VoidCallback? onPressed;

  final ButtonVariant variant;

  final ButtonSize size;

  final Color? color;

  final Color? foregroundColor;

  final double? radius;

  final double? elevation;

  final bool fullWidth;

  final bool isLoading;

  final bool showLabelWhileLoading;

  final IconData? icon;

  final Widget? leading;

  final Widget? trailing;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;

    final Color baseColor = color ?? _defaultBaseColorForVariant(variant);
    final _ResolvedStyle resolved = _resolveStyle(
      context,
      variant: variant,
      size: size,
      baseColor: baseColor,
      foregroundOverride: foregroundColor,
      radius: radius,
      elevation: elevation,
      padding: padding,
      enabled: enabled,
    );

    final Widget child = _Content(
      label: label,
      textStyle: resolved.textStyle,
      iconSize: resolved.iconSize,
      leading:
          leading ??
          (icon != null ? Icon(icon, size: resolved.iconSize) : null),
      trailing: trailing,
      gap: resolved.gap,
      isLoading: isLoading,
      showLabelWhileLoading: showLabelWhileLoading,
      spinnerColor: resolved.spinnerColor,
      spinnerStrokeWidth: resolved.spinnerStrokeWidth,
      height: resolved.height,
    );

    final ButtonStyle style = resolved.buttonStyle;

    Widget button;
    switch (variant) {
      case ButtonVariant.filled:
        button = ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: style,
          child: child,
        );
        break;
      case ButtonVariant.outline:
        button = OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: style,
          child: child,
        );
        break;
      case ButtonVariant.text:
        button = TextButton(
          onPressed: enabled ? onPressed : null,
          style: style,
          child: child,
        );
        break;
    }

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

enum ButtonVariant { filled, outline, text }

enum ButtonSize { small, medium, large }

class _ResolvedStyle {
  final ButtonStyle buttonStyle;
  final TextStyle textStyle;
  final double iconSize;
  final double gap;
  final double height;
  final Color spinnerColor;
  final double spinnerStrokeWidth;
  const _ResolvedStyle({
    required this.buttonStyle,
    required this.textStyle,
    required this.iconSize,
    required this.gap,
    required this.height,
    required this.spinnerColor,
    required this.spinnerStrokeWidth,
  });
}

Color _defaultBaseColorForVariant(ButtonVariant variant) {
  switch (variant) {
    case ButtonVariant.filled:
      return AppColors.primary;
    case ButtonVariant.outline:
      return AppColors.primary;
    case ButtonVariant.text:
      return AppColors.primary;
  }
}

_ResolvedStyle _resolveStyle(
  BuildContext context, {
  required ButtonVariant variant,
  required ButtonSize size,
  required Color baseColor,
  Color? foregroundOverride,
  double? radius,
  double? elevation,
  EdgeInsetsGeometry? padding,
  required bool enabled,
}) {
  final ThemeData theme = Theme.of(context);

  late final double height;
  late final EdgeInsetsGeometry defaultPadding;
  late final TextStyle textStyle;
  late final double iconSize;
  late final double gap;
  switch (size) {
    case ButtonSize.small:
      height = 40;
      defaultPadding = const EdgeInsets.symmetric(horizontal: 12);
      textStyle =
          theme.textTheme.labelLarge?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ) ??
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
      iconSize = 18;
      gap = 8;
      break;
    case ButtonSize.medium:
      height = 48;
      defaultPadding = const EdgeInsets.symmetric(horizontal: 16);
      textStyle =
          theme.textTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ) ??
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
      iconSize = 20;
      gap = 10;
      break;
    case ButtonSize.large:
      height = 56;
      defaultPadding = const EdgeInsets.symmetric(horizontal: 20);
      textStyle =
          theme.textTheme.labelLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ) ??
          const TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
      iconSize = 22;
      gap = 12;
      break;
  }

  final double corner = radius ?? 12;
  final OutlinedBorder shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(corner),
  );

  final bool isDisabled = !enabled;
  final Color onPrimary = foregroundOverride ?? Colors.white;
  final Color onSurface = foregroundOverride ?? baseColor;
  final Color disabledBg = switch (variant) {
    ButtonVariant.filled => baseColor.withAlpha(145),
    ButtonVariant.outline => Colors.transparent,
    ButtonVariant.text => Colors.transparent,
  };
  final Color disabledFg = (variant == ButtonVariant.filled)
      ? Colors.white.withAlpha(230)
      : onSurface.withAlpha(125);

  final EdgeInsetsGeometry resolvedPadding = padding ?? defaultPadding;

  ButtonStyle style;
  switch (variant) {
    case ButtonVariant.filled:
      style = ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? disabledBg : baseColor,
        foregroundColor: isDisabled ? disabledFg : onPrimary,
        disabledForegroundColor: disabledFg,
        disabledBackgroundColor: disabledBg,
        shape: shape,
        elevation: elevation ?? 1.5,
        padding: resolvedPadding,
        minimumSize: Size(48, height),
        maximumSize: Size(double.infinity, height),
      );
      break;
    case ButtonVariant.outline:
      style = OutlinedButton.styleFrom(
        foregroundColor: isDisabled ? disabledFg : onSurface,
        side: BorderSide(
          color: (isDisabled ? onSurface.withOpacity(0.4) : baseColor),
          width: 1.2,
        ),
        shape: shape,
        padding: resolvedPadding,
        minimumSize: Size(48, height),
        maximumSize: Size(double.infinity, height),
      );
      break;
    case ButtonVariant.text:
      style = TextButton.styleFrom(
        foregroundColor: isDisabled ? disabledFg : onSurface,
        shape: shape,
        padding: resolvedPadding,
        minimumSize: Size(48, height),
        maximumSize: Size(double.infinity, height),
      );
      break;
  }

  final Color spinnerColor = (variant == ButtonVariant.filled)
      ? (isDisabled ? disabledFg : onPrimary)
      : (isDisabled ? disabledFg : onSurface);
  final double spinnerStrokeWidth = size == ButtonSize.large ? 3 : 2.25;

  return _ResolvedStyle(
    buttonStyle: style,
    textStyle: textStyle,
    iconSize: iconSize,
    gap: gap,
    height: height,
    spinnerColor: spinnerColor,
    spinnerStrokeWidth: spinnerStrokeWidth,
  );
}

class _Content extends StatelessWidget {
  const _Content({
    required this.label,
    required this.textStyle,
    required this.gap,
    required this.iconSize,
    required this.isLoading,
    required this.showLabelWhileLoading,
    required this.spinnerColor,
    required this.spinnerStrokeWidth,
    required this.height,
    this.leading,
    this.trailing,
  });

  final String label;
  final TextStyle textStyle;
  final double gap;
  final double iconSize;
  final bool isLoading;
  final bool showLabelWhileLoading;
  final Color spinnerColor;
  final double spinnerStrokeWidth;
  final double height;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rowChildren = [];

    Widget? leadingWidget = leading;
    if (isLoading) {
      leadingWidget = SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: spinnerStrokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
        ),
      );
    }

    if (leadingWidget != null) {
      rowChildren.add(leadingWidget);
      if (showLabelWhileLoading || !isLoading) {
        rowChildren.add(SizedBox(width: gap));
      }
    }

    if (showLabelWhileLoading || !isLoading) {
      rowChildren.add(
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
      );
    }

    if (trailing != null && (showLabelWhileLoading || !isLoading)) {
      rowChildren.add(SizedBox(width: gap));
      rowChildren.add(trailing!);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: rowChildren,
      ),
    );
  }
}
