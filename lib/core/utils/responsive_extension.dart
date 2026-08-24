import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_constants.dart';

/// Context extensions for responsive design and theme access
extension ResponsiveContext on BuildContext {
  // Screen Metrics
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double get statusBarHeight => MediaQuery.of(this).padding.top;
  double get bottomBarHeight => MediaQuery.of(this).padding.bottom;

  // Device Form Factor
  bool get isMobile => screenWidth < AppConstants.tabletBreakpoint;
  bool get isTablet =>
      screenWidth >= AppConstants.tabletBreakpoint &&
      screenWidth < AppConstants.desktopBreakpoint;
  bool get isDesktop => screenWidth >= AppConstants.desktopBreakpoint;
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;

  // Dynamic Horizontal / Vertical Spacing
  EdgeInsets get pagePadding => EdgeInsets.symmetric(
        horizontal: isTablet ? 24.w : 16.w,
        vertical: 12.h,
      );

  // Quick Theme Access
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}

/// Dynamic number sizing extensions with fallback safety
extension ResponsiveNum on num {
  /// Responsive width
  double get rw => ScreenUtil().setWidth(this);

  /// Responsive height
  double get rh => ScreenUtil().setHeight(this);

  /// Responsive font size
  double get rsp => ScreenUtil().setSp(this);

  /// Responsive radius
  double get rr => ScreenUtil().radius(this);
}
