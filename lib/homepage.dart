import 'dart:convert'; // Import to decode JSON
import 'package:flutter/material.dart';
import 'package:hrms/attendence.dart';
import 'package:hrms/leaves.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrms/leavesmanagement.dart';
import 'package:intl/intl.dart'; // Import the intl package

class HRDashboard extends StatefulWidget {
  const HRDashboard({super.key});

  @override
  _HRDashboardState createState() => _HRDashboardState();
}

class _HRDashboardState extends State<HRDashboard> {
  String _username = ''; // Variable to store username

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  // Fetch username from SharedPreferences
  _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData =
        prefs.getString('user_data'); // Assuming user data is saved as a string
    if (userData != null) {
      var user = jsonDecode(userData);
      setState(() {
        _username = user['username'] ?? ''; // Retrieve the username
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background Container with Gradient
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nandi Properties',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey[200],
                              backgroundImage:
                                  const AssetImage("assets/images/sam.jpg"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Welcome Text
                  _username.isEmpty
                      ? const CircularProgressIndicator() // Show loading until username is fetched
                      : Text(
                          'HELLO, $_username!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                  const Text(
                    'Nandi Properties',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Notification Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now()), // Format the date
                              style: TextStyle(
                                color: const Color(0xFF1E3A8A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Hooray! Today is Pay-Day!',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Get yourself a treat!',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Question
                  const Text(
                    'What do you want to do today?',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Grid Menu
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      children: [
                        MenuIcon(
                          icon: Icons.access_time_rounded,
                          label: 'Attendance',
                          color: const Color(0xFF3B82F6),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AttendanceScreen(),
                              ),
                            );
                          },
                        ),
                        MenuIcon(
                          icon: Icons.calendar_today_rounded,
                          label: 'Leave',
                          color: const Color(0xFF10B981),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeaveManagementScreen(),
                              ),
                            );
                          },
                        ),
                        MenuIcon(
                          icon: Icons.description_rounded,
                          label: 'Claims',
                          color: const Color(0xFFF59E0B),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmployeeLeavesScreen(),
                              ),
                            );
                          },
                        ),
                        MenuIcon(
                          icon: Icons.mail_rounded,
                          label: 'Payslip',
                          color: const Color(0xFFEF4444),
                          onPressed: () {},
                        ),
                        MenuIcon(
                          icon: Icons.calculate_rounded,
                          label: 'Income Tax',
                          color: const Color(0xFF8B5CF6),
                          onPressed: () {},
                        ),
                        MenuIcon(
                          icon: Icons.file_copy_rounded,
                          label: 'HR Memos',
                          color: const Color(0xFFEC4899),
                          onPressed: () {},
                        ),
                        MenuIcon(
                          icon: Icons.business_rounded,
                          label: 'Company\nPolicies',
                          color: const Color(0xFF14B8A6),
                          onPressed: () {},
                        ),
                        MenuIcon(
                          icon: Icons.meeting_room_rounded,
                          label: 'Meeting\nRoom',
                          color: const Color(0xFF6366F1),
                          onPressed: () {},
                        ),
                        MenuIcon(
                          icon: Icons.grid_view_rounded,
                          label: 'More',
                          color: const Color(0xFF64748B),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Referral Banner
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Refer & Earn!',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Spread the word and we\'ll',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFBBF24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Click to Share Now',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const MenuIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
