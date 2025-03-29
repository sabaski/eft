import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: SettingsPage(),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF202020),
      body: Column(
        children: [
          SizedBox(height: 25),
          Container(
            height: 45,
            padding: EdgeInsets.symmetric(horizontal: 10),
            color: Color(0xFF202020),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Expanded(
           child: Padding(
             padding: const EdgeInsets.all(20.0),
             child: Column(
               children: [
                 // سطر اول: دو دکمه در کنار هم
                 Row(
                   children: [
                     Expanded(
                       child: _buildSettingButton(
                         Icons.article, 
                         "Timer Profile", 
                         () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => TimerProfileScreen()),
                           );
                         },
                       ),
                     ),
                     SizedBox(width: 10), // فاصله بین دو دکمه
                     Expanded(
                       child: _buildSettingButton(
                         Icons.color_lens, 
                         "Timer Color", 
                         () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => TimerColorDialog()),
                           );
                         },
                       ),
                     ),
                   ],
                 ),

                 SizedBox(height: 10),

                 // سطر دوم: دکمه تمام‌عرض About us
                 SizedBox(
                   width: double.infinity,
                   child: _buildSettingButton(
                     Icons.info, 
                     "About us", 
                     () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutUsPage()),
                      );
                     },
                   ),
                 ),
               ],
             ),
           ),
         ),
        ],
      ),
    );
  }

  Widget _buildSettingButton(IconData icon, String label, VoidCallback onPressed) {
  return Container(
    decoration: BoxDecoration(
      color: Color(0xFF151515),
      borderRadius: BorderRadius.circular(8),
    ),
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size(double.infinity, 125), // ارتفاع دکمه به 100 پیکسل تنظیم می‌شود
        padding: EdgeInsets.symmetric(vertical: 16.0), // پدینگ داخلی
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ارتفاع ستون به اندازه محتوایش تنظیم می‌شود
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.cyan),
          SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.cyan, fontSize: 14)),
        ],
      ),
    ),
  );
 }
}

class TimerProfileScreen extends StatefulWidget {
  @override
  _TimerProfileScreenState createState() => _TimerProfileScreenState();
}

class _TimerProfileScreenState extends State<TimerProfileScreen> {
  int workMin = 2;
  int workSec = 0;
  int alarmMin = 0;
  int alarmSec = 5;
  int restMin = 1;
  int restSec = 0;
  int rounds = 3;

  bool isAlarmValid() {
    int workTime = workMin * 60 + workSec;
    int alarmTime = alarmMin * 60 + alarmSec;
    return alarmTime <= workTime;
  }

  @override
  void initState() {
    super.initState();
    loadSavedData();
  }

