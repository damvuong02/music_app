import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/blocs/bloc/download_songs_bloc.dart';
import 'package:music_app/blocs/repositories/audio_handler_repository.dart';
import 'package:music_app/models/song.dart';

class SongBottomSheet extends StatefulWidget {
  final Song song;
  const SongBottomSheet({super.key, required this.song});

  @override
  State<SongBottomSheet> createState() => _SongBottomSheetState();
}

class _SongBottomSheetState extends State<SongBottomSheet> {
  Widget builditemOption(IconData icon, String title, String type) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        final audioHandler = context.read<AudioHandleRepository>().audioHandler;
        switch (type) {
          case "like":
            print("like");
            break;
          case "playlist":
            print("add to playlist");
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
        }
      },
    );
  }

  Widget buildOptionList() {
    if (widget.song.isDownloadInApp != null) {
      return Column(
        children: [
          builditemOption(
              FontAwesomeIcons.heart, "Thêm vào mục yêu thích", "like"),
          builditemOption(
              FontAwesomeIcons.plus, "Thêm vào playlist", "playlist"),
          builditemOption(FontAwesomeIcons.eraser, "Xóa khỏi app", "delete"),
          builditemOption(
              FontAwesomeIcons.trash, "Xóa file trên thiết bị", "kill"),
        ],
      );
    }
    return Column(
      children: [
        builditemOption(
            FontAwesomeIcons.heart, "Thêm vào mục yêu thích", "like"),
        builditemOption(FontAwesomeIcons.circleArrowDown, "Tải về", "download"),
        builditemOption(FontAwesomeIcons.plus, "Thêm vào playlist", "playlist"),
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
            child: Image.network(
              widget.song.imageSong,
            ),
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
