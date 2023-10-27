part of 'audio_player_bloc.dart';

class AudioPlayerState extends Equatable {
  final AudioPlayer player;
  final bool isPlaying;
  final Song currentSong;
  final Duration position;
  final Duration maxDuration;
  const AudioPlayerState(
      {required this.player,
      required this.isPlaying,
      required this.currentSong,
      required this.position,
      required this.maxDuration});

  @override
  List<Object> get props =>
      [player, isPlaying, currentSong, position, maxDuration];

  AudioPlayerState copyWith({
    AudioPlayer? player,
    bool? isPlaying,
    Song? currentSong,
    Duration? position,
    Duration? maxDuration,
  }) {
    return AudioPlayerState(
      player: player ?? this.player,
      isPlaying: isPlaying ?? this.isPlaying,
      currentSong: currentSong ?? this.currentSong,
      position: position ?? this.position,
      maxDuration: maxDuration ?? this.maxDuration,
    );
  }
}
