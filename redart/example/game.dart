import 'dart:async';

import 'package:redart/redart.dart';
import 'dart:core';

class Player with ControllerUtils {
  @Re()
  int _score = 0;
  @Re()
  int _health = 100;

  void attack(Player enemy) {
    enemy.health -= 10;
    score += 1;
  }
}

class Game {
  Game(this._players);

  final List<Player> _players;

  void run() {
    for (final player in _players) {
      print('player: score: ${player.score} health: ${player.health}');
    }
    print('game running...');
  }
}

void main() async {
  final player1 = Player();
  final player2 = Player();
  final game = Game([player1, player2]);
  final dispose = listen(() {
    // this will re run the game.run() whenever any of the reactive fields change
    game.run();
  });

  // start playing
  player1.attack(player2);
  player1.attack(player2);
  player1.attack(player2);

  // await tick, that will process above code and print the output once
  await Future.delayed(Duration.zero);

  // continue playing
  player1.attack(player2);
  player1.attack(player2);
  player1.attack(player2);

  // tick again
  await Future.delayed(Duration.zero);

  // end game
  dispose();

  // that would have printed
  // player: score: 0 health: 100
  // player: score: 0 health: 100
  // game running...
  // player: score: 3 health: 100
  // player: score: 0 health: 70
  // game running...
  // player: score: 6 health: 100
  // player: score: 0 health: 40
  // game running...
}
