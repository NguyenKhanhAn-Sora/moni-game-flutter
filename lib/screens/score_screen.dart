import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/score_service.dart';
import '../models/score_model.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  final ScoreService _scoreService = ScoreService();
  String _selectedMode = '4x4';
  List<ScoreModel> _scores = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _modes = [
    {'value': '2x2', 'label': '2x2 (Easy)'},
    {'value': '4x4', 'label': '4x4 (Medium)'},
    {'value': '6x6', 'label': '6x6 (Hard)'},
    {'value': '6x8', 'label': '6x8 (Expert)'},
  ];

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    setState(() => _isLoading = true);
    final scores = await _scoreService.getScores(_selectedMode);
    setState(() {
      _scores = scores;
      _isLoading = false;
    });
  }

  void _onModeChanged(String? newMode) {
    if (newMode != null && newMode != _selectedMode) {
      setState(() => _selectedMode = newMode);
      _loadScores();
    }
  }

  Future<void> _clearScores() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa kỷ lục'),
        content: Text(
          'Bạn có chắc muốn xóa tất cả kỷ lục của mode $_selectedMode?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _scoreService.clearScores(_selectedMode);
      _loadScores();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xóa kỷ lục')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kỷ lục cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Xóa kỷ lục',
            onPressed: _scores.isEmpty ? null : _clearScores,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.grid_on, color: Colors.blue),
                      const SizedBox(width: 10),
                      const Text(
                        'Chế độ:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedMode,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _modes.map((mode) {
                            return DropdownMenuItem<String>(
                              value: mode['value'],
                              child: Text(mode['label']),
                            );
                          }).toList(),
                          onChanged: _onModeChanged,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _scores.isEmpty
                  ? _buildEmptyState()
                  : _buildScoresList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Chưa có kỷ lục',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Hãy chơi mode $_selectedMode để tạo kỷ lục đầu tiên!',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScoresList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _scores.length,
      itemBuilder: (context, index) {
        final score = _scores[index];
        final isTopThree = index < 3;
        final medal = index == 0
            ? '🥇'
            : index == 1
            ? '🥈'
            : index == 2
            ? '🥉'
            : null;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: isTopThree ? 4 : 2,
          color: isTopThree ? Colors.amber.shade50 : Colors.white,
          child: ListTile(
            leading: SizedBox(
              width: 40,
              child: Center(
                child: medal != null
                    ? Text(medal, style: const TextStyle(fontSize: 28))
                    : Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
              ),
            ),
            title: Row(
              children: [
                const Icon(Icons.touch_app, size: 18, color: Colors.blue),
                const SizedBox(width: 5),
                Text(
                  '${score.moves} moves',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isTopThree
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isTopThree ? Colors.orange.shade900 : Colors.black87,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(score.date),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            trailing: isTopThree
                ? Icon(Icons.star, color: Colors.amber.shade700, size: 28)
                : null,
          ),
        );
      },
    );
  }
}
