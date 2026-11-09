import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import 'dart:ui' show ImageFilter;

// Export public components for use across the app
export 'ui_components.dart' show
  DataCard,
  SectionHeader,
  MetricPill,
  EyebrowPill,
  Badge,
  Avatar,
  DataChip,
  ActionChip,
  QuickActionButton,
  LabeledDivider,
  EmptyState,
  ShimmerPlaceholder,
  BackdropBlur,
  PressableScale,
  HoverElevationCard;

/// //
/// ArcFit UI Components - Data-Dense & Functional Design System
/// //

// //
// HELPER EXTENSIONS
// //

extension _ThemeColors on ThemeData {
  Color get borderColor => colorScheme.outlineVariant;
  bool get isDark => brightness == Brightness.dark;
}

// //
// EYEBROW PILL - Subtle emphasis label for section headers, categories
// //

class EyebrowPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool selected;

  const EyebrowPill({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.backgroundColor,
    this.onTap,
    this.padding,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final effectiveBg = backgroundColor ??
        (selected ? effectiveColor.withValues(alpha: 0.16) : effectiveColor.withValues(alpha: 0.10));
    final borderColor = selected ? effectiveColor : effectiveColor.withValues(alpha: 0.25);

    final child = Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: effectiveColor),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: effectiveColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          child: child,
        ),
      );
    }

    return child;
  }
}

// //
// DATA CARD - Primary container for metrics, progress, info density
// //

class DataCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool hoverable;
  final Widget? header;
  final Widget? footer;
  final CrossAxisAlignment crossAxisAlignment;
  final bool dense;

  const DataCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.hoverable = false,
    this.header,
    this.footer,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.cardTheme.color ?? theme.colorScheme.surface;
    final effectiveBorderColor = borderColor ?? theme.colorScheme.outlineVariant;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(AppTheme.radiusMd);
    final effectiveElevation = elevation ?? (Theme.of(context).isDark ? 0 : 0);
    final cardPadding = dense
        ? const EdgeInsets.all(AppTheme.space3)
        : (padding ?? const EdgeInsets.all(AppTheme.space4));

    final cardContent = Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null) ...[
          header!,
          SizedBox(height: dense ? AppTheme.space2 : AppTheme.space3),
        ],
        child,
        if (footer != null) ...[
          SizedBox(height: dense ? AppTheme.space2 : AppTheme.space3),
          footer!,
        ],
      ],
    );

    final decoratedCard = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: effectiveRadius,
        border: Border.all(color: effectiveBorderColor, width: 1),
        boxShadow: effectiveElevation > 0
            ? [
                BoxShadow(
                  color: theme.shadowColor,
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                  spreadRadius: -3,
                ),
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                  spreadRadius: -1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: Padding(
          padding: cardPadding,
          child: cardContent,
        ),
      ),
    );

    if (onTap != null || hoverable) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          hoverColor: theme.colorScheme.primaryContainer.withValues(alpha: hoverable ? 0.06 : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(borderRadius: effectiveRadius),
            child: decoratedCard,
          ),
        ),
      );
    }

    return decoratedCard;
  }
}

// //
// SECTION HEADER - Consistent section titles with optional eyebrow, trailing action
// //

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? eyebrow;
  final Widget? trailing;
  final double spacing;
  final bool dense;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.trailing,
    this.spacing = 8,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = dense
        ? GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
            height: 1.3,
          )
        : GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
            height: 1.25,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eyebrow != null) ...[
          eyebrow!,
          SizedBox(height: dense ? 6 : 10),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: titleStyle),
                  if (subtitle != null) ...[
                    SizedBox(height: dense ? 2 : 4),
                    Text(
                      subtitle!,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: dense ? 12 : 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.25,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.43,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppTheme.space3),
              trailing!,
            ],
          ],
        ),
      ],
    );
  }
}

// //
// METRIC PILL - Compact metric display: icon + label + value (data-dense)
// //

class MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;
  final MainAxisAlignment mainAxisAlignment;
  final bool dense;
  final Widget? trend;
  final bool isPrimary;

  const MetricPill({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.backgroundColor,
    this.valueStyle,
    this.labelStyle,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.dense = false,
    this.trend,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataTheme = context.dataTextTheme;
    final effectiveColor = color ?? theme.colorScheme.primary;
    final effectiveBg = backgroundColor ?? effectiveColor.withValues(alpha: isPrimary ? 0.14 : 0.08);

    final hPad = dense ? AppTheme.space2 : AppTheme.space3;
    final vPad = dense ? AppTheme.space1 : AppTheme.space2;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: effectiveColor.withValues(alpha: isPrimary ? 0.3 : 0.2),
          width: isPrimary ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 14 : 16, color: effectiveColor),
            SizedBox(width: dense ? 6 : 8),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: labelStyle ??
                    GoogleFonts.ibmPlexSans(
                      fontSize: dense ? 9 : 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.2,
                    ),
              ),
              SizedBox(height: dense ? 1 : 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: valueStyle ??
                        dataTheme.displayMedium?.copyWith(
                          fontSize: dense ? 14 : 16,
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (trend != null) ...[
                    const SizedBox(width: 4),
                    trend!,
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// //
// METRIC ROW - Horizontal row of metric pills (for dashboard stats)
//

class MetricRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final double spacing;
  final bool scrollable;

  const MetricRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.spacing = AppTheme.space3,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: children
              .expand((widget) => [widget, SizedBox(width: spacing)])
              .take(children.length * 2 - 1)
              .toList(),
        ),
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: children
          .expand((widget) => [widget, SizedBox(width: spacing)])
          .take(children.length * 2 - 1)
          .toList(),
    );
  }
}

// //
// PROGRESS RING - Circular progress indicator with centered value
//

class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? centerChild;
  final String? centerText;
  final TextStyle? centerStyle;
  final bool showBackground;
  final StrokeCap strokeCap;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.progressColor,
    this.backgroundColor,
    this.centerChild,
    this.centerText,
    this.centerStyle,
    this.showBackground = true,
    this.strokeCap = StrokeCap.round,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveProgressColor = progressColor ?? theme.colorScheme.primary;
    final effectiveBackgroundColor = backgroundColor ??
        (theme.isDark ? Colors.grey.shade800 : Colors.grey.shade200);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showBackground)
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: strokeWidth,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(effectiveBackgroundColor),
                strokeCap: strokeCap,
              ),
            ),
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
              strokeCap: strokeCap,
            ),
          ),
          if (centerChild != null)
            centerChild!
          else if (centerText != null)
            Text(
              centerText!,
              style: centerStyle ??
                  context.dataTextTheme.displayLarge?.copyWith(
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
            ),
        ],
      ),
    );
  }
}

// //
// LABELED DIVIDER - Divider with optional center label
//

class LabeledDivider extends StatelessWidget {
  final String? label;
  final Color? color;
  final double thickness;
  final EdgeInsetsGeometry? labelPadding;

  const LabeledDivider({
    super.key,
    this.label,
    this.color,
    this.thickness = 1,
    this.labelPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.outlineVariant;

    if (label == null) {
      return Divider(
        color: effectiveColor,
        thickness: thickness,
        height: 1,
      );
    }

    return Row(
      children: [
        Expanded(child: Divider(color: effectiveColor, thickness: thickness, height: 1)),
        Padding(
          padding: labelPadding ?? const EdgeInsets.symmetric(horizontal: AppTheme.space3),
          child: Text(
            label!,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: effectiveColor, thickness: thickness, height: 1)),
      ],
    );
  }
}

// //
// EMPTY STATE - Consistent empty state with illustration, message, action
// //

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.actionLabel,
    this.onAction,
    this.iconSize = 56,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary.withValues(alpha: 0.5);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize + 20,
              height: iconSize + 20,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: iconSize, color: effectiveIconColor),
            ),
            const SizedBox(height: AppTheme.space4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
                height: 1.3,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppTheme.space2),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppTheme.space5),
              action!,
            ] else if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTheme.space5),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// //
// SHIMMER PLACEHOLDER - Loading skeleton
//

class ShimmerPlaceholder extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerPlaceholder({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.isDark;
    final baseColor = widget.baseColor ??
        (isDark ? Colors.grey.shade800 : Colors.grey.shade200);
    final highlightColor = widget.highlightColor ??
        (isDark ? Colors.grey.shade700 : Colors.grey.shade100);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusSm),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_animation.value - 0.4).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.4).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

// BACKDROP BLUR - Frosted glass effect for nav bars, sheets
//

class BackdropBlur extends StatelessWidget {
  final Widget child;
  final double sigmaX;
  final double sigmaY;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  const BackdropBlur({
    super.key,
    required this.child,
    this.sigmaX = 20,
    this.sigmaY = 20,
    this.backgroundColor,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.isDark;
    final effectiveBg = backgroundColor ??
        (isDark
            ? theme.colorScheme.surface.withValues(alpha: 0.8)
            : theme.colorScheme.surface.withValues(alpha: 0.8));

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: borderRadius,
            border: border,
          ),
          child: child,
        ),
      ),
    );
  }
}

