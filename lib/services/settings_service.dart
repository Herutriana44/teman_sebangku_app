import 'package:shared_preferences/shared_preferences.dart';

import '../app_constants.dart';

class SettingsService {
  static const _keyApiKey = 'gemini_api_key';
  static const _keyModel = 'gemini_model_id';

  Future<String?> getApiKey() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(_keyApiKey);
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  Future<String> getModelId() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyModel)?.trim().isNotEmpty == true
        ? p.getString(_keyModel)!.trim()
        : kDefaultGeminiModel;
  }

  Future<void> saveApiKey(String key) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyApiKey, key.trim());
  }

  Future<void> saveModelId(String model) async {
    final p = await SharedPreferences.getInstance();
    final m = model.trim().isEmpty ? kDefaultGeminiModel : model.trim();
    await p.setString(_keyModel, m);
  }
}
