import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursehub/utils/index.dart';
import '../../utils/error_handler.dart';
import '../../providers/auth_provider.dart';
import '../onboarding/interest_selection_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  EmailVerificationScreen({required this.email});

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryPink),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.email,
                size: 80,
                color: primaryPink,
              ),
              SizedBox(height: 30),
              Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkGrey,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'We sent a verification code to',
                style: TextStyle(
                  fontSize: 16,
                  color: mediumGrey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Text(
                widget.email,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryPink,
                ),
              ),
              SizedBox(height: 40),
              Icon(
                Icons.mark_email_read,
                size: 80,
                color: primaryPink,
              ),
              SizedBox(height: 20),
              Text(
                'Check your email inbox for a verification link.',
                style: TextStyle(
                  fontSize: 16,
                  color: mediumGrey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : () => _checkVerification(authProvider),
                      child: _isVerifying
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(white),
                              ),
                            )
                          : Text('I\'ve Verified My Email', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPink,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return TextButton(
                    onPressed: _isResending ? null : () => _resendVerification(authProvider),
                    child: _isResending
                        ? Text('Sending...', style: TextStyle(color: primaryPink))
                        : Text(
                            'Didn\'t receive email? Resend',
                            style: TextStyle(color: primaryPink),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkVerification(AuthProvider authProvider) async {
    setState(() => _isVerifying = true);
    try {
      await authProvider.reloadUser();
      if (authProvider.isEmailVerified) {
        ErrorHandler.showSuccess(context, 'Email verified successfully!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InterestSelectionScreen()),
        );
      } else {
        ErrorHandler.showError(
          context,
          'Email not verified yet. Please check your inbox and click the verification link.',
          customMessage: 'Email not verified yet. Please check your inbox.',
        );
      }
    } catch (e) {
      ErrorHandler.showError(context, e);
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendVerification(AuthProvider authProvider) async {
    setState(() => _isResending = true);
    try {
      await authProvider.sendEmailVerification();
      ErrorHandler.showSuccess(context, 'Verification email sent! Check your inbox.');
    } catch (e) {
      ErrorHandler.showError(context, e);
    } finally {
      setState(() => _isResending = false);
    }
  }
}