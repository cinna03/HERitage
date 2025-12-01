import 'package:flutter/material.dart';

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
    
    final errorString = error.toString().toLowerCase();
    
    // Network errors
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'No internet connection. Please check your network and try again.';
    }
    
    // Authentication errors
    if (errorString.contains('user-not-found')) {
      return 'User account not found. Please check your email and try again.';
    }
    if (errorString.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    }
    if (errorString.contains('email-already-in-use')) {
      return 'This email is already registered. Please sign in instead.';
    }
    if (errorString.contains('weak-password')) {
      return 'Password is too weak. Please use at least 6 characters.';
    }
    if (errorString.contains('invalid-email')) {
      return 'Invalid email address. Please check and try again.';
    }
    if (errorString.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    }
    if (errorString.contains('too-many-requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
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

