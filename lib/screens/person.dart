import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/blocs/bloc/download_songs_bloc.dart';
import 'package:music_app/database/database_helper.dart';
import 'package:music_app/screens/downloadsong.dart';
import 'package:music_app/utilities/consoleLog.dart';
import 'package:music_app/widgets/icon_button.dart';
import 'package:music_app/widgets/playlist_item.dart';
import '../blocs/cubit/playlist_cubit.dart';
import '../blocs/cubit/playlist_song_cubit.dart';
import '../models/playlist.dart';
import 'playlist_detail.dart';

class PersonPage extends StatefulWidget {
  final Function(int) callback;
  const PersonPage({super.key, required this.callback});

  @override
  State<PersonPage> createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  void getPlaylists() async {
    BlocProvider.of<PlaylistCubit>(context).getAllPlaylist();
  }

  @override
  void initState() {
    super.initState();
    getPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  MyButton(
                    backgroundColor: Colors.grey,
                    backgroundIconColor: Colors.blueAccent,
                    icon: FontAwesomeIcons.heart,
                    title: "Bài hát yêu thích",
                    subTitle: "200",
                    onTap: () {},
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  BlocBuilder<DownloadSongsBloc, DownloadSongsState>(
                    builder: (context, state) {
                      return MyButton(
                        backgroundColor: Colors.grey,
                        backgroundIconColor: Colors.orangeAccent,
                        icon: FontAwesomeIcons.compactDisc,
                        title: "Bài hát đã tải",
                        subTitle: "${state.downloadSongs.length}",
                        onTap: () async {
                          int index =
                              await Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const DownloadSongScreen();
                            },
                          ));
                          widget.callback(index);
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  MyButton(
                    backgroundColor: Colors.grey,
                    backgroundIconColor: Colors.pinkAccent,
                    icon: FontAwesomeIcons.music,
                    title: "Playlist",
                    subTitle: "14",
                    onTap: () {},
                  ),
                ],
              )),
          const SizedBox(
            height: 30,
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Playlist",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            String textFieldValue = '';
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: const Text('Tạo Playlist mới'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            textFieldValue = value;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Nhập tên Playlist',
                                          filled: true,
                                          fillColor: const Color.fromARGB(
                                              255, 84, 4, 154),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      ElevatedButton(
                                        onPressed: textFieldValue.isNotEmpty
                                            ? () {
                                                final playlist = Playlist(
                                                    id: Random().nextInt(9999),
                                                    name: textFieldValue,
                                                    image:
                                                        "https://www.listenspotify.com/uploaded_files/Thf_1616456968.jpg",
                                                    author: null);
                                                Navigator.pop(context);
                                                BlocProvider.of<PlaylistCubit>(
                                                        context)
                                                    .createPlaylist(playlist);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailPlaylist(
                                                              playlist:
                                                                  playlist),
                                                    ));
                                              }
                                            : null,
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                            const Color(0xff9b4de0), // Màu nền
                                          ),
                                          shape: MaterialStateProperty.all<
                                              OutlinedBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      30.0), // Độ cong border
                                            ),
                                          ),
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15),
                                          child: const Text(
                                            'Tạo mới',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Container(
                          height: 50,
                          width: 50,
                          margin: const EdgeInsets.only(left: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.purpleAccent),
                          child: const Icon(FontAwesomeIcons.plus)),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      "Tạo Playlist",
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
                BlocBuilder<PlaylistCubit, List<Playlist>>(
                  builder: (context, state) {
                    return Column(
                      children: List.generate(
                          state.length,
                          (index) => InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPlaylist(
                                        playlist: state[index],
                                      ),
                                    ));
                              },
                              child: PlayListItem(playlist: state[index]))),
                    );
                  },
                ),
                const SizedBox(height: 70)
              ],
            ),
          ))
        ],
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  final Color backgroundColor;
  final Color backgroundIconColor;
  final IconData icon;
  final String title;
  final String subTitle;
  final Function()? onTap;
  const MyButton(
      {super.key,
      required this.backgroundColor,
      required this.backgroundIconColor,
      required this.icon,
      required this.title,
      required this.subTitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.sizeOf(context).width * 0.4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            color: backgroundColor, borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyIconButton(
              backgroundColor: backgroundIconColor,
              iconSize: 40,
              size: 60,
              icon: icon,
              onTap: onTap,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              subTitle,
              style: const TextStyle(fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}
