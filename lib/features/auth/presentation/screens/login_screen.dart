import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../shared/controllers/global_error_handler.dart';
import '../providers/auth_providers.dart';

/// CBEX customer-app login screen, wired to `POST /api/v1/login`.
///
/// Visual language from the CBEX Logistics design system: light background,
/// white rounded card, navy ink, red primary CTA (CBEX secondary #D04A4B) with a
/// soft red glow, bordered inputs that turn red on focus. Arabic / RTL.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // ── Design tokens (CBEX design system neutrals) ──
  static const Color _bg = Color(0xFFF4F6FA);
  static const Color _line = Color(0xFFE8EBF1);
  static const Color _ink2 = Color(0xFF4A5870);
  static const Color _ink3 = Color(0xFF8693A8);

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _remember = true;
  bool _loading = false;
  Map<String, List<String>> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    // Pre-fill the last used email (persisted across logout).
    Future.microtask(() async {
      final email = await ref.read(authRepositoryProvider).lastEmail();
      if (!mounted) return;
      if (email != null && email.isNotEmpty) _emailCtrl.text = email;
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _fieldError(String key) =>
      (_fieldErrors[key]?.isNotEmpty ?? false) ? _fieldErrors[key]!.first : null;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _fieldErrors = {});
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .login(_emailCtrl.text.trim(), _passCtrl.text);
      // Success → the router redirect navigates to /home automatically.
    } on ValidationException catch (e) {
      if (mounted) setState(() => _fieldErrors = e.errors);
    } on ApiException catch (e) {
      if (mounted) GlobalErrorHandler.show(context, GlobalErrorHandler.handle(e));
    } catch (e) {
      if (mounted) GlobalErrorHandler.show(context, GlobalErrorHandler.handle(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _brand(),
                  const SizedBox(height: 28),
                  _formCard(),
                  const SizedBox(height: 22),
                  Text(
                    '© CBEX Logistics',
                    style: TextStyle(
                      fontSize: 12,
                      color: _ink3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Brand / logo block ──
  Widget _brand() {
    return Column(
      children: [
        Container(
          width: 78,
          height: 78,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.secondary, AppColors.secondaryDark],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.32),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Text(
            'C',
            style: TextStyle(
              fontSize: 40,
              height: 1,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'CBEX',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'بوابة العملاء — حلول الشحن واللوجستيات',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _ink3,
          ),
        ),
      ],
    );
  }

  // ── Form card ──
  Widget _formCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'تسجيل الدخول',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'مرحبًا بك مجددًا 👋 أدخل بياناتك للمتابعة',
              style: TextStyle(
                fontSize: 13.5,
                color: _ink3,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 22),

            _label('البريد الإلكتروني'),
            const SizedBox(height: 7),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username, AutofillHints.email],
              enabled: !_loading,
              decoration: _decoration(
                hint: 'name@cbex.com',
                icon: Icons.mail_outline_rounded,
                errorText: _fieldError('email'),
              ),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'أدخل البريد الإلكتروني';
                if (!value.contains('@')) return 'بريد إلكتروني غير صالح';
                return null;
              },
            ),
            const SizedBox(height: 15),

            _label('كلمة المرور'),
            const SizedBox(height: 7),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              enabled: !_loading,
              onFieldSubmitted: (_) => _submit(),
              decoration: _decoration(
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                errorText: _fieldError('password'),
                suffix: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  splashRadius: 20,
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _ink3,
                    size: 20,
                  ),
                ),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'أدخل كلمة المرور' : null,
            ),
            const SizedBox(height: 6),

            // Remember me + forgot password
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _remember,
                    onChanged: (v) => setState(() => _remember = v ?? false),
                    activeColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'تذكّرني',
                  style: TextStyle(
                    fontSize: 13,
                    color: _ink2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'نسيت كلمة المرور؟',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            _primaryButton(),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: _ink2,
          ),
        ),
      );

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
    String? errorText,
  }) {
    OutlineInputBorder border(Color c, [double w = 1.5]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(color: _ink3, fontSize: 14, fontWeight: FontWeight.w500),
      errorText: errorText,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: _ink3, size: 21),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
      border: border(_line),
      enabledBorder: border(_line),
      focusedBorder: border(AppColors.secondary),
      errorBorder: border(AppColors.error, 1.2),
      focusedErrorBorder: border(AppColors.error),
      errorStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    );
  }

  Widget _primaryButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: _loading
            ? null
            : [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.30),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.6),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle:
                const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
          ),
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : const Text('تسجيل الدخول'),
        ),
      ),
    );
  }
}
