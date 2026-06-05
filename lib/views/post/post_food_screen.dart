import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_provider.dart';
import '../../widgets/custom_text_field.dart';

class PostFoodScreen extends StatefulWidget {
  const PostFoodScreen({super.key});

  @override
  State<PostFoodScreen> createState() => _PostFoodScreenState();
}

class _PostFoodScreenState extends State<PostFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locCtrl = TextEditingController();

  File? _imageFile;
  int _qty = 1;
  TimeOfDay _expiryTime = TimeOfDay.now().replacing(
      hour: (TimeOfDay.now().hour + 4) % 24);
  bool _isHalal = true;
  bool _submitted = false;

  double get _progress {
    double s = 0;
    if (_imageFile != null) s += 0.25;
    if (_titleCtrl.text.length > 3) s += 0.25;
    if (_descCtrl.text.length > 5) s += 0.15;
    if (_locCtrl.text.length > 3) s += 0.15;
    if (_qty > 1) s += 0.1;
    return s.clamp(0.0, 0.9);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _expiryTime);
    if (t != null) setState(() => _expiryTime = t);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final food = context.read<FoodProvider>();
    if (auth.user == null) return;

    final now = DateTime.now();
    final expiry = DateTime(
        now.year, now.month, now.day, _expiryTime.hour, _expiryTime.minute);

    final ok = await food.postFood(
      donorId: auth.user!.uid,
      donorName: auth.user!.name,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      pickupLocation: _locCtrl.text.trim(),
      quantity: _qty,
      expiryTime: expiry,
      isHalal: _isHalal,
      imageFile: _imageFile,
    );

    if (ok && mounted) setState(() => _submitted = true);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(food.error ?? 'Failed to post food'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // App bar
                Container(
                  color: AppColors.card,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(Icons.arrow_back,
                              size: 16, color: AppColors.bodyText),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text('Post Food',
                            style: GoogleFonts.sora(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.dark)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('Save Draft',
                            style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
                // Progress bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 3,
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    onChanged: () => setState(() {}),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      children: [
                        // Image upload
                        GestureDetector(
                          onTap: _pickImage,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 180,
                            decoration: BoxDecoration(
                              color: _imageFile != null
                                  ? null
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: _imageFile != null
                                    ? Colors.transparent
                                    : AppColors.primary.withOpacity(0.35),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              image: _imageFile != null
                                  ? DecorationImage(
                                      image: FileImage(_imageFile!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _imageFile != null
                                ? Stack(
                                    children: [
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.black
                                                .withOpacity(0.4),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.edit,
                                              color: Colors.white,
                                              size: 15),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        child: const Icon(
                                            Icons.camera_alt_outlined,
                                            color: AppColors.primary,
                                            size: 22),
                                      ),
                                      const SizedBox(height: 10),
                                      Text('Add Food Photo',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.dark)),
                                      const SizedBox(height: 4),
                                      Text(
                                          'Tap to choose from gallery or camera',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 11.5,
                                              color: AppColors.muted)),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _sectionTitle('Food Details'),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: 'Food Name / Menu Title',
                          placeholder: 'e.g. Nasi Lemak Ayam Berempah',
                          icon: Icons.restaurant,
                          controller: _titleCtrl,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                        // Description (textarea)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DESCRIPTION',
                                style: GoogleFonts.dmSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.muted,
                                    letterSpacing: 0.9)),
                            const SizedBox(height: 7),
                            TextFormField(
                              controller: _descCtrl,
                              maxLines: 3,
                              style: GoogleFonts.dmSans(
                                  fontSize: 15, color: AppColors.dark),
                              decoration: InputDecoration(
                                hintText:
                                    'Describe the food — ingredients, freshness...',
                                hintStyle: GoogleFonts.dmSans(
                                    color: const Color(0xFFCBD5E1),
                                    fontSize: 15),
                                filled: true,
                                fillColor: AppColors.card,
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(left: 14, top: 14),
                                  child: Icon(Icons.notes,
                                      color: Color(0xFFCBD5E1), size: 18),
                                ),
                                prefixIconConstraints:
                                    const BoxConstraints(minWidth: 44),
                                contentPadding: const EdgeInsets.fromLTRB(
                                    44, 14, 14, 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                      color: AppColors.border, width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                      color: AppColors.border, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                      color: AppColors.primary, width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: 'Pickup Location',
                          placeholder: 'e.g. Main entrance, Level 1, Lobby',
                          icon: Icons.location_on_outlined,
                          controller: _locCtrl,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 22),
                        _sectionTitle('Availability'),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            // Quantity stepper
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: AppColors.border, width: 1.5),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('QUANTITY',
                                        style: GoogleFonts.dmSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.muted,
                                            letterSpacing: 0.8)),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _stepBtn(Icons.remove, () {
                                          if (_qty > 1) {
                                            setState(() => _qty--);
                                          }
                                        }),
                                        Text('$_qty',
                                            style: GoogleFonts.sora(
                                                fontSize: 22,
                                                fontWeight:
                                                    FontWeight.w800,
                                                color: AppColors.dark)),
                                        _stepBtn(Icons.add, () {
                                          setState(() => _qty++);
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Time picker
                            Expanded(
                              child: GestureDetector(
                                onTap: _pickTime,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: AppColors.border,
                                        width: 1.5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('BEST BEFORE',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.muted,
                                              letterSpacing: 0.8)),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time,
                                              color: AppColors.primary,
                                              size: 18),
                                          const SizedBox(width: 6),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _expiryTime.hour > 12
                                                    ? '${_expiryTime.hour - 12}:${_expiryTime.minute.toString().padLeft(2, '0')}'
                                                    : '${_expiryTime.hour}:${_expiryTime.minute.toString().padLeft(2, '0')}',
                                                style: GoogleFonts.sora(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    color: AppColors.dark),
                                              ),
                                              Text(
                                                _expiryTime.hour >= 12
                                                    ? 'PM'
                                                    : 'AM',
                                                style: GoogleFonts.dmSans(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color: AppColors.muted),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _sectionTitle('Certification'),
                        const SizedBox(height: 14),
                        // Halal toggle
                        GestureDetector(
                          onTap: () =>
                              setState(() => _isHalal = !_isHalal),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFF0FDF4),
                                  Color(0xFFDCFCE7)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFBBF7D0),
                                  width: 1.5),
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: _isHalal
                                        ? AppColors.green
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _isHalal
                                          ? AppColors.green
                                          : const Color(0xFF86EFAC),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: _isHalal
                                        ? Colors.white
                                        : const Color(0xFF86EFAC),
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('✓ Halal Confirmed',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(
                                                  0xFF15803D))),
                                      Text(
                                          'I confirm this food is Halal-certified & safe',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 11.5,
                                              color: const Color(
                                                  0xFF4ADE80))),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.greenDark,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('HALAL',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Tips card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFEFF6FF),
                                  Color(0xFFDBEAFE)
                                ]),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFFBFDBFE),
                                width: 1.5),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('💡',
                                  style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: const Color(0xFF1E40AF),
                                        height: 1.5),
                                    children: const [
                                      TextSpan(
                                          text: 'Pro tip: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700)),
                                      TextSpan(
                                          text:
                                              'Listings with clear photos and descriptions get claimed 3× faster. Set an accurate expiry time so receivers can plan their pickup!'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Sticky submit button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background.withOpacity(0),
                      AppColors.background,
                    ],
                  ),
                ),
                child: Consumer<FoodProvider>(
                  builder: (_, fp, __) => GestureDetector(
                    onTap: fp.loading ? null : _submit,
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
                      child: fp.loading
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
                                const Icon(Icons.send,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 10),
                                Text('Post Food Now',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
            // Success overlay
            if (_submitted)
              Container(
                color: AppColors.card,
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.green, AppColors.greenDark],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.green.withOpacity(0.35),
                            blurRadius: 50,
                            offset: const Offset(0, 20),
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child:
                          const Text('🎉', style: TextStyle(fontSize: 48)),
                    ),
                    const SizedBox(height: 24),
                    Text('Food Posted!',
                        style: GoogleFonts.sora(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark)),
                    const SizedBox(height: 8),
                    Text(
                      'Your listing is now live and visible to receivers nearby. Thank you for making a difference!',
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.muted,
                          height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        _successStat('🍽️ $_qty', 'Portions Listed'),
                        _successStat('👁️ 0', 'Views So Far'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text('Back to My Donations →',
                            style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String label) => Row(
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.sora(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(color: AppColors.border)),
        ],
      );

  Widget _stepBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Icon(icon, size: 16, color: AppColors.dark),
        ),
      );

  Widget _successStat(String val, String label) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(val,
                  style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark)),
              const SizedBox(height: 2),
              Text(label,
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: AppColors.muted)),
            ],
          ),
        ),
      );
}
