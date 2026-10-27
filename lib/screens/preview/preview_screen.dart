import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../analysis/analysis_screen.dart';

class PreviewScreen extends StatelessWidget {
  final Uint8List imageBytes;
  final XFile imageFile;

  const PreviewScreen({
    super.key,
    required this.imageBytes,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F8FC),
        foregroundColor: const Color(0xFF1E293B),
        centerTitle: true,
        title: const Text(
          'Image Preview',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --------------------------------------------------
                  // HEADER
                  // --------------------------------------------------
                  const Text(
                    'Review Your Image',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172033),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Review your gingival image before starting AI analysis.',
                    style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                  ),

                  const SizedBox(height: 24),

                  // --------------------------------------------------
                  // IMAGE CARD
                  // --------------------------------------------------
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 900,
                        maxHeight: 360,
                      ),

                      child: Container(
                        width: double.infinity,
                        height: 340,
                        padding: const EdgeInsets.all(8),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),

                          border: Border.all(color: const Color(0xFFE2E8F0)),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),

                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(17),

                          child: Image.memory(
                            imageBytes,
                            fit: BoxFit.contain,

                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      size: 55,
                                      color: Color(0xFF94A3B8),
                                    ),

                                    SizedBox(height: 10),

                                    Text(
                                      'Unable to display image',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // --------------------------------------------------
                  // IMAGE STATUS
                  // --------------------------------------------------
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),

                      borderRadius: BorderRadius.circular(16),

                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),

                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF009688),
                          size: 22,
                        ),

                        SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            'Image selected successfully. Make sure the gingival region is clearly visible.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF3F6F68),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // --------------------------------------------------
                  // BEFORE ANALYSIS CARD
                  // --------------------------------------------------
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF0FDFA), Color(0xFFF5F3FF)],
                      ),

                      borderRadius: BorderRadius.circular(22),

                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13),
                              ),

                              child: const Icon(
                                Icons.lightbulb_outline,
                                color: Color(0xFF7C3AED),
                              ),
                            ),

                            const SizedBox(width: 12),

                            const Text(
                              'Before Analysis',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        _Tip(
                          icon: Icons.visibility_outlined,
                          text: 'Gingiva should be clearly visible',
                        ),

                        _Tip(
                          icon: Icons.wb_sunny_outlined,
                          text: 'Use adequate lighting',
                        ),

                        _Tip(
                          icon: Icons.center_focus_strong,
                          text: 'Avoid excessive blur',
                        ),

                        _Tip(
                          icon: Icons.crop_free,
                          text: 'Include the gingival region',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --------------------------------------------------
                  // ACTION BUTTONS
                  // --------------------------------------------------
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },

                          icon: const Icon(Icons.refresh),

                          label: const Text('Change Image'),

                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 54),

                            foregroundColor: const Color(0xFF3154B5),

                            side: const BorderSide(color: Color(0xFF8BA4FF)),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) => AnalysisScreen(
                                  imageBytes: imageBytes,
                                  imageFile: imageFile,
                                ),
                              ),
                            );
                          },

                          icon: const Icon(Icons.auto_awesome),

                          label: const Text('Start AI Analysis'),

                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 54),

                            backgroundColor: const Color(0xFF3154B5),

                            foregroundColor: Colors.white,

                            elevation: 3,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // --------------------------------------------------
                  // INFORMATION
                  // --------------------------------------------------
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(15),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(16),

                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),

                    child: const Row(
                      children: [
                        Icon(
                          Icons.science_outlined,
                          color: Color(0xFF7C3AED),
                          size: 21,
                        ),

                        SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            'MelanoScan AI analyzes the image using an AI model for DOPI-based pigmentation assessment.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// TIP WIDGET
// ================================================================

class _Tip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Tip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),

      child: Row(
        children: [
          Icon(icon, size: 19, color: const Color(0xFF009688)),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }
}
