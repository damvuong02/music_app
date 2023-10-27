part of 'download_songs_bloc.dart';

sealed class DownloadSongsEvent extends Equatable {
  const DownloadSongsEvent();

  @override
  List<Object> get props => [];
}

class FetchDownloadSongs extends DownloadSongsEvent {}

class DownloadSong extends DownloadSongsEvent {
  final Song song;
  final BuildContext context;
  const DownloadSong({required this.song, required this.context});
  @override
  List<Object> get props => [song];
}

class DeleteDownLoadSongs extends DownloadSongsEvent {
  final int id;
  const DeleteDownLoadSongs(this.id);
  @override
  List<Object> get props => [id];
}

class KillDownLoadSongs extends DownloadSongsEvent {
  final int id;
  const KillDownLoadSongs(this.id);
  @override
  List<Object> get props => [id];
}
