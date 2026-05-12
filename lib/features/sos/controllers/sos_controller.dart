import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class SosController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool sosSent = false.obs;
  final Rx<DateTime?> lastSosTime = Rx<DateTime?>(null);
  final RxString errorMessage = ''.obs;
  final RxDouble? lat = RxDouble(0.0);
  final RxDouble? lng = RxDouble(0.0);

  Future<Position?> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> triggerSos() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not logged in');

      final position = await _getLocation();
      final now = DateTime.now();

      await FirebaseFirestore.instance.collection('sos_events').add({
        'uid': uid,
        'timestamp': now,
        'latitude': position?.latitude ?? 0.0,
        'longitude': position?.longitude ?? 0.0,
        'locationAvailable': position != null,
      });

      lat?.value = position?.latitude ?? 0.0;
      lng?.value = position?.longitude ?? 0.0;
      lastSosTime.value = now;
      sosSent.value = true;
    } catch (e) {
      errorMessage.value = 'SOS failed: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void reset() {
    sosSent.value = false;
    errorMessage.value = '';
  }
}