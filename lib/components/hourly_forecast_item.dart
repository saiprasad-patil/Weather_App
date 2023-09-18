import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HourlyForecastItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final String value;
  final String weatherStatus;
  const HourlyForecastItem({
    super.key,
    required this.time,
    required this.icon,
    required this.value,
    required this.weatherStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(60, 255, 255, 255),
      elevation: 6,
      child: Container(
        width: 100,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              time,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            const SizedBox(
              height: 5,
            ),
            Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              "$value °C",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              weatherStatus,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
