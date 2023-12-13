import 'package:music_app/models/song.dart';
import 'package:sqflite/sqflite.dart';

import '../models/playlist.dart';
import '../models/playlist_link_song.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = '$path/song_database.db';
    return await openDatabase(
      databasePath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE songs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            artist TEXT NOT NULL,
            album TEXT,
            category_id TEXT,
            lyrics TEXT,
            link TEXT NOT NULL,
            image_song TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            is_download_in_app INTEGER,
            duration INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE playlists(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            image TEXT NOT NULL,
            author TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE playlist_song_relation(
            playlistId INTEGER NOT NULL,
            songId INTEGER NOT NULL
          )
        ''');
      },
    );
  }

// song queries
  Future<int> insertSong(Song song) async {
    final db = await database;
    return await db.insert('songs', song.toMap());
  }

  Future<List<Song>> getAllSongs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('songs', orderBy: 'title');
    return List.generate(maps.length, (i) {
      return Song.fromMap(maps[i]);
    });
  }

  Future<List<Song>> getSongsByTitle(String title) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT *
    FROM songs
    WHERE title LIKE ?
  ''', ['%$title%']);

    return List.generate(maps.length, (i) {
      return Song.fromMap(maps[i]);
    });
  }

  Future<bool> checkSongExistence(String link) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'songs',
      where: 'link = ?',
      whereArgs: [link],
    );

    return result
        .isNotEmpty; // Returns true if the song with the provided link exists
  }

  Future<int> deleteSong(int id) async {
    final db = await database;
    return await db.delete('songs', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllSongs() async {
    final db = await database;
    return await db.delete('songs');
  }

// playlist queries
  Future<int> insertPlaylist(Playlist playlist) async {
    final db = await database;
    return await db.insert('playlists', playlist.toMap());
  }

  Future<List<Playlist>> getAllPlaylists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('playlists');
    return List.generate(maps.length, (i) {
      return Playlist.fromMap(maps[i]);
    });
  }

  Future<Playlist> getPlaylistById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'playlists',
      where: 'id = ?',
      whereArgs: [id],
    );

    return Playlist.fromMap(result.first);
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE playlists SET name = ?, image = ? WHERE id = ?',
      [playlist.name, playlist.image, playlist.id],
    );
  }

  Future<void> deletePlaylist(int playlistId) async {
    final db = await database;
    await db.delete('playlist_song_relation',
        where: 'playlistId = ?', whereArgs: [playlistId]);
    await db.delete('playlists', where: 'id = ?', whereArgs: [playlistId]);
  }

// playlist_song_relation queries
  Future<int> insertPlaylistSongRelation(PlaylistSongRelation relation) async {
    final db = await database;
    return await db.insert('playlist_song_relation', relation.toMap());
  }

  Future<List<Song>> getSongsInPlaylist(int playlistId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT songs.*
      FROM songs
      INNER JOIN playlist_song_relation ON playlist_song_relation.songId = songs.id
      WHERE playlist_song_relation.playlistId = $playlistId
      ORDER BY songs.title ASC
    ''');
    return List.generate(maps.length, (i) {
      return Song.fromMap(maps[i]);
    });
  }

  Future<List<Song>> getSongsInPlaylistByTitle(
      int playlistId, String title) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT *
      FROM (SELECT songs.*
      FROM songs
      INNER JOIN playlist_song_relation ON playlist_song_relation.songId = songs.id
      WHERE playlist_song_relation.playlistId = $playlistId)
      WHERE title LIKE ?
    ''', ['%$title%']);
    return List.generate(maps.length, (i) {
      return Song.fromMap(maps[i]);
    });
  }

  Future<bool> isSongInPlaylist(int songId, int playlistId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT * FROM playlist_song_relation
    WHERE playlistId = ? AND songId = ?
  ''', [playlistId, songId]);

    return result.isNotEmpty;
  }

  Future<int> deleteSongInPlaylist(int songId, int playlistId) async {
    final db = await database;
    return await db.delete('playlist_song_relation',
        where: 'songId = ? AND playlistId = ?',
        whereArgs: [songId, playlistId]);
  }

  Future<void> deleteDB() async {
    final path = await getDatabasesPath();
    final databasePath = '$path/song_database.db';
    await deleteDatabase(databasePath);
    _database = null;
  }
}
