import 'package:expense_track/pages/dashboard_page.dart';
import 'package:expense_track/widgets/CustomAppbar.dart';
import 'package:expense_track/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  @override
  void initState() {
    super.initState();

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
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();

    final emailError = InputValidators.Validate(email, 'email');
    final passwordError = InputValidators.Validate(password, 'password');
    final nameError = isLogin ? null : InputValidators.Validate(name, 'name');

    setState(() {
      emailErrorText = emailError;
      passwordErrorText = passwordError;
      nameErrorText = nameError;
    });

    if (emailError != null || passwordError != null || nameError != null) {
      return;
    }

    setState(() => isLoading = true);
    try {
      if (isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login successful")));
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        }
      } else {
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup successful. Check your email.")),
        );
        setState(() => isLogin = true);
      }
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('invalid login credentials')) {
        setState(() {
          passwordErrorText = "Incorrect email or password.";
          emailErrorText = "Incorrect email or password.";
        });
      }
      else if(errorMessage.contains('email not confirmed')){
        setState(() {
          emailErrorText = 'Confirm email before logging in';
        });
      } 
      else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $errorMessage")));
      }
    } finally {
      setState(() => isLoading = false);
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
