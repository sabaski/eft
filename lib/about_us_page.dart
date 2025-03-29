import 'package:flutter/material.dart';
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
      theme: ThemeData.dark(),
      home: const AboutUsPage(),
    );
  }
}

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202020),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "About us",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.white),
            const SizedBox(height: 12),
            Text(
              "این اپلیکیشن به صورت اختصاصی برای باشگاه ستاره ساز با مدیریت احسان فسنقری طراحی و توسعه داده شده است هدف از ساخت این برنامه بهبود نظم و دقت در زمان بندی تمرینات و افزایش بهره وری ورزشکاران در طول جلسات تمرینی است. ",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            _buildInfoRow("باشگاه ستاره ساز", Image.asset('assets/image/ss_logo.png', width: 90, height: 90)),
            _buildInfoRow("مدیریت احسان فسنقری", Image.asset('assets/image/ef_logo.png', width: 60, height: 60)),
            _buildInfoRow("توسعه دهنده سینا انارکی", Image.asset('assets/image/s.soft_logo.png', width: 100, height: 100)),
            const SizedBox(height: 20),
            Text(
              "این برنامه با دقت و هماهنگی کامل بین مدیریت باشگاه و توسعه دهنده طراحی شده تا بهترین تجربه کاربری را برای اعضای باشگاه فراهم کند",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildInfoRow(String text, Widget icon) {
   return Padding(
     padding: const EdgeInsets.symmetric(vertical: 10),
     child: Row(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
         icon, // حالا هر نوع ویجتی قبول می‌کنه!
         const SizedBox(width: 10),
         Text(
           text,
           style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
         ),
       ],
     ),
   );
 }
}
