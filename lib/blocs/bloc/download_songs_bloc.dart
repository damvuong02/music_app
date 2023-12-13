import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/database/database_helper.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/utilities/consoleLog.dart';
import 'package:path_provider/path_provider.dart';

import '../repositories/audio_handler_repository.dart';

part 'download_songs_event.dart';
part 'download_songs_state.dart';

class DownloadSongsBloc extends Bloc<DownloadSongsEvent, DownloadSongsState> {
  final DatabaseHelper _songDatabase = DatabaseHelper();
  final AudioHandleRepository repository;
  Timer? _debounce;
  Future<Song?> downloadFile(Song song) async {
    final dio = Dio(); // Tạo một phiên Dio mới

    try {
      final savePath =
          "${(await getExternalStorageDirectory())!.path}/${song.title}_${song.artist}_.mp3";
      updateDownloadProgressNotification(0);
      final response = await dio.download(
        song.link, // URL của tệp bạn muốn tải
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100);

            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(const Duration(milliseconds: 50), () {
              updateDownloadProgressNotification(progress.toInt());
              if (progress == 100) {
                AwesomeNotifications().cancel(1);
              }
            });
          }
        },
      );
      final player = AudioPlayer();
      // Tạo một AudioSource để có thể lấy thông tin độ dài của file
      final audioSource = AudioSource.uri(Uri.parse(song.link));
      await player.setAudioSource(audioSource);
      // Đợi cho đến khi player đã load xong
      await player.load();
      // Lấy độ dài của file MP3
      final duration = player.duration;
      // Giải phóng resources của player
      player.dispose();
      _songDatabase.insertSong(song.copyWith(
          link: savePath, isDownloadInApp: true, duration: duration));

      return song.copyWith(
          link: savePath, isDownloadInApp: true, duration: duration);
    } catch (e) {
      debugPrint('Error during download: $e');
      AwesomeNotifications().cancel(1);
      AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 2,
            channelKey: "basic_channel",
            title: 'Không thể tải bài hát',
            color: Colors.amber),
      );
      return null;
    }
  }

  void updateDownloadProgressNotification(int progress) {
    // Tạo hoặc cập nhật thông báo tiến trình tải
    AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 1,
          channelKey: "basic_channel",
          progress: progress.toInt(),
          title: 'Tải bài hát',
          notificationLayout: NotificationLayout.ProgressBar,
          color: Colors.amber),
    );
  }

  Future<void> deleteFileAsync(String filePath) async {
    File file = File(filePath);
    if (file.existsSync()) {
      await file.delete(); // Xóa bất đồng bộ và đợi quá trình xóa hoàn thành
    }
  }

  Future<List<File>> findMp3FilesLargeOneMB(Directory directory) async {
    final mp3Files = <File>[];
    final entities = directory.listSync();

    for (final entity in entities) {
      if (entity is File && entity.path.toLowerCase().endsWith('.mp3')) {
        // Kiểm tra nếu là tệp .mp3 thì kiểm tra dung lượng
        final file = entity;
        final fileSize = await file.length();
        // file lớn hơn 1.5MB
        if (fileSize >= 1572864) {
          mp3Files.add(entity);
        }
      } else if (entity is Directory) {
        if (entity.path.contains('com.example.music_app')) {
          // Bỏ qua thư mục này và không tiếp tục đệ quy vào bên trong nó
          continue;
        }
        final mp3FilesInSubdirectory = await findMp3FilesLargeOneMB(entity);
        mp3Files.addAll(mp3FilesInSubdirectory);
      }
    }

    return mp3Files;
  }

  String getSongName(String filePath) {
    final parts = filePath.split('/');
    final fileName = parts.last;
    String name = fileName.replaceAll('.mp3', '');
    name = name.replaceAll(RegExp(r'^[\d\W]+'), '');

    return name;
  }

  Future<List<Song>> loadDeviceMusic() async {
    List<Song> songs = [];
    final appDocumentDirectory = await getExternalStorageDirectories();

    await Future.forEach(appDocumentDirectory!, (element) async {
      final list =
          await findMp3FilesLargeOneMB(element.parent.parent.parent.parent);

      await Future.forEach(list, (element) async {
        bool songExists =
            await DatabaseHelper().checkSongExistence(element.path);

        if (!songExists) {
          final player = AudioPlayer();
          final audioSource = AudioSource.uri(Uri.parse(element.path));
          await player.setAudioSource(audioSource);
          await player.load();
          final duration = player.duration;
          player.dispose();

          Song song = Song(
            id: Random().nextInt(99999999),
            title: getSongName(element.path),
            link: element.path,
            isDownloadInApp: false,
            duration: duration,
          );

          await DatabaseHelper().insertSong(song);
          songs.add(song);
        }
      });
    });
    return songs;
  }

  DownloadSongsBloc(this.repository) : super(const DownloadSongsState([])) {
    on<FetchDownloadSongs>((event, emit) async {
      List<Song> songs = await _songDatabase.getAllSongs();
      emit(state.copyWith(downloadSongs: songs));
    });

    on<DownloadSong>(
      (event, emit) async {
        List<Song> updatedDownloadSongs = List.from(state.downloadSongs);

        for (var element in updatedDownloadSongs) {
          if (element.id == event.song.id) {
            ScaffoldMessenger.of(event.context).showSnackBar(
              const SnackBar(
                content: Text("Bài hát đã tồn tại"),
              ),
            );
            return;
          }
        }
        final Song? newSong = await downloadFile(event.song);
        if (newSong != null) {
          if (repository.currentPlayingPlaylist == "download") {
            repository.audioHandler.addQueueItem(newSong.toMediaItem());
          }
          updatedDownloadSongs.add(newSong);
          updatedDownloadSongs.sort((a, b) => a.title.compareTo(b.title));
          emit(state.copyWith(downloadSongs: updatedDownloadSongs));
        } else {
          ScaffoldMessenger.of(event.context).showSnackBar(
            const SnackBar(
              content: Text("Không thể tải bài hát"),
            ),
          );
          return;
        }
      },
    );
    on<LoadDeviceSongs>(
      (event, emit) async {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: 2,
              channelKey: "basic_channel",
              title: 'Quét nhạc',
              body: "Đang quét nhạc trong máy",
              color: Colors.amber),
        );
        List<Song> updatedDownloadSongs = List.from(state.downloadSongs);

        List<Song> deviceSongs = await loadDeviceMusic();
        updatedDownloadSongs.addAll(deviceSongs);
        if (repository.currentPlayingPlaylist == "download") {
          repository.audioHandler.addQueueItems(
              deviceSongs.map((song) => song.toMediaItem()).toList());
        }
        updatedDownloadSongs.sort((a, b) => a.title.compareTo(b.title));
        emit(state.copyWith(downloadSongs: updatedDownloadSongs));
        AwesomeNotifications().cancel(2);
        ScaffoldMessenger.of(event.context).showSnackBar(
          SnackBar(
            content: Text("Đã thêm ${deviceSongs.length} vào danh sách"),
          ),
        );
      },
    );
    on<DeleteDownLoadSongs>(
      (event, emit) {
        List<Song> updatedDownloadSongs = List.from(state.downloadSongs);
        for (var element in updatedDownloadSongs) {
          if (element.id == event.id) {
            updatedDownloadSongs.remove(element);
            _songDatabase.deleteSong(event.id);
            break;
          }
        }
        emit(state.copyWith(downloadSongs: updatedDownloadSongs));
      },
    );
    on<KillDownLoadSongs>(
      (event, emit) {
        List<Song> updatedDownloadSongs = List.from(state.downloadSongs);
        for (var element in updatedDownloadSongs) {
          if (element.id == event.id) {
            updatedDownloadSongs.remove(element);
            _songDatabase.deleteSong(event.id);
            deleteFileAsync(element.link);
            break;
          }
        }
        emit(state.copyWith(downloadSongs: updatedDownloadSongs));
      },
    );
  }
}
