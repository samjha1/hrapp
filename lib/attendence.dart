import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hrms/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition =
      const LatLng(12.9716, 77.5946); // Default to Bangalore
  Set<Marker> _markers = {};
  String currentLocation = 'Fetching location...';
  String placeName = '';
  String cityName = '';
  String stateName = '';

  final TextEditingController _remarksController = TextEditingController();

  TimeOfDay inTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay outTime = const TimeOfDay(hour: 16, minute: 0);
  String _username = '';
  String _image = '';
  String _empid = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadUsername();
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentPosition,
      ),
    );
  }

  _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user_data');
    if (userData != null) {
      var user = jsonDecode(userData);
      setState(() {
        _username = user['username'] ?? '';
        _empid = user['emp_id'] ?? '';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        currentLocation = 'Location services are disabled';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          currentLocation = 'Location permissions denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        currentLocation = 'Location permissions permanently denied';
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      _updateLocation(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        currentLocation = 'Unable to fetch location';
      });
    }
  }

  Future<void> _updateLocation(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        setState(() {
          _currentPosition = LatLng(latitude, longitude);
          placeName = place.name ?? "";
          cityName = place.locality ?? "";
          stateName = place.administrativeArea ?? "";
          currentLocation =
              '$placeName, $cityName, $stateName'; // Display in UI

          _markers = {
            Marker(
              markerId: const MarkerId('current_location'),
              position: _currentPosition,
              infoWindow: InfoWindow(
                title: 'Current Location',
                snippet: '$placeName, $cityName, $stateName',
              ),
            ),
          };

          _mapController?.animateCamera(
            CameraUpdate.newLatLng(_currentPosition),
          );
        });
      }
    } catch (e) {
      setState(() {
        currentLocation = 'Failed to get place name';
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isInTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isInTime ? inTime : outTime,
    );
    if (picked != null) {
      setState(() {
        if (isInTime) {
          inTime = picked;
        } else {
          outTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    String hour = time.hourOfPeriod.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getPeriod(TimeOfDay time) {
    return time.period == DayPeriod.am ? 'AM' : 'PM';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Attendance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Map Container
          Container(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                setState(() {
                  _mapController = controller;
                  controller.animateCamera(
                    CameraUpdate.newLatLng(_currentPosition),
                  );
                });
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _markers,
              mapType: MapType.normal,
            ),
          ),

          // Location Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    currentLocation,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Employee ID and Company
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _empid,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'InDataAi',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Employee Name
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text(
                            _username,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Time Selection
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectTime(context, true),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'In',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          _formatTime(inTime),
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _getPeriod(inTime),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectTime(context, false),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Out',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          _formatTime(outTime),
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _getPeriod(outTime),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Time Statistics
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTimeStatus('Late:', '0.00'),
                          _buildTimeStatus('Under:', '0.00'),
                          _buildTimeStatus('OT:', '0.00'),
                        ],
                      ),
                    ),

                    // Location Selection
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 12, vertical: 10),
                    //     decoration: BoxDecoration(
                    //       color: Colors.grey[100],
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     child: TextField(
                    //       controller: TextEditingController(
                    //         text: _currentPosition != null
                    //             ? "${_currentPosition.latitude}, ${_currentPosition.longitude}"
                    //             : "Fetching location...",
                    //       ),
                    //       readOnly: true, // Prevent user from editing manually
                    //       decoration: const InputDecoration(
                    //         labelText: 'Work Location',
                    //         border: OutlineInputBorder(),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    // Remarks
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _remarksController,
                        decoration: InputDecoration(
                          labelText: 'Remarks (optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CameraPage()),
                        );
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        child: Icon(Icons.camera_alt,
                            size: 50, color: Colors.grey[600]),
                      ),
                    ),

                    // Submit Button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          var url = Uri.parse(
                              'https://landlink.in/attendence_api.php');
                          var response = await http.post(url, body: {
                            'username': _username,
                            'employee_id': _empid,
                            'location': currentLocation,
                            'state':
                                '${_currentPosition.latitude}, ${_currentPosition.longitude}',
                            'in_time': _formatTime(inTime),
                            'out_time': _formatTime(outTime),
                            'remarks': _remarksController.text,
                          });
                          if (response.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Attendance successfully marked'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to mark attendance'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Clock My Attendance',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeStatus(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
