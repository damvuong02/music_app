import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_app/methods/shared_preference_method.dart';
import 'package:music_app/models/song.dart';

part 'audio_player_event.dart';
part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer player;

  AudioPlayerBloc({required this.player})
      : super(AudioPlayerState(
            player: player,
            isPlaying: false,
            currentSong: Song(id: 0, title: "", link: ""),
            position: Duration.zero,
            maxDuration: const Duration(seconds: 60))) {
    on<PlayEvent>((event, emit) {
      if (event.song.isDownloadInApp != null) {
        player.play(DeviceFileSource(event.song.link));
      } else {
        player.play(UrlSource(event.song.link));
      }
      SharedPreferrenceMethod().setCurrentSong(event.song);
      emit(state.copyWith(isPlaying: true, currentSong: event.song));
    });
    on<PauseEvent>((event, emit) {
      player.pause();
      emit(state.copyWith(isPlaying: false));
    });
    on<ResumeEvent>((event, emit) {
      player.resume();
      emit(state.copyWith(isPlaying: true));
    });
    on<SeekEvent>((event, emit) async {
      final newPosition = event.position;
      await player.seek(newPosition);
      emit(state.copyWith(position: newPosition));
    });
    on<GetMaxDurationEvent>((event, emit) async {
      final player = state.player;
      await for (var duration in player.onDurationChanged) {
        emit(state.copyWith(maxDuration: duration));
      }
    });

    on<GetPositioinChangeEvent>((event, emit) async {
      final player = state.player;
      await for (var position in player.onPositionChanged) {
        emit(state.copyWith(position: position));
      }
    });
  }
}
