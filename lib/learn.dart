import 'dart:async';
import 'settings_page.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TimerScreen(),
    );
  }
}

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  int _timeLeft = 120;
  int _initialTime = 120;
  int _restTime = 60;
  int _warningTime = 5;
  int _round = 1;
  int _totalRounds = 3;
  bool _isRunning = false;
  bool _isResting = false;
  bool _hasPlayedAlarm = false;
  bool _hasPlayedWorkSound = false;

  // دو instance جداگانه از AudioPlayer
  final AudioPlayer backgroundPlayer = AudioPlayer();
  final AudioPlayer effectsPlayer = AudioPlayer();

  Timer? _timer;
  late AnimationController _controller;
  late AnimationController _rotationController;
  late AnimationController _millisecondsController;
  Color workColor = const Color.fromARGB(255, 29, 121, 32);
  Color alarmColor = Colors.yellow;
  Color restColor = const Color.fromARGB(255, 136, 18, 10);

  void updateWakelock() {
    WakelockPlus.enable();
  }

  Future<void> loadSavedData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int workMin = int.parse(prefs.getString('workMin') ?? '2');
    int workSec = int.parse(prefs.getString('workSec') ?? '0');
    int restMin = int.parse(prefs.getString('restMin') ?? '1');
    int restSec = int.parse(prefs.getString('restSec') ?? '0');
    int alarmMin = int.parse(prefs.getString('alarmMin') ?? '0');
    int alarmSec = int.parse(prefs.getString('alarmSec') ?? '5');
    int round = int.parse(prefs.getString('rounds') ?? '3');

    setState(() {
      _initialTime = (workMin * 60) + workSec;
      _restTime = (restMin * 60) + restSec;
      _warningTime = (alarmMin * 60) + alarmSec;
      _totalRounds = round;
      _timeLeft = _initialTime;
    });
  }

  Future<Color> loadColor(String key, Color defaultColor) async {
    final prefs = await SharedPreferences.getInstance();
    return Color(prefs.getInt(key) ?? defaultColor.value);
  }

  void loadColors() async {
    workColor = await loadColor('workColor', const Color.fromARGB(255, 29, 121, 32));
    alarmColor = await loadColor('alarmColor', Colors.yellow);
    restColor = await loadColor('restColor', const Color.fromARGB(255, 136, 18, 10));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadSavedData();
    WakelockPlus.enable();
    loadColors();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _timeLeft),
    );
    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _timeLeft),
    );
    _millisecondsController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    // تنظیم AudioContext برای جلوگیری از درخواست audio focus
    final AudioContext audioContext = AudioContext(
      android: AudioContextAndroid(
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {AVAudioSessionOptions.mixWithOthers},
      ),
    );

    // اعمال تنظیمات روی هر دو پخش‌کننده
    backgroundPlayer.setAudioContext(audioContext);
    effectsPlayer.setAudioContext(audioContext);

    // تنظیم حالت پخش برای هر کدام (background به صورت loop)
    backgroundPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    backgroundPlayer.setReleaseMode(ReleaseMode.loop);

    effectsPlayer.setPlayerMode(PlayerMode.lowLatency);
    effectsPlayer.setReleaseMode(ReleaseMode.stop);
  }

  void startTimer() {
    if (_isRunning) {
      pauseTimer();
      return;
    }

    _millisecondsController.reset();
    updateWakelock();

    if (_isResting) {
      _millisecondsController.repeat();
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_timeLeft > 0) {
          setState(() => _timeLeft--);
        } else {
          timer.cancel();
          _millisecondsController.stop();
          _isResting = false;
          nextRound();
        }
      });
    } else {
      if (!_isResting && !_hasPlayedWorkSound) {
        // پخش صدای تمرین بدون درخواست audio focus
        effectsPlayer.play(AssetSource('audio/work.mp3'));
        _hasPlayedWorkSound = true;
      }
      _controller.forward(from: _controller.value);
      _rotationController.repeat();
      _millisecondsController.repeat();

      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_timeLeft > 0) {
          setState(() => _timeLeft--);

          if (_timeLeft == _warningTime && !_hasPlayedAlarm) {
            // پخش صدای هشدار بدون درخواست audio focus
            effectsPlayer.play(AssetSource('audio/alarm.mp3'));
            _hasPlayedAlarm = true;
          }
        } else {
          timer.cancel();
          _rotationController.stop();
          _millisecondsController.stop();

          if (_round >= _totalRounds) {
            nextRound();
          } else {
            startRest();
          }
        }
      });
    }

    setState(() {
      _isRunning = true;
    });
  }

  void startRest() {
    setState(() {
      _isResting = true;
      _timeLeft = _restTime;
    });

    _millisecondsController.reset();
    _millisecondsController.repeat();
    effectsPlayer.play(AssetSource('audio/rest.mp3'));

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        timer.cancel();
        _millisecondsController.stop();
        _isResting = false;
        nextRound();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _controller.stop();
    _rotationController.stop();
    _millisecondsController.stop();
    setState(() {
      _isRunning = false;
    });
    updateWakelock();
  }

  void resetTimer() {
    _timer?.cancel();
    _controller.reset();
    _rotationController.stop();
    _millisecondsController.reset();
    pauseTimer();
    setState(() {
      _timeLeft = _initialTime;
      _round = 1;
      _isResting = false;
      _hasPlayedAlarm = false;
      _hasPlayedWorkSound = false;
    });
    updateWakelock();
    backgroundPlayer.stop();
  }

  void nextRound() {
    if (_round < _totalRounds) {
      setState(() {
        _round++;
        _timeLeft = _initialTime;
        _isResting = false;
        _isRunning = false;
        _hasPlayedAlarm = false;
        _hasPlayedWorkSound = false;
      });
      _millisecondsController.reset();
      startTimer();
    } else {
      setState(() {
        _isRunning = false;
        resetTimer();
      });
    }
    updateWakelock();
  }

  void skipRound() {
    _timer?.cancel();
    _controller.reset();
    _rotationController.stop();
    _millisecondsController.stop();

    if (!_isResting) {
      startRest();
    } else {
      nextRound();
    }
  }

  String formatTime(int seconds) {
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color getCircleColor() {
    if (_isResting) {
      return restColor;
    } else if (_timeLeft <= _warningTime) {
      return alarmColor;
    } else {
      return workColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000000), Color(0xFF353333)],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Column(
                        children: [
                          Text("Work", style: TextStyle(color: Colors.white, fontSize: 18)),
                          Text(formatTime(_initialTime), style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 30),
                      child: Column(
                        children: [
                          Text("Rest", style: TextStyle(color: Colors.white, fontSize: 18)),
                          Text(formatTime(_restTime), style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 1.0, end: _timeLeft / (_isResting ? _restTime : _initialTime)),
                  duration: Duration(milliseconds: 500),
                  builder: (context, double progress, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: progress > 0 ? progress : 0.01,
                            strokeWidth: 9,
                            backgroundColor: getCircleColor(),
                            valueColor: AlwaysStoppedAnimation(Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ),
                        RotationTransition(
                          turns: _rotationController,
                          child: SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              backgroundColor: Colors.black,
                              valueColor: _isRunning
                                  ? AlwaysStoppedAnimation(getCircleColor())
                                  : AlwaysStoppedAnimation(const Color.fromARGB(255, 0, 0, 0)),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 15,
                          top: 30,
                          child: Image.asset(
                            'assets/image/ss_black.png',
                            color: getCircleColor(),
                            colorBlendMode: BlendMode.srcIn,
                            width: 150,
                            height: 145,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 20),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formatTime(_timeLeft),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 5),
                    AnimatedBuilder(
                      animation: _millisecondsController,
                      builder: (context, child) {
                        return Text(
                          '${(_millisecondsController.value * 100).toInt().toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Round $_round/$_totalRounds',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow, size: 60),
                      color: _isRunning ? Colors.red : Colors.green,
                      onPressed: startTimer,
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.refresh, size: 40, color: Colors.white),
                      onPressed: resetTimer,
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.skip_next, size: 40, color: Colors.white),
                      onPressed: skipRound,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.settings, size: 40, color: Colors.white),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                    pauseTimer();
                    await loadSavedData();
                    loadColors();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 1),
              child: Image.asset(
                'assets/image/ef_link.png',
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.125,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
