import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:music_app/blocs/bloc/download_songs_bloc.dart';
import 'package:music_app/constants/colors.dart';
import 'package:music_app/screens/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/utilities/consoleLog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'audio_handel.dart';
import 'blocs/repositories/audio_handler_repository.dart';
import 'database/database_helper.dart';

Future<List<File>> findMp3FilesLargeOneMB(Directory directory) async {
  final mp3Files = <File>[];
  final entities = directory.listSync();

  for (final entity in entities) {
    if (entity is File && entity.path.toLowerCase().endsWith('.mp3')) {
      // Kiểm tra nếu là tệp .mp3 thì kiểm tra dung lượng
      final file = entity;
      final fileSize = await file.length();
      // file lớn hơn 1MB
      if (fileSize >= 1048576) {
        mp3Files.add(entity);
      }
    } else if (entity is Directory) {
      final mp3FilesInSubdirectory = await findMp3FilesLargeOneMB(entity);
      mp3Files.addAll(mp3FilesInSubdirectory);
    }
  }

  return mp3Files;
}

void printFileNameWithoutExtension(String filePath) {
  final parts = filePath.split('/');

  if (parts.isNotEmpty) {
    final fileName = parts.last;
    String name = fileName.replaceAll('.mp3', '');
    name = name.replaceAll(RegExp(r'^[\d\W]+'), '');
    consoleLog('Tên tệp', name);
  } else {
    consoleLog('name', 'Không tìm thấy tệp hoặc đường dẫn không hợp lệ.');
  }
}

late AudioHandler _audioHandler;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
  AwesomeNotifications().isNotificationAllowed().then(
    (isAllowed) async {
      if (!isAllowed) {
        // Yêu cầu quyền thông báo
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    },
  );
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      "resource://drawable/ic_launcher",
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: const Color(0xFF9D50DD),
            enableVibration: false,
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true);
  final appDocumentDirectory = await getExternalStorageDirectories();
  for (var element in appDocumentDirectory!) {
    final list =
        await findMp3FilesLargeOneMB(element.parent.parent.parent.parent);
    for (var element in list) {
      consoleLog("name", element.path);
      // printFileNameWithoutExtension(element.path);
    }
  }
  AudioPlayerHandler audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandlerImpl(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  runApp(MyApp(
    audioHandlerRepo: AudioHandleRepository(audioHandler, ''),
  ));
}

class MyApp extends StatelessWidget {
  final AudioHandleRepository audioHandlerRepo;
  const MyApp({super.key, required this.audioHandlerRepo});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: audioHandlerRepo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => DownloadSongsBloc(audioHandlerRepo),
          ),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          darkTheme: ThemeData(
              brightness: Brightness.dark, primaryColor: primaryDarkColor),
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: primaryLightColor,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(1),
        ),
      ),
    );
  }
}
