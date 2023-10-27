import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/methods/shared_preference_method.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/widgets/icon_button.dart';
import 'package:music_app/widgets/song_item.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:music_app/widgets/task_bar.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
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
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 350,
                  padding: const EdgeInsets.only(top: 15),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: ImageSlideshow(
                          width: double.infinity,

                          /// Height of the [ImageSlideshow].
                          height: 200,

                          /// The page to show when first creating the [ImageSlideshow].
                          initialPage: 0,

                          /// The color to paint the indicator.
                          indicatorColor: Colors.blue,

                          /// The color to paint behind th indicator.
                          indicatorBackgroundColor: Colors.grey,
                          autoPlayInterval: 3000,
                          isLoop: true,
                          children: [
                            Image.network(
                              'https://toigingiuvedep.vn/wp-content/uploads/2022/01/anh-meo-cute.jpg',
                              fit: BoxFit.cover,
                            ),
                            Image.network(
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTFU7-eJHS1DerxF4CF-ioTXfCaFoqGalWGZ8k3HYA&s',
                              fit: BoxFit.cover,
                            ),
                            Image.network(
                              'https://nhadepso.com/wp-content/uploads/2023/03/loa-mat-voi-101-hinh-anh-avatar-meo-cute-dang-yeu-dep-mat_2.jpg',
                              fit: BoxFit.cover,
                            ),
                            Image.network(
                              'https://nhadepso.com/wp-content/uploads/2023/03/loa-mat-voi-101-hinh-anh-avatar-meo-cute-dang-yeu-dep-mat_1.jpg',
                              fit: BoxFit.cover,
                            ),
                            Image.network(
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTvO3DLvKZpFBe-_FwOkgbLtYOVmTUhcm3RiBnNeA9BVFdYgFjmNjOVyMfLNdiAkH2HeFk&usqp=CAU',
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              MyIconButton(
                                backgroundColor: const Color(0xff3340B4),
                                iconSize: 40,
                                size: 60,
                                icon: FontAwesomeIcons.music,
                                onTap: () {},
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              const Text(
                                "Nhạc mới",
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              MyIconButton(
                                backgroundColor: const Color(0xffB47133),
                                iconSize: 40,
                                size: 60,
                                icon: Icons.category,
                                onTap: () {},
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              const Text(
                                "Thể loại",
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              MyIconButton(
                                backgroundColor: const Color(0xffB133B4),
                                iconSize: 40,
                                size: 60,
                                icon: Icons.star,
                                onTap: () {},
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              const Text(
                                "Top 100",
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TOP 20",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            const Color(0xFF1F005C),
                            const Color(0xFF1F005C),
                            const Color(0xff5b0060),
                            const Color(0xff870160).withOpacity(0.3),
                            Colors.black
                          ], // Gradient from https://learnui.design/tools/gradient-generator.html
                          tileMode: TileMode.mirror,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SongWidget(
                              isFavouriteSong: false,
                              topTitle: "1",
                              topTitleColor: Colors.red,
                              song: Song(
                                id: 1,
                                title: "Anh là ngoại lệ của em",
                                artist: "Phương Ly",
                                imageSong:
                                    "https://chungcuthongnhatcomplex.com/wp-content/uploads/2022/10/0d5010d57434e378fa296a43898a988c.jpg",
                                link:
                                    "https://firebasestorage.googleapis.com/v0/b/instagram-clone-d57d2.appspot.com/o/ANH%20LA%20NGOAI%20L%C3%8A%20CUA%20EM%20-%20PH%C6%AF%C6%A0NG%20LY%20-%20OFFICIAL%20MV.mp3?alt=media&token=87fcbd9d-ffa0-4a44-a333-a18d350449e7&_gl=1*wxyki2*_ga*MTc0MTA0NjEzNS4xNjY5MDQ1ODMx*_ga_CW55HF8NVT*MTY5ODI0MTk4OC43MC4xLjE2OTgyNDQxMTUuNjAuMC4w",
                              ),
                            ),
                            SongWidget(
                              isFavouriteSong: false,
                              topTitle: "2",
                              topTitleColor: Colors.yellow,
                              song: Song(
                                id: 2,
                                title: "Gió",
                                artist: "Jank, QuanVro",
                                imageSong:
                                    "https://chungcuthongnhatcomplex.com/wp-content/uploads/2022/10/0d5010d57434e378fa296a43898a988c.jpg",
                                link:
                                    "https://firebasestorage.googleapis.com/v0/b/instagram-clone-d57d2.appspot.com/o/Gi%C3%B3%20-%20JanK%20x%20QuanvroxLofi%20Ver.-%20Official%20Lyrics%20Video.mp3?alt=media&token=793ec26b-0857-4f6a-8155-5c32c47a0e36&_gl=1*1p7bgnb*_ga*MTc0MTA0NjEzNS4xNjY5MDQ1ODMx*_ga_CW55HF8NVT*MTY5ODI0MTk4OC43MC4xLjE2OTgyNDQ3NDIuMjUuMC4w",
                              ),
                            ),
                            SongWidget(
                              isFavouriteSong: false,
                              topTitle: "3",
                              topTitleColor: Colors.blueAccent,
                              song: Song(
                                id: 3,
                                title: "Hẹn em ở lần yêu thứ 2",
                                artist: "Nguyenn, Đặng Tuấn Vũ",
                                imageSong:
                                    "https://chungcuthongnhatcomplex.com/wp-content/uploads/2022/10/0d5010d57434e378fa296a43898a988c.jpg",
                                link:
                                    "https://firebasestorage.googleapis.com/v0/b/instagram-clone-d57d2.appspot.com/o/H%E1%BA%B9n%20Em%20%E1%BB%9E%20L%E1%BA%A7n%20Y%C3%AAu%20Th%E1%BB%A9%202%20-%20Nguyenn%20x%20%C4%90%E1%BA%B7ng%20Tu%E1%BA%A5n%20V%C5%A9%20-%20Official%20Lyrics%20Video%20-%20Anh%20ph%E1%BA%A3i%20l%C3%A0m%20g%C3%AC%20%C4%91%E1%BB%83%20em....mp3?alt=media&token=2b2ef4df-0b73-4698-be60-b491f75a853a&_gl=1*1pvir9o*_ga*MTc0MTA0NjEzNS4xNjY5MDQ1ODMx*_ga_CW55HF8NVT*MTY5ODI0MTk4OC43MC4xLjE2OTgyNDQ4NTcuNjAuMC4w",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 500,
                  color: Colors.red,
                )
              ],
            ),
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
