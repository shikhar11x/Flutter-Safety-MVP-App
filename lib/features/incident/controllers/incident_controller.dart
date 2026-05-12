import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class IncidentController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isSubmitted = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedType = 'Theft'.obs;
  final RxBool isFetchingLocation = false.obs;
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final RxBool locationCaptured = false.obs;

  final List<String> incidentTypes = [
    'Theft',
    'Assault',
    'Accident',
    'Fire',
    'Suspicious Activity',
    'Medical Emergency',
    'Other',
  ];

  Future<void> captureLocation() async {
    isFetchingLocation.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorMessage.value = 'Location services are disabled.';
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          errorMessage.value = 'Location permission denied.';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        errorMessage.value = 'Location permission permanently denied.';
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;
      locationCaptured.value = true;
    } catch (e) {
      errorMessage.value = 'Failed to get location: $e';
    } finally {
      isFetchingLocation.value = false;
    }
  }

  Future<void> submitIncident(String description) async {
    if (description.trim().isEmpty) {
      errorMessage.value = 'Please enter a description.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not logged in');

      await FirebaseFirestore.instance.collection('incidents').add({
        'uid': uid,
        'type': selectedType.value,
        'description': description.trim(),
        'imageUrl': null,
        'latitude': locationCaptured.value ? latitude.value : null,
        'longitude': locationCaptured.value ? longitude.value : null,
        'locationCaptured': locationCaptured.value,
        'timestamp': DateTime.now(),
      });

      isSubmitted.value = true;
    } catch (e) {
      errorMessage.value = 'Failed to submit: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void reset() {
    isSubmitted.value = false;
    errorMessage.value = '';
    selectedType.value = 'Theft';
    locationCaptured.value = false;
    latitude.value = 0.0;
    longitude.value = 0.0;
  }
}