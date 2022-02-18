/* 
 * Githo – An app that helps you gradually form long-lasting habits.
 * Copyright (C) 2022 Florian Thaler
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:githo/config/app_theme.dart';

/// Theme-dependent color-getters for all the different situations in which
/// the training-cards in the [HomeScreen] can be used.
class CardColors {
  static Color get successful {
    final ThemeEnum theme = AppThemeData.instance.currentThemeEnum;
    switch (theme) {
      case ThemeEnum.light:
        return Colors.green;
      case ThemeEnum.dark:
        return Colors.green.shade900;
      default:
        return Colors.green;
    }
  }

  static Color get unsuccessful {
    final ThemeEnum theme = AppThemeData.instance.currentThemeEnum;
    switch (theme) {
      case ThemeEnum.light:
        return Colors.red;
      case ThemeEnum.dark:
        return Colors.red.shade900;
      default:
        return Colors.red;
    }
  }

  static Color get skipped {
    final ThemeEnum theme = AppThemeData.instance.currentThemeEnum;
    switch (theme) {
      case ThemeEnum.black:
        return Colors.grey;
      default:
        return ThemedColors.grey;
    }
  }

  static Color get waiting {
    return ThemedColors.orange;
  }

  static Color get locked {
    return skipped.withOpacity(0.5);
  }

  static Color get activeNotDone {
    final ThemeEnum theme = AppThemeData.instance.currentThemeEnum;
    switch (theme) {
      case ThemeEnum.light:
        return Colors.red.shade100;
      case ThemeEnum.dark:
        return Colors.red;
      default:
        return Colors.red.shade100;
    }
  }

  static Color get activeDone {
    final ThemeEnum theme = AppThemeData.instance.currentThemeEnum;
    switch (theme) {
      case ThemeEnum.light:
        return Colors.lightGreenAccent;
      case ThemeEnum.dark:
        return Colors.green.shade600;
      default:
        return Colors.lightGreenAccent;
    }
  }
}

/// Returns the color the padding in the [Background]-Widget should have.
Color getBackgroundPaddingColor(final BuildContext context) {
  final ThemeEnum currentTheme = AppThemeData.instance.currentThemeEnum;
  switch (currentTheme) {
    case ThemeEnum.black:
      return Colors.black;
    default:
      return Colors.transparent;
  }
}

/// Color-getters for the different colors a Level can have.
class LevelColors {
  static Color get completed {
    return ThemedColors.green;
  }

  static Color get active {
    return ThemedColors.orange;
  }

  static Color get locked {
    final ThemeEnum theme = AppThemeData.instance.currentThemeEnum;
    switch (theme) {
      case ThemeEnum.black:
        return Colors.black;
      default:
        return ThemedColors.grey.withOpacity(0.5);
    }
  }
}

/// Color-getters for commonly used colors that vary from theme to theme.
class ThemedColors {
  static Color get gold {
    final ThemeEnum theme = AppThemeData.instance.currentThemeEnum;
    switch (theme) {
      case ThemeEnum.light:
        return Colors.amberAccent;
      default:
        return Colors.amber.shade900;
    }
  }

  static Color get green {
    final ThemeEnum theme = AppThemeData.instance.currentThemeEnum;
    switch (theme) {
      case ThemeEnum.light:
        return Colors.green;
      default:
        return Colors.green.shade700;
    }
  }

  static Color get grey {
    final ThemeEnum theme = AppThemeData.instance.currentThemeEnum;
    switch (theme) {
      case ThemeEnum.light:
        return Colors.grey.shade300;
      case ThemeEnum.dark:
        return Colors.grey.shade800;
      default:
        return Colors.black;
    }
  }

  static Color get lightBlue {
    final ThemeEnum theme = AppThemeData.instance.currentThemeEnum;
    switch (theme) {
      case ThemeEnum.light:
        return Colors.lightBlue;
      default:
        return Colors.lightBlue.shade700;
    }
  }

  static Color get orange {
    final ThemeEnum theme = AppThemeData.instance.currentThemeEnum;
    switch (theme) {
      case ThemeEnum.light:
        return Colors.orange;
      default:
        return Colors.orange.shade800;
    }
  }

  static Color get red {
    final ThemeEnum theme = AppThemeData.instance.currentThemeEnum;
    switch (theme) {
      case ThemeEnum.light:
        return Colors.red;
      default:
        return Colors.red.shade900;
    }
  }

  static Color greyFrom(final ThemeEnum theme) {
    switch (theme) {
      case ThemeEnum.light:
        return Colors.grey.shade300;
      case ThemeEnum.dark:
        return Colors.grey.shade800;
      default:
        return Colors.black;
    }
  }
}

/// Color-getters for the status-text-color in the info-bottom-sheet
/// for a level.
class LevelContrastColors {
  static Color get completed {
    final ThemeEnum theme = AppThemeData.instance.currentThemeEnum;
    switch (theme) {
      case ThemeEnum.light:
        return Colors.green.shade800;
      case ThemeEnum.dark:
        return Colors.green.shade200;

      default:
        return Colors.green.shade200;
    }
  }

  static Color get active {
    final ThemeEnum theme = AppThemeData.instance.currentThemeEnum;
    switch (theme) {
      case ThemeEnum.light:
        return Colors.orange.shade800;
      case ThemeEnum.dark:
        return Colors.orange.shade200;

      default:
        return Colors.orange.shade200;
    }
  }

  static Color get locked {
    final ThemeEnum theme = AppThemeData.instance.currentThemeEnum;
    switch (theme) {
      case ThemeEnum.light:
        return Colors.grey.shade800;
      case ThemeEnum.dark:
        return Colors.grey.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
}

/// A styling-shortcut that returns a training-card styled accordingly to
/// the current theme.
class TrainingCardThemes {
  static const double topMargin = 5;
  static const double bottomMargin = 15;

  /// Returns an appropriately styled visible part of a [TrainingCard].
  static Widget getThemedCard({
    required final double cardHeight,
    required final Color color,
    required final double elevation,
    final Color? shadowColor,
    final void Function()? onTap,
    final void Function()? onLongPress,
    required final Widget child,
  }) {
    const double borderRadius = 7;
    final ThemeEnum currentTheme = AppThemeData.instance.currentThemeEnum;
    switch (currentTheme) {
      case ThemeEnum.black:
        return Material(
          borderRadius: BorderRadius.circular(borderRadius),
          color: color,
          elevation: elevation,
          shadowColor: shadowColor,
          child: Padding(
            padding: EdgeInsets.all(
              cardHeight / 20,
            ), // Adapts border-width to card-height.
            child: Material(
              color: Colors.black,
              borderRadius: BorderRadius.circular(borderRadius - 3),
              child: InkWell(
                splashColor: Colors.white,
                onTap: onTap,
                onLongPress: onLongPress,
                borderRadius: BorderRadius.circular(borderRadius - 3),
                child: Center(
                  child: child,
                ),
              ),
            ),
          ),
        );
      default: // For light and dark theme.
        return Material(
          borderRadius: BorderRadius.circular(borderRadius),
          color: color,
          elevation: elevation,
          shadowColor: shadowColor,
          child: InkWell(
            splashColor: Colors.black,
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Center(
              child: child,
            ),
          ),
        );
    }
  }
}

/// Returns the dialog's background-color with a fitting opacity.
Color get dialogBackgroundColor {
  final ThemeEnum currentTheme = AppThemeData.instance.currentThemeEnum;
  switch (currentTheme) {
    case ThemeEnum.light:
      return Colors.white.withOpacity(0.7);
    default:
      return Colors.black.withOpacity(0.6);
  }
}
