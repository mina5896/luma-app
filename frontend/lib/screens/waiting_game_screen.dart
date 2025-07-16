import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:luma/screens/topics_screen.dart';
import 'package:luma/widgets/themed_background.dart';

class WaitingGameScreen extends StatefulWidget {
  const WaitingGameScreen({super.key});

  @override
  State<WaitingGameScreen> createState() => _WaitingGameScreenState();
}

class _WaitingGameScreenState extends State<WaitingGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Dino _dino = Dino();
  List<Obstacle> _obstacles = [];
  double _groundSpeed = 8.0;
  int _score = 0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 99), // Effectively infinite
    )..addListener(_gameLoop);

    // Start the game after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _startGame();
      }
    });
  }

  void _startGame() {
    setState(() {
      _isGameOver = false;
      _score = 0;
      _obstacles.clear();
      _dino = Dino();
      _controller.forward();
    });
  }

  void _gameLoop() {
    if (_isGameOver) return;

    // Update dino
    _dino.update();

    // Update obstacles
    List<Obstacle> toRemove = [];
    for (var obstacle in _obstacles) {
      obstacle.update(_groundSpeed);
      if (obstacle.isOffScreen()) {
        toRemove.add(obstacle);
        setState(() {
          _score++;
        });
      }

      // Check for collision
      if (obstacle.collidesWith(_dino)) {
        setState(() {
          _isGameOver = true;
          _controller.stop();
        });
      }
    }

    // Remove off-screen obstacles
    setState(() {
      _obstacles.removeWhere((obs) => toRemove.contains(obs));
    });

    // Spawn new obstacles
    if (_obstacles.isEmpty || _obstacles.last.x < 200) {
      setState(() {
        _obstacles.add(Obstacle());
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isGameOver) {
          _startGame();
        } else {
          _dino.jump();
        }
      },
      child: Scaffold(
        body: ThemedBackground(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Game elements drawn here
              _DinoWidget(dino: _dino),
              ..._obstacles.map((obs) => _ObstacleWidget(obstacle: obs)),
              // Ground
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 20,
                  color: Colors.grey.shade700,
                ),
              ),
              // Score and instructions
              Positioned(
                top: 60,
                right: 20,
                child: Text("SCORE: $_score",
                    style:
                        const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              if (_isGameOver)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("GAME OVER",
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 20),
                        const Text("Tap to play again",
                            style: TextStyle(fontSize: 20, color: Colors.white70)),
                        const SizedBox(height: 60),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const TopicsScreen()),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: const Text("Exit to Main Menu"))
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Game Object Classes ---

class Dino {
  double y = 0;
  double yVelocity = 0;
  bool isJumping = false;
  final double _gravity = 0.9;
  final double _jumpVelocity = -18.0;

  void jump() {
    if (!isJumping) {
      isJumping = true;
      yVelocity = _jumpVelocity;
    }
  }

  void update() {
    if (isJumping) {
      yVelocity += _gravity;
      y += yVelocity;

      if (y >= 0) {
        y = 0;
        yVelocity = 0;
        isJumping = false;
      }
    }
  }

  Rect get rect => Rect.fromLTWH(50, 200 + y, 50, 50);
}

class Obstacle {
  double x = 400;
  double height = 50 + Random().nextInt(50).toDouble();
  double width = 20 + Random().nextInt(20).toDouble();

  void update(double speed) {
    x -= speed;
  }

  bool isOffScreen() => x < -width;

  bool collidesWith(Dino dino) {
    return dino.rect.overlaps(Rect.fromLTWH(x, 250 - height, width, height));
  }
}

// --- Game Widget Classes ---

class _DinoWidget extends StatelessWidget {
  final Dino dino;
  const _DinoWidget({required this.dino});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: dino.rect.left,
      top: dino.rect.top,
      width: dino.rect.width,
      height: dino.rect.height,
      child: const Icon(Icons.android, color: Colors.green, size: 50),
    );
  }
}

class _ObstacleWidget extends StatelessWidget {
  final Obstacle obstacle;
  const _ObstacleWidget({required this.obstacle});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: obstacle.x,
      bottom: 20, // Sit on top of the ground
      width: obstacle.width,
      height: obstacle.height,
      child: Container(color: Colors.red.shade400),
    );
  }
}