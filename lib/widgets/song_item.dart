import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/screens/detail_song.dart';
import 'package:music_app/widgets/song_bottomSheet.dart';

class SongWidget extends StatelessWidget {
  final String? topTitle;
  final Color? topTitleColor;
  final bool isFavouriteSong;
  final Song song;

  const SongWidget({
    super.key,
    this.topTitle,
    this.topTitleColor,
    required this.isFavouriteSong,
    required this.song,
  });

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
            child: Image.network(
              song.imageSong,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child; // Return the image if it's loaded successfully
                }
                return CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                );
              },
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                // Catch network image loading failure and display a fallback AssetImage
                return Image.asset(
                  "assets/images/meow.jpg",
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
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
                IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        builder: (context) => SongBottomSheet(
                          song: song,
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
