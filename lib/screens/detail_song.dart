import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/audio_handel.dart';
import 'package:music_app/blocs/repositories/audio_handler_repository.dart';
import 'package:music_app/methods/shared_preference_method.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/utilities/consoleLog.dart';
import 'package:music_app/widgets/cache_circle_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/widgets/seek_bar.dart';
import 'package:rxdart/rxdart.dart';

class DetailSong extends StatefulWidget {
  @override
  State<DetailSong> createState() => _DetailSongState();
}

class _DetailSongState extends State<DetailSong> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 10),
    vsync: this,
  )..repeat(reverse: false);

  String currentpostlabel = "00:00";
  late AudioPlayerHandler _audioHandler;

  void initAudioHandler() {
    _audioHandler = context.read<AudioHandleRepository>().audioHandler;
    _audioHandler.play();
  }

  @override
  void initState() {
    super.initState();
    initAudioHandler();
    initRandomSong();
    initRepeatSongList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void initRepeatSongList() async {
    int repeat = await SharedPreferrenceMethod().getRepeatSongList();
    if (repeat == 0) {
      _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
    } else if (repeat == 1) {
      _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
    } else {
      _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
    }
  }

  void initRandomSong() async {
    bool random = await SharedPreferrenceMethod().getRandomSong();
    await _audioHandler.setShuffleMode(
        random ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none);
  }

  String formatDuration(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
            icon: const Icon(Icons.arrow_downward_outlined)),
        title: StreamBuilder<MediaItem?>(
            stream: _audioHandler.mediaItem,
            builder: (context, snapshot) {
              final mediaItem = snapshot.data;
              if (mediaItem == null) return const SizedBox();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mediaItem.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    mediaItem.artist ?? "Unknow Artist",
                    style: const TextStyle(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              );
            }),
        actions: <Widget>[
          IconButton(
              onPressed: () {},
              icon: const Icon(FontAwesomeIcons.ellipsisVertical))
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // MediaItem display
            Expanded(
              child: StreamBuilder<MediaItem?>(
                stream: _audioHandler.mediaItem,
                builder: (context, snapshot) {
                  final mediaItem = snapshot.data;
                  if (mediaItem == null) return const SizedBox();
                  SharedPreferrenceMethod().setCurrentSong(Song(
                      id: 0,
                      title: mediaItem.title,
                      link: mediaItem.id,
                      album: mediaItem.album,
                      artist: mediaItem.artist,
                      duration: mediaItem.duration,
                      imageSong: mediaItem.artUri.toString()));
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (mediaItem.artUri != null)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: RotationTransition(
                                turns: Tween(begin: 0.0, end: 1.0)
                                    .animate(_controller),
                                child: CacheCircleImage(
                                    mediaItem.artUri!.toString(), 150),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            // A seek bar.
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data ??
                    PositionData(Duration.zero, Duration.zero, Duration.zero);
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
                  StreamBuilder<AudioServiceRepeatMode>(
                    stream: _audioHandler.playbackState
                        .map((state) => state.repeatMode)
                        .distinct(),
                    builder: (context, snapshot) {
                      final repeatMode =
                          snapshot.data ?? AudioServiceRepeatMode.none;
                      const icons = [
                        Icon(
                          FontAwesomeIcons.repeat,
                          color: Colors.grey,
                          size: 38,
                        ),
                        Icon(
                          FontAwesomeIcons.repeat,
                          color: Colors.orange,
                          size: 38,
                        ),
                        Icon(
                          Icons.repeat_one,
                          color: Colors.orange,
                          size: 45,
                        ),
                      ];
                      const cycleModes = [
                        AudioServiceRepeatMode.none,
                        AudioServiceRepeatMode.all,
                        AudioServiceRepeatMode.one,
                      ];
                      final index = cycleModes.indexOf(repeatMode);
                      return IconButton(
                        icon: icons[index],
                        onPressed: () {
                          _audioHandler.setRepeatMode(cycleModes[
                              (cycleModes.indexOf(repeatMode) + 1) %
                                  cycleModes.length]);
                          SharedPreferrenceMethod().setRepeatSongList(
                              (cycleModes.indexOf(repeatMode) + 1) %
                                  cycleModes.length);
                        },
                      );
                    },
                  ),
                  const Expanded(child: SizedBox()),
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
                      final processingState = playbackState?.processingState;
                      final playing = playbackState?.playing;
                      if (processingState == AudioProcessingState.loading ||
                          processingState == AudioProcessingState.buffering) {
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
                            _controller.repeat(reverse: false);
                          },
                        );
                      } else {
                        return IconButton(
                          icon: const Icon(FontAwesomeIcons.circlePause),
                          iconSize: 64.0,
                          onPressed: () {
                            _audioHandler.pause();
                            _controller.stop();
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
                  const Expanded(child: SizedBox()),
                  StreamBuilder<bool>(
                    stream: _audioHandler.playbackState
                        .map((state) =>
                            state.shuffleMode == AudioServiceShuffleMode.all)
                        .distinct(),
                    builder: (context, snapshot) {
                      final shuffleModeEnabled = snapshot.data ?? false;
                      return IconButton(
                        icon: shuffleModeEnabled
                            ? const Icon(
                                FontAwesomeIcons.shuffle,
                                color: Colors.orange,
                                size: 38,
                              )
                            : const Icon(
                                FontAwesomeIcons.shuffle,
                                color: Colors.grey,
                                size: 38,
                              ),
                        onPressed: () async {
                          final enable = !shuffleModeEnabled;
                          await _audioHandler.setShuffleMode(enable
                              ? AudioServiceShuffleMode.all
                              : AudioServiceShuffleMode.none);
                          SharedPreferrenceMethod()
                              .setRandomSong(enable ? true : false);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            // Repeat/shuffle controls

            // Playlist
            SizedBox(
              height: 240.0,
              child: StreamBuilder<QueueState>(
                stream: _audioHandler.queueState,
                builder: (context, snapshot) {
                  final queueState = snapshot.data ?? QueueState.empty;
                  final queue = queueState.queue;
                  return ReorderableListView(
                    onReorder: (int oldIndex, int newIndex) {
                      if (oldIndex < newIndex) newIndex--;
                      _audioHandler.moveQueueItem(oldIndex, newIndex);
                    },
                    children: [
                      for (var i = 0; i < queue.length; i++)
                        Dismissible(
                          key: ValueKey(queue[i].id),
                          background: Container(
                            color: Colors.redAccent,
                            alignment: Alignment.centerRight,
                            child: const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                          onDismissed: (dismissDirection) {
                            _audioHandler.removeQueueItem(queue[i]);
                            queue.removeAt(i);
                          },
                          child: Material(
                            color: i == queueState.queueIndex
                                ? Colors.grey.shade300
                                : null,
                            child: ListTile(
                              title: Text(queue[i].title),
                              onTap: () => _audioHandler.skipToQueueItem(i),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
