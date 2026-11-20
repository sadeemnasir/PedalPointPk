import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

class AuthService {
  SupabaseClient get _supabase => Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  User? get currentAuthUser => _supabase.auth.currentUser;

  Future<AppUser?> getCurrentUserProfile() async {
    final user = currentAuthUser;
    if (user == null) return null;

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      final meta = user.userMetadata ?? {};
      return AppUser(
        id: user.id,
        email: user.email ?? '',
        fullName: meta['full_name'] as String? ?? 'PedalPoint User',
        phone: meta['phone'] as String?,
        cnic: meta['cnic'] as String?,
        role: meta['role'] == 'business' ? UserRole.business : UserRole.customer,
        businessName: meta['business_name'] as String?,
        cityHub: meta['city_hub'] as String?,
      );
    }

    return AppUser.fromJson(data);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phone,
    String? cnic,
    String? businessName,
    String? cityHub,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
        'cnic': cnic,
        'role': role.name,
        'business_name': role == UserRole.business ? businessName : null,
        'city_hub': role == UserRole.business ? cityHub : null,
      },
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
    required UserRole expectedRole,
  }) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final profile = await getCurrentUserProfile();
    if (profile != null && profile.role != expectedRole) {
      await _supabase.auth.signOut();
      final actualLabel = profile.isBusiness ? 'Business' : 'Customer';
      final chosenLabel =
          expectedRole == UserRole.business ? 'Business' : 'Customer';
      throw Exception(
        'This email is registered as a $actualLabel account, not a $chosenLabel account. Please switch tabs to $actualLabel Login.',
      );
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
