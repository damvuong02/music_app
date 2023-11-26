import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/screens/detail_song.dart';
import 'package:music_app/widgets/cache_circle_image.dart';

import '../audio_handel.dart';
import '../blocs/repositories/audio_handler_repository.dart';

class TaskBar extends StatelessWidget {
  const TaskBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final _audioHandler = context.read<AudioHandleRepository>().audioHandler;
    return StreamBuilder<MediaItem?>(
        stream: _audioHandler.mediaItem,
        builder: (context, snapshot) {
          final mediaItem = snapshot.data;
          if (mediaItem == null) return const SizedBox();
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
                                    builder: (context) => DetailSong(),
                                  ));
                            },
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                CacheCircleImage(
                                    mediaItem.artUri.toString(), 25),
                                const SizedBox(
                                  width: 15,
                                ),
                                SizedBox(
                                  width: 170,
                                  child: Text(
                                    mediaItem.title,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )),
                          StreamBuilder<QueueState>(
                            stream: _audioHandler.queueState,
                            builder: (context, snapshot) {
                              final queueState =
                                  snapshot.data ?? QueueState.empty;
                              return IconButton(
                                icon: const Icon(
                                  FontAwesomeIcons.backwardStep,
                                  size: 30,
                                ),
                                onPressed: queueState.hasPrevious
                                    ? _audioHandler.skipToPrevious
                                    : null,
                              );
                            },
                          ),
                          StreamBuilder<PlaybackState>(
                            stream: _audioHandler.playbackState,
                            builder: (context, snapshot) {
                              final playbackState = snapshot.data;
                              final processingState =
                                  playbackState?.processingState;
                              final playing = playbackState?.playing;
                              if (processingState ==
                                      AudioProcessingState.loading ||
                                  processingState ==
                                      AudioProcessingState.buffering) {
                                return Container(
                                  margin: const EdgeInsets.all(8.0),
                                  width: 44.0,
                                  height: 44.0,
                                  child: const CircularProgressIndicator(),
                                );
                              } else if (playing != true) {
                                return IconButton(
                                  icon: const Icon(FontAwesomeIcons.circlePlay),
                                  iconSize: 44.0,
                                  onPressed: () {
                                    _audioHandler.play();
                                  },
                                );
                              } else {
                                return IconButton(
                                  icon:
                                      const Icon(FontAwesomeIcons.circlePause),
                                  iconSize: 44.0,
                                  onPressed: () {
                                    _audioHandler.pause();
                                  },
                                );
                              }
                            },
                          ),
                          StreamBuilder<QueueState>(
                            stream: _audioHandler.queueState,
                            builder: (context, snapshot) {
                              final queueState =
                                  snapshot.data ?? QueueState.empty;
                              return IconButton(
                                icon: const Icon(
                                  FontAwesomeIcons.forwardStep,
                                  size: 30,
                                ),
                                onPressed: queueState.hasNext
                                    ? _audioHandler.skipToNext
                                    : null,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder<Duration>(
                      stream: AudioService.position,
                      builder: (context, snapshot) {
                        final duration = snapshot.data ?? Duration.zero;
                        return LinearProgressIndicator(
                          value: duration.inSeconds /
                              mediaItem.duration!.inSeconds,
                          valueColor:
                              AlwaysStoppedAnimation(Colors.blue.shade900),
                          backgroundColor: Colors.grey,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
