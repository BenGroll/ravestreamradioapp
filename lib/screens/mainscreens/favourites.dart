import 'package:flutter/material.dart';
import 'package:ravestreamradioapp/colors.dart' as cl;
import 'package:ravestreamradioapp/databaseclasses.dart' as dbc;

class Favourites extends StatefulWidget {
  final dbc.User? loggedinas;
  const Favourites({super.key, required this.loggedinas});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cl.nearly_black,
      appBar: AppBar(
        backgroundColor: cl.deep_black,
        title: const Text("Favourites"),
        centerTitle: true,
      ),
    );
  }
}
