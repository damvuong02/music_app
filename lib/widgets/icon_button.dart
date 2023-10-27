import 'package:flutter/material.dart';
import 'package:music_app/constants/colors.dart';

class MyIconButton extends StatelessWidget {
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final IconData icon;
  final Function()? onTap;
  const MyIconButton(
      {super.key,
      required this.size,
      required this.backgroundColor,
      required this.iconSize,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    bool darkModeOn = brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: size, // Set the width as needed
        height: size, // Set the height as needed
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(16.0), // Adjust the border radius as needed
          color: backgroundColor, // Set the background color as needed
        ),
        child: Icon(
          icon,
          color: darkModeOn
              ? primaryLightColor
              : Colors.black, // Set the icon color as needed
          size: iconSize, // Set the icon size as needed
        ),
      ),
    );
  }
}
