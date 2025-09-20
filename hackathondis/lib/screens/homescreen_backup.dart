// import 'package:flutter/material.dart';

// class ParkingSpot {
//   final String name;
//   final String distance;
//   final String walkTime;
//   final double rating;
//   final int availableSpots;
//   final String imagePath;
//   final bool hasShuttle;

//   ParkingSpot({
//     required this.name,
//     required this.distance,
//     required this.walkTime,
//     required this.rating,
//     required this.availableSpots,
//     required this.imagePath,
//     this.hasShuttle = false,
//   });
// }

// class RecentSearch {
//   final String name;
//   final String walkTime;
//   final String visitedDate;

//   RecentSearch({
//     required this.name,
//     required this.walkTime,
//     required this.visitedDate,
//   });
// }

// class ParkingTip {
//   final String title;
//   final String description;
//   final String imagePath;

//   ParkingTip({
//     required this.title,
//     required this.description,
//     required this.imagePath,
//   });
// }
//     'Sick child',
//     'Infrastructure',
//     'Art',
//     'Orphanage',
//     'Humanity',
//   ];
//   final random = Random();
//   final category = categories[random.nextInt(categories.length)];
//   final goal = (random.nextInt(200) + 50) * 1000.0;
//   final raised =
//       goal * (random.nextDouble() * 0.9); // funded between 0% and 90%

//   // Parking-related images from Unsplash (replace with your own if needed)
//   final parkingImages = [
//     'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80',
//     'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=600&q=80',
//     'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=600&q=80',
//     'https://images.unsplash.com/photo-1523413363574-c30aa1c2a1ae?auto=format&fit=crop&w=600&q=80',
//     'https://images.unsplash.com/photo-1509228468518-180dd4864904?auto=format&fit=crop&w=600&q=80',
//     'https://images.unsplash.com/photo-1465101178521-c1a4c8a0a8b7?auto=format&fit=crop&w=600&q=80',
//     'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb?auto=format&fit=crop&w=600&q=80',
//     'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?auto=format&fit=crop&w=600&q=80',
//     'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=600&q=80',
//     'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80',
//   ];

//   return Fundraiser(
//     id: 'fundraiser_$index',
//     title: 'Parking Spot for $category #${index + 1}',
//     mainImageUrl: parkingImages[index % parkingImages.length],
//     funding: raised,
//     donationAmount: goal,
//     expirationDate: DateTime.now().add(Duration(days: random.nextInt(60) + 5)),
//     donators: random.nextInt(500) + 20,
//     category: category,
//   );
// });

// final List<VideoReel> _mockVideos = List.generate(8, (index) {
//   // Parking-related video thumbnails from Unsplash
//   final parkingVideoImages = [
//     'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80',
//     'https://images.unsplash.com/photo-1523413363574-c30aa1c2a1ae?auto=format&fit=crop&w=400&q=80',
//     'https://images.unsplash.com/photo-1509228468518-180dd4864904?auto=format&fit=crop&w=400&q=80',
//     'https://images.unsplash.com/photo-1465101178521-c1a4c8a0a8b7?auto=format&fit=crop&w=400&q=80',
//     'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb?auto=format&fit=crop&w=400&q=80',
//     'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?auto=format&fit=crop&w=400&q=80',
//     'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
//     'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
//   ];
//   return VideoReel(
//     id: 'video_$index',
//     title: 'Parking Story: How Your Spot Helped #${index + 1}',
//     mainImageUrl: parkingVideoImages[index % parkingVideoImages.length],
//   );
// });

// // --- MAIN WIDGET ---

// class HomeScreen extends StatefulWidget {
//   @override
//   _FundraisingHomePageState createState() => _FundraisingHomePageState();
// }

// class _FundraisingHomePageState extends State<HomeScreen> {
//   String _selectedFilterUrgent = 'All';
//   String _selectedFilterMore = 'All';

