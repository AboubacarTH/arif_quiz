import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/ui.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel? user;

  const EditProfileScreen({super.key, this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.user?.name ?? '';
    _emailCtrl.text = widget.user?.email ?? '';
  }

  String? _validate() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (name.isEmpty || email.isEmpty) return AppLocalizations.of(context).fillAllFields;
    if (name.length < 2) return AppLocalizations.of(context).enterFullName;
    if (!emailPattern.hasMatch(email)) return AppLocalizations.of(context).enterValidEmail;

    return null;
  }

  Future<void> _saveProfile() async {
    final validationError = _validate();
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await apiService.updateProfile(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).updateProfileFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: QuizAppBar(title: AppLocalizations.of(context).editProfileTitle, showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.16),
                  child: Text(
                    (_nameCtrl.text.trim().isNotEmpty
                            ? _nameCtrl.text.trim()
                            : widget.user?.name ?? 'U')
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              if (_error != null) ...[
                _ProfileError(message: _error!),
                const SizedBox(height: 16),
              ],
              AppTextField(
                controller: _nameCtrl,
                label: AppLocalizations.of(context).fullName,
                hint: AppLocalizations.of(context).yourNameHint,
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _emailCtrl,
                label: AppLocalizations.of(context).email,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _saveProfile(),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: AppLocalizations.of(context).saveChanges,
                icon: Icons.check_rounded,
                iconTrailing: true,
                fullWidth: true,
                size: AppButtonSize.large,
                loading: _loading,
                onPressed: _loading ? null : _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  final String message;

  const _ProfileError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
