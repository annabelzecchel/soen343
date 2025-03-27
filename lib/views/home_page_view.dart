import 'package:flutter/material.dart';
import 'package:soen343/controllers/event_controller.dart';
import 'package:soen343/models/event_model.dart';
import 'package:soen343/views/profile_view.dart';
import 'package:soen343/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soen343/event_management_page.dart';
import 'package:soen343/views/event_detail_view.dart';
import 'package:soen343/views/chat_rooms_view.dart';
import '../controllers/profile_controller.dart';
import '../components/auth_service.dart';
import '../models/users_model.dart';
import '../controllers/profile_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ProfileController _profileController = ProfileController(AuthService());
  int _currentIndex = 0;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final FirebaseAuth _auth =FirebaseAuth.instance;
  User?_currentUser;
  String? type;
  String? name;
  
  
  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user){
      setState((){
        _currentUser=user;
      _fetchUserRole();
      });
    });
  }

  // Future<void> _fetchUserRole() async {
  //   final user = FirebaseAuth.instance.currentUser;

  //   if (user != null) {
  //     String userRole = await _profileController.getRoleById(user.uid);
  //      String userName = await _profileController.getNameById(user.uid);
  //     setState(() {
  //       type = userRole;
  //       name = userName;
  //     });
  //   }
  // }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userRole = await _profileController.getRoleById(user.uid);
       String userName = await _profileController.getNameById(user.uid);
      setState(() {
        type = userRole;
        name = userName;
      });
    }
  }

  final List<String> _categories = [
    'All',
    'Music',
    'Food',
    'Sports',
    'Business',
    'Education',
    'Art',
    'Technology'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventController = EventController();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // Soft green background
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary, // Lighter green
        elevation: 0,
        toolbarHeight: 90,
        title: Row(
          children: [
            Image.asset(
              '../../assets/Planini_NoBackground.png',
              height: 90,
            ),
            const SizedBox(width: 12),
            Text(
              widget.title,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.brown[800], // Dark brown text
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.event, color: Colors.brown[600]), // Brown icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventManagementPage(
                    title: 'Event Management',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.chat, color: Colors.brown[600]),
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatRoomsView(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(title: 'Login !'),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.brown[600]),
            onPressed: () {},
          ),
          if (_currentUser!=null)
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.brown[600]),
            onPressed: () => _navigateToProfile(context),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_currentUser == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(title: 'Sign In!'),
                  ),
                );
              } else {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(title: "HOME"),
                    ));
              }
            },
            child: Text(_currentUser == null ? "Sign in!" : "Sign out!"),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar - Styled with green and brown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.inversePrimary, // Light green
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  hintStyle:
                      TextStyle(color: Colors.brown[600]?.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.search, color: Colors.brown[600]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.brown[600]),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                style: TextStyle(color: Colors.brown[800]),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),

          // Category Chips - Green with brown text
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == _categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(
                      _categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.brown[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) => setState(() {
                      _selectedCategory = selected ? _categories[index] : 'All';
                    }),
                    selectedColor: colorScheme.primary, // Medium green
                    backgroundColor:
                        colorScheme.secondaryContainer, // Light beige
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.brown[300]!,
                        width: 1,
                      ),
                    ),
                    elevation: 2,
                  ),
                );
              },
            ),
          ),

          // Event List
          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: eventController.getEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.brown[600],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading events',
                      style: TextStyle(color: Colors.brown[800]),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available,
                            size: 50, color: Colors.brown[600]),
                        const SizedBox(height: 16),
                        Text(
                          'No events available',
                          style: TextStyle(
                            color: Colors.brown[800],
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter events
                final filteredEvents = snapshot.data!.where((event) {
                  final matchesCategory = _selectedCategory == 'All' ||
                      event.name
                          .toLowerCase()
                          .contains(_selectedCategory.toLowerCase());
                  final matchesSearch = _searchQuery.isEmpty ||
                      event.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      event.location
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                  return matchesCategory && matchesSearch;
                }).toList();

                if (filteredEvents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 50, color: Colors.brown[600]),
                        const SizedBox(height: 16),
                        Text(
                          'No matching events found',
                          style: TextStyle(
                            color: Colors.brown[800],
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Try different search terms',
                          style: TextStyle(
                            color: Colors.brown[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = filteredEvents[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      color: colorScheme.inversePrimary, // Light green
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailView(event: event),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color:
                                          colorScheme.primary, // Medium green
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(event.type ?? 'Event'),
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.name,
                                          style: TextStyle(
                                            color: Colors.brown[800],
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          event.location,
                                          style: TextStyle(
                                            color: Colors.brown[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (event.price != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.brown[50],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '\$${event.price!.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.brown[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Colors.brown[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDateTime(event.dateTime),
                                    style: TextStyle(
                                      color: Colors.brown[600],
                                    ),
                                  ),
                                  const Spacer(),
                                  if (event.attendees.contains(
                                      FirebaseAuth.instance.currentUser?.email))
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 16,
                                            color: Colors.green[800],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Attending',
                                            style: TextStyle(
                                              color: Colors.green[800],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (event.stakeholder==
                                      FirebaseAuth.instance.currentUser?.email)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red[100],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 16,
                                            color: Colors.red[800],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Sponsoring',
                                            style: TextStyle(
                                              color: Colors.red[800],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'music':
        return Icons.music_note;
      case 'food':
        return Icons.restaurant;
      case 'sports':
        return Icons.sports_soccer;
      case 'business':
        return Icons.business;
      case 'education':
        return Icons.school;
      case 'art':
        return Icons.palette;
      case 'technology':
        return Icons.computer;
      default:
        return Icons.event;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year} • ${_formatTime(dateTime)}';
  }

  String _getMonthName(int month) {
    return [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][month - 1];
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _navigateToProfile(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(title: 'Login !'),
        ),
      );
    }
  }
}
