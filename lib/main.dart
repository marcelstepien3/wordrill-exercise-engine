import 'package:flutter/material.dart';

import 'core/strings.dart';
import 'demo/demo_session_screen.dart';
import 'theme/wr_theme.dart';

void main() => runApp(const ExerciseEngineDemo());

/// Entry point for the sample.
///
/// Both themes are wired up and the mode follows the system setting, because
/// the renderers resolve every colour through the theme extension and are
/// meant to be checked in light and dark without a rebuild.
class ExerciseEngineDemo extends StatelessWidget {
  const ExerciseEngineDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: wrLightTheme(),
      darkTheme: wrDarkTheme(),
      themeMode: ThemeMode.system,
      home: const DemoSessionScreen(),
    );
  }
}
