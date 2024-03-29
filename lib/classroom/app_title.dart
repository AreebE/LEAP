//Rishitha Ravi
//Code for Individual Class Screen titles

// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  late String name;
  late double size;

  AppTitle(this.name, this.size);

  @override
  Widget build(BuildContext context) {
    return Text(name,
        textDirection: TextDirection.ltr,
        style: TextStyle(
          color: Color.fromARGB(255, 58, 27, 103),
          fontWeight: FontWeight.bold,
          fontFamily: 'Josefin Sans',
          fontSize: size,
        ));
  }
}
