import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const TimerColorDialog(),
    );
  }
}

class TimerColorDialog extends StatefulWidget {
  const TimerColorDialog({super.key});

  @override
  State<TimerColorDialog> createState() => _TimerColorDialogState();
}

class _TimerColorDialogState extends State<TimerColorDialog> {
  Color workColor = Colors.grey;
  Color alarmColor = Colors.grey;
  Color restColor = Colors.grey;

  void _pickColor(Color currentColor, Function(Color) onColorSelected) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text("Choose Color", style: GoogleFonts.poppins(color: Colors.white)),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: onColorSelected,
              showLabel: false,
              pickerAreaBorderRadius: BorderRadius.circular(10),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK", style: GoogleFonts.poppins(color: Colors.tealAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Timer Color Settings",
                style: GoogleFonts.poppins(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            const Divider(color: Colors.white54),
            _buildColorPicker("Work", workColor, (color) => setState(() => workColor = color)),
            _buildColorPicker("Alarm", alarmColor, (color) => setState(() => alarmColor = color)),
            _buildColorPicker("Rest", restColor, (color) => setState(() => restColor = color)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text("OK", style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(String label, Color color, Function(Color) onColorSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
          GestureDetector(
            onTap: () => _pickColor(color, onColorSelected),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 5,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
