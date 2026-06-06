import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  FLColors get c => context.clr;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String _role = AppConstants.roleStudent;
  bool _halalChecked = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text,
      role: _role,
    );
    if (!mounted) return;
    if (ok) {
      // Pop back to root so _AuthGate (which now sees isLoggedIn=true) shows MainShell.
      // pushAndRemoveUntil(MainShell) would bypass _AuthGate and break logout.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Registration failed'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // ── App bar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: c.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: c.border, width: 1.5),
                        ),
                        child: const Icon(Icons.arrow_back,
                            size: 18, color: AppColors.bodyText),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Create Account',
                        style: GoogleFonts.sora(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: c.text)),
                  ],
                ),
                const SizedBox(height: 28),
                // ── Step indicator
                Row(
                  children: [
                    _stepBar(true),
                    const SizedBox(width: 6),
                    _stepBar(true),
                    const SizedBox(width: 6),
                    _stepBar(false),
                  ],
                ),
                const SizedBox(height: 24),
                // ── Personal Info
                _sectionLabel('Personal Info'),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Full Name',
                  placeholder: 'e.g. Ahmad bin Ali',
                  icon: Icons.person_outline,
                  controller: _nameCtrl,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Email Address',
                  placeholder: 'you@example.com',
                  icon: Icons.email_outlined,
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter your email' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Phone Number',
                  placeholder: '+60 12-345 6789',
                  icon: Icons.phone_outlined,
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Password',
                  placeholder: 'Min. 6 characters',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passCtrl,
                  validator: (v) => v == null || v.length < 6
                      ? 'Min. 6 characters'
                      : null,
                ),
                const SizedBox(height: 24),
                // ── Role Selection
                _sectionLabel('I am a...'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        icon: Icons.volunteer_activism,
                        title: 'Receiver',
                        desc: 'Claim free food from nearby donors',
                        selected: _role == AppConstants.roleStudent,
                        onTap: () =>
                            setState(() => _role = AppConstants.roleStudent),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleCard(
                        icon: Icons.storefront,
                        title: 'Donor',
                        desc: 'Post surplus food for communities',
                        selected: _role == AppConstants.roleDonor,
                        onTap: () =>
                            setState(() => _role = AppConstants.roleDonor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // ── Halal declaration
                GestureDetector(
                  onTap: () =>
                      setState(() => _halalChecked = !_halalChecked),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFFBBF7D0), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _halalChecked
                                ? AppColors.green
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _halalChecked
                                  ? AppColors.green
                                  : const Color(0xFF86EFAC),
                              width: 2,
                            ),
                          ),
                          child: _halalChecked
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('Halal Declaration',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF15803D))),
                              const SizedBox(height: 1),
                              Text(
                                'I confirm all food I post/receive is Halal-certified',
                                style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: const Color(0xFF4ADE80)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // ── Register button
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => GestureDetector(
                    onTap: auth.loading ? null : _register,
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.42),
                            blurRadius: 22,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: auth.loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person_add,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text('Create Account',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.dmSans(
                          fontSize: 13.5, color: c.muted),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text('Sign in',
                                style: GoogleFonts.dmSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepBar(bool active) => Expanded(
        child: Container(
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: active ? AppColors.primaryGradient : null,
            color: active ? null : c.border,
          ),
        ),
      );

  Widget _sectionLabel(String label) => Text(
        label.toUpperCase(),
        style: GoogleFonts.sora(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: c.muted,
          letterSpacing: 0.8,
        ),
      );
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : c.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : c.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : c.elevated,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon,
                  color: selected ? Colors.white : AppColors.muted,
                  size: 22),
            ),
            const SizedBox(height: 10),
            Text(title,
                style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.text)),
            const SizedBox(height: 4),
            Text(desc,
                style: GoogleFonts.dmSans(
                    fontSize: 11, color: c.muted, height: 1.4),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color:
                      selected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check,
                      color: Colors.white, size: 10)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
