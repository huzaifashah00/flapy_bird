// Game Screen
import 'package:flame/game.dart';
import 'package:flapy_bird/Flappy%20Bird%20Game/flappy_bird_game.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: FlappyBirdGame()),
    );
  }
}
