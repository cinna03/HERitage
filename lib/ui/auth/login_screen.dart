import 'package:flutter/material.dart';
import 'package:coursehub/utils/index.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5E6D3), Color(0xFFE8D5C4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Pink circles
            Positioned(top: 50, left: -50, child: _buildCircle(150, lightPink.withOpacity(0.6))),
            Positioned(top: 100, right: 20, child: _buildCircle(80, palePink.withOpacity(0.7))),
            Positioned(top: 200, right: -30, child: _buildCircle(60, rosePink.withOpacity(0.5))),
            Positioned(top: 250, right: 100, child: _buildCircle(20, lightPink.withOpacity(0.8))),
            Positioned(bottom: 150, left: -80, child: _buildCircle(200, palePink.withOpacity(0.4))),
            Positioned(bottom: 50, right: -100, child: _buildCircle(250, lightPink.withOpacity(0.3))),
            Positioned(bottom: 200, left: 50, child: _buildCircle(100, rosePink.withOpacity(0.6))),
            
            // Login form
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: white,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 40),
                    
                    // Email field
                    Container(
                      decoration: BoxDecoration(
                        color: white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    
                    // Password field
                    Container(
                      decoration: BoxDecoration(
                        color: white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    
                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forget Password?',
                          style: TextStyle(
                            color: white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Login button
                    Container(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => DashboardScreen()),
                          );
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: lightPink,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: white.withOpacity(0.9),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0.1)],
          stops: [0.3, 1.0],
        ),
      ),
    );
  }
}