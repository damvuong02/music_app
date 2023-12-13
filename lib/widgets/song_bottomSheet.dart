import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/blocs/bloc/download_songs_bloc.dart';
import 'package:music_app/blocs/cubit/playlist_song_cubit.dart';
import 'package:music_app/blocs/repositories/audio_handler_repository.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/widgets/playlist_item.dart';
import 'package:ringtone_set/ringtone_set.dart';

import '../database/database_helper.dart';
import '../models/playlist.dart';
import '../models/playlist_link_song.dart';

class SongBottomSheet extends StatefulWidget {
  final Song song;
  final String typeBottomsheet;
  final int? playlistId;
  const SongBottomSheet(
      {super.key,
      required this.song,
      required this.typeBottomsheet,
      this.playlistId});

  @override
  State<SongBottomSheet> createState() => _SongBottomSheetState();
}

class _SongBottomSheetState extends State<SongBottomSheet> {
  Widget builditemOption(IconData icon, String title, String type) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () async {
        final audioHandler = context.read<AudioHandleRepository>().audioHandler;
        switch (type) {
          case "like":
            print("like");
            break;
          case "playlist":
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Chọn 1 Playlist"),
                  content: ListPlayList(songId: widget.song.id),
                );
              },
            );
            break;
          case "delete":
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Xác nhận xóa"),
                  content: const Text("Bạn có chắc chắn muốn xóa bài hát này?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Đóng AlertDialog
                      },
                      child: const Text("Hủy"),
                    ),
                    TextButton(
                      onPressed: () {
                        BlocProvider.of<DownloadSongsBloc>(context)
                            .add(DeleteDownLoadSongs(widget.song.id));
                        // nếu đang phát playlist download mà xóa bài hát download thì loại bỏ trong mediaLybrary
                        if (context
                                .read<AudioHandleRepository>()
                                .currentPlayingPlaylist ==
                            "download") {
                          audioHandler
                              .removeQueueItem(widget.song.toMediaItem());
                        }
                        Navigator.of(context)
                          ..pop()
                          ..pop();
                      },
                      child: const Text("Xóa"),
                    ),
                  ],
                );
              },
            );

            break;
          case "kill":
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Xác nhận xóa"),
                  content: const Text(
                      "Bạn có chắc chắn muốn xóa vĩnh viễn bài hát khỏi thiết bị?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Đóng AlertDialog
                      },
                      child: const Text("Hủy"),
                    ),
                    TextButton(
                      onPressed: () {
                        BlocProvider.of<DownloadSongsBloc>(context)
                            .add(KillDownLoadSongs(widget.song.id));
                        // nếu đang phát playlist download mà xóa bài hát download thì loại bỏ trong mediaLybrary
                        if (context
                                .read<AudioHandleRepository>()
                                .currentPlayingPlaylist ==
                            "download") {
                          audioHandler
                              .removeQueueItem(widget.song.toMediaItem());
                        }
                        Navigator.of(context)
                          ..pop()
                          ..pop();
                      },
                      child: const Text("Xóa"),
                    ),
                  ],
                );
              },
            );

            break;
          case "download":
            BlocProvider.of<DownloadSongsBloc>(context)
                .add(DownloadSong(song: widget.song, context: context));

            Navigator.pop(context);
            break;
          case "playlist-delete":
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Xác nhận xóa"),
                  content: const Text("Bạn có chắc chắn muốn xóa bài hát này?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Đóng AlertDialog
                      },
                      child: const Text("Hủy"),
                    ),
                    TextButton(
                      onPressed: () {
                        BlocProvider.of<PlaylistSongCubit>(context)
                            .deleteSongInPlaylist(
                                widget.song, widget.playlistId!);

                        // nếu đang phát playlist mà xóa bài hát thì loại bỏ trong mediaLybrary
                        if (context
                                .read<AudioHandleRepository>()
                                .currentPlayingPlaylist ==
                            "playlist_${widget.playlistId}") {
                          audioHandler
                              .removeQueueItem(widget.song.toMediaItem());
                        }
                        Navigator.of(context)
                          ..pop()
                          ..pop();
                      },
                      child: const Text("Xóa"),
                    ),
                  ],
                );
              },
            );
            break;
          case "set-ringtone":
            final File ringtoneFile = File(widget.song.link);
            bool result = await RingtoneSet.setRingtoneFromFile(ringtoneFile);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result
                    ? 'Đã đặt bài hát thành nhạc chuông'
                    : 'Không thể đặt bài hát thành nhạc chuông'),
                duration: const Duration(seconds: 2),
              ),
            );
            Navigator.pop(context);
        }
      },
    );
  }

  Widget buildOptionList() {
    return Column(
      children: [
        builditemOption(
            FontAwesomeIcons.heart, "Thêm vào mục yêu thích", "like"),
        if (widget.typeBottomsheet == 'download')
          builditemOption(
              FontAwesomeIcons.plus, "Thêm vào playlist", "playlist"),
        if (widget.typeBottomsheet == 'download')
          builditemOption(FontAwesomeIcons.eraser, "Xóa khỏi app", "delete"),
        if (widget.typeBottomsheet == 'download')
          builditemOption(
              FontAwesomeIcons.trash, "Xóa file trên thiết bị", "kill"),
        if (widget.typeBottomsheet == 'download' && Platform.isAndroid)
          builditemOption(Icons.ring_volume_outlined, "Đặt làm nhạc chuông",
              "set-ringtone"),
        if (widget.typeBottomsheet == 'playlist')
          builditemOption(
              FontAwesomeIcons.eraser, "Xóa khỏi playlist", "playlist-delete"),
        if (widget.typeBottomsheet == 'online')
          builditemOption(
              FontAwesomeIcons.circleArrowDown, "Tải về", "download"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
            child: CachedNetworkImage(imageUrl: widget.song.imageSong),
          ),
          title: Text(widget.song.title),
          subtitle: Text(widget.song.artist),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(
            thickness: 1,
          ),
        ),
        SingleChildScrollView(child: buildOptionList())
      ]),
    );
  }
}

class ListPlayList extends StatefulWidget {
  final int songId;
  const ListPlayList({super.key, required this.songId});

  @override
  State<ListPlayList> createState() => _ListPlayListState();
}

class _ListPlayListState extends State<ListPlayList> {
  List<Playlist> playlists = [];
  void getPlaylists() async {
    var list = await DatabaseHelper().getAllPlaylists();
    setState(() {
      playlists = list;
    });
  }

  @override
  void initState() {
    super.initState();
    getPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.5,
      width: MediaQuery.sizeOf(context).width * 2 / 3,
      child: ListView.builder(
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () async {
              bool isExistInPlaylist = await DatabaseHelper()
                  .isSongInPlaylist(widget.songId, playlists[index].id);
              if (!isExistInPlaylist) {
                DatabaseHelper().insertPlaylistSongRelation(
                    PlaylistSongRelation(
                        playlistId: playlists[index].id,
                        songId: widget.songId));

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã thêm bài hát vào Playlist'),
                    duration:
                        Duration(seconds: 2), // Thời gian hiển thị của snackbar
                  ),
                );
                Navigator.of(context)
                  ..pop()
                  ..pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bài hát đã tồn tại trong Playlist'),
                    duration:
                        Duration(seconds: 2), // Thời gian hiển thị của snackbar
                  ),
                );
                Navigator.of(context)
                  ..pop()
                  ..pop();
              }
            },
            child: PlayListItem(playlist: playlists[index]),
          );
        },
      ),
    );
  }
}
