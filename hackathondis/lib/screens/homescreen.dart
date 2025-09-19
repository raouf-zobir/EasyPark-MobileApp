import 'package:flutter/material.dart';

class ParkingSpot {
  final String name;
  final String distance;
  final String walkTime;
  final double rating;
  final int availableSpots;
  final String imagePath;
  final bool hasShuttle;

  ParkingSpot({
    required this.name,
    required this.distance,
    required this.walkTime,
    required this.rating,
    required this.availableSpots,
    required this.imagePath,
    this.hasShuttle = false,
  });
}

class RecentSearch {
  final String name;
  final String walkTime;
  final String visitedDate;

  RecentSearch({
    required this.name,
    required this.walkTime,
    required this.visitedDate,
  });
}

class ParkingTip {
  final String title;
  final String description;
  final String imagePath;

  ParkingTip({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<ParkingSpot> popularSpots = [
    ParkingSpot(
      name: "Downtown Garage",
      distance: "5 min walk",
      walkTime: "5 min walk to mall",
      rating: 4.5,
      availableSpots: 45,
      imagePath: "assets/images/parking.png",
    ),
    ParkingSpot(
      name: "City Center Parking",
      distance: "3 min walk",
      walkTime: "5 min walk to the...",
      rating: 4.2,
      availableSpots: 23,
      imagePath: "assets/images/parking.png",
    ),
    ParkingSpot(
      name: "Park & Ride Lot",
      distance: "2 min walk",
      walkTime: "Free shuttle to...",
      rating: 4.8,
      availableSpots: 67,
      imagePath: "assets/images/parking.png",
      hasShuttle: true,
    ),
  ];

  final List<RecentSearch> recentSearches = [
    RecentSearch(
      name: "Downtown Garage",
      walkTime: "5 min walk",
      visitedDate: "Visited on Oct 1",
    ),
    RecentSearch(
      name: "City Center Parking",
      walkTime: "3 min walk",
      visitedDate: "Visited on Sept 28",
    ),
    RecentSearch(
      name: "Park & Ride Lot",
      walkTime: "Free shuttle",
      visitedDate: "Visited on Sept 25",
    ),
  ];

  final List<ParkingTip> parkingTips = [
    ParkingTip(
      title: "Peak Hours",
      description: "Avoid between 5 PM to 7 PM for best availability",
      imagePath: "assets/images/parking.png",
    ),
    ParkingTip(
      title: "Payment Options",
      description: "Multiple payment methods accepted including credit cards and e-wallets",
      imagePath: "assets/images/parking.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Logo
                Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to parking icon if logo fails to load
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4DB6AC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.local_parking,
                            color: Colors.white,
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for parking spots',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Locate nearby parking spots section
                const Text(
                  'Locate nearby parking spots',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),

                // Featured Parking Spot Card
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/parking.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Downtown Garage',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    '5 min walk',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      ...List.generate(4, (index) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      )),
                                      const Icon(
                                        Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Available Spots',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Text(
                                    '45',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Popular Parking Spots section
                const Text(
                  'Popular Parking Spots',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),

                // Popular Spots Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: popularSpots.length,
                  itemBuilder: (context, index) {
                    final spot = popularSpots[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                image: DecorationImage(
                                  image: AssetImage(spot.imagePath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    spot.name,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    spot.walkTime,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          ...List.generate(4, (i) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 8,
                                          )),
                                          const Icon(
                                            Icons.star_border,
                                            color: Colors.amber,
                                            size: 8,
                                          ),
                                        ],
                                      ),
                                      if (spot.hasShuttle)
                                        const Icon(
                                          Icons.directions_bus,
                                          color: Color(0xFF4DB6AC),
                                          size: 10,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Map Section
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DB6AC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Map-like pattern
                      CustomPaint(
                        size: const Size(double.infinity, 200),
                        painter: MapPatternPainter(),
                      ),
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Color(0xFF4DB6AC),
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Locate nearby parking spots',
                              style: TextStyle(
                                color: Color(0xFF4DB6AC),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Recent Searches
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),

                ...recentSearches.map((search) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4DB6AC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.local_parking,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              search.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              search.walkTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        search.visitedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )).toList(),

                const SizedBox(height: 30),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'Share Spot',
                        Icons.share,
                        Colors.grey[100]!,
                        Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        'Get Directions',
                        Icons.directions,
                        Colors.grey[100]!,
                        Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _buildActionButton(
                    'Reserve Now',
                    Icons.book_online,
                    Colors.black,
                    Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // Parking Tips
                const Text(
                  'Parking Tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),

                ...parkingTips.map((tip) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(tip.imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tip.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: backgroundColor == Colors.grey[100]
            ? Border.all(color: Colors.grey[300]!)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4DB6AC).withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw a simple map-like grid pattern
    final path = Path();
    
    // Horizontal lines
    for (int i = 1; i < 6; i++) {
      final y = (size.height / 6) * i;
      path.moveTo(20, y);
      path.lineTo(size.width - 20, y);
    }
    
    // Vertical lines
    for (int i = 1; i < 8; i++) {
      final x = (size.width / 8) * i;
      path.moveTo(x, 20);
      path.lineTo(x, size.height - 20);
    }
    
    // Diagonal lines for streets
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.7);
    
    path.moveTo(size.width * 0.2, 0);
    path.lineTo(size.width * 0.8, size.height);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}