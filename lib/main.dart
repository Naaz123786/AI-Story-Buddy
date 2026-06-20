import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/story_screen.dart';
import 'theme/app_styles.dart';

void main() {
  runApp(const ProviderScope(child: AIStoryBuddyApp()));
}

class AIStoryBuddyApp extends StatelessWidget {
  const AIStoryBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppStyles.primary,
      primary: AppStyles.primary,
      secondary: AppStyles.secondary,
      surface: Colors.white,
      error: AppStyles.error,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'AI Story Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: AppStyles.background,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyLarge: AppStyles.body,
          titleLarge: AppStyles.headline,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppStyles.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(58),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      home: const StoryScreen(),
    );
  }
}
