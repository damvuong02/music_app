
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/bloc/download_songs_bloc.dart';


class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  bool isShowMusicDevice = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Thiết lập"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text("Hiển thị nhạc trong thiết bị"),
                subtitle: const Text("Bao gồm cả nhạc từ ngoài ứng dụng"),
                trailing: Switch(
                  thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return const Icon(Icons.close);
                      }
                      return const Icon(Icons.check);
                    },
                  ),
                  value: isShowMusicDevice,
                  onChanged: (bool value) {
                    setState(() {
                      isShowMusicDevice = value;
                    });
                  },
                ),
              ),
            ),
            Card(
              child: ListTile(
                  title: const Text("Đồng bộ nhạc trên máy"),
                  trailing: OutlinedButton(
                      onPressed: () {
                        BlocProvider.of<DownloadSongsBloc>(context).add(
                            LoadDeviceSongs(
                                context: context));
                      },
                      child: const Text(
                        "Quét nhạc",
                        style: TextStyle(color: Colors.red),
                      ))),
            ),
          ],
        ),
      ),
    );
  }
}
