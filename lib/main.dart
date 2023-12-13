import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:music_app/blocs/bloc/download_songs_bloc.dart';
import 'package:music_app/blocs/cubit/playlist_cubit.dart';
import 'package:music_app/blocs/cubit/playlist_song_cubit.dart';
import 'package:music_app/constants/colors.dart';
import 'package:music_app/database/database_helper.dart';
import 'package:music_app/screens/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'audio_handel.dart';
import 'blocs/repositories/audio_handler_repository.dart';

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

  AudioPlayerHandler audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandlerImpl(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  // DatabaseHelper().deleteAllSongs();
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
          BlocProvider(
            create: (context) => PlaylistSongCubit(),
          ),
          BlocProvider(
            create: (context) => PlaylistCubit(),
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
