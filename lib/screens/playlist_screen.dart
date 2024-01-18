import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/audio_handel.dart';
import 'package:music_app/blocs/repositories/audio_handler_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/methods/shared_preference_method.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/utilities/consoleLog.dart';
import 'package:music_app/widgets/seek_bar.dart';
import 'package:music_app/widgets/song_item.dart';
import 'package:rxdart/rxdart.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  late AudioPlayerHandler _audioHandler;
  bool isMultipleSelect = false;
  List<MediaItem> selectedList = [];
  bool? isSelectAll;
  void initAudioHandler() {
    _audioHandler = context.read<AudioHandleRepository>().audioHandler;
  }

  @override
  void initState() {
    super.initState();
    initAudioHandler();
  }

  Stream<Duration> get _bufferedPositionStream => _audioHandler.playbackState
      .map((state) => state.bufferedPosition)
      .distinct();
  Stream<Duration?> get _durationStream =>
      _audioHandler.mediaItem.map((item) => item?.duration).distinct();
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          AudioService.position,
          _bufferedPositionStream,
          _durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(FontAwesomeIcons.x)),
        title: StreamBuilder<QueueState>(
            stream: _audioHandler.queueState,
            builder: (context, snapshot) {
              final queueState = snapshot.data ?? QueueState.empty;
              final queue = queueState.queue;

              return isMultipleSelect
                  ? Row(
                      children: [
                        Checkbox(
                          value: isSelectAll ?? false,
                          onChanged: (value) {
                            setState(() {
                              isSelectAll = value;
                            });
                            if (value == true) {
                              setState(() {
                                selectedList = [...queue];
                              });
                            } else {
                              setState(() {
                                selectedList = [];
                              });
                            }
                          },
                        ),
                        Text("Bài hát (${selectedList.length})")
                      ],
                    )
                  : Text("Danh sách phát (${queue.length})");
            }),
        actions: <Widget>[
          isMultipleSelect
              ? TextButton(
                  onPressed: () {
                    setState(() {
                      selectedList = [];
                    });
                  },
                  child: const Text("Bỏ chọn"))
              : IconButton(
                  onPressed: () {},
                  icon: const Icon(FontAwesomeIcons.ellipsisVertical))
        ],
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          int sensitivity = 4;
          if (details.delta.dx < -sensitivity) {
            //Left Swipe
            Navigator.pop(context);
          }
        },
        child: SafeArea(
          child: StreamBuilder<QueueState>(
            stream: _audioHandler.queueState,
            builder: (context, snapshot) {
              final queueState = snapshot.data ?? QueueState.empty;
              final queue = queueState.queue;
              return ReorderableListView(
                buildDefaultDragHandles: false,
                onReorder: (int oldIndex, int newIndex) {
                  if (oldIndex < newIndex) newIndex--;
                  _audioHandler.moveQueueItem(oldIndex, newIndex);
                },
                children: [
                  for (var i = 0; i < queue.length; i++)
                    GestureDetector(
                      key: ValueKey(queue[i].id),
                      onTap: () => _audioHandler.skipToQueueItem(i),
                      onLongPress: () {
                        setState(() {
                          isMultipleSelect = true;
                          selectedList.add(queue[i]);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        color: i == queueState.queueIndex
                            ? Colors.purpleAccent
                            : null,
                        child: SongWidget(
                          song: Song(
                            id: i,
                            title: queue[i].title,
                            link: queue[i].id,
                            imageSong: queue[i].artUri.toString(),
                          ),
                          leading: isMultipleSelect
                              ? Checkbox(
                                  value: selectedList.contains(queue[i]),
                                  onChanged: (value) {
                                    setState(() {
                                      if (selectedList.contains(queue[i])) {
                                        selectedList.remove(queue[i]);
                                      } else {
                                        selectedList.add(queue[i]);
                                      }
                                    });
                                  },
                                )
                              : null,
                          actionButton: ReorderableDragStartListener(
                            index: i,
                            child: const Icon(FontAwesomeIcons.bars),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: isMultipleSelect
          ? InkWell(
              onTap: () async {
                setState(() {
                  isSelectAll = false;
                });
                List<MediaItem> tempList = [...selectedList];
               
                for (var element in tempList) {
                  await _audioHandler.removeQueueItem(element);
                  setState(() {
                    selectedList.remove(element);
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.orangeAccent.shade400,
                    borderRadius: BorderRadius.circular(15)),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FontAwesomeIcons.trash,
                      color: Colors.red,
                    ),
                    Text("Xóa khỏi danh sách phát")
                  ],
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // A seek bar.
                StreamBuilder<PositionData>(
                  stream: _positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data ??
                        PositionData(
                            Duration.zero, Duration.zero, Duration.zero);
                    return SeekBar(
                      duration: positionData.duration,
                      position: positionData.position,
                      onChangeEnd: (newPosition) {
                        _audioHandler.seek(newPosition);
                      },
                    );
                  },
                ),
                // Playback controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<QueueState>(
                        stream: _audioHandler.queueState,
                        builder: (context, snapshot) {
                          final queueState = snapshot.data ?? QueueState.empty;
                          return IconButton(
                            icon: const Icon(
                              FontAwesomeIcons.backwardStep,
                              size: 45,
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
                          if (processingState == AudioProcessingState.loading ||
                              processingState ==
                                  AudioProcessingState.buffering) {
                            return Container(
                              margin: const EdgeInsets.all(8.0),
                              width: 64.0,
                              height: 64.0,
                              child: const CircularProgressIndicator(),
                            );
                          } else if (playing != true) {
                            return IconButton(
                              icon: const Icon(FontAwesomeIcons.circlePlay),
                              iconSize: 64.0,
                              onPressed: () {
                                _audioHandler.play();
                              },
                            );
                          } else {
                            return IconButton(
                              icon: const Icon(FontAwesomeIcons.circlePause),
                              iconSize: 64.0,
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
                          final queueState = snapshot.data ?? QueueState.empty;
                          return IconButton(
                            icon: const Icon(
                              FontAwesomeIcons.forwardStep,
                              size: 45,
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
              ],
            ),
    );
  }
}
