import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/audio_handel.dart';
import 'package:music_app/blocs/bloc/download_songs_bloc.dart';
import 'package:music_app/methods/shared_preference_method.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/utilities/consoleLog.dart';
import 'package:music_app/widgets/app_bar.dart';
import 'package:music_app/widgets/song_item.dart';
import 'package:music_app/widgets/task_bar.dart';

import '../blocs/repositories/audio_handler_repository.dart';
import 'detail_song.dart';

class DownloadSongScreen extends StatefulWidget {
  const DownloadSongScreen({super.key});

  @override
  State<DownloadSongScreen> createState() => _DownloadSongScreenState();
}

class _DownloadSongScreenState extends State<DownloadSongScreen> {
  TextEditingController textController = TextEditingController();
  Song? currentSong;
  bool isSetedDownloadListSong = false;
  int? currentSongIndex;
  void getCurrentSong() async {
    Song? song = await SharedPreferrenceMethod().getCurrentSong();
    setState(() {
      currentSong = song;
    });
  }

  @override
  void initState() {
    getCurrentSong();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _audioHandler = context.read<AudioHandleRepository>().audioHandler;
    return BlocBuilder<DownloadSongsBloc, DownloadSongsState>(
      builder: (context, state) {
        List<MediaItem> listMedia =
            state.downloadSongs.map((song) => song.toMediaItem()).toList();
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back)),
            title: Text("Đã tải (${state.downloadSongs.length})"),
          ),
          body: Stack(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                height: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xff110a19)),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      MyAppBar(
                        avatarUrl: null,
                        controller: textController,
                        searchFunction: () {},
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        width: MediaQuery.sizeOf(context).width * 0.6,
                        child: InkWell(
                          onTap: () async {
                            context
                                .read<AudioHandleRepository>()
                                .setCurrentPlayingPlaylist("download");
                            if (!isSetedDownloadListSong) {
                              await _audioHandler.updateQueue(listMedia);
                            }

                            await _audioHandler
                                .setShuffleMode(AudioServiceShuffleMode.all);
                            SharedPreferrenceMethod().setRandomSong(true);
                            Random random = Random();
                            int index =
                                random.nextInt(state.downloadSongs.length);
                            await _audioHandler.skipToQueueItem(index);
                            Navigator.of(context)
                                .push(_createRoute(DetailSong()));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            decoration: BoxDecoration(
                                color: const Color(0xffA637DA),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Text(
                              "PHÁT NGẪU NHIÊN",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      Column(
                          children: List.generate(state.downloadSongs.length,
                              (index) {
                        Song song = state.downloadSongs[index];
                        return InkWell(
                          onTap: () async {
                            context
                                .read<AudioHandleRepository>()
                                .setCurrentPlayingPlaylist("download");
                            if (!isSetedDownloadListSong) {
                              await _audioHandler.updateQueue(listMedia);
                            }

                            await _audioHandler.skipToQueueItem(index);
                            Navigator.of(context)
                                .push(_createRoute(DetailSong()));
                          },
                          child: SongWidget(
                            isFavouriteSong: false,
                            song: Song(
                                id: song.id,
                                title: song.title,
                                artist: song.artist,
                                imageSong: song.imageSong,
                                link: song.link,
                                isDownloadInApp: song.isDownloadInApp),
                          ),
                        );
                      }))
                    ],
                  ),
                ),
              ),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child:
                      currentSong != null ? const TaskBar() : const SizedBox())
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            onTap: (int index) {
              Navigator.pop(context, index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.music),
                label: 'Cá nhân',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.compactDisc),
                label: 'Khám phá',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.chartLine),
                label: 'Music Chart',
              ),
            ],
          ),
        );
      },
    );
  }
}

Route _createRoute(var page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
