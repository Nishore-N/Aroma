import 'dart:async';

import 'package:flutter/material.dart';
import 'step_ingredients_bottomsheet.dart';
import 'step_timer_bottomsheet.dart';
import '../completion/completion_screen.dart';

class CookingStepsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> steps;
  final int currentStep;

  const CookingStepsScreen({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  State<CookingStepsScreen> createState() => _CookingStepsScreenState();
}

class _CookingStepsScreenState extends State<CookingStepsScreen> {
  Timer? _timer;
  int _totalSeconds = 0;
  int _secondsRemaining = 0;
  bool _isTimerRunning = false;
  bool _isTimerSet = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isTimerRunning || !_isTimerSet) return;
    
    setState(() {
      _isTimerRunning = true;
      _secondsRemaining = 0; // Start from 0
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining < _totalSeconds) {
        setState(() {
          _secondsRemaining++;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isTimerRunning = false;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _setTimer(int minutes) {
    setState(() {
      _totalSeconds = minutes * 60;
      _secondsRemaining = 0; // Initialize to 0 for count-up
      _isTimerSet = true;
      _isTimerRunning = false;
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  void _showTimerBottomSheet() {
    showStepTimerBottomSheet(context).then((selectedMinutes) {
      if (selectedMinutes != null) {
        _setTimer(selectedMinutes);
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[widget.currentStep - 1];
    final String instruction = (step['instruction'] ?? '').toString();
    final List<Map<String, dynamic>> stepIngredients =
        (step['ingredients'] as List?)?.whereType<Map<String, dynamic>>().toList(growable: false) ??
            <Map<String, dynamic>>[];
    final List<String> tips =
        (step['tips'] as List?)?.map((e) => e.toString()).toList(growable: false) ??
            <String>[];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ---------------- TITLE ----------------
              const Text(
                "Cooking Steps",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 10),

              // ---------------- STEP INDICATOR ----------------
              Row(
                children: [
                  Text(
                    "Step ${widget.currentStep}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFFF6A45),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    " / ${widget.steps.length}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Stack(
                children: [
                  Container(height: 4, color: Colors.grey.shade300),
                  Container(
                    height: 4,
                    width: MediaQuery.of(context).size.width *
                        (widget.currentStep / widget.steps.length),
                    color: const Color(0xFFFF6A45),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade300, thickness: 1.2),
              const SizedBox(height: 18),

              // ---------------- INSTRUCTION ----------------
              const Text(
                "Instruction",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Color(0xFFFFB99A), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instruction,

                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.55,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // TIMER WIDGET
                    GestureDetector(
                      onTap: _isTimerRunning ? _stopTimer : (_isTimerSet ? _startTimer : _showTimerBottomSheet),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: _isTimerRunning 
                              ? Colors.white 
                              : (_isTimerSet && _secondsRemaining >= _totalSeconds && _totalSeconds > 0)
                                  ? const Color(0xFFE8F5E9) // Light green background when completed
                                  : const Color(0xFFFFF1EC),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: _isTimerRunning 
                                ? const Color(0xFFFF6A45)
                                : (_isTimerSet && _secondsRemaining >= _totalSeconds && _totalSeconds > 0)
                                    ? const Color(0xFF81C784) // Green border when completed
                                    : const Color(0xFFFFC1A6),
                            width: _isTimerRunning ? 2.5 : 2,
                          ),
                          boxShadow: _isTimerRunning && _secondsRemaining <= 10
                              ? [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  )
                                ]
                              : (_isTimerSet && _secondsRemaining >= _totalSeconds && _totalSeconds > 0)
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isTimerRunning 
                                  ? Icons.timer_outlined
                                  : (_isTimerSet && _secondsRemaining >= _totalSeconds && _totalSeconds > 0)
                                      ? Icons.check_circle_outline
                                      : Icons.timer_outlined,
                              color: _isTimerRunning 
                                  ? const Color(0xFFFF6A45) 
                                  : (_isTimerSet && _secondsRemaining >= _totalSeconds && _totalSeconds > 0)
                                      ? const Color(0xFF4CAF50) // Green for completed
                                      : const Color(0xFF555555),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isTimerRunning 
                                  ? _formatTime(_secondsRemaining)
                                  : _isTimerSet 
                                      ? (_secondsRemaining >= _totalSeconds && _totalSeconds > 0)
                                          ? 'Completed' // Show Completed when done
                                          : '00:00' // Show 00:00 when set but not running
                                      : 'Add Timer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _isTimerRunning 
                                    ? const Color(0xFFFF6A45)
                                    : (_isTimerSet && _secondsRemaining >= _totalSeconds && _totalSeconds > 0)
                                        ? const Color(0xFF4CAF50) // Green for completed
                                        : const Color(0xFF555555),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ---------------- INGREDIENTS ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Ingredients",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => StepIngredientsBottomSheet(
                          ingredients: stepIngredients,
                        ),
                      );
                    },
                    child: const Text(
                      "View all",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6A45),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                "This Step’s Ingredients",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: List.generate(
                  stepIngredients.length,
                  (i) => Container(
                    width: MediaQuery.of(context).size.width * 0.43,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFFDCCD),
                        width: 1.6,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stepIngredients[i]["icon"],
                            style: const TextStyle(fontSize: 30)),
                        const SizedBox(height: 8),
                        Text(
                          stepIngredients[i]["name"],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stepIngredients[i]["qty"],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // ---------------- TIPS ----------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tips & Doubts",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...tips.map(
                      (t) {
                        // Split the tip into question and answer parts
                        final parts = t.split('?');
                        final question = parts.length > 0 ? '${parts[0].trim()}?' : '';
                        final answer = parts.length > 1 ? parts.sublist(1).join('?').trim() : '';
                        
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.2,
                                ),
                              ),
                              if (answer.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  answer,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ---------------- BUTTONS ----------------
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFFF6A45),
                          width: 2,
                        ),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Back",
                          style: TextStyle(
                            color: Color(0xFFFF6A45),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6A45),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextButton(
                        onPressed: () {
                          if (widget.currentStep < widget.steps.length) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CookingStepsScreen(
                                  steps: widget.steps,
                                  currentStep: widget.currentStep + 1,
                                ),
                              ),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CompletionScreen(),
                              ),
                            );
                          }
                        },
                        child: Text(
                          widget.currentStep < widget.steps.length ? "Next" : "Done",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}