//   // Local state to manage favorites, replacing Firebase Auth/Firestore
//   final Set<String> _favoriteIds = {};

//   // Local lists to hold our data
//   late List<Fundraiser> _urgentFundraisers;
//   late List<Fundraiser> _moreToHelpFundraisers;
//   late List<VideoReel> _videos;
//   late List<Fundraiser> _sliderFundraisers;

//   @override
//   void initState() {
//     super.initState();
//     // Load data from our mock source on initialization
//     _loadData();
//   }

//   void _loadData() {
//     // Top 3 fundraisers for the image slider
//     _sliderFundraisers = _mockFundraisers.take(3).toList();

//     // Initial data for "Urgent Fundraising" section
//     _urgentFundraisers = _getFilteredFundraisers(_selectedFilterUrgent);

//     // Initial data for "More to Help" section (sorted by donors)
//     _moreToHelpFundraisers = _getFilteredFundraisers(_selectedFilterMore)
//       ..sort((a, b) => b.donators.compareTo(a.donators));

//     // Video data
//     _videos = _mockVideos;
//   }

//   // Replaces Firebase's .where() query
//   List<Fundraiser> _getFilteredFundraisers(String filter) {
//     if (filter == 'All') {
//       return List.from(_mockFundraisers);
//     } else {
//       return _mockFundraisers.where((f) => f.category == filter).toList();
//     }
//   }

//   // Toggles favorite status locally
//   void toggleFavorite(String fundraiserId) {
//     setState(() {
//       if (_favoriteIds.contains(fundraiserId)) {
//         _favoriteIds.remove(fundraiserId);
//       } else {
//         _favoriteIds.add(fundraiserId);
//       }
//     });
//   }

//   // Checks if a fundraiser is a favorite locally
//   bool isFavorite(String fundraiserId) {
//     return _favoriteIds.contains(fundraiserId);
//   }

//   // Updates the filter and rebuilds the UI for the "Urgent" section
//   void setUrgentFilter(String? filter) {
//     setState(() {
//       _selectedFilterUrgent = filter ?? 'All';
//       _urgentFundraisers = _getFilteredFundraisers(_selectedFilterUrgent);
//     });
//   }

//   // Updates the filter and rebuilds the UI for the "More to Help" section
//   void setMoreFilter(String? filter) {
//     setState(() {
//       _selectedFilterMore = filter ?? 'All';
//       _moreToHelpFundraisers = _getFilteredFundraisers(_selectedFilterMore)
//         ..sort((a, b) => b.donators.compareTo(a.donators));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: ModernAppBar(
//         title: 'Home',
//         showLogo: true,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, size: 28),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => SearchPage()),
//               );
//             },
//           ),
//           SizedBox(width: 15),
//           IconButton(
//             icon: Icon(Icons.notifications, size: 28),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => NotificationScreen()),
//               );
//             },
//           ),
//           SizedBox(width: 15),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 12),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 12.0),
//               child: Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '\$0',
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text('My wallet balance'),
//                       ],
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => TopUpScreen(),
//                           ),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: Text(
//                         'Top up',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             _buildImageSlider(),
//             SizedBox(height: 16),
//             _buildFundraisingSection(
//               title: 'Urgent Fundraising',
//               fundraisers: _urgentFundraisers,
//               filters: [
//                 'All',
//                 'Medical',
//                 'Disaster',
//                 'Education',
//                 'Environment',
//                 'Social',
//                 'Sick child',
//                 'Infrastructure',
//                 'Art',
//                 'Orphanage',
//                 'Humanity',
//                 'Others',
//               ],
//               selectedFilter: _selectedFilterUrgent,
//               onFilterSelected: setUrgentFilter,
//             ),
//             SizedBox(height: 24),
//             _buildFundraisingSection(
//               title: 'More to Help',
//               fundraisers: _moreToHelpFundraisers,
//               filters: [
//                 'All',
//                 'Medical',
//                 'Education',
//                 'Environment',
//                 'Social',
//                 'Others',
//               ],
//               selectedFilter: _selectedFilterMore,
//               onFilterSelected: setMoreFilter,
//             ),
//             SizedBox(height: 24),

