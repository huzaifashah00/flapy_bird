
// Flappy Bird Game
import 'package:flapy_bird/Game%20Over%20Screen/game_over_screen.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class FlappyBirdGame extends FlameGame with TapDetector {
  late SpriteComponent bird;
  late TextComponent scoreText;
  int score = 0;
  int highScore = 0;
  bool isGameOver = false;

  // Game physics constants
  final double gravity = 1000.0;
  final double jumpForce = -350.0;
  double birdVelocity = 0.0;

  // Pipe configuration
  double pipeGap = 200.0; // Increased gap between top and bottom pipes
  double pipeWidth = 52.0; // Width of the pipes
  double pipeSpacing = 300.0; // Increased horizontal space between pipe pairs
  List<SpriteComponent> pipes = [];
  double pipeSpeed = 130.0; // Slightly reduced speed for better playability
  Random random = Random();

  @override
  Future<void> onLoad() async {
    // Load bird sprite
    final birdSprite = await loadSprite('bird.png');
    bird = SpriteComponent()
      ..sprite = birdSprite
      ..position = Vector2(
          size.x * 0.3, size.y / 2) // Position bird at 30% of screen width
      ..size = Vector2(40, 40) // Smaller bird size
      ..anchor = Anchor.center; // Set rotation anchor to center
    add(bird);

    // Load score text with better visibility
    scoreText = TextComponent(
      text: 'Score: $score',
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 40,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    )..position = Vector2(size.x / 2, 50);
    add(scoreText);

    // Load high score
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('highScore') ?? 0;

    // Start generating pipes
    _generatePipes();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameOver) return;

    // Apply gravity and update bird position
    birdVelocity += gravity * dt;
    bird.position.y += birdVelocity * dt;

    // Rotate bird based on velocity
    bird.angle = (birdVelocity / 500).clamp(-0.5, 0.5);

    // Check if bird hits the ground or ceiling
    if (bird.position.y > size.y - bird.size.y / 2 ||
        bird.position.y < bird.size.y / 2) {
      endGame();
      return;
    }

    // Move pipes
    for (final pipe in List.from(pipes)) {
      pipe.position.x -= pipeSpeed * dt;

      // Remove pipes that go off-screen
      if (pipe.position.x < -pipeWidth) {
        remove(pipe);
        pipes.remove(pipe);
      }
    }

    // Check for collisions with improved hit detection
    for (final pipe in pipes) {
      final pipeRect = pipe.toRect();
      final birdRect = Rect.fromCircle(
        center: bird.position.toOffset(),
        radius: bird.size.x * 0.3,
      );

      if (pipeRect.overlaps(birdRect)) {
        endGame();
        return;
      }
    }

    // Score when passing pipes
    if (pipes.isNotEmpty &&
        pipes[0].position.x + pipeWidth < bird.position.x &&
        pipes[0].position.x + pipeWidth > bird.position.x - pipeSpeed * dt) {
      score++;
      scoreText.text = 'Score: $score';
      scoreText.position = Vector2(size.x / 2 - scoreText.size.x / 2, 50);
    }

    // Generate new pipes
    if (pipes.isEmpty || pipes.last.position.x < size.x - pipeSpacing) {
      _generatePipes();
    }
  }

  void _generatePipes() async {
    // Randomize the gap position with better constraints
    final minY = size.y * 0.25; // Minimum 25% from top
    final maxY = size.y * 0.75; // Maximum 75% from top
    final gapPosition = minY + random.nextDouble() * (maxY - minY);

    // Create top pipe with adjusted height
    final topPipe = SpriteComponent()
      ..sprite = await loadSprite('pipe.png')
      ..position = Vector2(size.x, gapPosition - pipeGap / 2)
      ..size = Vector2(pipeWidth, gapPosition - pipeGap / 2)
      ..angle = pi; // Rotate top pipe 180 degrees
    add(topPipe);
    pipes.add(topPipe);

    // Create bottom pipe with adjusted height
    final bottomPipe = SpriteComponent()
      ..sprite = await loadSprite('pipe.png')
      ..position = Vector2(size.x, gapPosition + pipeGap / 2)
      ..size = Vector2(pipeWidth, size.y - (gapPosition + pipeGap / 2));
    add(bottomPipe);
    pipes.add(bottomPipe);
  }

  @override
  void onTap() {
    if (isGameOver) return;

    // Apply jump force with smooth animation
    birdVelocity = jumpForce;
  }

  void endGame() async {
    isGameOver = true;

    // Save high score
    final prefs = await SharedPreferences.getInstance();
    if (score > highScore) {
      highScore = score;
      await prefs.setInt('highScore', highScore);
    }

    // Navigate to Game Over Screen
    final context = buildContext;
    if (context != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              GameOverScreen(score: score, highScore: highScore),
        ),
      );
    }
  }
}
