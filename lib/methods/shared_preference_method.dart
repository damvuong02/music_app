import 'dart:convert';

import 'package:music_app/models/song.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferrenceMethod {
  void setRandomSong(bool isRandomSong) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('random', isRandomSong);
  }

  void setRepeatSongList(int isRepeatSongList) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('repeat', isRepeatSongList);
  }

  Future<int> getRepeatSongList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? repeat = prefs.getInt('repeat');
    return repeat ?? 0;
  }

  Future<bool> getRandomSong() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? random = prefs.getBool('random');
    return random ?? false;
  }

  void setCurrentSong(Song song) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentSong', jsonEncode(song.toJson()));
  }

  Future<Song?> getCurrentSong() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? songJson = prefs.getString('currentSong');
    if (songJson != null) {
      final Map<String, dynamic> songMap = jsonDecode(songJson);
      final Song song = Song.fromJson(songMap);
      return song;
    }
    return null; // Trả về null nếu không tìm thấy dữ liệu trong SharedPreferences
  }
}
