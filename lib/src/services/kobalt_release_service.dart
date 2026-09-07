import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/kobalt_project.dart';

/// Файл (ассет), прикреплённый к релизу на GitHub.
class KobaltReleaseAsset {
  final String name;
  final String downloadUrl;
  final int sizeBytes;

  const KobaltReleaseAsset({
    required this.name,
    required this.downloadUrl,
    required this.sizeBytes,
  });

  factory KobaltReleaseAsset.fromJson(Map<String, dynamic> json) {
    return KobaltReleaseAsset(
      name: json['name'] as String? ?? '',
      downloadUrl: json['browser_download_url'] as String? ?? '',
      sizeBytes: json['size'] as int? ?? 0,
    );
  }
}

/// Информация о последнем релизе проекта на GitHub.
class KobaltRelease {
  final String tagName;
  final String htmlUrl;
  final List<KobaltReleaseAsset> assets;
  final String? publishedAt;
  final String? body;

  const KobaltRelease({
    required this.tagName,
    required this.htmlUrl,
    this.assets = const [],
    this.publishedAt,
    this.body,
  });

  factory KobaltRelease.fromJson(Map<String, dynamic> json) {
    final rawAssets = json['assets'] as List<dynamic>? ?? [];
    return KobaltRelease(
      tagName: json['tag_name'] as String? ?? '',
      htmlUrl: json['html_url'] as String? ?? '',
      publishedAt: json['published_at'] as String?,
      body: json['body'] as String?,
      assets: rawAssets
          .whereType<Map<String, dynamic>>()
          .map((a) => KobaltReleaseAsset.fromJson(a))
          .toList(),
    );
  }

  /// Находит главный установочный или бинарный файл (.msi, .exe, .zip).
  KobaltReleaseAsset? get primaryAsset {
    if (assets.isEmpty) return null;

    // 1. Предпочитаем .msi установщик Windows
    for (final a in assets) {
      if (a.name.toLowerCase().endsWith('.msi')) return a;
    }

    // 2. Предпочитаем Setup.exe
    for (final a in assets) {
      final lower = a.name.toLowerCase();
      if (lower.endsWith('.exe') && lower.contains('setup')) return a;
    }

    // 3. Любой .exe
    for (final a in assets) {
      if (a.name.toLowerCase().endsWith('.exe')) return a;
    }

    // 4. .zip архив
    for (final a in assets) {
      if (a.name.toLowerCase().endsWith('.zip')) return a;
    }

    return assets.first;
  }

  /// Прямая ссылка на скачивание актуального файла, либо fallback на страницу релиза.
  String get downloadUrl => primaryAsset?.downloadUrl ?? htmlUrl;
}

/// Сервис запросов к публичному GitHub REST API для автоматизации релизов экосистемы Kobalt.
class KobaltReleaseService {
  static final Map<KobaltProjectId, KobaltRelease> _cache = {};

  /// Возвращает закэшированный релиз, если он уже был загружен.
  static KobaltRelease? getCached(KobaltProjectId project) => _cache[project];

  /// Получает информацию о последнем релизе с GitHub.
  /// Результат кэшируется в памяти, предотвращая исчерпание лимитов GitHub API.
  static Future<KobaltRelease?> fetchLatestRelease(KobaltProjectId project) async {
    if (_cache.containsKey(project)) {
      return _cache[project];
    }

    final meta = KobaltRegistry.getById(project);
    final repoUrl = meta.repoUrl;
    if (!repoUrl.contains('github.com/')) {
      return null;
    }

    final repoSlug = repoUrl.split('github.com/').last.replaceAll(RegExp(r'\.git$'), '');
    final uri = Uri.parse('https://api.github.com/repos/$repoSlug/releases/latest');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'Kobalt-Ecosystem-Web',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final release = KobaltRelease.fromJson(data);
        _cache[project] = release;
        return release;
      } else {
        debugPrint('GitHub API ($repoSlug) returned status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching release for $repoSlug: $e');
    }

    return null;
  }
}
