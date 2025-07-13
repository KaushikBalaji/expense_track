import 'package:expense_track/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:expense_track/services/supabase_services.dart'; // <-- adjust path if needed
import 'package:shared_preferences/shared_preferences.dart';

class AuthDialogContent extends StatefulWidget {
  final VoidCallback? onClose;

  const AuthDialogContent({super.key, this.onClose});

  @override
  State<AuthDialogContent> createState() => _AuthDialogContentState();
}

class _AuthDialogContentState extends State<AuthDialogContent> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  String? emailErrorText;
  String? passwordErrorText;
  String? nameErrorText;

  bool isLogin = true;
  bool isLoading = false;
  bool rememberEmail = false;

  final service = SupabaseService();

  @override
  void initState() {
    super.initState();

    _loadRememberedEmail();

    emailController.addListener(() {
      if (emailErrorText != null) {
        setState(() => emailErrorText = null);
      }
    });

    passwordController.addListener(() {
      if (passwordErrorText != null) {
        setState(() => passwordErrorText = null);
      }
    });

    nameController.addListener(() {
      if (nameErrorText != null) {
        setState(() => nameErrorText = null);
      }
    });
  }

  Future<void> handleAuth() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();

    try {
      await service.handleAuth(
        email: email,
        password: password,
        name: isLogin ? null : name,
        isLogin: isLogin,
      );

      if (!mounted) return;
      if (rememberEmail) {
        await prefs.setString('remembered_email', email);
      } else {
        await prefs.remove('remembered_email');
      }
      Navigator.of(context).pop(); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isLogin
                ? 'Login successful'
                : 'Signup successful. Check your email.',
          ),
        ),
      );
      Navigator.pushNamed(context, '/dashboard');
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');

      setState(() {
        emailErrorText = null;
        passwordErrorText = null;
        nameErrorText = null;

        if (message.contains('email')) emailErrorText = message;
        if (message.contains('password')) passwordErrorText = message;
        if (message.contains('name')) nameErrorText = message;
      });

      if (!message.contains('email') &&
          !message.contains('password') &&
          !message.contains('name')) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remembered_email');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        rememberEmail = true;
        emailController.text = savedEmail;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isLogin ? 'Login to Sync' : 'Sign Up',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!isLogin) ...[
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              errorText: nameErrorText,
            ),
          ),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: emailErrorText,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: passwordErrorText,
          ),
        ),
        const SizedBox(height: 16),
        if (isLogin) ...[
          Row(
            children: [
              Checkbox(
                value: rememberEmail,
                onChanged: (value) {
                  setState(() {
                    rememberEmail = value ?? false;
                  });
                },
              ),
              const Text("Remember Email"),
            ],
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: isLoading ? null : handleAuth,
          child: Text(isLogin ? 'Login' : 'Sign Up'),
        ),
        const SizedBox(height: 13),
        TextButton(
          onPressed: () => setState(() => isLogin = !isLogin),
          child: Text(
            isLogin
                ? "Don't have an account? Sign Up"
                : "Already have an account? Login",
          ),
        ),
      ],
    );
  }
}
