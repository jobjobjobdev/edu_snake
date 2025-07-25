import 'package:flutter/material.dart';
import 'dart:math';

class LevelFact extends StatefulWidget {
  final int score;
  final VoidCallback onReset;

  const LevelFact({super.key, required this.score, required this.onReset});

  @override
  State<LevelFact> createState() => _LevelFactState();
}

class _LevelFactState extends State<LevelFact> {
  List<String> _facts = [
    "Bamboo is the fastest-growing plant on Earth.",
    "The Titan Arum emits a smell like rotting meat.",
    "Banana plants are actually herbs, not trees.",
  ];

  final Set<int> _usedIndexes = {};
  String _currentFact = "";
  int _lastScore = -1;
  bool _showCompletedMessage = false;
  void _updateFactIfScoreChanged() {
    if (widget.score == _lastScore) return;

    final availableIndexes = List.generate(_facts.length, (i) => i)
      ..removeWhere(_usedIndexes.contains);

    if (availableIndexes.isEmpty) {
      setState(() {
        _usedIndexes.clear();
        _lastScore = widget.score;
        _currentFact = "";
        _showCompletedMessage = true;
      });
      return;
    }

    final newIndex =
        availableIndexes[Random().nextInt(availableIndexes.length)];

    setState(() {
      _lastScore = widget.score;
      _usedIndexes.add(newIndex);
      _currentFact = _facts[newIndex];
      _showCompletedMessage = false;
    });
  }

  void _openEditDialog() async {
    final TextEditingController controller = TextEditingController(
      text: _facts.join(' # '),
    );

    final List<String>? newFacts = await showDialog<List<String>>(
      context: context,
      builder: (context) => Dialog(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Enter facts below. Separate each fact using the # symbol.",
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText: "Fact one # Fact two # ...",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            final rawText = controller.text.trim();
                            final newFacts = rawText
                                .split('#')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList();
                            Navigator.pop(context, newFacts);
                          },
                          child: const Text("Save"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    if (newFacts != null && newFacts.isNotEmpty) {
      setState(() {
        _facts = newFacts;
        _usedIndexes.clear();
        _lastScore = -1;
        _updateFactIfScoreChanged();
      });
    }
  }

  void _handleExternalReset() {
    setState(() {
      _usedIndexes.clear();
      _lastScore = widget.score;
      _currentFact = "";
    });
  }

  @override
  void didUpdateWidget(LevelFact oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateFactIfScoreChanged();
  }

  @override
  void initState() {
    super.initState();
    _updateFactIfScoreChanged();
  }

  @override
  Widget build(BuildContext context) {
    final int total = _facts.length;
    final int done = _usedIndexes.length;
    final double progress = total == 0 ? 0 : done / total;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey[700],
              color: Colors.greenAccent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "$done of $total facts shown",
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              _currentFact,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          if (_showCompletedMessage)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "All facts completed! Starting over.",
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _openEditDialog,
                child: const Text("Edit facts"),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {
                  _handleExternalReset();
                  widget.onReset();
                },
                child: const Text("Reset"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
