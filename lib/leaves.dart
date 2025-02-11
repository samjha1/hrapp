import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmployeeLeavesScreen extends StatefulWidget {
  const EmployeeLeavesScreen({super.key});

  @override
  _EmployeeLeavesScreenState createState() => _EmployeeLeavesScreenState();
}

class _EmployeeLeavesScreenState extends State<EmployeeLeavesScreen> {
  List<Map<String, dynamic>> leaveRequests = [];
  bool isLoading = true; // To show loading state
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchLeaveRequests();
  }

  Future<void> _fetchLeaveRequests() async {
    const String apiUrl =
        'http://localhost/api/hrms/leaves_fetch.php'; // Replace with your API URL

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          leaveRequests = data.map((item) {
            return {
              'leave_type': item['leave_type'],
              'start_date': item['start_date'],
              'reason': item['reason'],
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Leaves'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Text(
                    'Failed to load leave requests. Please try again later.',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : leaveRequests.isEmpty
                  ? const Center(child: Text('No leave requests found.'))
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        itemCount: leaveRequests.length,
                        itemBuilder: (context, index) {
                          final request = leaveRequests[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'leave type: ${request['leave_type']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('start date: ${request['start_date']}'),
                                  const SizedBox(height: 4),
                                  Text('Reason: ${request['reason']}'),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          _handleApprove(
                                              context, request['name']);
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.green,
                                        ),
                                        child: const Text('Approve'),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton(
                                        onPressed: () {
                                          _handleReject(
                                              context, request['name']);
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Reject'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  void _handleApprove(BuildContext context, String? name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Approved leave for $name')),
    );
  }

  void _handleReject(BuildContext context, String? name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rejected leave for $name')),
    );
  }
}
