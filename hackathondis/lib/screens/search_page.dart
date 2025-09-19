import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  final int initialTabIndex;

  const SearchPage({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: Center(child: Text('Search Page - Placeholder')),
    );
  }
}
