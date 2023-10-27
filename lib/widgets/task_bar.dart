import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/blocs/bloc/audio_player_bloc.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/screens/detail_song.dart';
import 'package:music_app/widgets/cache_circle_image.dart';

class TaskBar extends StatelessWidget {
  const TaskBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final audioPlayerBloc = BlocProvider.of<AudioPlayerBloc>(context);
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        return Column(
          children: [
            Container(
              height: 70,
              color: Colors.black,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                            child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailSong(
                                    song: state.currentSong,
                                  ),
                                ));
                          },
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 15,
                              ),
                              CacheCircleImage(state.currentSong.imageSong, 25),
                              const SizedBox(
                                width: 15,
                              ),
                              SizedBox(
                                width: 180,
                                child: Text(
                                  state.currentSong.title,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )),
                        IconButton(
                          icon: const Icon(
                            FontAwesomeIcons.backwardStep,
                            size: 30,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(
                            state.isPlaying
                                ? FontAwesomeIcons.circlePause
                                : FontAwesomeIcons.circlePlay,
                            size: 30,
                          ),
                          onPressed: () {
                            if (state.isPlaying) {
                              // Bài hát đang phát, gửi sự kiện PauseEvent
                              audioPlayerBloc.add(PauseEvent());
                            } else {
                              if (state.position.inSeconds == 0) {
                                audioPlayerBloc
                                    .add(PlayEvent(song: state.currentSong));
                                audioPlayerBloc.add(GetMaxDurationEvent());
                                audioPlayerBloc.add(GetPositioinChangeEvent());
                              }
                              audioPlayerBloc.add(ResumeEvent());
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            FontAwesomeIcons.forwardStep,
                            size: 30,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  LinearProgressIndicator(
                    value: state.position.inSeconds.toDouble() <
                            state.maxDuration.inSeconds.toDouble()
                        ? state.position.inSeconds.toDouble() /
                            state.maxDuration.inSeconds.toDouble()
                        : 1,
                    valueColor: AlwaysStoppedAnimation(Colors.blue.shade900),
                    backgroundColor: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
