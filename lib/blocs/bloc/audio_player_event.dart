part of 'audio_player_bloc.dart';

sealed class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();

  @override
  List<Object> get props => [];
}

class PlayEvent extends AudioPlayerEvent {
  final Song song; // URL của bài hát cần phát

  const PlayEvent({required this.song});

  @override
  List<Object> get props => [song];
}

// Sự kiện "PauseEvent"
class PauseEvent extends AudioPlayerEvent {}

// Sự kiện "ResumeEvent"
class ResumeEvent extends AudioPlayerEvent {}

class SeekEvent extends AudioPlayerEvent {
  final Duration position;

  const SeekEvent({required this.position});

  @override
  List<Object> get props => [position];
}

class GetMaxDurationEvent extends AudioPlayerEvent {}

class GetPositioinChangeEvent extends AudioPlayerEvent {}
