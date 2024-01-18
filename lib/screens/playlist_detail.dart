import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/database/database_helper.dart';
import 'package:music_app/models/playlist.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/screens/playlist_add_song.dart';
import 'package:music_app/utilities/consoleLog.dart';
import '../blocs/cubit/playlist_cubit.dart';
import '../blocs/cubit/playlist_song_cubit.dart';
import '../blocs/repositories/audio_handler_repository.dart';
import '../methods/shared_preference_method.dart';
import '../models/song.dart';
import '../widgets/search_bar.dart';
import '../widgets/song_item.dart';
import 'detail_song.dart';

class DetailPlaylist extends StatefulWidget {
  final Playlist playlist;
  const DetailPlaylist({super.key, required this.playlist});

  @override
  State<DetailPlaylist> createState() => _DetailPlaylistState();
}

class _DetailPlaylistState extends State<DetailPlaylist> {
  bool isUpdatedQueue = false;
  final TextEditingController searchBarController = TextEditingController();
  String playlistName = '';
  String playlistImage = '';
  void getPlayListSongs() async {
    BlocProvider.of<PlaylistSongCubit>(context)
        .initPlaylistSongs(widget.playlist.id);
  }

  @override
  void initState() {
    setState(() {
      playlistName = widget.playlist.name;
      playlistImage = widget.playlist.image;
    });
    BlocProvider.of<PlaylistSongCubit>(context).clearPlayListSong();
    super.initState();
    getPlayListSongs();
  }

  Widget buildPlaylistBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(children: [
        ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(imageUrl: playlistImage),
          ),
          title: Text(playlistName),
          subtitle: Text(widget.playlist.author ?? ''),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(
            thickness: 1,
          ),
        ),
        SingleChildScrollView(
            child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text("Thêm bài hát"),
              onTap: () async {
                Navigator.pop(context);
                String? newPlaylistImage = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PlaylistAddSong(idPlayist: widget.playlist.id),
                    ));

