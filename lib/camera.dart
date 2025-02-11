import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For platform check

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  XFile? _capturedImage;
  Uint8List? _webImageBytes; // Store image bytes for web
  bool _isUploading = false;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.medium);
      await _controller!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final image = await _controller!.takePicture();

      if (kIsWeb) {
        // Convert XFile to bytes for web
        final bytes = await image.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
        });
      } else {
        setState(() {
          _capturedImage = image;
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_capturedImage == null && _webImageBytes == null) return;

    setState(() {
      _isUploading = true;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost/api/wereads/upload.php'), // Adjust as needed
    );

    String imageName = "image_${DateTime.now().millisecondsSinceEpoch}.jpg";

    if (!kIsWeb) {
      request.files.add(
          await http.MultipartFile.fromPath('image', _capturedImage!.path));
    } else {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        _webImageBytes!,
        filename: imageName,
      ));
    }

    request.fields['image_name'] = imageName; // Send image name

    try {
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      setState(() {
        _isUploading = false;
        if (response.statusCode == 200) {
          _uploadedImageUrl = "http://localhost/uploads/$imageName";
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload Successful!')),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload Failed! Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera App')),
      body: Column(
        children: [
          Expanded(
            child: _isCameraInitialized
                ? CameraPreview(_controller!)
                : Center(child: CircularProgressIndicator()),
          ),
          if (_capturedImage != null || _webImageBytes != null) ...[
            SizedBox(height: 10),
            kIsWeb
                ? Image.memory(_webImageBytes!,
                    height: 200) // Display image in web
                : Image.file(File(_capturedImage!.path),
                    height: 200), // Display image in mobile
            SizedBox(height: 10),
          ],
          if (_isUploading) CircularProgressIndicator(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _takePicture,
                child: Text('Capture'),
              ),
              if (_capturedImage != null || _webImageBytes != null)
                ElevatedButton(
                  onPressed: _uploadImage,
                  child: Text('Upload'),
                ),
            ],
          ),
          if (_uploadedImageUrl != null) ...[
            SizedBox(height: 20),
            Text("Uploaded Image:"),
            Image.network(_uploadedImageUrl!),
          ],
        ],
      ),
    );
  }
}
