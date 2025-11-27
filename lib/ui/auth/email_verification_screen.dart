import 'package:flutter/material.dart';
import 'package:coursehub/utils/index.dart';
import '../onboarding/interest_selection_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  EmailVerificationScreen({required this.email});

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return Container(
                    width: 45,
                    height: 55,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: lightPink),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: primaryPink, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              SizedBox(height: 40),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InterestSelectionScreen()),
                    );
                  },
                  child: Text('Verify', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Resend code
                },
                child: Text(
                  'Didn\'t receive code? Resend',
                  style: TextStyle(color: primaryPink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}