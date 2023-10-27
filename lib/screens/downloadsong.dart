import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/blocs/bloc/download_songs_bloc.dart';
import 'package:music_app/methods/shared_preference_method.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/widgets/app_bar.dart';
import 'package:music_app/widgets/song_item.dart';
import 'package:music_app/widgets/task_bar.dart';

class DownloadSongScreen extends StatefulWidget {
  const DownloadSongScreen({super.key});

  @override
  State<DownloadSongScreen> createState() => _DownloadSongScreenState();
}

class _DownloadSongScreenState extends State<DownloadSongScreen> {
  TextEditingController textController = TextEditingController();
  Song? currentSong;
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
    return BlocBuilder<DownloadSongsBloc, DownloadSongsState>(
      builder: (context, state) {
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
                          onTap: () {},
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
                        return SongWidget(
                          isFavouriteSong: false,
                          song: Song(
                              id: song.id,
                              title: song.title,
                              artist: song.artist,
                              imageSong: song.imageSong,
                              link: song.link,
                              isDownloadInApp: song.isDownloadInApp),
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
