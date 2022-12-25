import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ravestreamradioapp/screens/eventcreationscreens.dart';
import 'package:ravestreamradioapp/screens/loginscreen.dart';
import 'package:ravestreamradioapp/screens/overviewpages/eventoverviewpage.dart';
import 'package:ravestreamradioapp/conv.dart';
import 'package:ravestreamradioapp/databaseclasses.dart' as dbc;
import 'package:ravestreamradioapp/screens/overviewpages/useroverviewpage.dart';
import 'package:ravestreamradioapp/shared_state.dart';
import 'package:ravestreamradioapp/main.dart' as main;
import 'package:flutter/material.dart';
import 'package:ravestreamradioapp/database.dart' as db;
import 'package:beamer/beamer.dart';

Map<Pattern, dynamic Function(BuildContext, BeamState, Object?)> webroutes = {
  // Routes for web navigation
  "/": (context, state, data) => const BeamPage(child: main.MainRoute(), title: "Events"),
  "/events": (context, state, data) => const BeamPage(child: main.MainRoute()),
  "/favorites": (context, state, data) =>
      const BeamPage(child: main.MainRoute(startingscreen: Screens.favourites)),
  "/groups": (context, state, data) =>
      const BeamPage(child: main.MainRoute(startingscreen: Screens.forums)),
  "/profile": (context, state, data) =>
      const BeamPage(child: main.MainRoute(startingscreen: Screens.profile))  ,
  "/users": (context, state, data) => const Text("No user provided"),
  "/users/:username": (context, state, data) {
    final username = state.pathParameters["username"];
    return BeamPage(
        key: ValueKey("User - $username"),
        //type: BeamPageType.scaleTransition,
        title: "@$username",
        child: username == null
            ? const Text("Empty Userid")
            : UserOverviewPage(username: username));
  },

  "/events/:eventid": (context, state, data){
    final eventid = state.pathParameters["eventid"]!;
    return BeamPage(
        key: ValueKey("Event - $eventid"),
        popToNamed: "/events",
        type: BeamPageType.scaleTransition,
        child: eventid.isEmpty
            ? const Text("Event not found.")
            : EventOverviewPage(eventid));
  },
  "/login": (context, state, data) => LoginScreen(),
  "/hostevent": (context, state, data) => EventCreationScreen(),
  "/createaccount": (context, state, data) => CreateAccountScreen(),
};
