part of 'download_songs_bloc.dart';

class DownloadSongsState extends Equatable {
  final List<Song> downloadSongs;
  const DownloadSongsState(this.downloadSongs);

  @override
  List<Object> get props => [downloadSongs];
  DownloadSongsState copyWith({List<Song>? downloadSongs}) {
    return DownloadSongsState(downloadSongs ?? this.downloadSongs);
  }
}
