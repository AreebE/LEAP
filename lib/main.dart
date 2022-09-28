// Tanya Bhandari
// Join a Class and/or Create a new class page
//ignore_for_file: prefer_const_constructors, unused_import, must_be_immutable
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edunciate/classroom/top_nav_bar.dart';
import 'package:edunciate/firebaseAccessor/firebase_listener.dart';
import 'package:edunciate/firebaseAccessor/settings_firebase.dart';
import 'package:edunciate/firebaseAccessor/users_firebase.dart';
import 'package:edunciate/homepage/homepage.dart';
import 'package:edunciate/joinAndCreateClass/class_alternator_screen.dart';
import 'package:edunciate/joinAndCreateClass/join_and_create_start_screen.dart';
import 'package:edunciate/settings/items/settings_item.dart';
import 'package:edunciate/settings/items/time_range.dart';
import 'package:edunciate/settings/settings.dart';
import 'package:edunciate/signUpScreen/registration_alternator.dart';
import 'package:edunciate/signUpScreen/loginscreen.dart';
import 'package:edunciate/signUpScreen/signupscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'color_scheme.dart';

enum Page {
  settings,
  login,
  joinClass,
  homepage,

  calendar,
  personalProfile
}

class BlankListener extends FirebaseListener {
  @override
  void onSuccess(List items) {
    // print(items);
  }
}

class OnPageChangeListener {
  void changePage(Page newPage) {}
}

void main() {
  runApp(MainDisplay());
}

class MainDisplay extends StatefulWidget {
  const MainDisplay({Key? key}) : super(key: key);

  @override
  State<MainDisplay> createState() => _MainDisplayState();
}

class _MainDisplayState extends State<MainDisplay>
    implements OnPageChangeListener, FirebaseListener {
  Page current = Page.login;
  Widget body = RegistrationAlternator();

  @override
  Widget build(BuildContext context) {
    // print("started");
    Firebase.initializeApp().whenComplete(() {
      // UsersFirebaseAccessor().createNewUser("1054159@apps.nsd.org",
      // "425-236-3911", "he/him", "Areeb;Emran", BlankListener());
    });

    return MaterialApp(
        home: Scaffold(
      bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
                child: AddNewTaskbarButton(
                    this, current)), // plus sign (current page)
            Expanded(
                child: HomeTaskbarButton(this,
                    current)), // home page (list of classes) and default page
            Expanded(
                child: ProfileTaskbarButton(this, current)), // personal profile
            Expanded(child: SettingsTaskbarButton(this, current)), // settings
          ]),
      body: body,
    ));
  }

  void setBody() {
    switch (current) {
      case Page.homepage:
        body = Homepage(CustomColorScheme.defaultColors);

        break;
      case Page.joinClass:
        body = ClassAlternator();
        break;
      case Page.login:
        body = RegistrationAlternator();
        break;
      case Page.settings:
        print("calling this");
        FirebaseSettingsAccessor()
            .getSettingsInfo("uSDrCPEvRKmTQHPrbP5N", this);
        break;
      // case Page.personalInfo:
      // return PersonalInfoPage();
    }
  }

  @override
  void changePage(Page newPage) {
    if (newPage != current) {
      current = newPage;
      setBody();
      setState(() {});
    }
  }

  @override
  void onFailure(String reason) {
    // TODO: implement onFailure
  }

  @override
  void onSuccess(List objects) {
    switch (current) {
      case Page.settings:
        print(objects);
        SettingsItem item = SettingsItem(
            objects[FirebaseSettingsAccessor.notifStatusArrayKey],
            objects[FirebaseSettingsAccessor.textArrayKey],
            (objects[FirebaseSettingsAccessor.workHoursStatusArrayKey] as List)
                .cast<TimeRange>(),
            objects[FirebaseSettingsAccessor.langArrayKey],
            "uSDrCPEvRKmTQHPrbP5N");
        body = SettingsPage(
            settingsItem: item, colorScheme: CustomColorScheme.defaultColors);
        setState(() {});
    }
  }
}

// Tanya Bhandari
// Taskbar
// Home page sign
class AddNewTaskbarButton extends StatelessWidget {
  OnPageChangeListener listener;
  Page current;
  AddNewTaskbarButton(this.listener, this.current, {super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            backgroundColor: CustomColorScheme.defaultColors.getColor(
                (current == Page.homepage)
                    ? CustomColorScheme.darkPrimary
                    : CustomColorScheme.backgroundAndHighlightedNormalText),
            side: BorderSide(color: Colors.white)),
        onPressed: () {
          listener.changePage(Page.homepage);
        },
        child: Icon(
          Icons.home,
          color: CustomColorScheme.defaultColors.getColor(
              (current != Page.homepage)
                  ? CustomColorScheme.darkPrimary
                  : CustomColorScheme.backgroundAndHighlightedNormalText),
        ),
      ),
    );
  }
}

// calendar page sign
class HomeTaskbarButton extends StatelessWidget {
  OnPageChangeListener listener;
  Page current;

  HomeTaskbarButton(this.listener, this.current, {super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            backgroundColor: CustomColorScheme.defaultColors.getColor(
                (current == Page.calendar) // calendarPage needs to be updated
                    ? CustomColorScheme.darkPrimary
                    : CustomColorScheme.backgroundAndHighlightedNormalText),
            side: BorderSide(color: Colors.white)),
        onPressed: () {
          listener.changePage(Page.calendar);
        },
        child: Icon(
          Icons.calendar_month,
          color: CustomColorScheme.defaultColors.getColor(
              (current != Page.calendar)
                  ? CustomColorScheme.darkPrimary
                  : CustomColorScheme.backgroundAndHighlightedNormalText),
        ),
      ),
    );
  }
}

// indvidual profile
class ProfileTaskbarButton extends StatelessWidget {
  OnPageChangeListener listener;
  Page current;

  ProfileTaskbarButton(this.listener, this.current, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            backgroundColor: CustomColorScheme.defaultColors.getColor(
                (current == Page.personalProfile)
                    ? CustomColorScheme.darkPrimary
                    : CustomColorScheme.backgroundAndHighlightedNormalText),
            side: BorderSide(color: Colors.white)),
        onPressed: () {
          // listener.changePage(Page.personalProfile);
        },
        child: Icon(
          Icons.person,
          color: CustomColorScheme.defaultColors.getColor(
              (current != Page.personalProfile)
                  ? CustomColorScheme.darkPrimary
                  : CustomColorScheme.backgroundAndHighlightedNormalText),
        ),
      ),
    );
  }
}

// settings
class SettingsTaskbarButton extends StatelessWidget {
  OnPageChangeListener listener;
  Page current;

  SettingsTaskbarButton(this.listener, this.current, {super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            backgroundColor: CustomColorScheme.defaultColors.getColor(
                (current == Page.settings)
                    ? CustomColorScheme.darkPrimary
                    : CustomColorScheme.backgroundAndHighlightedNormalText),
            side: BorderSide(color: Colors.white)),
        onPressed: () {
          listener.changePage(Page.settings);
        },
        child: Icon(
          Icons.settings,
          color: CustomColorScheme.defaultColors.getColor(
              (current != Page.settings)
                  ? CustomColorScheme.darkPrimary
                  : CustomColorScheme.backgroundAndHighlightedNormalText),
        ),
      ),
    );
  }
}