                if (newPlaylistImage != null) {
                  setState(() {
                    playlistImage = newPlaylistImage;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(FontAwesomeIcons.penToSquare),
              title: const Text("Chỉnh sửa playlist"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    String textFieldValue = '';
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Chỉnh sửa playlist'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                initialValue: playlistName,
                                onChanged: (value) {
                                  setState(() {
                                    textFieldValue = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Nhập tên Playlist',
                                  filled: true,
                                  fillColor:
                                      const Color.fromARGB(255, 84, 4, 154),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              ElevatedButton(
                                onPressed: (textFieldValue ==
                                            widget.playlist.name ||
                                        textFieldValue.isEmpty)
                                    ? null
                                    : () {
                                        Navigator.of(context)
                                          ..pop()
                                          ..pop(textFieldValue);
                                        BlocProvider.of<PlaylistCubit>(context)
                                            .updatePlaylist(widget.playlist
                                                .copyWith(
                                                    name: textFieldValue));
                                      },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    const Color(0xff9b4de0), // Màu nền
                                  ),
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          30.0), // Độ cong border
                                    ),
                                  ),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  child: const Text(
                                    'Cập nhật',
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
            ),
            ListTile(
              leading: const Icon(FontAwesomeIcons.trash),
              title: const Text("Xóa playlist"),
              onTap: () {
                Navigator.of(context)
                  ..pop()
                  ..pop();
                BlocProvider.of<PlaylistCubit>(context)
                    .deletePlaylist(widget.playlist);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text("Chia sẻ"),
              onTap: () {},
            ),
          ],
        ))
      ]),
    );
  }

  void searchFunction(String title) {
    BlocProvider.of<PlaylistSongCubit>(context)
        .searchSongInPlaylist(widget.playlist.id, title);
  }

  void suffixFunction() {
    BlocProvider.of<PlaylistSongCubit>(context).clearPlayListSong();
    BlocProvider.of<PlaylistSongCubit>(context)
        .initPlaylistSongs(widget.playlist.id);
  }

  @override
  Widget build(BuildContext context) {
    final _audioHandler = context.read<AudioHandleRepository>().audioHandler;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        title: MySearchBar(
          searchFunction: searchFunction,
          controller: searchBarController,
          suffixFunction: suffixFunction,
        ),
        actions: [
          IconButton(
              onPressed: () async {
                String? newPlaylistName = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: true,
                  builder: (context) {
                    return buildPlaylistBottomSheet();
                  },
                );
                if (newPlaylistName != null) {
                  setState(() {
                    playlistName = newPlaylistName;
                  });
                }
              },
              icon: const Icon(FontAwesomeIcons.ellipsisVertical)),
        ],
      ),
      body: BlocBuilder<PlaylistSongCubit, List<Song>>(
        builder: (context, state) {
          return SizedBox(
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 2 / 3,
                        child: CachedNetworkImage(
                          imageUrl: playlistImage,
                          placeholder: (context, url) => Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          playlistName,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.isEmpty
                                ? "Chưa có bài hát nào"
                                : "${state.length} bài hát"),
                            if (widget.playlist.author != null)
                              Text("bởi ${widget.playlist.author}")
                          ],
                        ),
                      ),
                      state.isEmpty
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PlaylistAddSong(
                                                    idPlayist:
                                                        widget.playlist.id),
                                          ));
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                        ),
                                      ),
                                      padding: MaterialStateProperty.all<
                                          EdgeInsetsGeometry>(
                                        const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 10),
                                      ),
                                    ),
                                    child: const Text(
                                      "THÊM BÀI",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 24),
                                    ))
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Flexible(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {},
                                      child: const Column(
                                        children: [
                                          Icon(
                                            Icons.share_rounded,
                                            size: 30,
                                          ),
                                          Text("Chia sẻ")
                                        ],
                                      ),
                                    )),
                                Flexible(
                                  flex: 4,
                                  child: InkWell(
                                    onTap: () async {
                                      context
                                          .read<AudioHandleRepository>()
                                          .setCurrentPlayingPlaylist(
                                              "playlist_${widget.playlist.id}");
                                      if (!isUpdatedQueue) {
                                        await _audioHandler.updateQueue(state
                                            .map((song) => song.toMediaItem())
                                            .toList());
                                      }
                                      await _audioHandler.setShuffleMode(
                                          AudioServiceShuffleMode.all);
                                      SharedPreferrenceMethod()
                                          .setRandomSong(true);
                                      Random random = Random();
                                      int index = random.nextInt(state.length);
                                      await _audioHandler
                                          .skipToQueueItem(index);
                                      Navigator.of(context)
                                          .push(_createRoute(DetailSong()));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      decoration: BoxDecoration(
                                          color: const Color(0xffA637DA),
                                          borderRadius:
                                              BorderRadius.circular(20)),
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
                                Flexible(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PlaylistAddSong(
                                                      idPlayist:
                                                          widget.playlist.id),
                                            ));
                                      },
                                      child: const Column(
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline,
                                            size: 30,
                                          ),
                                          Text("Thêm bài")
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                    ],
                  ),
                  Column(
                      children: List.generate(state.length, (index) {
                    Song song = state[index];
                    return InkWell(
                      onTap: () async {
                        context
                            .read<AudioHandleRepository>()
                            .setCurrentPlayingPlaylist(
                                "playlist_${widget.playlist.id}");
                        if (!isUpdatedQueue) {
                          await _audioHandler.updateQueue(
                              state.map((song) => song.toMediaItem()).toList());
                        }

                        await _audioHandler.skipToQueueItem(index);
                        Navigator.of(context).push(_createRoute(DetailSong()));
                      },
                      child: SongWidget(
                        isFavouriteSong: false,
                        typeofBottomSheet: 'playlist',
                        playlistId: widget.playlist.id,
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
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    searchBarController.dispose();
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
