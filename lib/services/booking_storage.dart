import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';

class BookingStorage {
  static const _key = 'pedalpoint_bookings';

  static Future<List<Booking>> loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    return raw
        .map((item) => Booking.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveBooking(Booking booking) async {
    final prefs = await SharedPreferences.getInstance();
    final bookings = await loadBookings();
    bookings.insert(0, booking);
    await prefs.setStringList(
      _key,
      bookings.map((b) => jsonEncode(b.toJson())).toList(),
    );
  }
}