  Future<void> loadSavedData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      workMin = int.tryParse(prefs.getString('workMin') ?? '2') ?? 2;
      workSec = int.tryParse(prefs.getString('workSec') ?? '0') ?? 0;
      alarmMin = int.tryParse(prefs.getString('alarmMin') ?? '0') ?? 0;
      alarmSec = int.tryParse(prefs.getString('alarmSec') ?? '5') ?? 5;
      restMin = int.tryParse(prefs.getString('restMin') ?? '1') ?? 1;
      restSec = int.tryParse(prefs.getString('restSec') ?? '0') ?? 0;
      rounds = int.tryParse(prefs.getString('rounds') ?? '3') ?? 3;
    });
  }
  
  Future<void> saveData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('workMin', workMin.toString());
    await prefs.setString('workSec', workSec.toString());
    await prefs.setString('alarmMin', alarmMin.toString());
    await prefs.setString('alarmSec', alarmSec.toString());
    await prefs.setString('restMin', restMin.toString());
    await prefs.setString('restSec', restSec.toString());
    await prefs.setString('rounds', rounds.toString());

    await loadSavedData();
    setState(() {});
  }

  void applyChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Changes applied!',
            style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 25, 53, 26),
      ),
    );
  }

  void NoApplyChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('The alarm time should not be equal to or longer than the workout time.',
            style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 54, 5, 5),
      ),
    );
  }

  /// ویجت برای انتخاب زمان (دقیقه و ثانیه) با استفاده از NumberPicker
  Widget buildTimePicker(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // NumberPicker برای دقیقه (محدوده 0 تا 99)
            NumberPicker(
              value: label == "Work"
                  ? workMin
                  : label == "Alarm"
                      ? alarmMin
                      : restMin,
              minValue: 0,
              maxValue: 99,
              itemWidth: 50,
              axis: Axis.vertical,
              textStyle: GoogleFonts.poppins(color: Colors.white54),
              selectedTextStyle: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              onChanged: (value) {
                setState(() {
                  if (label == "Work") {
                    workMin = value;
                  } else if (label == "Alarm") {
                    alarmMin = value;
                  } else {
                    restMin = value;
                  }
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(":",
                  style: GoogleFonts.poppins(
                      fontSize: 22, color: Colors.white)),
            ),
            // NumberPicker برای ثانیه (محدوده 0 تا 59)
            NumberPicker(
              value: label == "Work"
                  ? workSec
                  : label == "Alarm"
                      ? alarmSec
                      : restSec,
              minValue: 0,
              maxValue: 59,
              itemWidth: 50,
              axis: Axis.vertical,
              textStyle: GoogleFonts.poppins(color: Colors.white54),
              selectedTextStyle: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              onChanged: (value) {
                setState(() {
                  if (label == "Work") {
                    workSec = value;
                  } else if (label == "Alarm") {
                    alarmSec = value;
                  } else {
                    restSec = value;
                  }
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        Divider(
          color: Colors.white30,
          thickness: 1,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  /// ویجت برای انتخاب تعداد دورها با NumberPicker
  Widget buildRoundPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Round",
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 5),
        NumberPicker(
          value: rounds,
          minValue: 1,
          maxValue: 100,
          itemWidth: 60,
          axis: Axis.horizontal,
          textStyle: GoogleFonts.poppins(color: Colors.white54),
          selectedTextStyle: GoogleFonts.poppins(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          onChanged: (value) {
            setState(() {
              rounds = value;
            });
          },
        ),
        const SizedBox(height: 20),
        Divider(
          color: Colors.white30,
          thickness: 1,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, 
      backgroundColor: const Color(0xFF202020),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 2,
        title: Text("Timer Profile Settings",
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildTimePicker("Work"),
              buildTimePicker("Rest"),
              buildTimePicker("Alarm"),
              buildRoundPicker(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!isAlarmValid()) { 
                    NoApplyChanges(); 
                  } else { 
                    await saveData();
                    applyChanges();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 22, 41, 128),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("OK",
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
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
          onPressed: () {
            Navigator.pop(context);
          },
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

class TimerColorDialog extends StatefulWidget {
  const TimerColorDialog({super.key});

  @override
  State<TimerColorDialog> createState() => _TimerColorDialogState();
}

class _TimerColorDialogState extends State<TimerColorDialog> {
  Color workColor = Colors.grey;
  Color alarmColor = Colors.grey;
  Color restColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    loadSavedColors();
  } 

  Future<void> saveColor(String key, Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, color.value);
  }

// ✅ بازیابی رنگ از SharedPreferences
  Future<Color> loadColor(String key, Color defaultColor) async {
    final prefs = await SharedPreferences.getInstance();
    return Color(prefs.getInt(key) ?? defaultColor.value);
  }

  Future<void> loadSavedColors() async {
    Color savedWorkColor = await loadColor('workColor', const Color.fromARGB(255, 29, 121, 32));
    Color savedAlarmColor = await loadColor('alarmColor', Colors.yellow);
    Color savedRestColor = await loadColor('restColor', const Color.fromARGB(255, 136, 18, 10));

    setState(() {
      workColor = savedWorkColor;
      alarmColor = savedAlarmColor;
      restColor = savedRestColor;
    });
  }

  void applyChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Changes applied!', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 25, 53, 26),
      ),
    );
  }

  void _pickColor(Color currentColor, Function(Color) onColorSelected, String key) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text("Choose Color", style: GoogleFonts.poppins(color: Colors.white)),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) {
                onColorSelected(color);
                saveColor(key, color); // ✅ ذخیره رنگ در SharedPreferences
              },
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
          // دکمه بک در گوشه بالا سمت چپ
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Text("Timer Color Settings",
              style: GoogleFonts.poppins(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          const Divider(color: Colors.white54),
          _buildColorPicker("Work", workColor, (color) => setState(() => workColor = color), "workColor"),
          _buildColorPicker("Alarm", alarmColor, (color) => setState(() => alarmColor = color), "alarmColor"),
          _buildColorPicker("Rest", restColor, (color) => setState(() => restColor = color), "restColor"),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 22, 41, 128),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              applyChanges();
            },
            child: Text("OK", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildColorPicker(String label, Color color, Function(Color) onColorSelected, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
          GestureDetector(
            onTap: () => _pickColor(color, onColorSelected, key),
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
