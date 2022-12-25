// ignore_for_file: prefer_const_constructors, sort_child_properties_last
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:ravestreamradioapp/databaseclasses.dart' as dbc;
import 'package:ravestreamradioapp/colors.dart' as cl;
import 'package:ravestreamradioapp/screens/mainscreens/calendar.dart';
import 'package:ravestreamradioapp/screens/mainscreens/favourites.dart';
import 'package:ravestreamradioapp/screens/mainscreens/forums.dart';
import 'package:ravestreamradioapp/screens/mainscreens/profile.dart';
import 'package:ravestreamradioapp/screens/eventcreationscreens.dart';
import 'package:ravestreamradioapp/commonwidgets.dart' as cw;
import 'package:ravestreamradioapp/shared_state.dart';

Screens map_Index_to_Screen(int index) {
  switch (index) {
    case 0:
      {
        return Screens.events;
      }
    case 1:
      {
        return Screens.favourites;
      }
    case 3:
      {
        return Screens.forums;
      }
    case 4:
      {
        return Screens.profile;
      }
    default:
      {
        return currently_selected_screen.value;
      }
  }
}

int map_Screen_to_Index(Screens screen) {
  switch (screen) {
    case Screens.events:
      {
        return 0;
      }
    case Screens.favourites:
      {
        return 1;
      }
    case Screens.forums:
      {
        return 3;
      }
    case Screens.profile:
      {
        return 4;
      }
    default:
      {
        return 2;
      }
  }
}

Widget map_Widget_to_Screen(Screens screen) {
  switch (screen) {
    case Screens.events:
      {
        return EventCalendar(loggedinas: currently_loggedin_as.value);
      }
    case Screens.favourites:
      {
        return Favourites(loggedinas: currently_loggedin_as.value);
      }
    case Screens.forums:
      {
        return ForumsScreen(loggedinas: currently_loggedin_as.value);
      }
    case Screens.profile:
      {
        return ProfileScreen(loggedinas: currently_loggedin_as.value);
      }
    default:
      {
        return EventCalendar(loggedinas: currently_loggedin_as.value);
      }
  }
}

class HomeScreen extends StatelessWidget {
  dbc.User? loggedinas;
  final Screens startingscreen;
  HomeScreen(
      {super.key,
      required this.loggedinas,
      this.startingscreen = Screens.events});

  @override
  Widget build(BuildContext context) {
    currently_selected_screen.value = startingscreen;
    currently_loggedin_as.value = loggedinas;
    return ValueListenableBuilder(
        valueListenable: currently_loggedin_as,
        builder: ((context, value, child) {
          return ValueListenableBuilder(
              valueListenable: currently_selected_screen,
              builder: ((context, value, child) {
                return Scaffold(
                  body: map_Widget_to_Screen(currently_selected_screen.value),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  floatingActionButton: FloatingActionButton(
                    backgroundColor: cl.deep_black,
                    onPressed: () {
                      if (currently_loggedin_as.value != null) {
                        kIsWeb
                        ? Beamer.of(context).beamToNamed("/hostevent/")
                        : Navigator.of(context).push(MaterialPageRoute(
                            builder: ((context) => EventCreationScreen())));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            cw.hintSnackBar(
                                "Has to be logged in to create Event"));
                      }
                    },
                    child: Icon(Icons.add),
                  ),
                  bottomNavigationBar: BottomAppBar(
                    shape: CircularNotchedRectangle(),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    notchMargin: 6,
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(canvasColor: cl.deep_black),
                      child: BottomNavigationBar(
                        backgroundColor: cl.deep_black,
                        selectedItemColor: Colors.white,
                        unselectedItemColor: Colors.white,
                        items: [
                          BottomNavigationBarItem(
                              label: "Events",
                              icon: Icon(currently_selected_screen.value ==
                                      Screens.events
                                  ? Icons.calendar_month
                                  : Icons.calendar_month_outlined)),
                          BottomNavigationBarItem(
                              label: "Favourites",
                              icon: Icon(currently_selected_screen.value ==
                                      Screens.favourites
                                  ? Icons.favorite
                                  : Icons.favorite_border)),
                          BottomNavigationBarItem(
                              label: "",
                              icon: Icon(Icons.add,
                                  color: Color.fromARGB(0, 255, 255, 255))),
                          BottomNavigationBarItem(
                              label: "Forums",
                              icon: Icon(currently_selected_screen.value ==
                                      Screens.forums
                                  ? Icons.groups
                                  : Icons.groups_outlined)),
                          BottomNavigationBarItem(
                              label: "Profile",
                              icon: Icon(currently_selected_screen.value ==
                                      Screens.profile
                                  ? Icons.person
                                  : Icons.person_outline)),
                        ],
                        currentIndex: map_Screen_to_Index(
                            currently_selected_screen.value),
                        onTap: ((value) {
                          currently_selected_screen.value =
                              map_Index_to_Screen(value);
                        }),
                      ),
                    ),
                  ),
                  backgroundColor: cl.nearly_black,
                );
              }));
        }));
  }
}
