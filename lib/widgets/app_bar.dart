import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:music_app/widgets/search_bar.dart';

class MyAppBar extends StatelessWidget {
  final TextEditingController controller;
  final Function searchFunction;
  final String? avatarUrl;
  const MyAppBar(
      {super.key,
      required this.controller,
      required this.searchFunction,
      required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Row(
        children: [
          if (avatarUrl != null)
            CachedNetworkImage(
              imageUrl: avatarUrl!,
              placeholder: (context, url) => const CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 20,
              ),
              imageBuilder: (context, image) => CircleAvatar(
                backgroundImage: image,
                radius: 20,
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          const SizedBox(
            width: 30,
          ),
          Expanded(
              child: MySearchBar(
            controller: controller,
            searchFunction: searchFunction,
          )),
          const SizedBox(
            width: 30,
          ),
        ],
      ),
    );
  }
}
