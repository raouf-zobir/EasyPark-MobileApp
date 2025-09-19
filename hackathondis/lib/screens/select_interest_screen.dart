import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectInterestScreen extends StatefulWidget {
  final bool isEditing;
  final List<dynamic> currentInterests;

  const SelectInterestScreen({
    Key? key,
    this.isEditing = false,
    this.currentInterests = const [],
  }) : super(key: key);

  @override
  _SelectInterestScreenState createState() => _SelectInterestScreenState();
}

class _SelectInterestScreenState extends State<SelectInterestScreen> {
  final List<String> _availableInterests = [
    'Medical',
    'Education',
    'Environment',
    'Social',
    'Disaster',
    'Sick child',
    'Infrastructure',
    'Art',
    'Orphanage',
    'Difable',
    'Humanity',
    'Others',
  ];

  Set<String> _selectedInterests = {};

  @override
  void initState() {
    super.initState();
    _selectedInterests = widget.currentInterests
        .map((e) => e.toString())
        .toSet();
  }

  Future<void> _saveInterests() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'interests': _selectedInterests.toList()});
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving interests: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Interests'),
        backgroundColor: const Color(0xFF57AB7D),
        actions: [
          TextButton(
            onPressed: _saveInterests,
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your interests',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableInterests.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return FilterChip(
                  label: Text(interest),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedInterests.add(interest);
                      } else {
                        _selectedInterests.remove(interest);
                      }
                    });
                  },
                  backgroundColor: isSelected
                      ? const Color(0xFF57AB7D).withOpacity(0.1)
                      : Colors.grey[200],
                  selectedColor: const Color(0xFF57AB7D).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF57AB7D),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? const Color(0xFF57AB7D)
                        : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
