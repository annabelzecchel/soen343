import 'package:flutter/material.dart';

class AppTheme {
  static late ColorScheme colorScheme; // Store ColorScheme globally

  static void init(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;
  }
}
