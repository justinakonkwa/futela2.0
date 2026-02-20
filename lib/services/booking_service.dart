import 'package:dio/dio.dart';
import '../models/booking/reservation.dart';
import '../models/booking/visit.dart';
import 'api_client.dart';

class BookingService {
  final Dio _dio;

  BookingService() : _dio = ApiClient().dio;

  // --- Reservations ---

  Future<Reservation> createReservation({
    required String propertyId,
    required String startDate,
    required String endDate,
    required int numberOfGuests,
    String? specialRequests,
  }) async {
    final response = await _dio.post('/api/reservations', data: {
      'propertyId': propertyId,
      'startDate': startDate,
      'endDate': endDate,
      'numberOfGuests': numberOfGuests,
      'specialRequests': specialRequests,
    });

    if (response.statusCode == 201) {
      return Reservation.fromJson(response.data);
    } else {
      throw Exception('Failed to create reservation: ${response.data}');
    }
  }

  Future<Reservation> getReservation(String id) async {
    final response = await _dio.get('/api/reservations/$id');
    if (response.statusCode == 200) {
      return Reservation.fromJson(response.data);
    } else {
      throw Exception('Failed to retrieve reservation');
    }
  }

  Future<void> cancelReservation(String id, String reason) async {
    await _dio.post('/api/reservations/$id/cancel', data: {'reason': reason});
  }

  Future<List<Reservation>> getMyReservations(
      {String status = 'pending'}) async {
    final response = await _dio.get('/api/me/reservations', queryParameters: {
      'status': status,
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Reservation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch my reservations');
    }
  }

  // --- Visits ---

  Future<Visit> scheduleVisit({
    required String propertyId,
    required String date,
    required String time,
  }) async {
    // Combine date and time to ISO 8601 if needed, or pass separately depending on backend expectation
    final dateTime = '${date}T$time';
    final response = await _dio.post('/api/visits', data: {
      'propertyId': propertyId,
      'scheduledAt': dateTime,
    });

    if (response.statusCode == 201) {
      return Visit.fromJson(response.data);
    } else {
      throw Exception('Failed to schedule visit: ${response.data}');
    }
  }

  Future<List<Visit>> getMyVisits({String status = 'scheduled'}) async {
    final response = await _dio.get('/api/me/visits', queryParameters: {
      'status': status,
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Visit.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch visits');
    }
  }

  Future<void> cancelVisit(String id) async {
    await _dio.delete('/api/visits/$id');
  }
}
