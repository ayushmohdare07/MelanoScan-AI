import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/api_service.dart';
import '../result/result_screen.dart';

class AnalysisScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final XFile imageFile;

  const AnalysisScreen({
    super.key,
    required this.imageBytes,
    required this.imageFile,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  double progress = 0.0;

  int currentStep = 0;

  bool isAnalyzing = false;
  bool analysisFailed = false;

  String errorMessage = '';

  late AnimationController _pulseController;

  final List<String> stepTitles = [
    'Image Received',
    'Preparing Gingival Region',
    'AI Classification',
    'Generating Assessment',
  ];

  final List<String> stepDescriptions = [
    'Validating the selected dental image.',
    'Preparing the image for AI analysis.',
    'Running the DOPI classification model.',
    'Preparing the final assessment report.',
  ];

  final List<IconData> stepIcons = [
    Icons.image_rounded,
    Icons.crop_free_rounded,
    Icons.psychology_rounded,
    Icons.description_rounded,
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startAnalysis();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ============================================================
  // START REAL AI ANALYSIS
  // ============================================================

  Future<void> startAnalysis() async {
    if (isAnalyzing) return;

    setState(() {
      isAnalyzing = true;
      analysisFailed = false;
      errorMessage = '';
      progress = 0.05;
      currentStep = 0;
    });

    try {
      // ----------------------------------------------------------
      // STEP 1
      // ----------------------------------------------------------

      await _updateStep(step: 0, progressValue: 0.18);

      // Small delay so the UI transition feels natural.
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // ----------------------------------------------------------
      // STEP 2
      // ----------------------------------------------------------

      await _updateStep(step: 1, progressValue: 0.40);

      await Future.delayed(const Duration(milliseconds: 450));

      if (!mounted) return;

      // ----------------------------------------------------------
      // STEP 3
      // REAL BACKEND REQUEST
      // ----------------------------------------------------------

      await _updateStep(step: 2, progressValue: 0.62);

      final Map<String, dynamic> result = await ApiService.analyzeImage(
        widget.imageFile,
      );

      if (!mounted) return;

      // ----------------------------------------------------------
      // STEP 4
      // ----------------------------------------------------------

      await _updateStep(step: 3, progressValue: 0.90);

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      setState(() {
        progress = 1.0;
      });

      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      // ----------------------------------------------------------
      // OPEN REAL RESULT SCREEN
      // ----------------------------------------------------------

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            imageBytes: widget.imageBytes,
            imageFile: widget.imageFile,
            result: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isAnalyzing = false;
        analysisFailed = true;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ============================================================
  // UPDATE STEP
  // ============================================================

  Future<void> _updateStep({
    required int step,
    required double progressValue,
  }) async {
    if (!mounted) return;

    setState(() {
      currentStep = step;
      progress = progressValue;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF172033)),
          onPressed: isAnalyzing
              ? null
              : () {
                  Navigator.pop(context);
                },
        ),

        title: const Text(
          'AI Analysis',
          style: TextStyle(
            color: Color(0xFF172033),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        centerTitle: true,
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool wide = constraints.maxWidth >= 850;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: EdgeInsets.symmetric(
              horizontal: wide ? 60 : 20,
              vertical: 25,
            ),

            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1050),

                child: Column(
                  children: [
                    _buildImageCard(),

                    const SizedBox(height: 28),

                    if (analysisFailed)
                      _buildErrorCard()
                    else
                      _buildAnalysisCard(),

                    const SizedBox(height: 25),

                    if (!analysisFailed) _buildProcessingSteps(),

                    const SizedBox(height: 25),

                    if (!analysisFailed) _buildDisclaimer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // IMAGE CARD
  // ============================================================

  Widget _buildImageCard() {
    return Container(
          width: double.infinity,
          height: 300,

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(25),

            border: Border.all(color: const Color(0xFFE0E5ED)),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),

            child: Stack(
              fit: StackFit.expand,

              children: [
                Image.memory(widget.imageBytes, fit: BoxFit.contain),

                Positioned(
                  top: 15,
                  left: 15,

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.58),

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'AI Image Analysis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }

  // ============================================================
  // MAIN ANALYSIS CARD
  // ============================================================

  Widget _buildAnalysisCard() {
    final int percentage = (progress * 100).round().clamp(0, 100);

    return Container(
          width: double.infinity,

          padding: const EdgeInsets.all(28),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(25),

            border: Border.all(color: const Color(0xFFE0E5ED)),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Column(
            children: [
              // ------------------------------------------------------
              // ANIMATED ICON
              // ------------------------------------------------------
              AnimatedBuilder(
                animation: _pulseController,

                builder: (context, child) {
                  final double scale = 1 + (_pulseController.value * 0.06);

                  return Transform.scale(scale: scale, child: child);
                },

                child: Container(
                  width: 76,
                  height: 76,

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00897B), Color(0xFF3949AB)],

                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

                    shape: BoxShape.circle,

                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3949AB).withValues(alpha: 0.20),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Analyzing Gingival Image',
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172033),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                stepDescriptions[currentStep],
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF718096),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------------
              // PROGRESS
              // ------------------------------------------------------
              ClipRRect(
                borderRadius: BorderRadius.circular(20),

                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),

                  duration: const Duration(milliseconds: 700),

                  curve: Curves.easeOutCubic,

                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 9,

                      backgroundColor: const Color(0xFFE5E9F5),

                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF3949AB),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    'Processing',
                    style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
                  ),

                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3949AB),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 550.ms)
        .slideY(
          begin: 0.04,
          end: 0,
          duration: 550.ms,
          curve: Curves.easeOutCubic,
        );
  }

  // ============================================================
  // PROCESSING STEPS
  // ============================================================

  Widget _buildProcessingSteps() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: const Color(0xFFE0E5ED)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Analysis Workflow',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 18),

          ...List.generate(stepTitles.length, (index) {
            final bool completed = index < currentStep;

            final bool active = index == currentStep;

            final bool pending = index > currentStep;

            return _buildStep(
              index: index,
              title: stepTitles[index],
              completed: completed,
              active: active,
              pending: pending,
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 500.ms);
  }

  Widget _buildStep({
    required int index,
    required String title,
    required bool completed,
    required bool active,
    required bool pending,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),

                width: 42,
                height: 42,

                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFFE8F5F3)
                      : active
                      ? const Color(0xFFE8EAF6)
                      : const Color(0xFFF1F3F7),

                  shape: BoxShape.circle,

                  border: Border.all(
                    color: completed
                        ? const Color(0xFF00897B)
                        : active
                        ? const Color(0xFF3949AB)
                        : const Color(0xFFDCE1E9),
                  ),
                ),

                child: Icon(
                  completed ? Icons.check_rounded : stepIcons[index],

                  size: 20,

                  color: completed
                      ? const Color(0xFF00897B)
                      : active
                      ? const Color(0xFF3949AB)
                      : const Color(0xFF9AA4B2),
                ),
              ),

              if (index < stepTitles.length - 1)
                Container(
                  width: 2,
                  height: 25,
                  color: completed
                      ? const Color(0xFFB2DFDB)
                      : const Color(0xFFE3E7EE),
                ),
            ],
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: active || completed
                          ? FontWeight.bold
                          : FontWeight.w500,

                      color: active
                          ? const Color(0xFF3949AB)
                          : completed
                          ? const Color(0xFF00897B)
                          : const Color(0xFF7D8797),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    completed
                        ? 'Completed'
                        : active
                        ? 'In progress...'
                        : 'Waiting',

                    style: TextStyle(
                      fontSize: 11,
                      color: active
                          ? const Color(0xFF68758A)
                          : const Color(0xFF9AA4B2),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (active)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFF3949AB)),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR CARD
  // ============================================================

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(28),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(25),

        border: Border.all(color: const Color(0xFFFFCDD2)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,

            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFE53935),
              size: 34,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Analysis Failed',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263238),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            errorMessage.isEmpty
                ? 'Unable to complete the AI analysis.'
                : errorMessage,

            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF718096),
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 52,

            child: ElevatedButton.icon(
              onPressed: () {
                startAnalysis();
              },

              icon: const Icon(Icons.refresh_rounded),

              label: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3949AB),

                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).shake(hz: 2, duration: 450.ms);
  }

  // ============================================================
  // DISCLAIMER
  // ============================================================

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F8),

        borderRadius: BorderRadius.circular(15),
      ),

      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF68758A)),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'This AI assessment is a research and educational '
              'prototype and should not replace professional '
              'clinical evaluation.',
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: Color(0xFF68758A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
