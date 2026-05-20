import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInModel {
  final String id;
  final String userId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String? location;
  final double? latitude;
  final double? longitude;

  CheckInModel({
    required this.id,
    required this.userId,
    required this.checkInTime,
    this.checkOutTime,
    this.location,
    this.latitude,
    this.longitude,
  });

  factory CheckInModel.fromMap(Map<String, dynamic> map, String id) {
    return CheckInModel(
      id: id,
      userId: map['userId'] ?? '',
      checkInTime: (map['checkInTime'] as Timestamp).toDate(),
      checkOutTime: map['checkOutTime'] != null
          ? (map['checkOutTime'] as Timestamp).toDate()
          : null,
      location: map['location'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}