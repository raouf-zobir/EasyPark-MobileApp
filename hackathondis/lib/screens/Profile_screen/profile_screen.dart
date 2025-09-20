import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  const ModernAppBar({Key? key, required this.title, this.actions = const []}) : super(key: key);
  @override
  Widget build(BuildContext context) => AppBar(title: Text(title), actions: actions);
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _StaticUserData {
  String displayName;
  String photoUrl;
  String carAge;
  String vehicleMake;
  String vehicleYear;
  String matricule;

  _StaticUserData({
    required this.displayName,
    required this.photoUrl,
    required this.carAge,
    required this.vehicleMake,
    required this.vehicleYear,
    required this.matricule,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  XFile? _pickedImage;

  final _staticUserData = _StaticUserData(
    displayName: 'Aymen B.',
    photoUrl: 'https://picsum.photos/seed/picsum/200/300',
    carAge: '5 years',
    vehicleMake: 'Toyota',
    vehicleYear: '2018',
    matricule: '1234-AB-56',
  );

  Future<void> _updateProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated locally!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade300,
              Colors.green.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: _pickedImage != null
                          ? FileImage(File(_pickedImage!.path)) as ImageProvider
                          : NetworkImage(_staticUserData.photoUrl),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF57AB7D)),
                          onPressed: _updateProfilePicture,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _staticUserData.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // Car Details Section
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Car Details",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow("Car Age", _staticUserData.carAge),
                        _buildDetailRow("Vehicle Make", _staticUserData.vehicleMake),
                        _buildDetailRow("Vehicle Year", _staticUserData.vehicleYear),
                        _buildDetailRow("Matricule", _staticUserData.matricule),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

