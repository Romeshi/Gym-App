import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fithub_gym/core/providers/gym_provider.dart';

// --- Local Theme Configuration for a Premium Finish ---
class ModernUI {
  static const Color primaryBlue = Color(0xFF2962FF);
  static const Color darkBlue = Color(0xFF1A237E);
  static const Color fieldBg = Color(0xFFF8F9FA); // Clean soft grey fill

  static InputDecoration fieldDecoration({
    required String label,
    required IconData prefixIcon,
    Widget? suffixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: fieldBg,
      prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600),
      prefixText: prefixText,
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),

      // Modern smooth corner radii matching app aesthetics
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}

class RegisterGymScreen extends StatefulWidget {
  const RegisterGymScreen({super.key});

  @override
  State<RegisterGymScreen> createState() => _RegisterGymScreenState();
}

class _RegisterGymScreenState extends State<RegisterGymScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gymNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isBotVerified = false;

  // Initial Location (Moratuwa)
  LatLng _selectedLocation = const LatLng(6.8060, 79.8937);
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _checkInitialPermissions();
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _phoneController.dispose();
    _gymNameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _checkInitialPermissions() async {
    await Permission.location.request();
  }

  Future<void> _updateLocationDisplay(LatLng point) async {
    setState(() => _selectedLocation = point);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      String areaName = placemarks.isNotEmpty
          ? placemarks.first.locality ?? "Unknown"
          : "Unknown";

      setState(() {
        _locationController.text =
            "${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)} ($areaName)";
      });
    } catch (e) {
      setState(() {
        _locationController.text =
            "${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}";
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      setState(() => _isLoading = true);
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        LatLng currentLatLng = LatLng(position.latitude, position.longitude);
        await _updateLocationDisplay(currentLatLng);
        _mapController.move(currentLatLng, 15.0);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Terms and Conditions"),
        content: const SingleChildScrollView(
          child: Text(
            "1. Accurate Data: You agree to provide real location data.\n\n"
            "2. Privacy: Gym data is used to connect users with facilities.\n\n"
            "3. Verification: We use email and SMS verification for security.\n\n"
            "4. Account Security: Owners are responsible for their credentials.",
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> _simulateVerification() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isBotVerified = true;
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Identity Verified Successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _handleRegistration() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept Terms and Conditions')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      String fullPhoneNumber = "+94${_phoneController.text.trim()}";

      try {
        final success = await context.read<GymProvider>().registerNewGym(
          id: 'GYM-${DateTime.now().millisecond}',
          gymName: _gymNameController.text,
          location: _locationController.text,
          ownerName: _ownerNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phoneNumber: fullPhoneNumber,
        );

        if (success && mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Row(
                children: [
                  Icon(Icons.mark_email_read, color: Colors.green),
                  SizedBox(width: 10),
                  Text("Verify Your Email"),
                ],
              ),
              content: Text(
                "A verification link has been sent to ${_emailController.text}.\n\nPlease check your inbox and click the link to activate your account before logging in.",
                style: const TextStyle(fontSize: 15),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "OK, I'll Check",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register Your Gym',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Owner Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ModernUI.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Owner Full Name Input
                  _buildTextField(
                    _ownerNameController,
                    'Owner Full Name',
                    Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  // Phone Number Input with Clean Prefix Styling
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: ModernUI.fieldDecoration(
                      label: 'Phone Number',
                      prefixIcon: Icons.phone_outlined,
                      prefixText: '+94 ',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      if (value.length < 9) return 'Invalid phone number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Gym Name Input
                  _buildTextField(
                    _gymNameController,
                    'Gym Name',
                    Icons.fitness_center_outlined,
                  ),
                  const SizedBox(height: 25),

                  const Text(
                    "Pin Gym Location",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ModernUI.darkBlue,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- Map Card Container with Rounded Bounds and Shadow ---
                  Container(
                    height: 230,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _selectedLocation,
                          initialZoom: 13.0,
                          onTap: (tapPos, point) =>
                              _updateLocationDisplay(point),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.fithub.gym',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _selectedLocation,
                                width: 80,
                                height: 80,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 42,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Selected Location Result View Field
                  TextFormField(
                    controller: _locationController,
                    readOnly: true,
                    decoration: ModernUI.fieldDecoration(
                      label: 'Selected Location',
                      prefixIcon: Icons.map_outlined,
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.my_location,
                          color: ModernUI.primaryBlue,
                        ),
                        onPressed: _getCurrentLocation,
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please pin a location'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Email Input
                  _buildTextField(
                    _emailController,
                    'Email Address',
                    Icons.email_outlined,
                    isEmail: true,
                  ),
                  const SizedBox(height: 20),

                  // Password Input
                  _buildTextField(
                    _passwordController,
                    'Password',
                    Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Input
                  _buildTextField(
                    _confirmPasswordController,
                    'Confirm Password',
                    Icons.lock_reset_outlined,
                    isPassword: true,
                    isConfirm: true,
                  ),
                  const SizedBox(height: 25),

                  // Captcha Shaded Box
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: _isBotVerified,
                        activeColor: ModernUI.primaryBlue,
                        onChanged: (v) => _simulateVerification(),
                      ),
                      title: const Text(
                        "I'm not a robot",
                        style: TextStyle(fontSize: 15),
                      ),
                      trailing: const Icon(
                        Icons.security,
                        color: ModernUI.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Terms Checklist
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        activeColor: ModernUI.primaryBlue,
                        onChanged: (value) =>
                            setState(() => _acceptTerms = value!),
                      ),
                      const Text("I agree to the "),
                      GestureDetector(
                        onTap: _showTermsDialog,
                        child: const Text(
                          "Terms and Conditions",
                          style: TextStyle(
                            color: ModernUI.primaryBlue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),

                  // Styled Action Execution Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: (_isLoading || !_isBotVerified)
                          ? null
                          : _handleRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ModernUI.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Complete Registration',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Clean Global Progress Screen Overlay
          if (_isLoading)
            Container(
              color: Colors.black12,
              child: const Center(
                child: CircularProgressIndicator(color: ModernUI.primaryBlue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    bool isEmail = false,
    bool isConfirm = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword
          ? (isConfirm ? _obscureConfirmPassword : _obscurePassword)
          : false,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: ModernUI.fieldDecoration(
        label: label,
        prefixIcon: icon,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  (isConfirm ? _obscureConfirmPassword : _obscurePassword)
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey.shade600,
                ),
                onPressed: () => setState(() {
                  if (isConfirm) {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  } else {
                    _obscurePassword = !_obscurePassword;
                  }
                }),
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
        if (isEmail && !value.contains('@')) return 'Invalid email';
        if (isPassword && value.length < 6) return 'Password too short';
        if (isConfirm && value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}
