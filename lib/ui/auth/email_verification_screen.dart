import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursehub/utils/index.dart';
import 'package:coursehub/utils/responsive_helper.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = ResponsiveHelper.getResponsivePadding(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: theme.iconTheme.color,
          onPressed: () => Navigator.pop(context),
          constraints: BoxConstraints(minWidth: 48, minHeight: 48),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Icon(
                    Icons.email,
                    size: 80,
                    color: primaryPink,
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Verify Your Email',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'We sent a verification code to',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.email,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primaryPink,
                      fontFamily: 'Lato',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Icon(
                    Icons.mark_email_read,
                    size: 80,
                    color: primaryPink,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Check your email inbox for a verification link.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isVerifying ? null : () => _checkVerification(authProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isVerifying
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(white),
                                  ),
                                )
                              : Text(
                                  'I\'ve Verified My Email',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Lato',
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return TextButton(
                        onPressed: _isResending ? null : () => _resendVerification(authProvider),
                        style: TextButton.styleFrom(
                          minimumSize: Size(88, 48),
                        ),
                        child: _isResending
                            ? Text(
                                'Sending...',
                                style: TextStyle(
                                  color: primaryPink,
                                  fontFamily: 'Lato',
                                ),
                              )
                            : Text(
                                'Didn\'t receive email? Resend',
                                style: TextStyle(
                                  color: primaryPink,
                                  fontSize: 14,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
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