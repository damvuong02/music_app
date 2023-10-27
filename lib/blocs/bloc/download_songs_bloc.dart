import 'dart:async';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:music_app/database/database_helper.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/utilities/consoleLog.dart';
import 'package:path_provider/path_provider.dart';

part 'download_songs_event.dart';
part 'download_songs_state.dart';

class DownloadSongsBloc extends Bloc<DownloadSongsEvent, DownloadSongsState> {
  final SongDatabase _songDatabase = SongDatabase();
  Timer? _debounce;
  Future<String?> downloadFile(
      String fileUrl, String fileName, Song song) async {
    final dio = Dio(); // Tạo một phiên Dio mới

    try {
      final savePath =
          "${(await getExternalStorageDirectory())!.path}/$fileName";
      updateDownloadProgressNotification(0);
      final response = await dio.download(
        fileUrl, // URL của tệp bạn muốn tải
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
      SongDatabase()
          .insertSong(song.copyWith(link: savePath, isDownloadInApp: true));
      return savePath;
    } catch (e) {
      print('Error during download: $e');
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

  DownloadSongsBloc() : super(const DownloadSongsState([])) {
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
        final String? savePath = await downloadFile(event.song.link,
            "${event.song.title}_${event.song.artist}_.mp3", event.song);
        if (savePath != null) {
          updatedDownloadSongs
              .add(event.song.copyWith(isDownloadInApp: true, link: savePath));
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
