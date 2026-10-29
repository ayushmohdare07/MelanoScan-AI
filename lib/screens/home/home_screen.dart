import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

import '../upload/upload_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openAssessment(BuildContext context, ImageSource source) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UploadScreen(initialSource: source)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,

        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00897B), Color(0xFF3949AB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.health_and_safety_outlined,
                color: Colors.white,
                size: 25,
              ),
            ),

            const SizedBox(width: 12),

            const Text(
              'MelanoScan AI',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),
          ],
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool wide = constraints.maxWidth >= 850;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: EdgeInsets.symmetric(
              horizontal: wide ? 55 : 20,
              vertical: 25,
            ),

            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // =================================================
                    // HERO
                    // =================================================
                    _buildHero(context, wide),

                    const SizedBox(height: 38),

                    // =================================================
                    // ASSESSMENT ACTIONS
                    // =================================================
                    const Text(
                      'Start an Assessment',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172033),
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Choose how you want to provide the gingival image.',
                      style: TextStyle(fontSize: 15, color: Color(0xFF68758A)),
                    ),

                    const SizedBox(height: 20),

                    if (wide)
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              context,
                              icon: Icons.camera_alt_rounded,
                              title: 'Take a Photo',
                              subtitle: 'Capture a new gingival image',
                              tag: 'CAMERA',
                              gradient: const [
                                Color(0xFF00897B),
                                Color(0xFF26A69A),
                              ],
                              onTap: () {
                                _openAssessment(context, ImageSource.camera);
                              },
                            ),
                          ),

                          const SizedBox(width: 18),

                          Expanded(
                            child: _buildActionCard(
                              context,
                              icon: Icons.photo_library_rounded,
                              title: 'Upload Photo',
                              subtitle: 'Choose an existing image',
                              tag: 'GALLERY',
                              gradient: const [
                                Color(0xFF5E35B1),
                                Color(0xFF7E57C2),
                              ],
                              onTap: () {
                                _openAssessment(context, ImageSource.gallery);
                              },
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildActionCard(
                            context,
                            icon: Icons.camera_alt_rounded,
                            title: 'Take a Photo',
                            subtitle: 'Capture a new gingival image',
                            tag: 'CAMERA',
                            gradient: const [
                              Color(0xFF00897B),
                              Color(0xFF26A69A),
                            ],
                            onTap: () {
                              _openAssessment(context, ImageSource.camera);
                            },
                          ),

                          const SizedBox(height: 15),

                          _buildActionCard(
                            context,
                            icon: Icons.photo_library_rounded,
                            title: 'Upload Photo',
                            subtitle: 'Choose an existing image',
                            tag: 'GALLERY',
                            gradient: const [
                              Color(0xFF5E35B1),
                              Color(0xFF7E57C2),
                            ],
                            onTap: () {
                              _openAssessment(context, ImageSource.gallery);
                            },
                          ),
                        ],
                      ),

                    const SizedBox(height: 42),

                    // =================================================
                    // AI WORKFLOW
                    // =================================================
                    _sectionHeader(
                      'AI Assessment Workflow',
                      'From dental image to DOPI classification.',
                    ),

                    const SizedBox(height: 20),

                    _buildWorkflow(wide),

                    const SizedBox(height: 42),

                    // =================================================
                    // DOPI
                    // =================================================
                    _sectionHeader(
                      'DOPI Classification',
                      'Four grades used to describe gingival pigmentation.',
                    ),

                    const SizedBox(height: 20),

                    _buildDopiSection(wide),

                    const SizedBox(height: 42),

                    // =================================================
                    // WHY MELANOSCAN
                    // =================================================
                    _sectionHeader(
                      'Why MelanoScan AI?',
                      'An AI-assisted approach to digital gingival assessment.',
                    ),

                    const SizedBox(height: 20),

                    _buildWhySection(wide),

                    const SizedBox(height: 35),

                    // =================================================
                    // ABOUT
                    // =================================================
                    _buildAboutCard(),

                    const SizedBox(height: 22),

                    // =================================================
                    // DISCLAIMER
                    // =================================================
                    _buildDisclaimer(),

                    const SizedBox(height: 25),

                    const Center(
                      child: Text(
                        'MelanoScan AI  •  Gingival Melanin Pigmentation Assessment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A95A7),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ===============================================================
  // HERO SECTION
  // ===============================================================

  Widget _buildHero(BuildContext context, bool wide) {
    return Container(
          width: double.infinity,

          padding: EdgeInsets.all(wide ? 42 : 26),

          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00695C), Color(0xFF00897B), Color(0xFF3949AB)],

              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

            borderRadius: BorderRadius.circular(30),

            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00695C).withValues(alpha: 0.20),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),

          child: wide
              ? Row(
                  children: [
                    Expanded(child: _buildHeroText()),

                    const SizedBox(width: 35),

                    _buildAIVisual(205),
                  ],
                )
              : Column(
                  children: [
                    _buildAIVisual(135),

                    const SizedBox(height: 25),

                    _buildHeroText(centered: true),
                  ],
                ),
        )
        .animate()
        .fadeIn(duration: 650.ms)
        .slideY(
          begin: 0.08,
          end: 0,
          duration: 650.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildHeroText({bool centered = false}) {
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,

      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),

          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(30),
          ),

          child: const Text(
            'AI-POWERED DENTAL ASSESSMENT',

            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),

        const SizedBox(height: 18),

        Text(
          'Gingival Melanin\nPigmentation Assessment',

          textAlign: centered ? TextAlign.center : TextAlign.left,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            height: 1.12,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        Text(
          'Analyze gingival pigmentation from dental images '
          'using AI-assisted DOPI classification.',

          textAlign: centered ? TextAlign.center : TextAlign.left,

          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 22),

        Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            _heroBadge(Icons.image_outlined, 'Image AI'),

            const SizedBox(width: 9),

            _heroBadge(Icons.analytics_outlined, 'DOPI 0–3'),
          ],
        ),
      ],
    );
  }

  Widget _heroBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, color: Colors.white, size: 15),

          const SizedBox(width: 6),

          Text(
            text,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // AI VISUAL
  // ===============================================================

  Widget _buildAIVisual(double size) {
    return SizedBox(
          width: size,
          height: size,

          child: Stack(
            alignment: Alignment.center,

            children: [
              Container(
                width: size,
                height: size,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: Colors.white.withValues(alpha: 0.06),

                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.13),
                  ),
                ),
              ),

              Container(
                width: size * 0.75,
                height: size * 0.75,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: Colors.white.withValues(alpha: 0.08),

                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
              ),

              Container(
                width: size * 0.50,
                height: size * 0.50,

                decoration: const BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: LinearGradient(
                    colors: [Color(0xFF80CBC4), Color(0xFF5C6BC0)],

                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),

                child: const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),

              Positioned(
                top: size * 0.12,
                right: size * 0.08,

                child: _floatingDot(Icons.image_outlined),
              ),

              Positioned(
                bottom: size * 0.13,
                left: size * 0.08,

                child: _floatingDot(Icons.analytics_outlined),
              ),
            ],
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1.03, 1.03),
          duration: 2200.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _floatingDot(IconData icon) {
    return Container(
      width: 42,
      height: 42,

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),

        borderRadius: BorderRadius.circular(13),

        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),

      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  // ===============================================================
  // ACTION CARD
  // ===============================================================

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String tag,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
          color: Colors.transparent,

          child: InkWell(
            onTap: onTap,

            borderRadius: BorderRadius.circular(22),

            child: Ink(
              padding: const EdgeInsets.all(21),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,

                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.circular(22),

                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withValues(alpha: 0.18),

                    blurRadius: 20,

                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),

                      borderRadius: BorderRadius.circular(17),
                    ),

                    child: Icon(icon, color: Colors.white, size: 30),
                  ),

                  const SizedBox(width: 17),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.13),

                                borderRadius: BorderRadius.circular(6),
                              ),

                              child: Text(
                                tag,

                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        Text(
                          subtitle,

                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideX(
          begin: 0.05,
          end: 0,
          duration: 600.ms,
          curve: Curves.easeOutCubic,
        );
  }

  // ===============================================================
  // SECTION HEADER
  // ===============================================================

  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF172033),
          ),
        ),

        const SizedBox(height: 7),

        Text(
          subtitle,

          style: const TextStyle(fontSize: 15, color: Color(0xFF68758A)),
        ),
      ],
    );
  }

  // ===============================================================
  // WORKFLOW
  // ===============================================================

  Widget _buildWorkflow(bool wide) {
    final items = [
      (
        '01',
        Icons.camera_alt_outlined,
        'Capture',
        'Take a clear gingival image.',
        const Color(0xFF00897B),
      ),

      (
        '02',
        Icons.crop_free_rounded,
        'Prepare',
        'Review the selected image.',
        const Color(0xFF3949AB),
      ),

      (
        '03',
        Icons.psychology_outlined,
        'Analyze',
        'AI evaluates pigmentation.',
        const Color(0xFF7E57C2),
      ),

      (
        '04',
        Icons.analytics_outlined,
        'Report',
        'View the DOPI assessment.',
        const Color(0xFFE67E22),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      itemCount: items.length,

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: wide ? 4 : 2,

        crossAxisSpacing: 15,
        mainAxisSpacing: 15,

        childAspectRatio: wide ? 1.25 : 1.0,
      ),

      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),

                border: Border.all(color: const Color(0xFFE0E5ED)),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),

                    blurRadius: 15,

                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Container(
                        width: 44,
                        height: 44,

                        decoration: BoxDecoration(
                          color: item.$5.withValues(alpha: 0.10),

                          borderRadius: BorderRadius.circular(13),
                        ),

                        child: Icon(item.$2, color: item.$5, size: 24),
                      ),

                      Text(
                        item.$1,

                        style: TextStyle(
                          color: item.$5,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Text(
                    item.$3,

                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172033),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    item.$4,

                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF748095),
                    ),
                  ),
                ],
              ),
            )
            .animate(delay: (100 * index).ms)
            .fadeIn(duration: 500.ms)
            .slideY(
              begin: 0.06,
              end: 0,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }

  // ===============================================================
  // DOPI
  // ===============================================================

  Widget _buildDopiSection(bool wide) {
    final items = [
      (
        '0',
        'No Pigmentation',
        'Pink tissue with no clinical pigmentation.',
        const Color(0xFF43A047),
      ),

      ('1', 'Mild', 'Mild light-brown pigmentation.', const Color(0xFF8D6E63)),

      (
        '2',
        'Moderate',
        'Medium-brown or mixed pigmentation.',
        const Color(0xFF6D4C41),
      ),

      (
        '3',
        'Severe',
        'Deep brown or blue/black pigmentation.',
        const Color(0xFF37474F),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      itemCount: items.length,

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: wide ? 4 : 2,

        crossAxisSpacing: 15,
        mainAxisSpacing: 15,

        childAspectRatio: wide ? 1.15 : 1.0,
      ),

      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),

                border: Border.all(color: const Color(0xFFE0E5ED)),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Container(
                        width: 47,
                        height: 47,

                        decoration: BoxDecoration(
                          color: item.$4.withValues(alpha: 0.11),

                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: Center(
                          child: Text(
                            item.$1,

                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: item.$4,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        'DOPI ${item.$1}',

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Text(
                    item.$2,

                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: item.$4,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Expanded(
                    child: Text(
                      item.$3,

                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF748095),
                      ),
                    ),
                  ),
                ],
              ),
            )
            .animate(delay: (100 * index).ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.05, end: 0, duration: 500.ms);
      },
    );
  }

  // ===============================================================
  // WHY MELANOSCAN
  // ===============================================================

  Widget _buildWhySection(bool wide) {
    final items = [
      (
        Icons.image_search_outlined,
        'Image-Based',
        'Analyze gingival images digitally.',
        const Color(0xFF00897B),
      ),

      (
        Icons.psychology_outlined,
        'AI-Assisted',
        'Use deep learning for DOPI prediction.',
        const Color(0xFF5E35B1),
      ),

      (
        Icons.bar_chart_rounded,
        'DOPI-Based',
        'Classify pigmentation into four grades.',
        const Color(0xFFE67E22),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      itemCount: items.length,

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: wide ? 3 : 1,

        crossAxisSpacing: 15,
        mainAxisSpacing: 15,

        childAspectRatio: wide ? 2.15 : 3.0,
      ),

      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),

                border: Border.all(color: const Color(0xFFE0E5ED)),
              ),

              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,

                    decoration: BoxDecoration(
                      color: item.$4.withValues(alpha: 0.10),

                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Icon(item.$1, color: item.$4, size: 27),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          item.$2,

                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          item.$3,

                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: Color(0xFF748095),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
            .animate(delay: (100 * index).ms)
            .fadeIn(duration: 500.ms)
            .slideX(begin: 0.04, end: 0, duration: 500.ms);
      },
    );
  }

  // ===============================================================
  // ABOUT
  // ===============================================================

  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5F3), Color(0xFFEDE7F6)],
        ),

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: const Color(0xFFDDE4ED)),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF3949AB),
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'About MelanoScan AI',

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),

                SizedBox(height: 7),

                Text(
                  'MelanoScan AI is an AI-assisted research '
                  'prototype designed to analyze gingival '
                  'melanin pigmentation from dental images '
                  'and classify the observed pigmentation '
                  'according to DOPI grades.',

                  style: TextStyle(
                    fontSize: 13,
                    height: 1.55,
                    color: Color(0xFF68758A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // DISCLAIMER
  // ===============================================================

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: const Color(0xFFFFCC80)),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFE67E22),
            size: 22,
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'Research and educational prototype. '
              'AI-generated results should not replace '
              'professional clinical evaluation.',

              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF75634A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
