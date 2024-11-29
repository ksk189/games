import 'package:just_audio/just_audio.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  MusicService._internal();

  factory MusicService() {
    return _instance;
  }

  Future<void> playBackgroundMusic() async {
    if (_isPlaying) return;
    try {
      await _audioPlayer.setAsset('assets/background_music.mp3');
      _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();
      _isPlaying = true;
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  Future<void> stopMusic() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  bool get isPlaying => _isPlaying;
}