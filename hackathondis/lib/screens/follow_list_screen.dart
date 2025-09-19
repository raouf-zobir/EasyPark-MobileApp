import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class FollowListScreen extends StatelessWidget {
  final String userId;
  final bool isFollowers;

  const FollowListScreen({
    Key? key,
    required this.userId,
    required this.isFollowers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isFollowers ? 'Followers' : 'Following'),
        backgroundColor: const Color(0xFF57AB7D),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> followList =
              userData[isFollowers ? 'followers' : 'following'] ?? [];

          if (followList.isEmpty) {
            return Center(
              child: Text(
                'No ${isFollowers ? 'followers' : 'following'} yet',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: followList.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(followList[index])
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.grey[200]),
                      title: Container(
                        width: 100,
                        height: 20,
                        color: Colors.grey[200],
                      ),
                    );
                  }

                  final followedUser =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        followedUser['photoURL'] ?? '',
                      ),
                    ),
                    title: Text(
                      followedUser['displayName'] ?? 'Unknown User',
                      style: GoogleFonts.poppins(),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
