import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart'
    show AppTheme;
import '../../../../features/shared/presentation/widgets/ui_components_export.dart';
import '../providers/auth_providers.dart'
    show authNotifierProvider;

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  String? _nameError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _emailError = null;
      _passwordError = null;
      _nameError = null;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _nameError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    bool hasError = false;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _emailError = 'Please enter a valid email');
      hasError = true;
    }

    if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      hasError = true;
    }

    if (_isSignUp && name.isEmpty) {
      setState(() => _nameError = 'Enter your name');
      hasError = true;
    }

    if (hasError) return;

    final notifier = ref.read(authNotifierProvider.notifier);
    final error = _isSignUp
        ? await notifier.signUp(email: email, password: password, name: name)
        : await notifier.signIn(email: email, password: password);
    if (error != null) {
      setState(() => _emailError = error);
    } else {
      if (mounted) context.goNamed('dashboard');
    }
  }

  Future<void> _tryDemo() async {
    final notifier = ref.read(authNotifierProvider.notifier);
    final error = await notifier.demoSignIn();
    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } else {
      if (mounted) context.goNamed('dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4, vertical: AppTheme.space6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Title
                  Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: Icon(
                          Icons.fitness_center_rounded,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.space4),
                      Text(
                        'ArcFit',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: AppTheme.space2),
                      Text(
                        _isSignUp ? 'Create your account' : 'Welcome back',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space6),

                  // Form
                  DataCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_isSignUp) ...[
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline_rounded, color: theme.colorScheme.onSurfaceVariant),
                              errorText: _nameError,
                            ),
                            onChanged: (_) => setState(() => _nameError = null),
                          ),
                          const SizedBox(height: AppTheme.space4),
                        ],
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: _isSignUp ? TextInputAction.next : TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.onSurfaceVariant),
                            errorText: _emailError,
                          ),
                          onChanged: (_) => setState(() => _emailError = null),
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: AppTheme.space4),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: theme.colorScheme.onSurfaceVariant),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            errorText: _passwordError,
                          ),
                          onChanged: (_) => setState(() => _passwordError = null),
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: AppTheme.space5),

                        // Primary Action
                        FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                          ),
                          child: Text(_isSignUp ? 'Create Account' : 'Sign In'),
                        ),
                        const SizedBox(height: AppTheme.space3),

                        // Demo Account
                        OutlinedButton.icon(
                          onPressed: _tryDemo,
                          icon: const Icon(Icons.science_outlined, size: 20),
                          label: const Text('Try Demo Account'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                          ),
                        ),
                        const SizedBox(height: AppTheme.space4),

                        // Toggle Mode
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _isSignUp ? 'Already have an account? ' : 'New to ArcFit? ',
                              style: GoogleFonts.ibmPlexSans(color: theme.colorScheme.onSurfaceVariant),
                            ),
                            TextButton(
                              onPressed: _toggleMode,
                              child: Text(_isSignUp ? 'Sign In' : 'Create Account'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.space6),

                  // Footer
                  Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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
}