import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.customer;
  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await AuthService().signIn(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        expectedRole: _selectedRole,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusiness = _selectedRole == UserRole.business;
    final compact = MediaQuery.sizeOf(context).width < 420;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 12 : 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              elevation: 8,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: EdgeInsets.all(compact ? 20 : 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              colors: isBusiness
                                  ? const [
                                      Color(0xFF0F172A),
                                      Color(0xFF059669),
                                    ]
                                  : const [
                                      Color(0xFF02569B),
                                      Color(0xFF0175C2),
                                      Color(0xFF00B4AB),
                                    ],
                            ),
                          ),
                          child: Icon(
                            isBusiness ? Icons.storefront : Icons.pedal_bike,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'PedalPoint',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isBusiness
                            ? 'BUSINESS FLEET & INVENTORY LOGIN'
                            : 'CUSTOMER RENTAL LOGIN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w800,
                          color: isBusiness
                              ? const Color(0xFF059669)
                              : const Color(0xFF0175C2),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Customer Login vs Business Login Switcher
                      SegmentedButton<UserRole>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: UserRole.customer,
                            label: Text(compact ? 'Customer' : 'Customer Login'),
                            icon: const Icon(Icons.pedal_bike),
                          ),
                          ButtonSegment(
                            value: UserRole.business,
                            label: Text(compact ? 'Business' : 'Business Login'),
                            icon: const Icon(Icons.storefront),
                          ),
                        ],
                        selected: {_selectedRole},
                        onSelectionChanged: (selection) {
                          setState(() => _selectedRole = selection.first);
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: isBusiness
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFEFF8FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isBusiness
                              ? 'Post your bicycles, set stock availability & manage customer bookings.'
                              : 'Browse verified cycles across Pakistan & book your ride on rent.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isBusiness
                                ? const Color(0xFF047857)
                                : const Color(0xFF02569B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: isBusiness
                              ? 'Business Email Address'
                              : 'Customer Email Address',
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (v) => v == null || !v.contains('@')
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => v == null || v.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBusiness
                              ? const Color(0xFF059669)
                              : const Color(0xFF0175C2),
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isBusiness
                                    ? 'Sign In as Business'
                                    : 'Sign In as Customer',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                              ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            isBusiness
                                ? 'Want to list your cycle shop?'
                                : 'New to PedalPoint?',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SignupScreen(
                                  initialRole: _selectedRole,
                                ),
                              ),
                            ),
                            child: Text(
                              isBusiness
                                  ? 'Register Business'
                                  : 'Create Customer Account',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}