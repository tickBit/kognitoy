import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AnimalGame(),
    );
  }
}

class AnimalGame extends StatefulWidget {
  const AnimalGame({super.key});

  @override
  _AnimalGameState createState() => _AnimalGameState();
}

class _AnimalGameState extends State<AnimalGame> with TickerProviderStateMixin {
  final player = AudioPlayer();

  late Animation<double> animation;
  late AnimationController _controller;

  late Animation<Color?> colorAnimation;
  late AnimationController colorController;

  bool _answered = false;
  bool _row = false;
  bool _wrong = false;
  int firstAnimal = 0;
  String _firstPicture = "";
  double _angle = pi / 180.0;

  List<int> indices = [0,1,2];
  List<int> rowOfPictures = [];

  List<String> pictures = ["assets/cat.jpg", "assets/dog.jpg", "assets/bird.jpg"];

  Future<void> _playSound(String soundFile) async {
    try {
      final ByteData data = await rootBundle.load(soundFile);
      final bytes = data.buffer.asUint8List();
      await player.play(BytesSource(bytes));
    } catch (e) {
      //print("Virhe ääntä toistettaessa: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    _row = false;
    _answered = false;
    _wrong = false;

    var rnd = Random();
    firstAnimal = rnd.nextInt(3);
    _firstPicture = pictures[firstAnimal];

    rowOfPictures = [];

    int index = 0;
    int rndNumber = 0;

    while (indices.isNotEmpty) {

	    rndNumber = rnd.nextInt(indices.length);
	    index = indices[rndNumber];
	    rowOfPictures.add(index);
	
	    indices.removeWhere( (item) => item == index );

    }

    _controller = AnimationController(duration: const Duration(seconds: 5), vsync: this);
    animation = Tween<double>(begin: 0, end: 300).animate(_controller)
      ..addListener(() {
        setState(() {
          _angle += 0.25 * pi / 180.0;
        });
      });
    _controller.repeat();

    colorController = AnimationController(duration: const Duration(seconds: 3), vsync: this)
      ..repeat(reverse: true);
    colorAnimation = ColorTween(
    begin: Colors.amberAccent.withOpacity(0.5),
    end: Colors.green.withOpacity(0.6),
  ).animate(_controller)
    ..addListener(() {
      setState(() {});
    });
}

void _checkConditionAndAnimate() {
  if (_answered && !_wrong) {
    _controller.repeat(reverse: true);
    _playSound('assets/win.ogg');
  } else {
    _controller.stop();
  }
}

void _updateAnswerStatus(bool answered, bool wrong) {
  setState(() {
    _answered = answered;
    _wrong = wrong;
  });
  _checkConditionAndAnimate();
}

  @override
  void dispose() {
    _controller.dispose();
    colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const spacer = Padding(padding: EdgeInsets.all(4));
    
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eläimet :-)'),
        backgroundColor: Colors.teal,
      ),
      body: GestureDetector(
        onDoubleTap: () => {
          if (_answered)
            setState(() {
              _row = false;
              _answered = false;
              _wrong = false;
              _updateAnswerStatus(_answered, _wrong);
              var rnd = Random();
              firstAnimal = rnd.nextInt(3);
              _firstPicture = pictures[firstAnimal];

              indices = [0,1,2];
              
              rowOfPictures = [];

              int index = 0;
              int rndNumber = 0;

              while (indices.isNotEmpty) {

	              rndNumber = rnd.nextInt(indices.length);
	              index = indices[rndNumber];
	              rowOfPictures.add(index);
	
	              indices.removeWhere( (item) => item == index );

              }
            })
        },
        child: Stack(
          children: [
            if (_answered && !_wrong)

            AnimatedBuilder(
              animation: colorAnimation,
              builder: (context, child) {
                return ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    colorAnimation.value ?? Colors.amberAccent,
                    BlendMode.srcATop,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/background.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            )
            else
               Container(

        decoration: const BoxDecoration(
          
          image: DecorationImage(
            
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
            
            
          ))),

            Center(
              child: Stack(
                children: [
                  if (_answered && !_wrong)
                    for (int i = 0; i < 18; i++)
                      Positioned(
                        left: cos(_angle + i * pi / 9) * width * 0.25 + width / 2,
                        top: sin(_angle + i * pi / 9) * height * 0.25 + height / 2 - 80,
                        child: Image.asset("assets/heart.png", width: 100, height: 100),
                      ),
                  if (!_row)
                    GestureDetector(
                      onTap: () => setState(() {
                        _row = true;
                        
                        switch (firstAnimal) {
                          case 0:
                            _playSound('assets/cat_meow.ogg');
                            break;
                          case 1:
                            _playSound('assets/dog_bark.ogg');
                            break;
                          case 2:
                            _playSound('assets/bird_sound.ogg');
                            break;
                        }

                        
                      }),
                      child: CircleAvatar(
                        radius: height *0.4,
                        foregroundColor: Colors.red,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: ClipOval(child: Image.asset(_firstPicture)),
                        ),
                      ),
                    ),
                  if (_row && !_wrong && !_answered)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => {
                            _answered = true,
                            if (firstAnimal == rowOfPictures[0])
                              setState(() {
                                _wrong = false;
                                _angle = pi / 180.0;
                                _updateAnswerStatus(_answered, _wrong);
                              })
                            else
                              setState(() {
                                _wrong = true;
                              })
                          },
                          child: CircleAvatar(
                            radius: width * 0.32 * 0.5,
                            foregroundColor: Colors.red,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: ClipOval(child: Image.asset(pictures[rowOfPictures[0]])),
                            ),
                          ),
                        ),
                        spacer,
                        GestureDetector(
                          onTap: () => {
                            _answered = true,
                            if (firstAnimal == rowOfPictures[1])
                              setState(() {
                                _wrong = false;
                                _angle = pi / 180.0;
                                _updateAnswerStatus(_answered, _wrong);
                              })
                            else
                              setState(() {
                                _wrong = true;
                                _updateAnswerStatus(_answered, _wrong);
                              })
                          },
                          child: CircleAvatar(
                            radius: width * 0.32 * 0.5,
                            foregroundColor: Colors.red,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: ClipOval(child: Image.asset(pictures[rowOfPictures[1]])),
                            ),
                          ),
                        ),
                        spacer,
                        GestureDetector(
                          onTap: () => {
                            _answered = true,
                            if (firstAnimal == rowOfPictures[2])
                              setState(() {
                                _wrong = false;
                                _angle = pi / 180.0;
                                _updateAnswerStatus(_answered, _wrong);
                              })
                            else
                              setState(() {
                                _wrong = true;
                                _updateAnswerStatus(_answered, _wrong);
                              })
                          },
                          child: CircleAvatar(
                            radius: width * 0.32 * 0.5,
                            foregroundColor: Colors.red,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: ClipOval(child: Image.asset(pictures[rowOfPictures[2]])),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (_wrong && _answered) Image.asset("assets/ghost.png", height: height * 0.4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
