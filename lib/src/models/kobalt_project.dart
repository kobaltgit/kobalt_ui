import 'package:flutter/material.dart';

enum KobaltProjectId {
  stashIt,
  miniBin,
  undoit,
  polyShift,
  peekIt,
  peekItPlugins,
  freeIt,
  custom,
}

class KobaltProjectMeta {
  final KobaltProjectId id;
  final String name;
  final String? defaultVersion;
  final String iconEmoji;
  final IconData fallbackIcon;
  final String taglineRu;
  final String taglineEn;
  final String shortBioRu;
  final String shortBioEn;
  final String siteUrl;
  final String repoUrl;
  final String releasesUrl;
  final String issuesUrl;
  final String licenseUrl;
  final List<Color> gradientColors;

  const KobaltProjectMeta({
    required this.id,
    required this.name,
    this.defaultVersion,
    required this.iconEmoji,
    required this.fallbackIcon,
    required this.taglineRu,
    required this.taglineEn,
    required this.shortBioRu,
    required this.shortBioEn,
    required this.siteUrl,
    required this.repoUrl,
    required this.releasesUrl,
    required this.issuesUrl,
    required this.licenseUrl,
    required this.gradientColors,
  });

  String get latestReleaseUrl => '$repoUrl/releases/latest';
  String getTagline(bool isRu) => isRu ? taglineRu : taglineEn;
  String getBio(bool isRu) => isRu ? shortBioRu : shortBioEn;
}

