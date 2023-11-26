import 'package:audio_service/audio_service.dart';
import 'package:intl/intl.dart';

class Song {
  int id;
  String title;
  String artist;
  String? album;
  String? categoryId;
  String? lyrics;
  String link;
  String imageSong;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isDownloadInApp;
  Duration? duration;

  Song({
    required this.id,
    required this.title,
    String? artist,
    this.album,
    this.categoryId,
    this.lyrics,
    required this.link,
    String? imageSong,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isDownloadInApp,
    this.duration,
  })  : artist = artist ?? "Unknown Artist",
        imageSong = imageSong ??
            "https://cdn.vectorstock.com/i/preview-1x/65/30/default-image-icon-missing-picture-page-vector-40546530.jpg",
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Song copyWith({
    int? id,
    String? title,
    String? artist,
    String? album,
    String? categoryId,
    String? lyrics,
    String? link,
    String? imageSong,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDownloadInApp,
    Duration? duration,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      categoryId: categoryId ?? this.categoryId,
      lyrics: lyrics ?? this.lyrics,
      link: link ?? this.link,
      imageSong: imageSong ?? this.imageSong,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDownloadInApp: isDownloadInApp ?? this.isDownloadInApp,
      duration: duration ?? this.duration,
    );
  }

  factory Song.fromJson(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
      album: map['album'],
      categoryId: map['category_id'],
      lyrics: map['lyrics'],
      link: map['link'],
      imageSong: map['image_song'],
      createdAt: DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(map['created_at']),
      updatedAt: DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(map['updated_at']),
      isDownloadInApp: map['is_download_in_app'],
      duration: map['duration'] != null
          ? Duration(milliseconds: map['duration'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'category_id': categoryId,
      'lyrics': lyrics,
      'link': link,
      'image_song': imageSong,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_download_in_app': isDownloadInApp,
      'duration': duration?.inMilliseconds,
    };
  }

  Map<String, dynamic> toMap() {
    int isDownloadInAppValue =
        isDownloadInApp == null ? 0 : (isDownloadInApp! ? 1 : 2);
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'category_id': categoryId,
      'lyrics': lyrics,
      'link': link,
      'image_song': imageSong,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_download_in_app': isDownloadInAppValue,
      'duration': duration?.inMilliseconds,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    int isDownloadInAppValue = map['is_download_in_app'];
    return Song(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
      album: map['album'],
      categoryId: map['category_id'],
      lyrics: map['lyrics'],
      link: map['link'],
      imageSong: map['image_song'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      isDownloadInApp: isDownloadInAppValue == 0
          ? null
          : isDownloadInAppValue == 1
              ? true
              : false,
      duration: map['duration'] != null
          ? Duration(milliseconds: map['duration'])
          : null,
    );
  }

  MediaItem toMediaItem() {
    return MediaItem(
      id: link,
      album: album,
      title: title,
      artist: artist,
      duration: duration,
      artUri: Uri.parse(imageSong),
    );
  }
}
