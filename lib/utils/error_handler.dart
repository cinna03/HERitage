import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandler {
  /// Shows a user-friendly error message
  static void showError(BuildContext context, dynamic error, {String? customMessage}) {
    String message = customMessage ?? _getErrorMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Shows a success message
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Shows an info message
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Converts error to user-friendly message
  static String _getErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';
    
    // Handle FirebaseAuthException with specific error codes
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'This email is not registered. Please sign up first or check your email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again or use "Forgot Password" to reset it.';
        case 'invalid-email':
          return 'Invalid email address. Please check your email and try again.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support for assistance.';
        case 'email-already-in-use':
          return 'This email is already registered. Please sign in instead.';
        case 'weak-password':
          return 'Password is too weak. Please use at least 6 characters.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please wait a few minutes and try again.';
        case 'invalid-credential':
          return 'Invalid email or password. Please check your credentials and try again.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with this email but different sign-in method.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection and try again.';
        case 'requires-recent-login':
          return 'Please sign out and sign in again to perform this action.';
        case 'sign_in_canceled':
        case 'sign_in_failed':
          return 'Google Sign-In was canceled or failed. Please try again.';
        case 'sign_in_required':
          return 'Please sign in with Google to continue.';
        default:
          // Check if it's a Google Sign-In specific error
          final errorMessage = error.message ?? '';
          if (errorMessage.contains('google') || errorMessage.contains('sign_in')) {
            return 'Google Sign-In error: ${errorMessage.isNotEmpty ? errorMessage : "Please check your Google Sign-In configuration."}';
          }
          return errorMessage.isNotEmpty ? errorMessage : 'Authentication failed. Please try again.';
      }
    }
    
    // Handle string error codes (from AuthProvider)
    if (error is String) {
      switch (error) {
        case 'user-not-found':
          return 'This email is not registered. Please sign up first or check your email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again or use "Forgot Password" to reset it.';
        case 'invalid-email':
          return 'Invalid email address. Please check your email and try again.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support for assistance.';
        case 'email-already-in-use':
          return 'This email is already registered. Please sign in instead.';
        case 'weak-password':
          return 'Password is too weak. Please use at least 6 characters.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please wait a few minutes and try again.';
        case 'invalid-credential':
          return 'Invalid email or password. Please check your credentials and try again.';
        case 'sign_in_canceled':
        case 'sign_in_failed':
          return 'Google Sign-In was canceled or failed. Please try again.';
      }
      
      final errorString = error.toLowerCase();
      
      // Google Sign-In errors
      if (errorString.contains('google') || errorString.contains('sign_in') || errorString.contains('client_id')) {
        return 'Google Sign-In configuration error. Please check your Firebase Console settings.';
      }
      
      // Network errors
      if (errorString.contains('network') || errorString.contains('connection')) {
        return 'No internet connection. Please check your network and try again.';
      }
      
      // Permission errors
      if (errorString.contains('permission-denied') || errorString.contains('permission')) {
        return 'You don\'t have permission to perform this action.';
      }
      
      // Firestore errors
      if (errorString.contains('not-found')) {
        return 'The requested item was not found.';
      }
      if (errorString.contains('unavailable')) {
        return 'Service temporarily unavailable. Please try again later.';
      }
      
      // Generic Firebase errors
      if (errorString.contains('firebase')) {
        return 'A service error occurred. Please try again.';
      }
    }
    
    // Default: return a cleaned version of the error
    return error.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim();
  }

  /// Shows a confirmation dialog
  static Future<bool> showConfirmation(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}





