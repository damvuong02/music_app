import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/models/playlist.dart';
import '../../database/database_helper.dart';

class PlaylistCubit extends Cubit<List<Playlist>> {
  PlaylistCubit() : super([]);
  void getAllPlaylist() async {
    List<Playlist> tempSongs = await DatabaseHelper().getAllPlaylists();

    emit(tempSongs);
  }

  void createPlaylist(Playlist playlist) async {
    DatabaseHelper().insertPlaylist(playlist);
    emit([...state, playlist]);
  }

  void updatePlaylist(Playlist playlist) {
    DatabaseHelper().updatePlaylist(playlist);
    List<Playlist> currentState = state;
    for (int i = 0; i < currentState.length; i++) {
      if (currentState[i].id == playlist.id) {
        currentState[i] = playlist;
        break;
      }
    }
    emit([...currentState]);
  }

  void deletePlaylist(Playlist playlist) {
    DatabaseHelper().deletePlaylist(playlist.id);
    List<Playlist> currentState = state;
    currentState.removeWhere((element) => element.id == playlist.id);
    emit([...currentState]);
  }
}
