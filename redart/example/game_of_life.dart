import 'dart:math';

import 'package:redart/redart.dart';

class Cell with ControllerUtils {
  final int x;
  final int y;

  @Re()
  bool _alive;

  @Re()
  bool get _nextState {
    final aliveNeighbors = neighbors.where((n) {
      return n.alive;
    }).length;
    // Any live cell with fewer than two live neighbors dies, as if by underpopulation.
    if (alive && aliveNeighbors < 2) {
      return false;
    }
    // Any live cell with two or three live neighbors lives on to the next generation.
    if (alive && (aliveNeighbors == 2 || aliveNeighbors == 3)) {
      return true;
    }
    // Any live cell with more than three live neighbors dies, as if by overpopulation.
    if (alive && aliveNeighbors > 3) {
      return false;
    }
    // Any dead cell with exactly three live neighbors becomes a live cell, as if by reproduction.
    if (!alive && aliveNeighbors == 3) {
      return true;
    }

    return false;
  }

  late final List<Cell> neighbors;

  Cell({
    required this.x,
    required this.y,
    required bool alive,
  }) : _alive = alive;
}

class GameOfLife {
  final int width;
  final int height;

  late final List<List<Cell>> cells;

  GameOfLife({required this.width, required this.height}) {
    final rng = Random();
    cells = List.generate(
      height,
          (y) =>
          List.generate(
            width,
                (x) {
              final alive = (rng.nextDouble() <= 0.5);
              return Cell(x: x, y: y, alive: alive);
            },
          ),
    );

    for (final row in cells) {
      for (final cell in row) {
        final neighbors = <Cell>[];
        for (final dy in [-1, 0, 1]) {
          for (final dx in [-1, 0, 1]) {
            if (dx == 0 && dy == 0) {
              continue;
            }
            final nx = cell.x + dx;
            final ny = cell.y + dy;
            if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
              neighbors.add(cells[ny][nx]);
            }
          }
        }
        cell.neighbors = neighbors;
      }
    }
  }

  void tick() {
    for (final row in cells) {
      for (final cell in row) {
        cell.alive = cell.nextState;
      }
    }
  }

  void render() {
    for (final row in cells) {
      final line = row.map((cell) => cell.alive ? 'X' : '.').join();
      print(line);
    }
  }
}

void main() async {
  final game = GameOfLife(width: 3, height: 3);
  final dispose = listen(() {
    game.tick();
    game.render();
    print('\n\n\n');
  });

  while(true) {
    await Future.delayed(Duration.zero);
    print('-');
  }

  dispose();
}
