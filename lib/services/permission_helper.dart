import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Izin kamera & penyimpanan (runtime). Internet: manifest + pengecekan koneksi.
class PermissionHelper {
  static Future<bool> isNetworkAvailable() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  static Future<bool> hasCameraAccess() async {
    final s = await Permission.camera.status;
    return s.isGranted;
  }

  static Future<bool> hasStorageAccess() async {
    if (Platform.isIOS) {
      final p = await Permission.photos.status;
      return p.isGranted || p.isLimited;
    }
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt >= 33) {
        final p = await Permission.photos.status;
        return p.isGranted;
      }
      final s = await Permission.storage.status;
      return s.isGranted;
    }
    return true;
  }

  static Future<bool> requestCamera() async {
    final r = await Permission.camera.request();
    return r.isGranted;
  }

  static Future<bool> requestStorage() async {
    if (Platform.isIOS) {
      final r = await Permission.photos.request();
      return r.isGranted || r.isLimited;
    }
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt >= 33) {
        final r = await Permission.photos.request();
        return r.isGranted;
      }
      final r = await Permission.storage.request();
      return r.isGranted;
    }
    return true;
  }

  static Future<bool> corePermissionsOk() async {
    final cam = await hasCameraAccess();
    final sto = await hasStorageAccess();
    return cam && sto;
  }

  static Future<bool> readyForApp() async {
    final core = await corePermissionsOk();
    final net = await isNetworkAvailable();
    return core && net;
  }
}
