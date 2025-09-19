import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReelsScreen extends StatelessWidget {
  final int initialIndex;
  final List<QueryDocumentSnapshot> videos;

  const ReelsScreen({
    Key? key,
    required this.initialIndex,
    required this.videos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Reels Screen - Placeholder',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
