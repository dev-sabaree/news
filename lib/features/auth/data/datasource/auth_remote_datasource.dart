import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login({required String email, required String password});

  Future<AuthResponse> signUp({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  });

  Future<void> logout();

  Session? getCurrentSession();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl(this.supabase);

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return response;
  }

  @override
  Future<AuthResponse> signUp({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone': phone},
    );

    return response;
  }

  @override
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Session? getCurrentSession() {
    return supabase.auth.currentSession;
  }
}
