import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/blocs/bloc/audio_player_bloc.dart';
import 'package:music_app/methods/shared_preference_method.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/widgets/cache_circle_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailSong extends StatefulWidget {
  final Song song;

  const DetailSong({
    super.key,
    required this.song,
  });

  @override
  State<DetailSong> createState() => _DetailSongState();
}

class _DetailSongState extends State<DetailSong> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 10),
    vsync: this,
  )..repeat(reverse: false);

  bool isRepeat = false;
  bool isRandom = false;
  String currentpostlabel = "00:00";

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
    getRandomSong();
    getRepeatSongList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void getRepeatSongList() async {
    bool repeat = await SharedPreferrenceMethod().getRepeatSongList();
    setState(() {
      isRepeat = repeat;
    });
  }

  void getRandomSong() async {
    bool random = await SharedPreferrenceMethod().getRandomSong();
    setState(() {
      isRandom = random;
    });
  }

  void initAudioPlayer() {
    final audioPlayerBloc = BlocProvider.of<AudioPlayerBloc>(context);
    audioPlayerBloc.add(PlayEvent(song: widget.song));
    audioPlayerBloc.add(GetMaxDurationEvent());
    audioPlayerBloc.add(GetPositioinChangeEvent());
  }

  String formatDuration(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayerBloc = BlocProvider.of<AudioPlayerBloc>(context);

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_downward_outlined)),
          title: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.song.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.song.artist,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ),
          actions: <Widget>[
            IconButton(
                onPressed: () {},
                icon: const Icon(FontAwesomeIcons.ellipsisVertical))
          ]),
      body: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        builder: (context, state) {
          return Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                children: [
                  Expanded(
                      child: Center(
                    child: RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                      child: CacheCircleImage(widget.song.imageSong, 150),
                    ),
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                FontAwesomeIcons.heart,
                                size: 36,
                              )),
                          if (widget.song.isDownloadInApp == null)
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  FontAwesomeIcons.circleDown,
                                  size: 36,
                                )),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                FontAwesomeIcons.clock,
                                size: 36,
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          Text(state.position < state.maxDuration
                              ? formatDuration(state.position)
                              : formatDuration(state.maxDuration)),
                          Expanded(
                            child: Slider(
                              value: state.position.inSeconds.toDouble() <
                                      state.maxDuration.inSeconds.toDouble()
                                  ? state.position.inSeconds.toDouble()
                                  : state.maxDuration.inSeconds.toDouble(),
                              max: state.maxDuration.inSeconds.toDouble(),
                              divisions: state.maxDuration.inSeconds.toInt(),
                              label: formatDuration(state.position),
                              onChanged: (double value) async {
                                final newPosition =
                                    Duration(seconds: value.toInt());
                                audioPlayerBloc
                                    .add(SeekEvent(position: newPosition));
                              },
                            ),
                          ),
                          Text(formatDuration(state.maxDuration)),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 100,
                            child: IconButton(
                              icon: Icon(
                                FontAwesomeIcons.shuffle,
                                size: 20,
                                color: isRandom ? Colors.deepPurple : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  isRandom = !isRandom;
                                });
                                SharedPreferrenceMethod()
                                    .setRandomSong(isRandom);
                              },
                            ),
                          ),
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: IconButton(
                              icon: const Icon(
                                FontAwesomeIcons.backwardStep,
                                size: 25,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: IconButton(
                              icon: Icon(
                                audioPlayerBloc.state.isPlaying
                                    ? FontAwesomeIcons.circlePause
                                    : FontAwesomeIcons.circlePlay,
                                size: 60,
                              ),
                              onPressed: () {
                                if (audioPlayerBloc.state.isPlaying) {
                                  // Bài hát đang phát, gửi sự kiện PauseEvent
                                  _controller.stop();
                                  audioPlayerBloc.add(PauseEvent());
                                } else {
                                  // Bài hát đang dừng, gửi sự kiện ResumeEvent
                                  _controller.repeat(reverse: false);
                                  audioPlayerBloc.add(ResumeEvent());
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: IconButton(
                              icon: const Icon(
                                FontAwesomeIcons.forwardStep,
                                size: 25,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          SizedBox(
                            height: 100,
                            child: IconButton(
                              icon: Icon(FontAwesomeIcons.repeat,
                                  size: 20,
                                  color: isRepeat ? Colors.deepPurple : null),
                              onPressed: () {
                                setState(() {
                                  isRepeat = !isRepeat;
                                });
                                SharedPreferrenceMethod()
                                    .setRepeatSongList(isRepeat);
                              },
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        "Lời bài hát",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: widget.song.lyrics != null
                            ? SingleChildScrollView(
                                child: Text(
                                widget.song.lyrics!,
                                style: const TextStyle(
                                    fontSize: 18, overflow: TextOverflow.clip),
                              ))
                            : const SizedBox(),
                      )
                    ],
                  ))
                ],
              ));
        },
      ),
    );
  }
}
