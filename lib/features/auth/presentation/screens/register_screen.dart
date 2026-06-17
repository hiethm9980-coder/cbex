import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/controllers/global_error_handler.dart';
import '../providers/auth_providers.dart';

/// Create-account screen, wired to `POST /api/v1/register`. On success the API
/// returns a token, so the user is auto-logged-in and routed to /home.
///
/// Same CBEX design system as the login screen (light bg, white card, navy ink,
/// red CTA). Arabic / RTL.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  static const Color _bg = Color(0xFFF4F6FA);
  static const Color _line = Color(0xFFE8EBF1);
  static const Color _ink2 = Color(0xFF4A5870);
  static const Color _ink3 = Color(0xFF8693A8);

  final _formKey = GlobalKey<FormState>();
  final _accountNameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'SA');
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _accountType = 'individual';
  bool _obscure = true;
  bool _obscure2 = true;
  bool _loading = false;
  Map<String, List<String>> _fieldErrors = {};

  @override
  void dispose() {
    _accountNameCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _countryCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
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
      await ref.read(authProvider.notifier).register(
            accountName: _accountNameCtrl.text.trim(),
            accountType: _accountType,
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            passwordConfirmation: _confirmCtrl.text,
            phone: _phoneCtrl.text.trim(),
            country: _countryCtrl.text.trim().toUpperCase(),
          );
      // Success → AuthStatus.authenticated → router redirects to /home.
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
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: IconButton(
                      tooltip: 'رجوع',
                      onPressed: _loading ? null : () => context.pop(),
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.primary),
                    ),
                  ),
                  _brand(),
                  const SizedBox(height: 22),
                  _formCard(),
                  const SizedBox(height: 16),
                  _loginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brand() => Column(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.secondary, AppColors.secondaryDark],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text('C',
                style: TextStyle(
                    fontSize: 30,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
          ),
          const SizedBox(height: 12),
          const Text('إنشاء حساب جديد',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary)),
          const SizedBox(height: 4),
          Text('أنشئ حساب عميل CBEX للبدء بالشحن',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500, color: _ink3)),
        ],
      );

  Widget _formCard() => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
              _label('نوع الحساب'),
              const SizedBox(height: 8),
              _accountTypeSelector(),
              const SizedBox(height: 15),
              _label('اسم الحساب / المتجر'),
              const SizedBox(height: 7),
              TextFormField(
                controller: _accountNameCtrl,
                enabled: !_loading,
                textInputAction: TextInputAction.next,
                decoration: _decoration(
                    hint: 'متجر السلام',
                    icon: Icons.storefront_outlined,
                    errorText: _fieldError('account_name')),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'أدخل اسم الحساب' : null,
              ),
              const SizedBox(height: 15),
              _label('الاسم الكامل'),
              const SizedBox(height: 7),
              TextFormField(
                controller: _nameCtrl,
                enabled: !_loading,
                textInputAction: TextInputAction.next,
                decoration: _decoration(
                    hint: 'أحمد علي',
                    icon: Icons.person_outline_rounded,
                    errorText: _fieldError('name')),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'أدخل الاسم' : null,
              ),
              const SizedBox(height: 15),
              _label('البريد الإلكتروني'),
              const SizedBox(height: 7),
              TextFormField(
                controller: _emailCtrl,
                enabled: !_loading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _decoration(
                    hint: 'name@cbex.com',
                    icon: Icons.mail_outline_rounded,
                    errorText: _fieldError('email')),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'أدخل البريد الإلكتروني';
                  if (!value.contains('@')) return 'بريد إلكتروني غير صالح';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label('رقم الهاتف'),
                        const SizedBox(height: 7),
                        TextFormField(
                          controller: _phoneCtrl,
                          enabled: !_loading,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          textDirection: TextDirection.ltr,
                          decoration: _decoration(
                              hint: '+9665xxxxxxxx',
                              icon: Icons.phone_outlined,
                              errorText: _fieldError('phone')),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label('الدولة'),
                        const SizedBox(height: 7),
                        TextFormField(
                          controller: _countryCtrl,
                          enabled: !_loading,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.next,
                          textAlign: TextAlign.center,
                          maxLength: 2,
                          decoration: _decoration(
                            hint: 'SA',
                            icon: null,
                            errorText: _fieldError('country'),
                          ).copyWith(counterText: ''),
                          validator: (v) =>
                              (v == null || v.trim().length != 2)
                                  ? 'حرفان'
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _label('كلمة المرور'),
              const SizedBox(height: 7),
              TextFormField(
                controller: _passCtrl,
                enabled: !_loading,
                obscureText: _obscure,
                textInputAction: TextInputAction.next,
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
                        size: 20),
                  ),
                ),
                validator: _passwordValidator,
              ),
              const SizedBox(height: 6),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  '٨ أحرف على الأقل، مع حرف كبير وصغير ورقم ورمز.',
                  style: TextStyle(fontSize: 11.5, color: _ink3),
                ),
              ),
              const SizedBox(height: 15),
              _label('تأكيد كلمة المرور'),
              const SizedBox(height: 7),
              TextFormField(
                controller: _confirmCtrl,
                enabled: !_loading,
                obscureText: _obscure2,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: _decoration(
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                    splashRadius: 20,
                    icon: Icon(
                        _obscure2
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: _ink3,
                        size: 20),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'أعد إدخال كلمة المرور';
                  if (v != _passCtrl.text) return 'كلمتا المرور غير متطابقتين';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _primaryButton(),
            ],
          ),
        ),
      );

  String? _passwordValidator(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'أدخل كلمة المرور';
    if (value.length < 8) return '٨ أحرف على الأقل';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'أضف حرفًا كبيرًا (A-Z)';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'أضف حرفًا صغيرًا (a-z)';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'أضف رقمًا';
    return null;
  }

  Widget _accountTypeSelector() {
    Widget seg(String label, String value, IconData icon) {
      final selected = _accountType == value;
      return Expanded(
        child: GestureDetector(
          onTap: _loading ? null : () => setState(() => _accountType = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: 18,
                    color: selected ? AppColors.secondary : _ink3),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: selected ? AppColors.primary : _ink3)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        seg('فرد', 'individual', Icons.person_rounded),
        seg('منشأة', 'organization', Icons.business_rounded),
      ]),
    );
  }

  Widget _label(String text) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(text,
            style: TextStyle(
                fontSize: 13.5, fontWeight: FontWeight.w700, color: _ink2)),
      );

  InputDecoration _decoration({
    required String hint,
    required IconData? icon,
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
      prefixIcon: icon == null ? null : Icon(icon, color: _ink3, size: 21),
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

  Widget _primaryButton() => Container(
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
              disabledBackgroundColor:
                  AppColors.secondary.withValues(alpha: 0.6),
              foregroundColor: Colors.white,
              elevation: 0,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              textStyle:
                  const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
            ),
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: Colors.white),
                  )
                : const Text('إنشاء الحساب'),
          ),
        ),
      );

  Widget _loginLink() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('لديك حساب بالفعل؟',
              style: TextStyle(
                  fontSize: 13, color: _ink2, fontWeight: FontWeight.w500)),
          TextButton(
            onPressed: _loading ? null : () => context.pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('تسجيل الدخول',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
          ),
        ],
      );
}
