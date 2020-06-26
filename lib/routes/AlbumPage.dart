import "dart:io";
import "package:flutter/material.dart";

import "package:Music/models/models.dart";
import "package:Music/helpers/db.dart";
import "package:Music/helpers/generateSubtitle.dart";
import "./widgets/SongPage.dart";

class AlbumPage extends StatefulWidget {
  final AlbumData album;

  const AlbumPage(this.album, {Key key}) : super(key: key);

  @override
  _AlbumPageState createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage>
    with SingleTickerProviderStateMixin {
  List<SongData> _songs = [];
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    beginAnimation();
    getSongs();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> beginAnimation() async {
    // TODO change this to constant variable for Custom page transition
    await Future.delayed(const Duration(milliseconds: 450));
    await _controller.forward();
  }

  Future<void> getSongs() async {
    var db = await getDB();

    var songs = SongData.fromMapArray(await db.query(
      Tables.Songs,
      where: "albumId LIKE ?",
      whereArgs: [widget.album.id],
      orderBy: "LOWER(title), title",
    ));

    if (!mounted) return;

    setState(() {
      _songs = songs;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return SongPage(
      controller: _controller,
      title: widget.album.name,
      subtitle: generateSubtitle(
        type: "Album",
        artist: widget.album.artist,
      ),
      hero: Hero(
        tag: widget.album.id,
        child: Image.file(
          File(widget.album.imagePath),
          width: screenWidth,
          height: screenWidth,
        ),
      ),
      songs: _songs,
    );
  }
}