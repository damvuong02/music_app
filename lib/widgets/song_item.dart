import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/widgets/song_bottomSheet.dart';

class SongWidget extends StatelessWidget {
  final String? topTitle;
  final Color? topTitleColor;
  final bool isFavouriteSong;
  final Song song;
  final Widget? actionButton;
  final Widget? modalBottomSheet;
  final String? typeofBottomSheet;
  final int? playlistId;

  const SongWidget(
      {super.key,
      this.topTitle,
      this.topTitleColor,
      this.isFavouriteSong = false,
      required this.song,
      this.actionButton,
      this.modalBottomSheet,
      this.typeofBottomSheet,
      this.playlistId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          if (topTitle != null)
            Text(
              topTitle!,
              style: TextStyle(
                  color: topTitleColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
          const SizedBox(
            width: 10,
          ),
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: song.imageSong,
                placeholder: (context, url) => Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                imageBuilder: (context, imageProvider) {
                  return Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover)),
                  );
                },
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )),
          const SizedBox(
            width: 10,
          ),
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: const TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    if (song.isDownloadInApp != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: FaIcon(
                          song.isDownloadInApp == true
                              ? FontAwesomeIcons.circleDown
                              : FontAwesomeIcons.mobile,
                          size: 16,
                        ),
                      ),
                    Text(
                      song.artist,
                      style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .color!
                              .withOpacity(0.7)),
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isFavouriteSong == true)
                  IconButton(
                      onPressed: () {},
                      icon: const FaIcon(
                        FontAwesomeIcons.solidHeart,
                        color: Colors.red,
                      )),
                actionButton != null
                    ? actionButton!
                    : IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            isDismissible: true,
                            builder: (context) => modalBottomSheet != null
                                ? modalBottomSheet!
                                : SongBottomSheet(
                                    song: song,
                                    typeBottomsheet:
                                        typeofBottomSheet ?? 'online',
                                    playlistId: playlistId,
                                  ),
                          );
                        },
                        icon: const FaIcon(FontAwesomeIcons.ellipsisVertical)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
