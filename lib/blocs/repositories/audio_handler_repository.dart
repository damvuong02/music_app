import 'package:music_app/audio_handel.dart';

class AudioHandleRepository {
  final AudioPlayerHandler _audioHandler;
  String _currentPlayingPlaylist;
  AudioHandleRepository(this._audioHandler, this._currentPlayingPlaylist);
  AudioPlayerHandler get audioHandler => _audioHandler;
  String get currentPlayingPlaylist => _currentPlayingPlaylist;
  void setCurrentPlayingPlaylist(String value) {
    _currentPlayingPlaylist = value;
  }
}
