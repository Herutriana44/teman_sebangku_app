import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/permission_helper.dart';
import '../services/settings_service.dart';
import 'configure_screen.dart';
import 'permission_screen.dart';
import 'summary_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _initializing = true;
  bool _capturing = false;
  final _gemini = GeminiService();
  final _settings = SettingsService();

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final ok = await PermissionHelper.readyForApp();
    if (!ok) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const PermissionScreen(),
        ),
      );
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _initializing = false);
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final ctrl = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await ctrl.initialize();
      if (!mounted) return;
      setState(() {
        _controller = ctrl;
        _initializing = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _initializing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kamera error: $e')),
        );
      }
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => const ConfigureScreen(),
      ),
    );
  }

  Future<void> _captureAndSolve() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized || _capturing) return;

    final apiKey = await _settings.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Atur kunci API Gemini terlebih dahulu.'),
          action: SnackBarAction(label: 'Pengaturan', onPressed: _openSettings),
        ),
      );
      return;
    }

    setState(() => _capturing = true);

    try {
      final file = await ctrl.takePicture();
      final bytes = await File(file.path).readAsBytes();
      final model = await _settings.getModelId();

      if (!mounted) return;
      final nav = Navigator.of(context);
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Mengirim ke Gemini…')),
            ],
          ),
        ),
      );

      final answer = await _gemini.solveFromImage(
        apiKey: apiKey,
        modelName: model,
        imageBytes: bytes,
      );

      if (!mounted) return;
      if (nav.canPop) nav.pop();

      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => SummaryScreen(
            imagePath: file.path,
            answer: answer,
            modelUsed: model,
          ),
        ),
      );
    } on GeminiSolveException catch (e) {
      if (mounted && Navigator.of(context).canPop) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted && Navigator.of(context).canPop) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto soal'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Pengaturan API',
            onPressed: _openSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : ctrl == null || !ctrl.value.isInitialized
              ? const Center(
                  child: Text('Kamera tidak tersedia.'),
                )
              : Column(
                  children: [
                    Expanded(
                      child: CameraPreview(ctrl),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: _capturing ? null : _captureAndSolve,
                            icon: _capturing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.document_scanner_outlined),
                            label: Text(
                              _capturing ? 'Memproses…' : 'Ambil & jawab',
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
