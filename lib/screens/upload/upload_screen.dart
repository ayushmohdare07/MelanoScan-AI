import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

import '../preview/preview_screen.dart';

class UploadScreen extends StatefulWidget {
  final ImageSource? initialSource;

  const UploadScreen({super.key, this.initialSource});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();

  Uint8List? selectedImage;
  XFile? selectedFile;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialSource != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        pickImage(widget.initialSource!);
      });
    }
  }

  // ===============================================================
  // PICK IMAGE
  // ===============================================================

  Future<void> pickImage(ImageSource source) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (image == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final Uint8List bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImage = bytes;
        selectedFile = image;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to access the image. Please try again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF263238),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // ===============================================================
  // REMOVE IMAGE
  // ===============================================================

  void removeImage() {
    setState(() {
      selectedImage = null;
      selectedFile = null;
    });
  }

  // ===============================================================
  // CONTINUE
  // ===============================================================

  void continueToPreview() {
    if (selectedImage == null || selectedFile == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PreviewScreen(imageBytes: selectedImage!, imageFile: selectedFile!),
      ),
    );
  }

  // ===============================================================
  // BUILD
  // ===============================================================

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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Gingival Image',
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
          final bool compact = constraints.maxWidth < 430;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: wide
                  ? 60
                  : compact
                  ? 14
                  : 20,
              vertical: compact ? 18 : 25,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // HEADER
                    // =================================================
                    _buildHeader()
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(
                          begin: 0.05,
                          end: 0,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    const SizedBox(height: 25),

                    // =================================================
                    // IMAGE AREA
                    // =================================================
                    wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 6, child: _buildImageArea()),
                              const SizedBox(width: 25),
                              Expanded(flex: 4, child: _buildGuidanceCard()),
                            ],
                          )
                        : Column(
                            children: [
                              _buildImageArea(),
                              const SizedBox(height: 20),
                              _buildGuidanceCard(),
                            ],
                          ),

                    const SizedBox(height: 25),

                    // =================================================
                    // ACTION BUTTONS
                    // =================================================
                    if (selectedImage == null)
                      _buildSelectionButtons(wide: wide)
                    else
                      _buildSelectedActions(wide: wide),

                    const SizedBox(height: 25),

                    // =================================================
                    // CONTINUE BUTTON
                    // =================================================
                    _buildContinueButton(),

                    const SizedBox(height: 25),

                    // =================================================
                    // INFORMATION
                    // =================================================
                    _buildInfoCard(),

                    const SizedBox(height: 25),

                    const Center(
                      child: Text(
                        'MelanoScan AI • AI-Assisted Assessment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A95A7),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
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
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Provide a Gingival Image',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF172033),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Capture a new image or select an existing dental image '
          'for AI-assisted pigmentation assessment.',
          style: TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF68758A)),
        ),
      ],
    );
  }

  // ===============================================================
  // IMAGE AREA
  // ===============================================================

  Widget _buildImageArea() {
    return Container(
      width: double.infinity,
      height: 420,
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
      child: selectedImage == null
          ? _buildEmptyImageArea()
          : _buildImagePreview(),
    ).animate().fadeIn(duration: 600.ms);
  }

  // ===============================================================
  // EMPTY IMAGE AREA
  // ===============================================================

  Widget _buildEmptyImageArea() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5F3), Color(0xFFEDE7F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                size: 42,
                color: Color(0xFF3949AB),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'No Image Selected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Take a photo or upload a gingival image',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF748095)),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: Color(0xFF68758A),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Image stays on this device',
                    style: TextStyle(fontSize: 11, color: Color(0xFF68758A)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // IMAGE PREVIEW
  // ===============================================================

  Widget _buildImagePreview() {
    return ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(selectedImage!, fit: BoxFit.contain),

              // TOP LABEL
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.58),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF80CBC4),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Image Selected',
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

              // REMOVE BUTTON
              Positioned(
                top: 15,
                right: 15,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: removeImage,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 450.ms)
        .scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1, 1),
          duration: 450.ms,
          curve: Curves.easeOutCubic,
        );
  }

  // ===============================================================
  // GUIDANCE CARD
  // ===============================================================

  Widget _buildGuidanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5F3), Color(0xFFEDE7F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE4ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.tips_and_updates_outlined,
                  color: Color(0xFFE67E22),
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'Image Guidelines',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _guideline(
            Icons.check_circle_outline,
            'Keep the gingiva clearly visible',
          ),

          _guideline(Icons.light_mode_outlined, 'Use adequate lighting'),

          _guideline(
            Icons.center_focus_strong_outlined,
            'Keep the image focused',
          ),

          _guideline(Icons.crop_free_rounded, 'Include the gingival region'),

          _guideline(
            Icons.remove_circle_outline,
            'Avoid excessive blur or obstruction',
          ),
        ],
      ),
    );
  }

  Widget _guideline(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF00897B)),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Color(0xFF68758A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SELECTION BUTTONS
  // ===============================================================

  Widget _buildSelectionButtons({required bool wide}) {
    final buttons = [
      _largeActionButton(
        icon: Icons.camera_alt_rounded,
        title: 'Take Photo',
        subtitle: 'Open camera',
        gradient: const [Color(0xFF00897B), Color(0xFF26A69A)],
        onTap: () {
          pickImage(ImageSource.camera);
        },
      ),
      _largeActionButton(
        icon: Icons.photo_library_rounded,
        title: 'Upload Photo',
        subtitle: 'Choose from device',
        gradient: const [Color(0xFF5E35B1), Color(0xFF7E57C2)],
        onTap: () {
          pickImage(ImageSource.gallery);
        },
      ),
    ];

    return (wide
            ? Row(
                children: [
                  Expanded(child: buttons[0]),
                  const SizedBox(width: 15),
                  Expanded(child: buttons[1]),
                ],
              )
            : Column(
                children: [buttons[0], const SizedBox(height: 14), buttons[1]],
              ))
        .animate()
        .fadeIn(duration: 550.ms)
        .slideY(begin: 0.05, end: 0, duration: 550.ms);
  }

  // ===============================================================
  // SELECTED ACTIONS
  // ===============================================================

  Widget _buildSelectedActions({required bool wide}) {
    final retakeButton = OutlinedButton.icon(
      onPressed: isLoading
          ? null
          : () {
              pickImage(ImageSource.camera);
            },
      icon: const Icon(Icons.camera_alt_outlined),
      label: const Text('Retake'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF00897B),
        side: const BorderSide(color: Color(0xFF00897B)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );

    final chooseButton = OutlinedButton.icon(
      onPressed: isLoading
          ? null
          : () {
              pickImage(ImageSource.gallery);
            },
      icon: const Icon(Icons.photo_library_outlined),
      label: const Text('Choose Another'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF5E35B1),
        side: const BorderSide(color: Color(0xFF5E35B1)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );

    return wide
        ? Row(
            children: [
              Expanded(child: retakeButton),
              const SizedBox(width: 15),
              Expanded(child: chooseButton),
            ],
          )
        : Column(
            children: [
              SizedBox(width: double.infinity, child: retakeButton),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: chooseButton),
            ],
          );
  }

  // ===============================================================
  // LARGE ACTION BUTTON
  // ===============================================================

  Widget _largeActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(icon, color: Colors.white, size: 26),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // CONTINUE BUTTON
  // ===============================================================

  Widget _buildContinueButton() {
    final bool enabled = selectedImage != null && selectedFile != null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: enabled ? continueToPreview : null,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: const Text(
          'Continue to Preview',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3949AB),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE1E5EC),
          disabledForegroundColor: const Color(0xFF9AA4B2),
          elevation: enabled ? 3 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // INFORMATION CARD
  // ===============================================================

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E5ED)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF3949AB),
            size: 21,
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'For best results, provide a clear image where '
              'the gingival tissue is visible. The image will '
              'be processed by MelanoScan AI for '
              'AI-assisted pigmentation assessment.',
              style: TextStyle(
                fontSize: 12,
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