// //
// PRESSABLE SCALE - Animated scale feedback on tap
//

class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final Duration duration;
  final Curve curve;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.97,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

// //
// HOVER ELEVATION CARD - Desktop/web hover elevation
// //

class HoverElevationCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final double restingElevation;
  final double hoverElevation;
  final Duration duration;
  final VoidCallback? onTap;

  const HoverElevationCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.restingElevation = 0,
    this.hoverElevation = 8,
    this.duration = const Duration(milliseconds: 150),
    this.onTap,
  });

  @override
  State<HoverElevationCard> createState() => _HoverElevationCardState();
}

class _HoverElevationCardState extends State<HoverElevationCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = widget.color ?? theme.cardTheme.color ?? theme.colorScheme.surface;
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusMd);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        margin: widget.margin,
        padding: widget.padding ?? const EdgeInsets.all(AppTheme.space4),
        decoration: BoxDecoration(
          color: effectiveColor,
          borderRadius: effectiveRadius,
          border: Border.all(color: theme.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(
                alpha: _isHovered ? 0.12 : 0.04,
              ),
              blurRadius: _isHovered ? widget.hoverElevation : widget.restingElevation,
              offset: Offset(0, _isHovered ? 8 : 1),
              spreadRadius: _isHovered ? 2 : 0,
            ),
          ],
        ),
        child: widget.onTap != null
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: effectiveRadius,
                  child: widget.child,
                ),
              )
            : widget.child,
      ),
    );
  }
}

// //
// BADGE - Small status indicator
// //

class Badge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final IconData? icon;
  final bool dot;
  final EdgeInsetsGeometry? padding;

  const Badge({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
    this.icon,
    this.dot = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final effectiveBg = backgroundColor ?? effectiveColor.withValues(alpha: 0.12);

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: effectiveColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          if (icon != null) ...[
            Icon(icon, size: 10, color: effectiveColor),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: effectiveColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// //
// AVATAR - User avatar with emoji or initials fallback
//

class Avatar extends StatelessWidget {
  final String? emoji;
  final String? initials;
  final double size;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  const Avatar({
    super.key,
    this.emoji,
    this.initials,
    this.size = 36,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.isDark;
    final bgColor = backgroundColor ?? theme.colorScheme.primaryContainer;
    final textColor = isDark ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onPrimaryContainer;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(color: borderColor ?? theme.colorScheme.outline, width: borderWidth)
            : null,
      ),
      child: emoji != null
          ? Text(emoji!, style: TextStyle(fontSize: size * 0.55))
          : initials != null
              ? Text(
                  initials!,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: size * 0.38,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                )
              : Icon(Icons.person, size: size * 0.5, color: textColor),
    );
  }
}

// //
// ACTION CHIP - Compact action button
//

class ActionChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool selected;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const ActionChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.selected = false,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final bgColor = selected
        ? effectiveColor
        : effectiveColor.withValues(alpha: 0.1);
    final fgColor = selected ? Colors.white : effectiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(
              color: effectiveColor.withValues(alpha: selected ? 0 : 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: fgColor),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: fgColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// //
// DATA CHIP - Compact action button (alias for ActionChip for exercise substitution)
// //

class DataChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool selected;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const DataChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.selected = false,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final bgColor = selected
        ? effectiveColor
        : effectiveColor.withValues(alpha: 0.1);
    final fgColor = selected ? Colors.white : effectiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(
              color: effectiveColor.withValues(alpha: selected ? 0 : 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: fgColor),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: fgColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// //
// QUICK ACTION BUTTON - Grid icon + label button
//

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool dense;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconSize = dense ? 20.0 : 22.0;
    final containerSize = dense ? 40.0 : 44.0;
    final vPad = dense ? 12.0 : 16.0;
    final radius = dense ? AppTheme.radiusSm : AppTheme.radiusMd;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: vPad, horizontal: dense ? 8 : 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: theme.borderColor, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: containerSize,
                height: containerSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(dense ? AppTheme.radiusXs : AppTheme.radiusSm),
                ),
                child: Icon(icon, size: iconSize, color: color),
              ),
              SizedBox(height: dense ? 6 : 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: dense ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}