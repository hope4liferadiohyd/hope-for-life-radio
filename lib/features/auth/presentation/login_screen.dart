import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../../core/widgets/brand_mark.dart';
import 'auth_controller.dart';
import 'auth_validators.dart';
import 'forgot_password_screen.dart';

enum _AuthMode { signIn, register }

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.controller, super.key});

  final AuthController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  _AuthMode _mode = _AuthMode.signIn;
  bool _obscurePassword = true;

  bool get _isRegistering => _mode == _AuthMode.register;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchMode() {
    setState(() {
      _mode = _isRegistering ? _AuthMode.signIn : _AuthMode.register;
      _formKey.currentState?.reset();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final AuthActionResult result;
    if (_isRegistering) {
      result = await widget.controller.signUp(
        displayName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      result = await widget.controller.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.succeeded ? Colors.green.shade700 : null,
        ),
      );

    if (_isRegistering &&
        result.succeeded &&
        widget.controller.access == AppAccess.signedOut) {
      setState(() {
        _mode = _AuthMode.signIn;
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
    }
  }

  Future<void> _openForgotPassword() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(
          controller: widget.controller,
          initialEmail: _emailController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('loginScreen'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const BrandMark(compact: true),
                      const SizedBox(height: 28),
                      Text(
                        _isRegistering
                            ? 'Create your account'
                            : 'Sign in to continue',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isRegistering
                            ? 'Save your preferences and stay connected.'
                            : 'Listen live, or enter immediately as a guest.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.blueGrey.shade700,
                            ),
                      ),
                      if (!widget.controller.emailAuthAvailable) ...[
                        const SizedBox(height: 20),
                        const _ConfigurationNotice(),
                      ],
                      const SizedBox(height: 24),
                      if (_isRegistering) ...[
                        TextFormField(
                          controller: _nameController,
                          autofillHints: const [AutofillHints.name],
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: AuthValidators.requiredName,
                        ),
                        const SizedBox(height: 14),
                      ],
                      TextFormField(
                        key: const ValueKey('emailField'),
                        controller: _emailController,
                        autofillHints: const [AutofillHints.email],
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: AuthValidators.email,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const ValueKey('passwordField'),
                        controller: _passwordController,
                        autofillHints: _isRegistering
                            ? const [AutofillHints.newPassword]
                            : const [AutofillHints.password],
                        obscureText: _obscurePassword,
                        textInputAction: _isRegistering
                            ? TextInputAction.next
                            : TextInputAction.done,
                        onFieldSubmitted: _isRegistering ? null : (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: AuthValidators.password,
                      ),
                      if (_isRegistering) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: const InputDecoration(
                            labelText: 'Confirm password',
                            prefixIcon: Icon(Icons.lock_reset_rounded),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                        ),
                      ],
                      if (!_isRegistering)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: widget.controller.isBusy
                                ? null
                                : _openForgotPassword,
                            child: const Text('Forgot password?'),
                          ),
                        )
                      else
                        const SizedBox(height: 20),
                      ElevatedButton(
                        key: const ValueKey('submitAuthButton'),
                        onPressed: widget.controller.isBusy ? null : _submit,
                        child: widget.controller.isBusy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_isRegistering ? 'Create account' : 'Sign in'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        key: const ValueKey('guestButton'),
                        onPressed: widget.controller.isBusy
                            ? null
                            : widget.controller.continueAsGuest,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.headphones_rounded),
                        label: const Text('Continue as guest'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: widget.controller.isBusy ? null : _switchMode,
                        child: Text(
                          _isRegistering
                              ? 'Already have an account? Sign in'
                              : 'New listener? Create an account',
                        ),
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

class _ConfigurationNotice extends StatelessWidget {
  const _ConfigurationNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.65)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.navy),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Guest mode is ready. Email sign-in will activate after the '
              'new app backend is connected.',
            ),
          ),
        ],
      ),
    );
  }
}
