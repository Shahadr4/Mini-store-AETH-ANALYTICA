import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/brand_header.dart';
import '../../../../core/widgets/soft_card.dart';
import '../provider/auth_provider.dart';
import '../provider/login_provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => sl<LoginProvider>(),
    child: const _LoginView(),
  );
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Show the "session expired" message (if any) once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      final message = authProvider.message;
      if (message != null) {
        _showMessage(message);
        authProvider.clearMessage();
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final login = context.read<LoginProvider>();
    final auth = context.read<AuthProvider>();
    final user = await login.login(
      username: _usernameController.text,
      password: _passwordController.text,
    );
    if (user != null) {
      // The router moves on to Home.
      auth.loggedIn(user);
    } else if (mounted) {
      _showMessage(login.errorMessage ?? 'Login failed');
    }
  }

  String? _required(String? value, String label) =>
      (value == null || value.trim().isEmpty) ? '$label is required' : null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Stack(
                children: [
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _LoginHeader(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      264,
                      AppSpacing.screenPadding,
                      AppSpacing.l,
                    ),
                    child: SoftCard(
                      padding: const EdgeInsets.all(AppSpacing.l),
                      child: _buildForm(),
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

  Widget _buildForm() => Form(
    key: _formKey,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Welcome back', style: context.textStyles.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text('Log in to continue shopping', style: context.secondaryBodyStyle),
        const SizedBox(height: AppSpacing.l),
        _buildFields(),
        const SizedBox(height: AppSpacing.l),
        Selector<LoginProvider, bool>(
          selector: (_, login) => login.isLoading,
          builder: (context, isLoading, _) => AppButton(
            label: 'Login',
            isLoading: isLoading,
            onPressed: _submit,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          'Demo account: emilys / emilyspass',
          textAlign: TextAlign.center,
          style: context.captionStyle,
        ),
      ],
    ),
  );

  Widget _buildFields() => Column(
    children: [
      TextFormField(
        controller: _usernameController,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: TextCapitalization.none,
        autofillHints: const [AutofillHints.username],
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: 'Username',
          prefixIcon: Icon(Icons.person_outline_rounded),
        ),
        validator: (v) => _required(v, 'Username'),
      ),
      const SizedBox(height: AppSpacing.m),
      TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: 'Password',
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          suffixIcon: IconButton(
            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        validator: (v) => _required(v, 'Password'),
      ),
    ],
  );
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 296,
    child: BrandHeader(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.l,
        AppSpacing.screenPadding,
        0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.m),
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.l),
              boxShadow: context.softShadow,
            ),
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.s),
              child: AppLogo(size: 72),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            'Mini Store',
            style: context.textStyles.titleLarge!.copyWith(
              color: context.colors.onPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Shop smart, shop simple',
            style: context.captionStyle.copyWith(
              color: context.colors.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    ),
  );
}
