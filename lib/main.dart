import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MemoryGameApp());
}

class MemoryGameApp extends StatelessWidget {
  const MemoryGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Match',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MemoryHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MemoryHomePage extends StatefulWidget {
  const MemoryHomePage({super.key});

  @override
  State<MemoryHomePage> createState() => _MemoryHomePageState();
}

class CardModel {
  final int id; // unique id for each card instance
  final String content; // emoji or image path
  bool revealed;
  bool matched;

  CardModel({
    required this.id,
    required this.content,
    this.revealed = false,
    this.matched = false,
  });
}

class _MemoryHomePageState extends State<MemoryHomePage> {
  // Default size: 4x4 (8 pairs)
  int gridSize = 4;
  late List<CardModel> cards;
  CardModel? firstPick;
  bool waiting = false;
  int moves = 0;
  int matchesFound = 0;
  final List<String> _allEmojis = [
    '🍎',
    '🍌',
    '🍇',
    '🍊',
    '🍓',
    '🍉',
    '🥝',
    '🍍',
    '🍒',
    '🥥',
    '🍑',
    '🍐',
    '🍋',
    '🥭',
    '🍈',
    '🍆',
    '🌟',
    '🔥',
    '⚽',
    '🎲',
    '🎯',
    '🎵',
    '🚗',
    '✈️',
  ];

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    moves = 0;
    matchesFound = 0;
    firstPick = null;
    waiting = false;

    final numPairs = (gridSize * gridSize) ~/ 2;
    final rnd = Random();
    final emojis = List<String>.from(_allEmojis)..shuffle(rnd);
    final chosen = emojis.take(numPairs).toList();

    final temp = <CardModel>[];
    int idCounter = 0;
    for (var e in chosen) {
      temp.add(CardModel(id: idCounter++, content: e));
      temp.add(CardModel(id: idCounter++, content: e));
    }
    temp.shuffle(rnd);
    cards = temp;

    setState(() {});
  }

  void _onCardTap(int index) {
    if (waiting) return;
    final card = cards[index];
    if (card.revealed || card.matched) return;

    setState(() {
      card.revealed = true;
    });

    if (firstPick == null) {
      firstPick = card;
      return;
    }

    // second pick
    moves++;
    if (firstPick!.content == card.content && firstPick!.id != card.id) {
      // matched
      setState(() {
        firstPick!.matched = true;
        card.matched = true;
        matchesFound++;
        firstPick = null;
      });

      // check win
      if (matchesFound == (gridSize * gridSize) ~/ 2) {
        _showWinDialog();
      }
    } else {
      // not matched -> flip back after short delay
      waiting = true;
      Future.delayed(const Duration(milliseconds: 700), () {
        setState(() {
          firstPick!.revealed = false;
          card.revealed = false;
          firstPick = null;
          waiting = false;
        });
      });
    }
  }

  Future<void> _showWinDialog() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Bạn chiến thắng! 🎉'),
        content: Text('Bạn hoàn thành trong $moves lượt. Chơi lại?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startNewGame();
            },
            child: const Text('Chơi lại'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(CardModel card, int index) {
    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        child: CardFlip(
          isFront: card.revealed || card.matched,
          front: Container(
            alignment: Alignment.center,
            child: Text(card.content, style: const TextStyle(fontSize: 32)),
          ),
          back: Container(
            color: Colors.blue.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.help_outline, size: 28),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double spacing = 8;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Match - Lật thẻ'),
        actions: [
          IconButton(
            tooltip: 'Đổi kích thước lưới',
            icon: const Icon(Icons.grid_on),
            onPressed: () => _showGridSizeDialog(),
          ),
          IconButton(
            tooltip: 'Chơi lại',
            icon: const Icon(Icons.refresh),
            onPressed: _startNewGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Text('Moves: $moves', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 16),
                  Text(
                    'Matches: $matchesFound',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _startNewGame,
                    icon: const Icon(Icons.replay),
                    label: const Text('New Game'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(spacing),
                child: GridView.builder(
                  itemCount: cards.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                  ),
                  itemBuilder: (context, index) {
                    return _buildCard(cards[index], index);
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Grid: ${gridSize}x$gridSize — Pairs: ${(gridSize * gridSize) ~/ 2}',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGridSizeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int tempSize = gridSize;
        return AlertDialog(
          title: const Text('Chọn kích thước lưới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int>(
                value: 2,
                groupValue: tempSize,
                title: const Text('2 x 2 (1 pair)'),
                onChanged: (v) => setState(() => tempSize = v ?? 2),
              ),
              RadioListTile<int>(
                value: 4,
                groupValue: tempSize,
                title: const Text('4 x 4 (8 pairs)'),
                onChanged: (v) => setState(() => tempSize = v ?? 4),
              ),
              RadioListTile<int>(
                value: 6,
                groupValue: tempSize,
                title: const Text('6 x 6 (18 pairs)'),
                onChanged: (v) => setState(() => tempSize = v ?? 6),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                // ensure even number of cards
                gridSize = tempSize;
                _startNewGame();
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

/// A simple flip widget: shows back when [isFront] is false, otherwise front.
/// Uses rotationY transform for flip effect.
class CardFlip extends StatelessWidget {
  final bool isFront;
  final Widget front;
  final Widget back;

  const CardFlip({
    super.key,
    required this.isFront,
    required this.front,
    required this.back,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        final rotate = Tween(begin: pi, end: 0.0).animate(animation);
        return AnimatedBuilder(
          animation: rotate,
          child: child,
          builder: (context, child) {
            final angle = rotate.value;
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(angle);
            return Transform(
              transform: transform,
              alignment: Alignment.center,
              child: child,
            );
          },
        );
      },
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: isFront
          ? Container(
              key: const ValueKey('front'),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black12,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: front,
            )
          : Container(
              key: const ValueKey('back'),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black12,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: back,
            ),
    );
  }
}
