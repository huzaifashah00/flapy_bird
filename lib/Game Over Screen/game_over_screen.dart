// Game Over Screen
import 'package:flapy_bird/Game%20Screen/game_screen.dart';
import 'package:flapy_bird/Start%20Screen/start_screen.dart';
import 'package:flutter/material.dart';

class GameOverScreen extends StatelessWidget {
  final int score;
  final int highScore;

  GameOverScreen({required this.score, required this.highScore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Game Over!',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Score: $score',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'High Score: $highScore',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen()),
                );
              },
              child: Text('Play Again'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => StartScreen()),
                );
              },
              child: Text('Main Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
