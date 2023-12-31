import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function searchFunction;
  final Function? suffixFunction;
  const MySearchBar(
      {super.key,
      required this.controller,
      required this.searchFunction,
      this.suffixFunction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          color: Colors.grey.withOpacity(0.4)),
      child: TextFormField(
          controller: controller,
          onFieldSubmitted: (value) {
            searchFunction(value);
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search), // Prefix icon (glass icon)
            hintText: 'Tìm kiếm', // Hint text
            suffixIcon: GestureDetector(
              onTap: () {
                controller.clear();
                if (suffixFunction != null) {
                  suffixFunction!();
                }
              },
              child: const Icon(Icons.clear),
            ),
            border: InputBorder.none,
          )),
    );
  }
}
