import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/blocs/bloc/download_songs_bloc.dart';
import 'package:music_app/screens/discover.dart';
import 'package:music_app/screens/person.dart';
import 'package:music_app/widgets/app_bar.dart';

class MyHomePage extends StatefulWidget {
  final int currentPage;
  const MyHomePage(this.currentPage, {super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 1; // Current index of the selected item

  // Define a list of screens or pages to navigate to when a bottom navigation item is tapped
  final List<Widget> _screens = [];
  final TextEditingController controller = TextEditingController();
  searchFunction(String value) {
    print(value);
  }

  void handleCallback(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    _screens.addAll([
      PersonPage(
        callback: handleCallback,
      ),
      const DiscoverPage(),
      ProfileScreen(),
    ]);
    _currentIndex = widget.currentPage;
    BlocProvider.of<DownloadSongsBloc>(context).add(FetchDownloadSongs());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: MyAppBar(
            avatarUrl:
                "https://nhadepso.com/wp-content/uploads/2023/03/loa-mat-voi-101-hinh-anh-avatar-meo-cute-dang-yeu-dep-mat_2.jpg",
            controller: controller,
            searchFunction: searchFunction,
          )),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Current index of the selected item
        onTap: (int index) {
          // Handle item taps
          setState(() {
            _currentIndex = index; // Update the current index
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.music),
            label: 'Cá nhân',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.compactDisc),
            label: 'Khám phá',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.chartLine),
            label: 'Music Chart',
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Screen'),
    );
  }
}
