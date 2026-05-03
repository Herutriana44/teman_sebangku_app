import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const _systemPrompt = '''
Anda adalah tutor yang membantu siswa. Pengguna mengirim foto soal (matematika, fisika, kimia, biologi, atau mata pelajaran lain).

Tugas Anda:
1) Baca teks/soal dari gambar sebaik mungkin.
2) Jika gambar tidak jelas atau bukan soal, jelaskan singkat dan minta foto yang lebih jelas.
3) Jika ini soal, berikan penyelesaian langkah demi langkah dalam Bahasa Indonesia.
4) Sebutkan mata pelajaran yang Anda perkirakan (jika bisa).

Gunakan format rapi dengan heading pendek (mis. ringkasan soal, langkah, jawaban akhir).
''';

  Future<String> solveFromImage({
    required String apiKey,
    required String modelName,
    required Uint8List imageBytes,
    String mimeType = 'image/jpeg',
  }) async {
    final model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
    );

    final user = Content.multi([
      TextPart(
        '$_systemPrompt\n\nAnalisis foto soal berikut dan jawab sesuai instruksi di atas.',
      ),
      DataPart(mimeType, imageBytes),
    ]);

    final response = await model.generateContent([user]);
    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw GeminiSolveException(
        'Model tidak mengembalikan teks. Coba model lain (mis. gemini-2.5-flash atau gemini-3.1-pro) atau periksa kuota API.',
      );
    }
    return text.trim();
  }
}

class GeminiSolveException implements Exception {
  GeminiSolveException(this.message);
  final String message;

  @override
  String toString() => message;
}
