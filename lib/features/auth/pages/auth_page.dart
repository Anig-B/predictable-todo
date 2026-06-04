import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _serverError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  String? _validateUsername(String? value) {
    final username = value?.trim() ?? '';
    if (username.isEmpty) return 'Username is required';
    if (username.length < 2) return 'Username must be at least 2 characters';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _serverError = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      if (_isLogin) {
        await repo.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await repo.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _usernameController.text.trim(),
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _serverError = e.message);
    } catch (e) {
      if (mounted) setState(() => _serverError = 'Unexpected error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'QuestLog',
                  textAlign: TextAlign.center,
                  style: AppTheme.mono(
                    size: 32,
                    weight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? 'Welcome back, Adventurer.' : 'Begin your journey.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.subtle, fontSize: 16),
                ),
                const SizedBox(height: 48),
                AutofillGroup(
                  child: Column(
                    children: [
                      if (!_isLogin) ...[
                        _buildTextFormField(
                          controller: _usernameController,
                          label: 'USERNAME',
                          hintText: 'Choose a name',
                          icon: Icons.person_outline,
                          validator: _validateUsername,
                          focusNode: _usernameFocusNode,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                          onFieldSubmitted: () =>
                              _emailFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildTextFormField(
                        controller: _emailController,
                        label: 'EMAIL',
                        hintText: 'you@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        focusNode: _emailFocusNode,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        onFieldSubmitted: () =>
                            _passwordFocusNode.requestFocus(),
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        controller: _passwordController,
                        label: 'PASSWORD',
                        hintText: _isLogin ? 'Enter your password' : 'At least 6 characters',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        focusNode: _passwordFocusNode,
                        textInputAction:
                            _isLogin ? TextInputAction.done : TextInputAction.next,
                        autofillHints: [
                          _isLogin
                              ? AutofillHints.password
                              : AutofillHints.newPassword
                        ],
                        onFieldSubmitted: _isLogin
                            ? _submit
                            : () => _confirmPasswordFocusNode.requestFocus(),
                        suffix: IconButton(
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.muted,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      if (!_isLogin) ...[
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _confirmPasswordController,
                          label: 'CONFIRM PASSWORD',
                          hintText: 'Re-enter your password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: _validateConfirmPassword,
                          focusNode: _confirmPasswordFocusNode,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          onFieldSubmitted: _submit,
                        ),
                      ],
                    ],
                  ),
                ),
                if (_serverError != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _serverError!,
                            style: AppTheme.sans(size: 12, color: AppColors.red),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _serverError = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.close, color: AppColors.red, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.bg,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bg))
                    : Text(
                        _isLogin ? 'LOG IN' : 'SIGN UP',
                        style: AppTheme.sans(weight: FontWeight.w800, size: 14),
                      ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading ? null : () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _serverError = null;
                    });
                    _formKey.currentState?.reset();
                  },
                  style: TextButton.styleFrom(foregroundColor: AppColors.muted),
                  child: Text.rich(
                    TextSpan(
                      text: _isLogin ? 'Need an account? ' : 'Already have an account? ',
                      style: AppTheme.sans(size: 13, color: AppColors.muted),
                      children: [
                        TextSpan(
                          text: _isLogin ? 'Sign up' : 'Log in',
                          style: AppTheme.sans(size: 13, color: AppColors.accent, weight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required String? Function(String?)? validator,
    required FocusNode focusNode,
    required TextInputAction textInputAction,
    required VoidCallback onFieldSubmitted,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffix,
    List<String>? autofillHints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.mono(
            size: 10,
            weight: FontWeight.w700,
            color: AppColors.subtle,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !_isLoading,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onFieldSubmitted: (_) => onFieldSubmitted(),
          style: TextStyle(color: AppColors.text.withValues(alpha: _isLoading ? 0.4 : 1), fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.muted, size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: _isLoading ? AppColors.surface.withValues(alpha: 0.5) : AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.red),
            ),
            errorStyle: AppTheme.sans(size: 11, color: AppColors.red),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: (_) {
            if (_serverError != null) setState(() => _serverError = null);
          },
        ),
      ],
    );
  }
}
