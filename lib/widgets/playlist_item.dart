import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/models/playlist.dart';

class PlayListItem extends StatelessWidget {
  final Playlist playlist;
  const PlayListItem({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: playlist.image,
                placeholder: (context, url) => Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )),
          const SizedBox(
            width: 10,
          ),
          playlist.author == null
              ? Text(
                  playlist.name,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                )
              : Column(
                  children: [
                    Text(
                      playlist.name,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      playlist.author!,
                      style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .color!
                              .withOpacity(0.7)),
                    )
                  ],
                ),
        ],
      ),
    );
  }
}
