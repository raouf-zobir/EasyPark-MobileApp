import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackathondis/screens/baridi_payment_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// Assuming BaridiPaymentScreen is in another file, you'd import it like this:
// import 'baridi_payment_screen.dart';
// For this example, the class is included at the bottom of the file.

// A placeholder for the ModernAppBar if it's in another file
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  const ModernAppBar({Key? key, required this.title, this.actions = const []}) : super(key: key);
  @override
  Widget build(BuildContext context) => AppBar(title: Text(title), actions: actions);
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


// --- Data Model for Static User Data ---
// This class replaces the data previously fetched from Firestore.
class _StaticUserData {
  String displayName;
  String photoUrl;
  String aboutMe;
  List<String> interests;
  int fundraisers;
  int followers;
  int following;
  double walletBalance;

  _StaticUserData({
    required this.displayName,
    required this.photoUrl,
    required this.aboutMe,
    required this.interests,
    required this.fundraisers,
    required this.followers,
    required this.following,
    required this.walletBalance,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- State variables ---
  bool _isEditingAbout = false;
  final TextEditingController _aboutController = TextEditingController();
  
  // This holds the locally picked image file to display.
  // It resets when the screen is left.
  XFile? _pickedImage; 

  // --- Static Data Initialization ---
  // All user data is hardcoded here.
  final _staticUserData = _StaticUserData(
    displayName: 'Aymen B.',
    photoUrl: 'https://picsum.photos/seed/picsum/200/300', // A placeholder image
    aboutMe: "Passionate about technology and creating helpful applications. Flutter enthusiast and avid learner.",
    interests: ['Technology', 'Environment', 'Education', 'Art'],
    fundraisers: 3,
    followers: 142,
    following: 78,
    walletBalance: 1250.00, // Example wallet balance in DA
  );

  @override
  void initState() {
    super.initState();
    _aboutController.text = _staticUserData.aboutMe;
  }

  // --- UI Helper Widgets ---
  Widget _buildStatItem(String title, String count) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildInterestChip(String label) {
    return Chip(
      label: Text(
        label,
        style: GoogleFonts.poppins(color: const Color(0xFF57AB7D)),
      ),
      backgroundColor: const Color(0xFF57AB7D).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF57AB7D)),
      ),
    );
  }

  // --- Functions ---

  /// Simulates updating the profile picture by picking an image from the gallery.
  /// The image is only stored in local state and is not uploaded.
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
  
  /// Launches the BaridiMob URL for payment.
  Future<void> _launchBaridiMob() async {
    final Uri baridiMobUrl = Uri.parse('https://baridimob.dz/');
    if (!await launchUrl(baridiMobUrl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $baridiMobUrl')),
      );
    }
  }

  /// Simulates logging out and navigates to the login screen.
  Future<void> handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (mounted) {
      // Assuming you have a '/login' route defined in your app
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: ModernAppBar(
        title: "Profile",
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: handleLogout,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {
              // Placeholder for settings action
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings clicked!')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    // If a new image is picked, show it. Otherwise, show the static URL.
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      _staticUserData.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // "About Me" Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "About Me",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF57AB7D),
                                ),
                              ),
                              if (!_isEditingAbout)
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFF57AB7D), size: 18),
                                  onPressed: () => setState(() => _isEditingAbout = true),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_isEditingAbout)
                            TextField(
                              controller: _aboutController,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.check, color: Color(0xFF57AB7D)),
                                  onPressed: () {
                                    // Save changes to local static data
                                    setState(() {
                                      _staticUserData.aboutMe = _aboutController.text;
                                      _isEditingAbout = false;
                                    });
                                  },
                                ),
                              ),
                              maxLines: 3,
                            )
                          else
                            Text(
                              _staticUserData.aboutMe,
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Stats Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem("Fundraising", _staticUserData.fundraisers.toString()),
                        _buildStatItem("Followers", _staticUserData.followers.toString()),
                        _buildStatItem("Following", _staticUserData.following.toString()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Wallet Section
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_wallet, color: Color(0xFF57AB7D)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${_staticUserData.walletBalance.toStringAsFixed(2)} DA",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "My wallet balance",
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: ElevatedButton(
                                onPressed: _launchBaridiMob, // Takes user to payment screen
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF57AB7D),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                child: Text(
                                  "Top up",
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- NEW: Add Payment Method Section ---
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.add_card, color: Color(0xFF57AB7D)),
                        title: Text(
                          'Add Payment Method',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                          // Navigate to the Baridi Payment Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BaridiPaymentScreen(
                                // NOTE: The BaridiPaymentScreen is currently designed for
                                // fundraiser donations. The 'Submit' logic on that screen
                                // will need to be adapted for a wallet top-up feature.
                                // We are passing dummy data here to allow navigation.
                                amount: 1000.00, // Example top-up amount
                                orderNumber: 'TOPUP-${DateTime.now().millisecondsSinceEpoch}',
                                fundraiserId: 'user_wallet_topup', // Dummy ID
                                isAnonymous: false,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Interests Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Interests",
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF57AB7D)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text("Edit interests clicked!"),
                            ));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _staticUserData.interests
                          .map((interest) => _buildInterestChip(interest))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

