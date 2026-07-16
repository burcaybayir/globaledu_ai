import 'package:flutter/material.dart';

extension WidgetExtensions on Widget {
  /// Wraps with Padding.
  Widget padded(EdgeInsetsGeometry padding) {
    return Padding(padding: padding, child: this);
  }

  /// Wraps with symmetric padding.
  Widget paddedSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      ),
      child: this,
    );
  }

  /// Wraps with all-sides padding.
  Widget paddedAll(double value) {
    return Padding(
      padding: EdgeInsets.all(value),
      child: this,
    );
  }

  /// Wraps in a SliverToBoxAdapter.
  Widget get sliver => SliverToBoxAdapter(child: this);

  /// Wraps in Center.
  Widget get centered => Center(child: this);

  /// Wraps in an Expanded widget.
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  /// Wraps in a Flexible widget.
  Widget flexible({int flex = 1}) => Flexible(flex: flex, child: this);

  /// Adds opacity.
  Widget withOpacity(double opacity) => Opacity(opacity: opacity, child: this);

  /// Clips with rounded corners.
  Widget clipRounded(double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: this,
    );
  }

  /// Wraps in a Hero widget.
  Widget hero(String tag) => Hero(tag: tag, child: this);

  /// Wraps in a SafeArea.
  Widget get safeArea => SafeArea(child: this);

  /// Wraps in a Material widget.
  Widget material({
    Color? color,
    double elevation = 0,
    BorderRadius? borderRadius,
  }) {
    return Material(
      color: color,
      elevation: elevation,
      borderRadius: borderRadius,
      child: this,
    );
  }
}
