import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Menampilkan foto soal dan jawaban dari Gemini.
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({
    super.key,
    required this.imagePath,
    required this.answer,
    required this.modelUsed,
  });

  final String imagePath;
  final String answer;
  final String modelUsed;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: answer));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Jawaban disalin ke papan klip.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);
    final exists = file.existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan jawaban'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Salin teks',
            onPressed: () => _copy(context),
            icon: const Icon(Icons.copy_outlined),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (exists)
            SizedBox(
              height: 200,
              child: Image.file(
                file,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            )
          else
            const SizedBox(
              height: 80,
              child: Center(child: Text('Pratinjau foto tidak tersedia.')),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Model: $modelUsed',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: SelectionArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Text(
                  answer,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.45,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Foto soal lain'),
          ),
        ),
      ),
    );
  }
}
