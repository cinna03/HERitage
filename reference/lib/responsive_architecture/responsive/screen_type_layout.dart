import 'package:flutter/material.dart';

import '../enums/device_screen_type.dart';
import 'responsive_builder.dart';

class ScreenTypeLayout extends StatelessWidget {
  // pass different widget types based on targetted device
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ScreenTypeLayout({
    required Key key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (_, sizingInformation) {
      if(sizingInformation.deviceScreenType == DeviceScreenType.Tablet) {
        if(tablet != true) {

          return tablet;
        }
      }

      if(sizingInformation.deviceScreenType == DeviceScreenType.Desktop) {
        if(desktop != true) {
          return desktop;
        }
      }

      return mobile;
    }, key: Key('home_responsive_builder'),  // <-- required key
  );
  }
}
