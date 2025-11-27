import 'package:flutter/material.dart';
import 'package:coursehub/utils/index.dart';

class BeautyCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palePink.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          // Episode 2 text
          Align(
            alignment: Alignment.topRight,
            child: Transform.rotate(
              angle: 0.1,
              child: Text(
                'EPISODE 2',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkPink,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          
          // Calendar grid
          Container(
            decoration: BoxDecoration(
              color: white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: darkGrey, width: 2),
            ),
            child: Column(
              children: [
                // Days header
                Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: darkGrey, width: 2)),
                  ),
                  child: Row(
                    children: [
                      _buildDayHeader('FRI', darkGrey),
                      _buildDayHeader('SAT', darkPink),
                      _buildDayHeader('SUN', darkPink),
                    ],
                  ),
                ),
                // Date cells
                Row(
                  children: [
                    _buildDateCell('25', false),
                    _buildDateCell('26', true),
                    _buildDateCell('27', false),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 15),
          
          // Beauty bag offer
          Text(
            'FREE BEAUTY BAG',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkGrey,
              letterSpacing: 1.0,
            ),
          ),
          Text(
            'when you spend £65 | £55',
            style: TextStyle(
              fontSize: 14,
              color: darkGrey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeader(String day, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: darkGrey, width: 1)),
        ),
        child: Text(
          day,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildDateCell(String date, bool isSpecial) {
    return Expanded(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: darkGrey, width: 1)),
        ),
        child: Stack(
          children: [
            // Date number
            Positioned(
              top: 10,
              left: 10,
              child: Text(
                date,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isSpecial ? darkPink : darkGrey,
                ),
              ),
            ),
            
            // Special content for Saturday
            if (isSpecial) ...[
              Positioned(
                top: 50,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // "NEW EP" with circle
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryPink, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'NEW EP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: darkGrey,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    // "In the Beauty Seat" text
                    Text(
                      'In the\nBeauty Seat',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: darkGrey,
                        fontStyle: FontStyle.italic,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}