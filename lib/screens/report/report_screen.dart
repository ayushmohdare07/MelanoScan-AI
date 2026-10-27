import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportScreen extends StatelessWidget {
  final Uint8List imageBytes;
  final XFile imageFile;
  final Map<String, dynamic> result;

  const ReportScreen({
    super.key,
    required this.imageBytes,
    required this.imageFile,
    required this.result,
  });

  int get dopiGrade {
    return int.tryParse(result['dopi_grade']?.toString() ?? '0') ?? 0;
  }

  String get classification {
    return result['classification']?.toString() ?? 'Unknown';
  }

  double get confidence {
    return double.tryParse(result['confidence_percent']?.toString() ?? '0') ??
        0;
  }

  Map<String, dynamic> get probabilities {
    final value = result['probabilities'];

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  Color get gradeColor {
    switch (dopiGrade) {
      case 0:
        return const Color(0xFF16A34A);

      case 1:
        return const Color(0xFFB7791F);

      case 2:
        return const Color(0xFFA65F3E);

      case 3:
        return const Color(0xFF7F1D1D);

      default:
        return const Color(0xFF3154B5);
    }
  }

  String get description {
    switch (dopiGrade) {
      case 0:
        return 'Pink tissue with no clinical pigmentation.';

      case 1:
        return 'Mild light-brown pigmentation.';

      case 2:
        return 'Medium-brown or mixed pink/brown pigmentation.';

      case 3:
        return 'Deep brown or blue/black pigmentation.';

      default:
        return 'AI-generated DOPI assessment.';
    }
  }

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
          'Detailed Report',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 35),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // IMAGE
                  // ==================================================
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 850,
                        maxHeight: 280,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 270,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 18,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(imageBytes, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // REPORT HEADER
                  // ==================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF009688), Color(0xFF3154B5)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.health_and_safety,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MelanoScan AI Report',
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF172033),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Gingival Melanin Pigmentation Assessment',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // RESULT SUMMARY
                  // ==================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          gradeColor.withValues(alpha: 0.12),
                          Colors.white,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: gradeColor.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Assessment Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // RESPONSIVE SUMMARY
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmallScreen = constraints.maxWidth < 600;

                            if (isSmallScreen) {
                              return Column(
                                children: [
                                  _ReportValue(
                                    title: 'DOPI Grade',
                                    value: '$dopiGrade',
                                    color: gradeColor,
                                    compact: true,
                                  ),

                                  const SizedBox(height: 10),

                                  _ReportValue(
                                    title: 'Classification',
                                    value: classification,
                                    color: gradeColor,
                                    compact: true,
                                  ),

                                  const SizedBox(height: 10),

                                  _ReportValue(
                                    title: 'AI Confidence',
                                    value: '${confidence.toStringAsFixed(2)}%',
                                    color: const Color(0xFF16A34A),
                                    compact: true,
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child: _ReportValue(
                                    title: 'DOPI Grade',
                                    value: '$dopiGrade',
                                    color: gradeColor,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: _ReportValue(
                                    title: 'Classification',
                                    value: classification,
                                    color: gradeColor,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: _ReportValue(
                                    title: 'AI Confidence',
                                    value: '${confidence.toStringAsFixed(2)}%',
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // INTERPRETATION
                  // ==================================================
                  _SectionCard(
                    icon: Icons.analytics_outlined,
                    title: 'Clinical Interpretation',
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // PROBABILITIES
                  // ==================================================
                  _SectionCard(
                    icon: Icons.bar_chart_rounded,
                    title: 'Prediction Probabilities',
                    child: Column(
                      children: [
                        _ProbabilityRow(
                          label: 'DOPI 0',
                          value: _probability('DOPI_0'),
                        ),
                        _ProbabilityRow(
                          label: 'DOPI 1',
                          value: _probability('DOPI_1'),
                        ),
                        _ProbabilityRow(
                          label: 'DOPI 2',
                          value: _probability('DOPI_2'),
                        ),
                        _ProbabilityRow(
                          label: 'DOPI 3',
                          value: _probability('DOPI_3'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // DOPI REFERENCE
                  // ==================================================
                  _SectionCard(
                    icon: Icons.menu_book_outlined,
                    title: 'DOPI Reference',
                    child: Column(
                      children: [
                        _ReferenceRow(
                          grade: '0',
                          title: 'No Pigmentation',
                          description:
                              'Pink tissue with no clinical pigmentation.',
                          color: const Color(0xFF16A34A),
                        ),
                        _ReferenceRow(
                          grade: '1',
                          title: 'Mild',
                          description: 'Mild light-brown pigmentation.',
                          color: const Color(0xFFB7791F),
                        ),
                        _ReferenceRow(
                          grade: '2',
                          title: 'Moderate',
                          description:
                              'Medium-brown or mixed pink/brown pigmentation.',
                          color: const Color(0xFFA65F3E),
                        ),
                        _ReferenceRow(
                          grade: '3',
                          title: 'Severe',
                          description: 'Deep brown or blue/black pigmentation.',
                          color: const Color(0xFF7F1D1D),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // DISCLAIMER
                  // ==================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFD97706),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This AI assessment is intended for research and educational purposes only and should not replace professional clinical evaluation.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // DOWNLOAD BUTTON
                  // ==================================================
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadReport(context),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Download PDF Report'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        backgroundColor: const Color(0xFF009688),
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
            ),
          ),
        ),
      ),
    );
  }

  double _probability(String key) {
    final value = probabilities[key];

    if (value == null) {
      return 0;
    }

    final parsed = double.tryParse(value.toString()) ?? 0;

    if (parsed <= 1) {
      return parsed;
    }

    return parsed / 100;
  }

  // ================================================================
  // PDF DOWNLOAD / PRINT
  // ================================================================

  Future<void> _downloadReport(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 14),
              Text('Generating PDF report...'),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );

      final pdfBytes = await _generatePdf();

      await Printing.layoutPdf(
        name: 'MelanoScan_AI_Report.pdf',
        onLayout: (PdfPageFormat format) async {
          return pdfBytes;
        },
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to generate the PDF report: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ================================================================
  // PDF GENERATOR
  // ================================================================

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();

    final imageProvider = pw.MemoryImage(imageBytes);

    final pdfGradeColor = _pdfColor(gradeColor);

    final probability0 = _probability('DOPI_0') * 100;

    final probability1 = _probability('DOPI_1') * 100;

    final probability2 = _probability('DOPI_2') * 100;

    final probability3 = _probability('DOPI_3') * 100;

    final now = DateTime.now();

    final dateText =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';

    final timeText =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 32, 32, 36),
        build: (pw.Context pdfContext) {
          return [
            // ======================================================
            // HEADER
            // ======================================================
            pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F4F8FC'),
                borderRadius: pw.BorderRadius.circular(14),
                border: pw.Border.all(color: PdfColor.fromHex('#DCE5F0')),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 48,
                    height: 48,
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#009688'),
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'M',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 14),

                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'MelanoScan AI',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#172033'),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Gingival Melanin Pigmentation Assessment',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColor.fromHex('#64748B'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'AI ASSESSMENT REPORT',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#3154B5'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        dateText,
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColor.fromHex('#64748B'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 22),

            // ======================================================
            // IMAGE
            // ======================================================
            pw.Container(
              width: double.infinity,
              height: 220,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: PdfColor.fromHex('#DCE5F0')),
              ),
              child: pw.ClipRRect(
                horizontalRadius: 8,
                verticalRadius: 8,
                child: pw.Image(imageProvider, fit: pw.BoxFit.contain),
              ),
            ),

            pw.SizedBox(height: 22),

            // ======================================================
            // ASSESSMENT SUMMARY
            // ======================================================
            pw.Text(
              'Assessment Summary',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#172033'),
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: pdfGradeColor.shade(0.92),
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: pdfGradeColor.shade(0.70)),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: _pdfMetric(
                      'DOPI Grade',
                      '$dopiGrade',
                      pdfGradeColor,
                    ),
                  ),

                  pw.SizedBox(width: 10),

                  pw.Expanded(
                    child: _pdfMetric(
                      'Classification',
                      classification,
                      pdfGradeColor,
                    ),
                  ),

                  pw.SizedBox(width: 10),

                  pw.Expanded(
                    child: _pdfMetric(
                      'AI Confidence',
                      '${confidence.toStringAsFixed(2)}%',
                      PdfColor.fromHex('#16A34A'),
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // ======================================================
            // CLINICAL INTERPRETATION
            // ======================================================
            _pdfSectionTitle('Clinical Interpretation'),

            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F8FAFC'),
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
              ),
              child: pw.Text(
                description,
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromHex('#475569'),
                  lineSpacing: 4,
                ),
              ),
            ),

            pw.SizedBox(height: 20),

            // ======================================================
            // PROBABILITIES
            // ======================================================
            _pdfSectionTitle('Prediction Probabilities'),

            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
              ),
              child: pw.Column(
                children: [
                  _pdfProbabilityRow(
                    'DOPI 0',
                    probability0,
                    PdfColor.fromHex('#16A34A'),
                  ),
                  pw.SizedBox(height: 11),
                  _pdfProbabilityRow(
                    'DOPI 1',
                    probability1,
                    PdfColor.fromHex('#B7791F'),
                  ),
                  pw.SizedBox(height: 11),
                  _pdfProbabilityRow(
                    'DOPI 2',
                    probability2,
                    PdfColor.fromHex('#A65F3E'),
                  ),
                  pw.SizedBox(height: 11),
                  _pdfProbabilityRow(
                    'DOPI 3',
                    probability3,
                    PdfColor.fromHex('#7F1D1D'),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // ======================================================
            // DOPI REFERENCE
            // ======================================================
            _pdfSectionTitle('DOPI Reference'),

            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColor.fromHex('#E2E8F0'),
                width: 0.6,
              ),
              columnWidths: const {
                0: pw.FixedColumnWidth(55),
                1: pw.FixedColumnWidth(100),
                2: pw.FlexColumnWidth(),
              },
              children: [
                _pdfReferenceHeader(),

                _pdfReferenceRow(
                  '0',
                  'No Pigmentation',
                  'Pink tissue with no clinical pigmentation.',
                  PdfColor.fromHex('#16A34A'),
                ),

                _pdfReferenceRow(
                  '1',
                  'Mild',
                  'Mild light-brown pigmentation.',
                  PdfColor.fromHex('#B7791F'),
                ),

                _pdfReferenceRow(
                  '2',
                  'Moderate',
                  'Medium-brown or mixed pink/brown pigmentation.',
                  PdfColor.fromHex('#A65F3E'),
                ),

                _pdfReferenceRow(
                  '3',
                  'Severe',
                  'Deep brown or blue/black pigmentation.',
                  PdfColor.fromHex('#7F1D1D'),
                ),
              ],
            ),

            pw.SizedBox(height: 22),

            // ======================================================
            // REPORT DETAILS
            // ======================================================
            _pdfSectionTitle('Report Details'),

            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F8FAFC'),
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
              ),
              child: pw.Column(
                children: [
                  _pdfDetailRow('Generated Date', dateText),

                  pw.SizedBox(height: 7),

                  _pdfDetailRow('Generated Time', timeText),

                  pw.SizedBox(height: 7),

                  _pdfDetailRow('Image File', imageFile.name),

                  pw.SizedBox(height: 7),

                  _pdfDetailRow('Assessment System', 'MelanoScan AI'),
                ],
              ),
            ),

            pw.SizedBox(height: 22),

            // ======================================================
            // DISCLAIMER
            // ======================================================
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FFFBEB'),
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: PdfColor.fromHex('#FDE68A')),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 20,
                    height: 20,
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#D97706'),
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        '!',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 10),

                  pw.Expanded(
                    child: pw.Text(
                      'This AI assessment is intended for research and educational purposes only and should not replace professional clinical evaluation.',
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        color: PdfColor.fromHex('#92400E'),
                        lineSpacing: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 18),

            // ======================================================
            // FOOTER
            // ======================================================
            pw.Divider(color: PdfColor.fromHex('#E2E8F0')),

            pw.SizedBox(height: 7),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'MelanoScan AI',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#3154B5'),
                  ),
                ),

                pw.Text(
                  'Gingival Melanin Pigmentation Assessment',
                  style: pw.TextStyle(
                    fontSize: 7.5,
                    color: PdfColor.fromHex('#94A3B8'),
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ================================================================
  // PDF HELPERS
  // ================================================================

  PdfColor _pdfColor(Color color) {
    return PdfColor(color.r / 255, color.g / 255, color.b / 255, 1);
  }

  pw.Widget _pdfMetric(String title, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 7.5,
              color: PdfColor.fromHex('#64748B'),
            ),
          ),

          pw.SizedBox(height: 5),

          pw.Text(
            value,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 15,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#172033'),
        ),
      ),
    );
  }

  pw.Widget _pdfProbabilityRow(
    String label,
    double percentage,
    PdfColor color,
  ) {
    final normalized = (percentage / 100).clamp(0.0, 1.0);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#334155'),
              ),
            ),

            pw.Text(
              '${percentage.toStringAsFixed(2)}%',
              style: pw.TextStyle(
                fontSize: 8.5,
                color: PdfColor.fromHex('#64748B'),
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 5),

        pw.Container(
          height: 7,
          width: double.infinity,
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#E8ECF8'),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Container(
              width: 450 * normalized,
              height: 7,
              decoration: pw.BoxDecoration(
                color: color,
                borderRadius: pw.BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  pw.TableRow _pdfReferenceHeader() {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F1F5F9')),
      children: [
        _pdfTableCell('Grade', bold: true),
        _pdfTableCell('Level', bold: true),
        _pdfTableCell('Description', bold: true),
      ],
    );
  }

  pw.TableRow _pdfReferenceRow(
    String grade,
    String title,
    String desc,
    PdfColor color,
  ) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            grade,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ),

        _pdfTableCell(title),

        _pdfTableCell(desc),
      ],
    );
  }

  pw.Widget _pdfTableCell(String text, {bool bold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColor.fromHex(bold ? '#334155' : '#64748B'),
        ),
      ),
    );
  }

  pw.Widget _pdfDetailRow(String title, String value) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 105,
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#475569'),
            ),
          ),
        ),

        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColor.fromHex('#64748B'),
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// REPORT VALUE
// ================================================================

class _ReportValue extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final bool compact;

  const _ReportValue({
    required this.title,
    required this.value,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                softWrap: true,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// SECTION CARD
// ================================================================

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF3154B5), size: 22),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}

// ================================================================
// PROBABILITY
// ================================================================

class _ProbabilityRow extends StatelessWidget {
  final String label;
  final double value;

  const _ProbabilityRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final percentage = value * 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),

              Text(
                '${percentage.toStringAsFixed(2)}%',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),

          const SizedBox(height: 7),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFE8ECF8),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF5369A8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// DOPI REFERENCE
// ================================================================

class _ReferenceRow extends StatelessWidget {
  final String grade;
  final String title;
  final String description;
  final Color color;

  const _ReferenceRow({
    required this.grade,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(
                grade,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
