import 'package:flutter_bloc/flutter_bloc.dart';
import '../../database/database_helper.dart';
import '../../models/playlist.dart';
import '../../models/playlist_link_song.dart';
import '../../models/song.dart';

class PlaylistSongCubit extends Cubit<List<Song>> {
  PlaylistSongCubit() : super([]);

  void initPlaylistSongs(int playlistId) async {
    List<Song> tempSongs =
        await DatabaseHelper().getSongsInPlaylist(playlistId);

    emit(state + tempSongs);
  }

  void addSongtoPlaylist(Song song, int playlistId) {
    DatabaseHelper().insertPlaylistSongRelation(
        PlaylistSongRelation(playlistId: playlistId, songId: song.id));
    List<Song> temp = state;
    temp.add(song);
    temp.sort(((a, b) => a.title.compareTo(b.title)));
    emit([...temp]);
  }

  void deleteSongInPlaylist(Song song, int playlistId) async {
    DatabaseHelper().deleteSongInPlaylist(song.id, playlistId);
    List<Song> currentState = state;
    currentState.removeWhere((element) => element.id == song.id);
    if (currentState.length == 1) {
      Playlist playlist = await DatabaseHelper().getPlaylistById(playlistId);
      DatabaseHelper().updatePlaylist(
          playlist.copyWith(image: currentState.first.imageSong));
    }
    emit([...currentState]);
  }

  void searchSongInPlaylist(int playlistId, String title) async {
    List<Song> currentState =
        await DatabaseHelper().getSongsInPlaylistByTitle(playlistId, title);
    emit([...currentState]);
  }

  void clearPlayListSong() {
    emit([]);
  }
}
