import 'package:flutter/services.dart';

// The app is portrait-only (set in main.dart). Only the player's fullscreen
// mode rotates, so these two are the only places orientation changes.

Future<void> enterFullscreen() async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

/// Also call from the player's `dispose`, so leaving the page (back gesture,
/// next lesson) never strands the app in landscape.
Future<void> exitFullscreen() async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
