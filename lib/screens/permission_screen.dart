import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/permission_helper.dart';
import 'camera_screen.dart';

/// Meminta izin kamera, penyimpanan/media, dan memastikan ada koneksi jaringan.
class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _busy = false;
  String? _message;

  Future<void> _refresh() async {
    setState(() {
      _message = null;
    });
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  Future<void> _requestAll() async {
    setState(() {
      _busy = true;
      _message = null;
    });

    final cam = await PermissionHelper.requestCamera();
    if (!cam) {
      if (mounted) {
        setState(() {
          _busy = false;
          _message =
              'Izin kamera ditolak. Aktifkan di pengaturan agar bisa memotret soal.';
        });
      }
      return;
    }

    final storage = await PermissionHelper.requestStorage();
    if (!storage) {
      if (mounted) {
        setState(() {
          _busy = false;
          _message =
              'Izin penyimpanan/media ditolak. Diperlukan untuk menyimpan dan mengakses foto.';
        });
      }
      return;
    }

    final net = await PermissionHelper.isNetworkAvailable();
    if (!net) {
      if (mounted) {
        setState(() {
          _busy = false;
          _message =
              'Tidak ada koneksi internet. Aktifkan Wi‑Fi atau data seluler, lalu ketuk «Coba lagi».';
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() => _busy = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const CameraScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Izin aplikasi'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Agar aplikasi berjalan baik, kami memerlukan:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          _Tile(
            icon: Icons.camera_alt_outlined,
            title: 'Kamera',
            subtitle: 'Memotret lembar soal atau tulisan di papan.',
            color: scheme.primary,
          ),
          const SizedBox(height: 12),
          _Tile(
            icon: Icons.folder_open_outlined,
            title: 'Penyimpanan / galeri',
            subtitle:
                'Mengakses dan menyimpan foto terkait soal (sesuai versi Android/iOS).',
            color: scheme.secondary,
          ),
          const SizedBox(height: 12),
          _Tile(
            icon: Icons.wifi_outlined,
            title: 'Internet',
            subtitle:
                'Tidak ada dialog sistem khusus; izin jaringan dideklarasikan di aplikasi. Pastikan perangkat terhubung.',
            color: scheme.tertiary,
          ),
          if (_message != null) ...[
            const SizedBox(height: 20),
            Material(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _message!,
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
            ),
          ],
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _busy ? null : _requestAll,
            icon: _busy
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.verified_user_outlined),
            label: Text(_busy ? 'Memproses…' : 'Izinkan & lanjut'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi (cek jaringan)'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
            label: const Text('Buka pengaturan sistem'),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