//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImageSlider() {
//     if (_sliderFundraisers.isEmpty) {
//       return Container(
//         height: 200.0,
//         child: Center(child: Text("No featured fundraisers.")),
//       );
//     }

//     return CarouselSlider(
//       options: CarouselOptions(
//         height: 200.0,
//         enlargeCenterPage: true,
//         autoPlay: true,
//         aspectRatio: 16 / 9,
//         autoPlayInterval: Duration(seconds: 4),
//         autoPlayAnimationDuration: Duration(milliseconds: 800),
//         autoPlayCurve: Curves.fastOutSlowIn,
//         enableInfiniteScroll: true,
//         viewportFraction: 0.92,
//       ),
//       items: _sliderFundraisers.map((fundraiser) {
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               CachedNetworkImage(
//                 imageUrl: fundraiser.mainImageUrl,
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 placeholder: (context, url) => Container(
//                   color: Colors.grey[300],
//                   child: Center(
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
//                     ),
//                   ),
//                 ),
//                 errorWidget: (context, url, error) => Container(
//                   color: Colors.grey[300],
//                   child: Icon(Icons.error, color: Colors.red),
//                 ),
//               ),
//               Container(
//                 alignment: Alignment.bottomLeft,
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                     colors: [Colors.black.withOpacity(0.6), Colors.transparent],
//                   ),
//                 ),
//                 child: Text(
//                   fundraiser.title,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildFundraisingSection({
//     required String title,
//     required List<Fundraiser> fundraisers,
//     required List<String> filters,
//     required String selectedFilter,
//     required Function(String?) onFilterSelected,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: -0.5,
//                 ),
//               ),
//               TextButton.icon(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => SearchPage(initialTabIndex: 0),
//                     ),
//                   );
//                 },
//                 icon: Icon(Icons.arrow_forward, size: 16, color: Colors.green),
//                 label: Text(
//                   'See all',
//                   style: TextStyle(
//                     color: Colors.green,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 style: TextButton.styleFrom(
//                   minimumSize: Size.zero,
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         if (filters.isNotEmpty)
//           Padding(
//             padding: EdgeInsets.only(bottom: 12.0),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               padding: EdgeInsets.symmetric(horizontal: 16.0),
//               child: Row(
//                 children: filters
//                     .map(
//                       (filter) => Padding(
//                         padding: const EdgeInsets.only(right: 8.0),
//                         child: FilterChip(
//                           label: Text(
//                             filter,
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: selectedFilter == filter
//                                   ? FontWeight.w600
//                                   : FontWeight.normal,
//                               color: selectedFilter == filter
//                                   ? Colors.white
//                                   : Colors.black87,
//                             ),
//                           ),
//                           selected: selectedFilter == filter,
//                           onSelected: (bool selected) {
//                             onFilterSelected(selected ? filter : 'All');
//                           },
//                           backgroundColor: Colors.grey[200],
//                           selectedColor: Colors.green,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           elevation: 0,
//                           pressElevation: 2,
//                           shadowColor: Colors.black26,
//                           padding: EdgeInsets.symmetric(horizontal: 8),
//                         ),
//                       ),
//                     )
//                     .toList(),
//               ),
//             ),
//           ),

//         // This container now directly builds the list from the passed 'fundraisers' data
//         fundraisers.isEmpty
//             ? Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(24.0),
//                   child: Text('No fundraisers found for this filter.'),
//                 ),
//               )
//             : Container(
//                 height: 265,
//                 child: ListView.builder(
//                   padding: EdgeInsets.symmetric(horizontal: 16.0),
//                   scrollDirection: Axis.horizontal,
//                   itemCount: fundraisers.length,
//                   itemBuilder: (context, index) {
//                     var fundraiser = fundraisers[index];
//                     double progress =
//                         fundraiser.funding / fundraiser.donationAmount;
//                     int daysLeft = fundraiser.expirationDate
//                         .difference(DateTime.now())
//                         .inDays;
//                     bool isFavorited = isFavorite(fundraiser.id);

//                     return Padding(
//                       padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
//                       child: Container(
//                         width: 260,
//                         constraints: BoxConstraints(
//                           minHeight: 260,
//                           maxHeight: 280,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.05),
//                               blurRadius: 8,
//                               offset: Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Stack(
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(16),
//                               child: Column(
//                                 children: [
//                                   Expanded(
//                                     child: Material(
//                                       color: Colors.transparent,
//                                       child: InkWell(
//                                         onTap: () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   AssociationScreen(
//                                                     fundraiser: fundraiser,
//                                                   ),
//                                             ),
//                                           );
//                                         },
//                                         splashColor: Colors.green.withOpacity(
//                                           0.1,
//                                         ),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Stack(
//                                               children: [
//                                                 Container(
//                                                   height: 140,
//                                                   width: double.infinity,
//                                                   child: CachedNetworkImage(
//                                                     imageUrl:
//                                                         fundraiser.mainImageUrl,
//                                                     fit: BoxFit.cover,
//                                                     placeholder:
//                                                         (context, url) =>
//                                                             Container(
//                                                               color: Colors
//                                                                   .grey[300],
//                                                             ),
//                                                     errorWidget:
//                                                         (
//                                                           context,
//                                                           url,
//                                                           error,
//                                                         ) => Container(
//                                                           color:
//                                                               Colors.grey[300],
//                                                           child: Icon(
//                                                             Icons.error,
//                                                             color: Colors.red,
//                                                           ),
//                                                         ),
//                                                   ),
//                                                 ),
//                                                 Positioned(
//                                                   top: 8,
//                                                   right: 8,
//                                                   child: Row(
//                                                     children: [
//                                                       Container(
//                                                         padding:
//                                                             EdgeInsets.symmetric(
//                                                               horizontal: 10,
//                                                               vertical: 6,
//                                                             ),
//                                                         decoration: BoxDecoration(
//                                                           color: Colors.black
//                                                               .withOpacity(0.7),
//                                                           borderRadius:
//                                                               BorderRadius.circular(
//                                                                 20,
//                                                               ),
//                                                         ),
//                                                         child: Row(
//                                                           children: [
//                                                             Icon(
//                                                               Icons.access_time,
//                                                               color:
//                                                                   Colors.white,
//                                                               size: 12,
//                                                             ),
//                                                             SizedBox(width: 4),
//                                                             Text(
//                                                               '$daysLeft days left',
//                                                               style: TextStyle(
//                                                                 color: Colors
//                                                                     .white,
//                                                                 fontSize: 12,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w500,
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                       SizedBox(width: 8),
//                                                       Material(
//                                                         color: Colors.black
//                                                             .withOpacity(0.7),
//                                                         shape: CircleBorder(),
//                                                         child: InkWell(
//                                                           onTap: () =>
//                                                               toggleFavorite(
//                                                                 fundraiser.id,
//                                                               ),
//                                                           customBorder:
//                                                               CircleBorder(),
//                                                           child: Padding(
//                                                             padding:
//                                                                 EdgeInsets.all(
//                                                                   6,
//                                                                 ),
//                                                             child: AnimatedSwitcher(
//                                                               duration: Duration(
//                                                                 milliseconds:
//                                                                     300,
//                                                               ),
//                                                               transitionBuilder:
//                                                                   (
//                                                                     child,
//                                                                     animation,
//                                                                   ) {
//                                                                     return ScaleTransition(
//                                                                       scale:
//                                                                           animation,
//                                                                       child:
//                                                                           child,
//                                                                     );
//                                                                   },
//                                                               child: Icon(
//                                                                 isFavorited
//                                                                     ? Icons
//                                                                           .favorite
//                                                                     : Icons
//                                                                           .favorite_border,
//                                                                 color:
//                                                                     isFavorited
//                                                                     ? Colors.red
//                                                                     : Colors
//                                                                           .white,
//                                                                 size: 18,
//                                                                 key:
//                                                                     ValueKey<
//                                                                       bool
//                                                                     >(
//                                                                       isFavorited,
//                                                                     ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 Positioned(
//                                                   left: 8,
//                                                   top: 8,
//                                                   child: Container(
//                                                     padding:
//                                                         EdgeInsets.symmetric(
//                                                           horizontal: 10,
//                                                           vertical: 6,
//                                                         ),
//                                                     decoration: BoxDecoration(
//                                                       color: Colors.black
//                                                           .withOpacity(0.7),
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                             20,
//                                                           ),
//                                                     ),
//                                                     child: Text(
//                                                       fundraiser.category,
//                                                       style: TextStyle(
//                                                         color: Colors.white,
//                                                         fontSize: 10,
//                                                         fontWeight:
//                                                             FontWeight.w600,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             Expanded(
//                                               child: Padding(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                       horizontal: 12.0,
//                                                       vertical: 4.0,
//                                                     ),
//                                                 child: Column(
//                                                   mainAxisSize:
//                                                       MainAxisSize.min,
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       fundraiser.title,
//                                                       style: TextStyle(
//                                                         fontWeight:
//                                                             FontWeight.w700,
//                                                         fontSize: 16,
//                                                       ),
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                     ),
//                                                     SizedBox(height: 4),
//                                                     ClipRRect(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                             4,
//                                                           ),
//                                                       child: LinearProgressIndicator(
//                                                         value: progress,
//                                                         backgroundColor:
//                                                             Colors.grey[200],
//                                                         valueColor:
//                                                             AlwaysStoppedAnimation<
//                                                               Color
//                                                             >(
//                                                               progress >= 1.0
//                                                                   ? Colors.blue
//                                                                   : Colors
//                                                                         .green,
//                                                             ),
//                                                         minHeight: 4,
//                                                       ),
//                                                     ),
//                                                     SizedBox(height: 4),
//                                                     Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceBetween,
//                                                       children: [
//                                                         Row(
//                                                           children: [
//                                                             Text(
//                                                               '\$${fundraiser.funding.toStringAsFixed(0)}',
//                                                               style: TextStyle(
//                                                                 color: Colors
//                                                                     .green,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w700,
//                                                                 fontSize: 13,
//                                                               ),
//                                                             ),
//                                                             Text(
//                                                               ' of \$${fundraiser.donationAmount.toStringAsFixed(0)}',
//                                                               style: TextStyle(
//                                                                 color: Colors
//                                                                     .grey[600],
//                                                                 fontSize: 13,
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         Row(
//                                                           children: [
//                                                             Icon(
//                                                               Icons.people,
//                                                               size: 13,
//                                                               color: Colors
//                                                                   .grey[600],
//                                                             ),
//                                                             SizedBox(width: 2),
//                                                             Text(
//                                                               '${fundraiser.donators} donors',
//                                                               style: TextStyle(
//                                                                 color: Colors
//                                                                     .grey[600],
//                                                                 fontSize: 11,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w500,
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     width: double.infinity,
//                                     decoration: BoxDecoration(
//                                       gradient: LinearGradient(
//                                         colors: [
//                                           Color(0xFF66BB6A),
//                                           Color(0xFF4CAF50),
//                                           Color(0xFF388E3C),
//                                           Color(0xFF2E7D32),
//                                         ],
//                                         begin: Alignment.centerLeft,
//                                         end: Alignment.centerRight,
//                                       ),
//                                       borderRadius: BorderRadius.only(
//                                         bottomLeft: Radius.circular(16),
//                                         bottomRight: Radius.circular(16),
//                                       ),
//                                     ),
//                                     child: Material(
//                                       color: Colors.transparent,
//                                       child: InkWell(
//                                         onTap: () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) => ChatPage(),
//                                             ),
//                                           );
//                                         },
//                                         child: Padding(
//                                           padding: EdgeInsets.symmetric(
//                                             vertical: 12,
//                                           ),
//                                           child: Text(
//                                             'Become a Part',
//                                             textAlign: TextAlign.center,
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//       ],
//     );
//   }
// }

// // --- REUSABLE WIDGETS ---

// class VideoCard extends StatelessWidget {
//   final String image;
//   final String title;
//   final VoidCallback onTap;

//   const VideoCard({
//     required this.image,
//     required this.title,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 200,
//         margin: EdgeInsets.only(right: 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: 280,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.15),
//                     blurRadius: 12,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(24),
//                 child: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     CachedNetworkImage(
//                       imageUrl: image,
//                       fit: BoxFit.cover,
//                       placeholder: (context, url) => Container(
//                         color: Colors.grey[200],
//                         child: Center(
//                           child: CircularProgressIndicator(
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               Colors.green,
//                             ),
//                           ),
//                         ),
//                       ),
//                       errorWidget: (context, url, error) => Container(
//                         color: Colors.grey[200],
//                         child: Icon(Icons.error),
//                       ),
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Colors.transparent,
//                             Colors.black.withOpacity(0.8),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 16,
//                       left: 16,
//                       right: 16,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             title,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               shadows: [
//                                 Shadow(
//                                   color: Colors.black.withOpacity(0.5),
//                                   offset: Offset(0, 1),
//                                   blurRadius: 4,
//                                 ),
//                               ],
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           SizedBox(height: 8),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons.play_arrow_rounded,
//                                   color: Colors.white,
//                                   size: 20,
//                                 ),
//                                 SizedBox(width: 4),
//                                 Text(
//                                   'Watch Now',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final bool showLogo;
//   final List<Widget>? actions;

//   const ModernAppBar({
//     Key? key,
//     required this.title,
//     this.showLogo = false,
//     this.actions,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: Row(
//         children: [
//           if (showLogo)
//             Padding(
//               padding: const EdgeInsets.only(right: 8.0),
//               child: Icon(
//                 Icons.volunteer_activism,
//                 color: Colors.green,
//               ), // Example logo
//             ),
//           Text(title),
//         ],
//       ),
//       actions: actions,
//     );
//   }

//   @override
//   Size get preferredSize => Size.fromHeight(kToolbarHeight);
// }

// // --- FAKE/PLACEHOLDER SCREENS (to make navigation work) ---

// class TopUpScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(title: Text('Top Up')),
//     body: Center(child: Text('TopUpScreen')),
//   );
// }

// class NotificationScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(title: Text('Notifications')),
//     body: Center(child: Text('NotificationScreen')),
//   );
// }

// class SearchPage extends StatelessWidget {
//   final int? initialTabIndex;
//   SearchPage({this.initialTabIndex});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(title: Text('Search')),
//     body: Center(child: Text('SearchPage')),
//   );
// }

// class AssociationScreen extends StatelessWidget {
//   final Fundraiser? fundraiser; // Changed to use the local model
//   AssociationScreen({this.fundraiser});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(title: Text(fundraiser?.title ?? 'Association')),
//     body: Center(child: Text('Details for: ${fundraiser?.title}')),
//   );
// }

// class ChatPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(title: Text('Chat')),
//     body: Center(child: Text('ChatPage')),
//   );
// }

// class ReelsScreen extends StatelessWidget {
//   final int? initialIndex;
//   final List<VideoReel>? videos; // Changed to use the local model
//   ReelsScreen({this.initialIndex, this.videos});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(title: Text('Reels')),
//     body: Center(child: Text('ReelsScreen')),
//   );
// }
