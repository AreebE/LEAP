// ignore_for_file: unnecessary_import, implementation_imports, prefer_final_fields, no_logic_in_create_state, must_be_immutable

import 'package:edunciate/color_scheme.dart';
import 'package:edunciate/font_standards.dart';
import 'package:edunciate/homepage/res/sizes.dart';
import 'package:edunciate/homepage/res/string_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

class ClassDisplay extends StatefulWidget {
  CustomColorScheme _colorScheme;
  ClassDisplay(this._colorScheme, {Key? key}) : super(key: key);

  @override
  State<ClassDisplay> createState() => _ClassDisplayState(_colorScheme);
}

class _ClassDisplayState extends State<ClassDisplay> {
  List<String> classes = [
    "AP Biology",
    "AP History",
    "DECA",
    "TSA",
    "AP Calculus",
    "Health",
    "Life Fitness",
  ];
  CustomColorScheme _colorScheme;

  _ClassDisplayState(this._colorScheme);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          StringList.className,
          style: FontStandards.getTextStyle(
              _colorScheme, Style.header, FontSize.title),
        ),
        Divider(
          thickness: Numbers.dividerThickness,
          height: Numbers.dividerHeight,
          color: _colorScheme.getColor(CustomColorScheme.darkPrimary),
        ),
        SizedBox(
            height: Numbers.classDisplayHeight,
            child: Container(
              color:
                  _colorScheme.getColor(CustomColorScheme.lightSecondVariant),
              padding: const EdgeInsets.all(Numbers.smallMargin),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _getClasses(),
                ),
              ),
            ))
      ],
    );
  }

  List<Widget> _getClasses() {
    List<Widget> widgets = [];
    for (int i = 0; i < classes.length; i++) {
      bool useLightColor = i % 2 == 1;
      widgets.add(Container(
        height: Numbers.nameHeight,
        width: Numbers.nameWidth,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(Numbers.smallMargin),
        color: _colorScheme.getColor((useLightColor)
            ? CustomColorScheme.lightPrimary
            : CustomColorScheme.lightVariant),
        child: Text(
          classes.elementAt(i),
          maxLines: 2,
          textAlign: TextAlign.center,
          style: FontStandards.getTextStyle(
              _colorScheme,
              (useLightColor) ? Style.darkVarNorm : Style.darkNorm,
              FontSize.medium),
        ),
      ));
    }
    return widgets;
  }
}