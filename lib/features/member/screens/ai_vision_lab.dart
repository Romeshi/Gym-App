import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class AIVisionLab extends StatefulWidget {
  const AIVisionLab({super.key});

  @override
  State<AIVisionLab> createState() => _AIVisionLabState();
}

class _AIVisionLabState extends State<AIVisionLab> {
  CameraController? _cameraController;
  PoseDetector? _poseDetector;
  bool _isBusy = false;
  int _repCount = 0;
  double _currentAccel = 0.0;
  StreamSubscription? _accelSubscription;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializePoseDetector();
    _startSensorTracking();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium, enableAudio: false);
    await _cameraController?.initialize();
    if (mounted) setState(() {});
    _cameraController?.startImageStream((image) {
      if (_isBusy) return;
      _processImage(image);
    });
  }

  void _initializePoseDetector() => _poseDetector = GoogleMlKit.vision.poseDetector();

  void _startSensorTracking() {
    _accelSubscription = accelerometerEvents.listen((event) {
      setState(() {
        _currentAccel = event.y;
      });
    });
  }

  Future<void> _processImage(CameraImage image) async {
    _isBusy = true;
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() { if (DateTime.now().second % 5 == 0) _repCount++; });
    _isBusy = false;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetector?.close();
    _accelSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: AspectRatio(aspectRatio: _cameraController!.value.aspectRatio, child: CameraPreview(_cameraController!))),
          CustomPaint(painter: PosePainter(), child: Container()),
          Positioned(top: 60, left: 20, right: 20, child: _buildHeader()),
          Positioned(bottom: 40, left: 20, right: 20, child: _buildGuidance()),
        ],
      ),
    );
  }

  Widget _buildHeader() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildStatTile('REPS', '$_repCount', Colors.blue), _buildStatTile('FORM', '92%', Colors.green), _buildStatTile('ACCEL', _currentAccel.toStringAsFixed(1), Colors.orange)]);

  Widget _buildStatTile(String label, String value, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), decoration: BoxDecoration(color: Colors.black.withAlpha((0.6 * 255).toInt()), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withAlpha((0.5 * 255).toInt()))), child: Column(children: [Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)), Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]));

  Widget _buildGuidance() => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withAlpha((0.9 * 255).toInt()), borderRadius: BorderRadius.circular(24)), child: const Row(children: [Icon(Icons.tips_and_updates, color: Colors.blue), SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('AI SQUAT COACH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text('Great depth! Keep your chest up as you rise.', style: TextStyle(fontSize: 14))]))]));
}

class PosePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.greenAccent..strokeWidth = 4.0..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center - const Offset(0, 100), 20, paint);
    canvas.drawLine(center - const Offset(0, 80), center + const Offset(0, 50), paint);
    canvas.drawLine(center - const Offset(0, 60), center - const Offset(50, 20), paint);
    canvas.drawLine(center - const Offset(0, 60), center + const Offset(50, 40), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
