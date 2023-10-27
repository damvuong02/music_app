import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CacheCircleImage extends StatelessWidget {
  final String imageSongUrl;
  final double? radius;
  const CacheCircleImage(this.imageSongUrl, this.radius);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageSongUrl,
      placeholder: (context, url) => CircleAvatar(
        backgroundColor: Colors.grey,
        radius: radius,
      ),
      imageBuilder: (context, image) => CircleAvatar(
        backgroundImage: image,
        radius: radius,
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
