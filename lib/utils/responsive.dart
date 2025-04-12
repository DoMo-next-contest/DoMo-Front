import 'package:flutter/material.dart';

/// A responsive layout widget that provides three breakpoints:
/// - Mobile: width < 576
/// - Tablet: 576 <= width <= 992
/// - Desktop: width > 992
///
/// In your Domo app, you can import this file as:
///   import 'package:domo_app/utils/responsive.dart';
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  // Helper methods for checking device sizes:
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 576;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 576 && width <= 992;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 992;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // Desktop layout if width > 992
    if (size.width > 992) {
      return desktop;
    }
    // Tablet layout if width is between 576 and 992 (and a tablet widget is provided)
    else if (size.width >= 576 && tablet != null) {
      return tablet!;
    }
    // Otherwise, default to mobile layout
    else {
      return mobile;
    }
  }
}
