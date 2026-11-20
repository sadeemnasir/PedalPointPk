import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/cycles.dart';
import '../models/booking.dart';
import '../models/cycle.dart';
import 'booking_storage.dart';

class BackendService {
  SupabaseClient get _supabase => Supabase.instance.client;

  // Fetch all available cycles from Supabase, falling back to default fleet if DB is empty
  Future<List<CycleModel>> fetchAvailableCycles() async {
    try {
      final data = await _supabase
          .from('cycles')
          .select('*, profiles(business_name)')
          .eq('is_available', true)
          .gt('stock_count', 0)
          .order('created_at', ascending: false);

      final list = (data as List)
          .map((e) => CycleModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (list.isEmpty) {
        return cyclesDatabase;
      }
      return list;
    } catch (_) {
      return cyclesDatabase;
    }
  }

  // Fetch cycles owned by the currently logged-in Business account
  Future<List<CycleModel>> fetchBusinessCycles() async {
    final userId = _supabase.auth.currentUser!.id;
    final data = await _supabase
        .from('cycles')
        .select()
        .eq('owner_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => CycleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Add a new cycle to the Business fleet
  Future<void> addCycle(CycleModel cycle) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('cycles').insert(cycle.toInsertJson(userId));
  }

  // Update cycle stock quantity
  Future<void> updateCycleStock(String cycleId, int newStock) async {
    final safeStock = newStock < 0 ? 0 : newStock;
    await _supabase.from('cycles').update({
      'stock_count': safeStock,
      'is_available': safeStock > 0,
    }).eq('id', cycleId);
  }

  // Toggle cycle availability
  Future<void> toggleCycleAvailability(String cycleId, bool isAvailable) async {
    await _supabase
        .from('cycles')
        .update({'is_available': isAvailable})
        .eq('id', cycleId);
  }

  // Delete cycle from Business fleet
  Future<void> deleteCycle(String cycleId) async {
    await _supabase.from('cycles').delete().eq('id', cycleId);
  }

  // Create booking in Supabase + local backup
  Future<Booking> createBooking(Booking booking) async {
    final user = _supabase.auth.currentUser;
    final payload = Booking(
      refCode: booking.refCode,
      customerId: user?.id,
      cycleId: booking.cycleId,
      bikeTitle: booking.bikeTitle,
      city: booking.city,
      delivery: booking.delivery,
      startDate: booking.startDate,
      endDate: booking.endDate,
      days: booking.days,
      customerName: booking.customerName,
      phone: booking.phone,
      cnic: booking.cnic,
      totalAmount: booking.totalAmount,
      status: 'confirmed',
      timestamp: booking.timestamp,
    );

    await BookingStorage.saveBooking(payload);

    if (user != null) {
      final inserted = await _supabase
          .from('bookings')
          .insert(payload.toSupabaseInsert())
          .select()
          .single();
      return Booking.fromSupabase(inserted);
    }
    return payload;
  }

  // Fetch bookings for logged-in Customer
  Future<List<Booking>> fetchCustomerBookings() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return BookingStorage.loadBookings();
    }

    try {
      final data = await _supabase
          .from('bookings')
          .select()
          .eq('customer_id', user.id)
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => Booking.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return BookingStorage.loadBookings();
    }
  }

  // Fetch bookings for logged-in Business (filtered automatically via RLS)
  Future<List<Booking>> fetchBusinessBookings() async {
    final data = await _supabase
        .from('bookings')
        .select()
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => Booking.fromSupabase(e as Map<String, dynamic>))
        .toList();
  }

  // Update booking status (confirmed, active, completed, cancelled)
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _supabase
        .from('bookings')
        .update({'status': status})
        .eq('id', bookingId);
  }
}
