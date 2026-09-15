import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'presentation/screens/game_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RunFromAinguApp());
}

class RunFromAinguApp extends StatelessWidget {
  const RunFromAinguApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Attempt to read ?challenge=XX from the URL in web
    int? challengeScore;
    try {
      final uri = Uri.base;
      if (uri.queryParameters.containsKey('challenge')) {
        challengeScore = int.tryParse(uri.queryParameters['challenge']!);
      }
    } catch (_) {
      // Ignored if not on web or error parsing
    }

    return MaterialApp(
      title: 'AINGU RUN 💀',
      theme: AppTheme.retroTheme,
      home: GameHomeScreen(challengeScore: challengeScore),
      debugShowCheckedModeBanner: false,
    );
  }
}
