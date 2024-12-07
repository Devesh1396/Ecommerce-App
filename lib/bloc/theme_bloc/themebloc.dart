import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme.dart';

// Events
abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

// States
class ThemeState {
  final ThemeData themeData;
  ThemeState(this.themeData);
}

// Bloc
class ThemeBloc extends Cubit<ThemeState> {
  ThemeBloc() : super(ThemeState(AppTheme.lightTheme)) { // Update reference here
    loadInitialTheme();
  }

  Future<void> loadInitialTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    final initialTheme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme; // Update reference here
    emit(ThemeState(initialTheme));
  }

  Future<void> toggleTheme() async {
    final isCurrentlyDarkMode = state.themeData == AppTheme.darkTheme; // Update reference here
    final newTheme = isCurrentlyDarkMode ? AppTheme.lightTheme : AppTheme.darkTheme; // Update reference here

    // Save the new preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', !isCurrentlyDarkMode);

    // Emit the new theme state
    emit(ThemeState(newTheme));
  }
}
