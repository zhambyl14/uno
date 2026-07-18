import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/insets.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/utils/ui_feedback.dart';
import '../auth_controller.dart';
import 'profile_setup_form.dart';

/// Email sign-in / registration. Registration reuses the child-safe
/// profile setup form.
class EmailAuthSheet extends ConsumerStatefulWidget {
  const EmailAuthSheet({super.key});

  @override
  ConsumerState<EmailAuthSheet> createState() => _EmailAuthSheetState();
}

class _EmailAuthSheetState extends ConsumerState<EmailAuthSheet> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _register = false;
  bool _busy = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return ok ? null : S.invalidEmail;
  }

  String? _passwordValidator(String? value) =>
      (value ?? '').length < 6 ? S.passwordTooShort : null;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      context.showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;
    _run(
      () => ref
          .read(authControllerProvider.notifier)
          .signInEmail(
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
            register: false,
          ),
    );
  }

  void _doRegister(String nickname, String avatarId, bool isChild) {
    if (!_formKey.currentState!.validate()) return;
    _run(
      () => ref
          .read(authControllerProvider.notifier)
          .signInEmail(
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
            register: true,
            nickname: nickname,
            avatarId: avatarId,
            isChild: isChild,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Insets.l,
        Insets.l,
        Insets.l,
        Insets.l + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _register ? S.signUp : S.signIn,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: Insets.l),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: S.emailLabel,
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: _emailValidator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: Insets.m),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: S.passwordLabel,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                validator: _passwordValidator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: Insets.m),
              if (_register)
                ProfileSetupForm(
                  submitLabel: S.signUp,
                  busy: _busy,
                  onSubmit: _doRegister,
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : _signIn,
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(S.signIn),
                  ),
                ),
              const SizedBox(height: Insets.s),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() => _register = !_register),
                child: Text(_register ? S.haveAccount : S.noAccountYet),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
