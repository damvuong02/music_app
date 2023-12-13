import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/database/database_helper.dart';
import 'package:music_app/models/playlist_link_song.dart';
import '../blocs/cubit/playlist_cubit.dart';
import '../blocs/cubit/playlist_song_cubit.dart';
import '../blocs/repositories/audio_handler_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../widgets/search_bar.dart';
import '../widgets/song_item.dart';

class PlaylistAddSong extends StatefulWidget {
  final int idPlayist;
  const PlaylistAddSong({super.key, required this.idPlayist});

  @override
  State<PlaylistAddSong> createState() => _PlaylistAddSongState();
}

class _PlaylistAddSongState extends State<PlaylistAddSong> {
  final TextEditingController searchBar = TextEditingController();
  List<Song> listSongs = [];
  List<Song> allSongs = [];
  List<Song> playlistSongs = [];
  List<Song>? selectedListSongs;
  String? newPlaylistImage;
  searchFunction(String value) async {
    var list = await DatabaseHelper().getSongsByTitle(value.trim());
    setState(() {
      listSongs = list;
    });
  }

  void clearSearchFunction() {
    setState(() {
      listSongs = allSongs;
    });
  }

  getDownloadSong() async {
    var list = await DatabaseHelper().getAllSongs();
    setState(() {
      listSongs = list;
      allSongs = list;
    });
  }

  void getPlayListSongs() async {
    List<Song> tempSongs =
        await DatabaseHelper().getSongsInPlaylist(widget.idPlayist);
    setState(() {
      playlistSongs = tempSongs;
    });
  }

  @override
  void initState() {
    super.initState();
    getDownloadSong();
    getPlayListSongs();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, newPlaylistImage);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(FontAwesomeIcons.x),
            onPressed: () {
              Navigator.pop(context, newPlaylistImage);
            },
          ),
          title: const Text("Thêm bài hát"),
        ),
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: MySearchBar(
                      controller: searchBar,
                      searchFunction: searchFunction,
                      suffixFunction: clearSearchFunction,
                    ),
                  ),
                  Column(
                      children: List.generate(listSongs.length, (index) {
                    Song song = listSongs[index];
                    bool isInPlaylist = false;
                    for (var playlistSong in playlistSongs) {
                      if (playlistSong.id == song.id) {
                        isInPlaylist = true;
                      }
                    }
                    return SongWidget(
                      actionButton: isInPlaylist
                          ? const Icon(
                              Icons.check,
                            )
                          : IconButton(
                              onPressed: () async {
                                setState(() {
                                  playlistSongs.add(song);
                                });

                                BlocProvider.of<PlaylistSongCubit>(context)
                                    .addSongtoPlaylist(song, widget.idPlayist);

                                if (context
                                        .read<AudioHandleRepository>()
                                        .currentPlayingPlaylist ==
                                    "playlist_${widget.idPlayist}") {
                                  context
                                      .read<AudioHandleRepository>()
                                      .audioHandler
                                      .addQueueItem(song.toMediaItem());
                                }
                                if (playlistSongs.length == 1) {
                                  Playlist playlist = await DatabaseHelper()
                                      .getPlaylistById(widget.idPlayist);
                                  BlocProvider.of<PlaylistCubit>(context)
                                      .updatePlaylist(playlist.copyWith(
                                          image: song.imageSong));
                                  newPlaylistImage = song.imageSong;
                                }
                              },
                              icon: const Icon(
                                Icons.add_circle_outline,
                              ),
                            ),
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
            )),
      ),
    );
  }
}
