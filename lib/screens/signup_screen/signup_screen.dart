import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/signup_model.dart';
import '../../providers/auth_provider.dart';
import '../login_screen/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = true;
  String? _errorMessage;

  // Design tokens matching LoginScreen
  static const Color _navy = Color(0xFF0A2A5E);
  static const Color _blue = Color(0xFF1565C0);
  static const Color _sky = Color(0xFF42A5F5);
  static const Color _bg = Color(0xFFF1F7FD);
  static const Color _textMuted = Color(0xFF6B7F99);
  static const Color _border = Color(0xFFDCE7F4);
  static const Color _error = Color(0xFFD32F2F);
  static const Color _success = Color(0xFF2E7D32);

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------
  static String? validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Full name is required';
    if (name.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (email.length > 254) return 'Email is too long';
    if (!_emailRegex.hasMatch(email)) {
      return 'Enter a valid email, e.g. name@example.com';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Use at least 8 characters';
    if (password.contains(' ')) return 'Password cannot contain spaces';
    if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password)) {
      return 'Include at least one letter and one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Sign Up Submission
  // ---------------------------------------------------------------------------
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      setState(() {
        _errorMessage = 'Please accept the terms & conditions to proceed.';
      });
      return;
    }

    final signUpData = SignUpModel(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.signUp(signUpData);

    if (!mounted) return;

    if (result.success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Account created! Please sign in with your password.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );

      // Navigate to LoginScreen with email pre-filled
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(initialEmail: signUpData.email),
        ),
      );
    } else {
      setState(() {
        _errorMessage = result.message;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Input Decoration Helper
  // ---------------------------------------------------------------------------
  static InputDecoration _inputDecoration({
    required String label,
    String? hint,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB0BFD1)),
      labelStyle: const TextStyle(color: _textMuted),
      floatingLabelStyle: const TextStyle(
        color: _blue,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icon, color: _blue, size: 22),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FBFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      errorMaxLines: 2,
      border: border(_border),
      enabledBorder: border(_border),
      focusedBorder: border(_blue, 1.8),
      errorBorder: border(_error),
      focusedErrorBorder: border(_error, 1.8),
    );
  }

  // ---------------------------------------------------------------------------
  // UI Widgets
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: const Icon(Icons.person_add_alt_1_rounded,
              size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign up to monitor air quality and get smog alerts',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.88),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: _errorMessage == null
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF5C2C2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: _error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: _error,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          // Full Name
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocus,
            enabled: !isLoading,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              label: 'Full Name',
              hint: 'e.g. Ali Khan',
              icon: Icons.person_outline_rounded,
            ),
            validator: validateName,
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
          ),
          const SizedBox(height: 14),

          // Email
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocus,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
            enableSuggestions: false,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            decoration: _inputDecoration(
              label: 'Email address',
              hint: 'name@example.com',
              icon: Icons.email_outlined,
            ),
            validator: validateEmail,
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
          ),
         const SizedBox(height: 14),

          // Password
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            enabled: !isLoading,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            autocorrect: false,
            enableSuggestions: false,
            decoration: _inputDecoration(
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                tooltip: _isPasswordVisible ? 'Hide password' : 'Show password',
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _textMuted,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            validator: validatePassword,
            onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
          ),
          const SizedBox(height: 14),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            enabled: !isLoading,
            obscureText: !_isConfirmPasswordVisible,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            autocorrect: false,
            enableSuggestions: false,
            decoration: _inputDecoration(
              label: 'Confirm Password',
              icon: Icons.lock_reset_rounded,
              suffix: IconButton(
                tooltip: _isConfirmPasswordVisible
                    ? 'Hide password'
                    : 'Show password',
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _textMuted,
                ),
                onPressed: () => setState(
                  () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                ),
              ),
            ),
            validator: _validateConfirmPassword,
            onFieldSubmitted: (_) => _submit(),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsRow(bool isLoading) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: isLoading
          ? null
          : () => setState(() => _agreeToTerms = !_agreeToTerms),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: _agreeToTerms,
                activeColor: _blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                onChanged: isLoading
                    ? null
                    : (v) => setState(() => _agreeToTerms = v ?? false),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'I agree to the Terms of Service & Privacy Policy',
                style: TextStyle(fontSize: 12.5, color: _textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupButton(bool isLoading) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          disabledBackgroundColor: _blue.withValues(alpha: 0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: isLoading ? null : _submit,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;

    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Top Gradient Backdrop
            Container(
              height: 320,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_navy, _blue, _sky],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(44),
                  bottomRight: Radius.circular(44),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: _navy.withValues(alpha: 0.12),
                                blurRadius: 30,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: AutofillGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildErrorBanner(),
                                _buildForm(isLoading),
                                const SizedBox(height: 8),
                                _buildTermsRow(isLoading),
                                const SizedBox(height: 18),
                                _buildSignupButton(isLoading),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(color: _textMuted, fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                    },
                              child: const Text(
                                'Sign in',
                                style: TextStyle(
                                  color: _blue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
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
          ],
        ),
      ),
    );
  }
}
