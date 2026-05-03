import 'package:flutter/material.dart';

import '../app_constants.dart';
import '../services/settings_service.dart';

/// Mengatur kunci API Gemini dan ID model (mis. gemini-3.1-pro).
class ConfigureScreen extends StatefulWidget {
  const ConfigureScreen({super.key});

  @override
  State<ConfigureScreen> createState() => _ConfigureScreenState();
}

class _ConfigureScreenState extends State<ConfigureScreen> {
  final _settings = SettingsService();
  final _keyCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final key = await _settings.getApiKey();
    final model = await _settings.getModelId();
    if (!mounted) return;
    setState(() {
      _keyCtrl.text = key ?? '';
      _modelCtrl.text = model;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final key = _keyCtrl.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan kunci API Gemini dari Google AI Studio.'),
        ),
      );
      return;
    }
    await _settings.saveApiKey(key);
    await _settings.saveModelId(_modelCtrl.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan disimpan.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Gemini'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Dapatkan API key di Google AI Studio (ai.google.dev). '
            'Untuk Gemini 3.1, gunakan ID model yang tertera di dokumentasi akun Anda '
            '(contoh: gemini-3.1-pro). Default stabil: $kDefaultGeminiModel.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _keyCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Kunci API Gemini',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _modelCtrl,
            decoration: const InputDecoration(
              labelText: 'ID model',
              hintText: 'gemini-2.5-flash atau gemini-3.1-pro',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
