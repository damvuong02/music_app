import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/blocs/bloc/download_songs_bloc.dart';
import 'package:music_app/methods/shared_preference_method.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/screens/downloadsong.dart';
import 'package:music_app/widgets/icon_button.dart';
import 'package:music_app/widgets/task_bar.dart';

class PersonPage extends StatefulWidget {
  final Function(int) callback;
  const PersonPage({super.key, required this.callback});

  @override
  State<PersonPage> createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  Song? currentSong;
  void getCurrentSong() async {
    Song? song = await SharedPreferrenceMethod().getCurrentSong();
    setState(() {
      currentSong = song;
    });
  }

  @override
  void initState() {
    getCurrentSong();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
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
                              int index = await Navigator.push(context,
                                  MaterialPageRoute(
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
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {},
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
                          width: 20,
                        ),
                        Text(
                          "Tạo Playlist",
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          height: 70,
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTFU7-eJHS1DerxF4CF-ioTXfCaFoqGalWGZ8k3HYA&s",
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child; // Return the image if it's loaded successfully
                                    }
                                    return CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    );
                                  },
                                  errorBuilder: (BuildContext context,
                                      Object exception,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Play list 1",
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Vuong",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .color!
                                                .withOpacity(0.7)),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ))
            ],
          ),
        ),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: currentSong != null ? const TaskBar() : const SizedBox())
      ],
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
