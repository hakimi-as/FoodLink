import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfile(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Profile updated!'),
        backgroundColor: AppColors.greenDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Failed to update profile'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: c.elevated,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.arrow_back,
                          size: 16, color: AppColors.bodyText),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('User Details',
                        style: GoogleFonts.sora(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: c.text)),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: c.border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Read-only email
                      _ReadOnlyField(
                        label: 'Email Address',
                        value: user?.email ?? '',
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 14),
                      // Read-only role
                      _ReadOnlyField(
                        label: 'Role',
                        value: user != null
                            ? '${user.role[0].toUpperCase()}${user.role.substring(1)}'
                            : '',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'EDITABLE FIELDS',
                        style: GoogleFonts.dmSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: c.muted,
                          letterSpacing: 0.9,
                        ),
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Full Name',
                        placeholder: 'Your full name',
                        icon: Icons.person_outline,
                        controller: _nameCtrl,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Phone Number',
                        placeholder: '+60 12-345 6789',
                        icon: Icons.phone_outlined,
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: auth.loading ? null : _save,
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
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: auth.loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Text('Save Changes',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _ReadOnlyField(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: c.muted,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: c.elevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.border, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFCBD5E1), size: 18),
                const SizedBox(width: 12),
                Text(value,
                    style: GoogleFonts.dmSans(
                        fontSize: 15, color: c.muted)),
              ],
            ),
          ),
        ],
      );
  }
}
