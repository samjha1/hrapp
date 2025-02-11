import 'package:flutter/material.dart';

class LeaveManagementScreen extends StatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  bool isCalendarView = false;
  DateTime selectedDate = DateTime.now();
  List<DateTime> markedDates = [
    DateTime(2025, 1, 6),
    DateTime(2025, 1, 7),
    DateTime(2025, 1, 8),
    DateTime(2025, 1, 24),
    DateTime(2025, 1, 30),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a237e),
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Leave Summary',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildUserInfo(),
          _buildToggleButtons(),
          Expanded(
            child:
                isCalendarView ? _buildCalendarView() : _buildLeaveBalances(),
          ),
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1a237e),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/images/sam.jpg'),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'shivam',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Supervisor',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '090 NANDI  PVT LTD',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => setState(() => isCalendarView = false),
              style: TextButton.styleFrom(
                backgroundColor:
                    !isCalendarView ? const Color(0xFF1a237e) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Leave Balances',
                style: TextStyle(
                  color:
                      !isCalendarView ? Colors.white : const Color(0xFF1a237e),
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () => setState(() => isCalendarView = true),
              style: TextButton.styleFrom(
                backgroundColor:
                    isCalendarView ? const Color(0xFF1a237e) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Leave Calendar',
                style: TextStyle(
                  color:
                      isCalendarView ? Colors.white : const Color(0xFF1a237e),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveBalances() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLeaveCard(
            'Annual Leave',
            7.50,
            0.00,
            7.50,
          ),
          const SizedBox(height: 16),
          _buildLeaveCard(
            'Sick Leave',
            11.00,
            1.00,
            10.00,
          ),
          const SizedBox(height: 16),
          _buildLeaveCard(
            'Unpaid Leave',
            20.00,
            0.00,
            20.00,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveCard(
    String title,
    double eligible,
    double taken,
    double balance,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLeaveDetail('Eligible\n(Earned)', eligible),
              _buildLeaveDetail('Taken', taken),
              _buildLeaveDetail('Balance', balance),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveDetail(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(
            color: Color(0xFF1a237e),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Company',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildCalendar(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 35  , // 6 weeks * 7 days
      itemBuilder: (context, index) {
        final date = DateTime(2025, 1, index - 2); // Adjust starting point
        final isMarked = markedDates.any(
          (marked) =>
              marked.year == date.year &&
              marked.month == date.month &&
              marked.day == date.day,
        );
        final isToday = date.day == 30; // Hardcoded for demo

        return Container(
          decoration: BoxDecoration(
            border: isMarked
                ? Border.all(color: Colors.blue)
                : Border.all(color: Colors.transparent),
            color: isToday ? Colors.green : Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: isToday ? Colors.white : Colors.black87,
                fontWeight: isMarked ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.amber,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Summary',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle_outline),
          label: 'Approve',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.edit_calendar),
          label: 'Apply',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
      ],
      currentIndex: 0,
      onTap: (index) {},
    );
  }
}
