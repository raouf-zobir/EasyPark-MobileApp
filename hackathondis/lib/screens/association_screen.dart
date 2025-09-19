import 'package:flutter/material.dart';

class AssociationScreen extends StatelessWidget {
  final Map<String, dynamic> fundraiser;

  const AssociationScreen({Key? key, required this.fundraiser})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fundraiser Details')),
      body: Center(child: Text('Association Screen - Placeholder')),
    );
  }
}
