import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';

class GpsScreen extends StatefulWidget {
  const GpsScreen({super.key});

  @override
  State<GpsScreen> createState() => _GpsScreenState();
}

class _GpsScreenState extends State<GpsScreen> {
  bool _isLoading = false;
  Position? _position;
  String? _errorMessage;

  Future<void> _fetchLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _errorMessage = 'Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _errorMessage = 'Location permission denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _errorMessage =
            'Location permission permanently denied. Enable from settings.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      setState(() => _position = position);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to get location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'GPS Tracking',
          style: TextStyle(
            color: AppTheme.textLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2196F3).withOpacity(0.15),
                  border: Border.all(
                    color: const Color(0xFF2196F3).withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF2196F3),
                  size: 48,
                ),
              ),

              const SizedBox(height: 24),

              if (_isLoading) ...[
                const CircularProgressIndicator(
                  color: Color(0xFF2196F3),
                  strokeWidth: 2,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Fetching your location...',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 14,
                  ),
                ),
              ] else if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _fetchLocation,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                  ),
                ),
              ] else if (_position != null) ...[
                const Text(
                  'Location Found',
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                AppCard(
                  hasBorder: true,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _LocationRow(
                        icon: Icons.north_rounded,
                        label: 'Latitude',
                        value: _position!.latitude.toStringAsFixed(6),
                        color: const Color(0xFF2196F3),
                      ),
                      const Divider(color: Colors.white10, height: 24),
                      _LocationRow(
                        icon: Icons.east_rounded,
                        label: 'Longitude',
                        value: _position!.longitude.toStringAsFixed(6),
                        color: const Color(0xFF2196F3),
                      ),
                      const Divider(color: Colors.white10, height: 24),
                      _LocationRow(
                        icon: Icons.speed_rounded,
                        label: 'Accuracy',
                        value: '±${_position!.accuracy.toStringAsFixed(1)} m',
                        color: AppTheme.success,
                      ),
                      const Divider(color: Colors.white10, height: 24),
                      _LocationRow(
                        icon: Icons.terrain_rounded,
                        label: 'Altitude',
                        value: '${_position!.altitude.toStringAsFixed(1)} m',
                        color: AppTheme.warning,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _fetchLocation,
                    icon: const Icon(Icons.my_location_rounded),
                    label: const Text(
                      'Refresh Location',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _LocationRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}