class KobaltRegistry {
  static const List<KobaltProjectMeta> allProjects = [
    KobaltProjectMeta(
      id: KobaltProjectId.stashIt,
      name: 'StashIt',
      defaultVersion: 'v1.0.1',
      iconEmoji: '📥',
      fallbackIcon: Icons.move_to_inbox_rounded,
      taglineRu: 'Плавающий карман Drag-and-Drop',
      taglineEn: 'Floating Drag-and-Drop Shelf',
      shortBioRu: 'Встряхните мышь или перетащите файлы к краю экрана. Умная временная полка для быстрой группировки и комфортного переноса файлов в Windows.',
      shortBioEn: 'Shake your mouse or drag files to the screen edge. A smart floating shelf for effortless multi-file drag-and-drop workflow on Windows.',
      siteUrl: 'https://kobaltgit.github.io/StashIt/',
      repoUrl: 'https://github.com/kobaltgit/StashIt',
      releasesUrl: 'https://github.com/kobaltgit/StashIt/releases',
      issuesUrl: 'https://github.com/kobaltgit/StashIt/issues',
      licenseUrl: 'https://github.com/kobaltgit/StashIt/blob/master/LICENSE',
      gradientColors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
    ),
    KobaltProjectMeta(
      id: KobaltProjectId.miniBin,
      name: 'MiniBin',
      defaultVersion: 'v2.0.1',
      iconEmoji: '🗑',
      fallbackIcon: Icons.delete_outline_rounded,
      taglineRu: 'Умная корзина в системном трее',
      taglineEn: 'System Tray Recycle Bin',
      shortBioRu: 'Легковесный монитор Корзины Windows с красивым всплывающим окном, быстрым предпросмотром удалённых файлов и очисткой в 1 клик.',
      shortBioEn: 'Lightweight Windows Recycle Bin tray companion with a sleek flyout, quick file preview, and instant one-click cleanup.',
      siteUrl: 'https://kobaltgit.github.io/minibin/',
      repoUrl: 'https://github.com/kobaltgit/minibin',
      releasesUrl: 'https://github.com/kobaltgit/minibin/releases',
      issuesUrl: 'https://github.com/kobaltgit/minibin/issues',
      licenseUrl: 'https://github.com/kobaltgit/minibin/blob/master/LICENSE',
      gradientColors: [Color(0xFF00E5FF), Color(0xFF1DE9B6)],
    ),
    KobaltProjectMeta(
      id: KobaltProjectId.undoit,
      name: 'Undoit',
      defaultVersion: 'v2.1.1',
      iconEmoji: '⏱',
      fallbackIcon: Icons.history_rounded,
      taglineRu: 'Машина времени для локальных файлов',
      taglineEn: 'Local File Time Machine',
      shortBioRu: 'Системный Ctrl+Z для проводника: отслеживание удалений, перезаписей и перемещений с возможностью моментального восстановления.',
      shortBioEn: 'System-wide Ctrl+Z for file operations: track deletions, overwrites, and accidental moves with instant snapshot rollback.',
      siteUrl: 'https://kobaltgit.github.io/Undoit/',
      repoUrl: 'https://github.com/kobaltgit/undoit',
      releasesUrl: 'https://github.com/kobaltgit/undoit/releases',
      issuesUrl: 'https://github.com/kobaltgit/undoit/issues',
      licenseUrl: 'https://github.com/kobaltgit/undoit/blob/master/LICENSE',
      gradientColors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    ),
    KobaltProjectMeta(
      id: KobaltProjectId.polyShift,
      name: 'PolyShift',
      defaultVersion: 'v2.0.0',
      iconEmoji: '🌐',
      fallbackIcon: Icons.auto_awesome,
      taglineRu: 'HUD-помощник и AI-перевод у курсора',
      taglineEn: 'Cursor HUD Translation & AI Assist',
      shortBioRu: 'Мгновенный перевод выделенного текста и умный ассистент поверх любых окон по шорткату с потоковыми ответами Google Gemini.',
      shortBioEn: 'Instant translation and smart AI assistance at your cursor over any window with live streaming responses from Google Gemini.',
      siteUrl: 'https://kobaltgit.github.io/polyshift/',
      repoUrl: 'https://github.com/kobaltgit/polyshift',
      releasesUrl: 'https://github.com/kobaltgit/polyshift/releases',
      issuesUrl: 'https://github.com/kobaltgit/polyshift/issues',
      licenseUrl: 'https://github.com/kobaltgit/polyshift/blob/master/LICENSE',
      gradientColors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
    ),
    KobaltProjectMeta(
      id: KobaltProjectId.peekIt,
      name: 'PeekIt',
      defaultVersion: 'v1.3.2',
      iconEmoji: '👁',
      fallbackIcon: Icons.visibility_rounded,
      taglineRu: 'Мгновенный просмотр файлов по Space',
      taglineEn: 'Instant Spacebar File Preview',
      shortBioRu: 'Молниеносный предварительный просмотр любых изображений, кода, PDF, 3D-моделей и архивов по нажатию клавиши пробел в стиле macOS QuickLook.',
      shortBioEn: 'Lightning-fast previews of images, code, PDFs, 3D models, and archives with a single tap of the spacebar for Windows.',
      siteUrl: 'https://kobaltgit.github.io/PeekIt/',
      repoUrl: 'https://github.com/kobaltgit/peekit',
      releasesUrl: 'https://github.com/kobaltgit/peekit/releases',
      issuesUrl: 'https://github.com/kobaltgit/peekit/issues',
      licenseUrl: 'https://github.com/kobaltgit/peekit/blob/main/LICENSE',
      gradientColors: [Color(0xFF00F2FE), Color(0xFF4FACFE)],
    ),
    KobaltProjectMeta(
      id: KobaltProjectId.peekItPlugins,
      name: 'PeekIt Plugins',
      defaultVersion: 'v0.1.0',
      iconEmoji: '🧩',
      fallbackIcon: Icons.extension_rounded,
      taglineRu: 'Официальный каталог расширений PeekIt',
      taglineEn: 'Official Extension Registry & Store',
      shortBioRu: 'Открытый репозиторий плагинов и SDK для разработчиков. Поддержка новых форматов файлов, рендереров и внешних утилит.',
      shortBioEn: 'Open plugin registry and developer SDK to extend PeekIt with custom formats, specialized renderers, and third-party tools.',
      siteUrl: 'https://kobaltgit.github.io/peekit-plugins/',
      repoUrl: 'https://github.com/kobaltgit/peekit-plugins',
      releasesUrl: 'https://github.com/kobaltgit/peekit-plugins/releases',
      issuesUrl: 'https://github.com/kobaltgit/peekit-plugins/issues',
      licenseUrl: 'https://github.com/kobaltgit/peekit-plugins/blob/main/LICENSE',
      gradientColors: [Color(0xFF6366F1), Color(0xFFA855F7)],
    ),
    KobaltProjectMeta(
      id: KobaltProjectId.freeIt,
      name: 'FreeIt',
      defaultVersion: 'v1.0.0',
      iconEmoji: '🔓',
      fallbackIcon: Icons.lock_open_rounded,
      taglineRu: 'Нативный разблокировщик файлов и папок для Windows 10 & 11',
      taglineEn: 'Native File & Folder Unlocker for Windows 10 & 11',
      shortBioRu: 'Моментальный поиск удерживающих процессов через Win32 Restart Manager API, ИИ-инспектор Gemini и безопасная разблокировка.',
      shortBioEn: 'Instant lock diagnostics via Win32 Restart Manager API, Gemini AI insights, safe unlocking and forced file removal.',
      siteUrl: 'https://kobaltgit.github.io/FreeIt/',
      repoUrl: 'https://github.com/kobaltgit/FreeIt',
      releasesUrl: 'https://github.com/kobaltgit/FreeIt/releases',
      issuesUrl: 'https://github.com/kobaltgit/FreeIt/issues',
      licenseUrl: 'https://github.com/kobaltgit/FreeIt/blob/main/LICENSE',
      gradientColors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
    ),
  ];

  static KobaltProjectMeta getById(KobaltProjectId id) {
    return allProjects.firstWhere(
      (p) => p.id == id,
      orElse: () => allProjects.first,
    );
  }

  static List<KobaltProjectMeta> getSisterProjects(KobaltProjectId currentId) {
    return allProjects.where((p) => p.id != currentId).toList();
  }
}
