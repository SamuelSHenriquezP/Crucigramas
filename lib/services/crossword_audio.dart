import 'package:audioplayers/audioplayers.dart';

/// Short, bundled sounds work offline and do not depend on system click settings.
class CrosswordAudio {
  static final AudioPlayer _keys = AudioPlayer();
  static final AudioPlayer _completion = AudioPlayer();

  static Future<void> play(String sound) async {
    try {
      final player = sound == 'key' ? _keys : _completion;
      await player.play(AssetSource('audio/$sound.wav'), volume: 0.22);
    } catch (_) {
      // Audio is optional; an unavailable output must never interrupt a game.
    }
  }
}
