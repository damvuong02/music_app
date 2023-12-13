class PlaylistSongRelation {
  final int playlistId;
  final int songId;

  PlaylistSongRelation({
    required this.playlistId,
    required this.songId,
  });

  Map<String, dynamic> toMap() {
    return {
      'playlistId': playlistId,
      'songId': songId,
    };
  }

  factory PlaylistSongRelation.fromMap(Map<String, dynamic> map) {
    return PlaylistSongRelation(
      playlistId: map['playlistId'],
      songId: map['songId'],
    );
  }
}
