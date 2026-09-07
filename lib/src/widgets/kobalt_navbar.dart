import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/kobalt_project.dart';
import '../services/kobalt_release_service.dart';
import '../theme/kobalt_tokens.dart';

class KobaltNavLink {
  final String label;
  final VoidCallback onTap;

  const KobaltNavLink({required this.label, required this.onTap});
}

class KobaltNavBar extends StatefulWidget {
  final KobaltProjectId project;
  final KobaltProjectMeta? customProject;
  final String? version;
  final bool isRussian;
  final VoidCallback onLanguageToggle;
  final bool? isDark;
  final VoidCallback? onThemeToggle;
  final Color? accentColor;
  final Gradient? accentGradient;
  final Widget? customLogo;
  final List<KobaltNavLink>? navLinks;
  final VoidCallback? onDownloadTap;
  final String? downloadLabel;
  final VoidCallback? onGitHubTap;
  final List<Widget>? extraActions;

  const KobaltNavBar({
    super.key,
    required this.project,
    this.customProject,
    this.version,
    this.isRussian = true,
    required this.onLanguageToggle,
    this.isDark,
    this.onThemeToggle,
    this.accentColor,
    this.accentGradient,
    this.customLogo,
    this.navLinks,
    this.onDownloadTap,
    this.downloadLabel,
    this.onGitHubTap,
    this.extraActions,
  });

  @override
  State<KobaltNavBar> createState() => _KobaltNavBarState();
}

class _KobaltNavBarState extends State<KobaltNavBar> {
  KobaltRelease? _release;

  @override
  void initState() {
    super.initState();
    _loadRelease();
  }

  Future<void> _loadRelease() async {
    final cached = KobaltReleaseService.getCached(widget.project);
    if (cached != null) {
      if (mounted) setState(() => _release = cached);
      return;
    }

    final rel = await KobaltReleaseService.fetchLatestRelease(widget.project);
    if (mounted && rel != null) {
      setState(() => _release = rel);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMeta = widget.customProject ?? KobaltRegistry.getById(widget.project);
    final effectiveAccent = widget.accentColor ?? currentMeta.gradientColors.first;
    final effectiveGradient = widget.accentGradient ??
        LinearGradient(
          colors: currentMeta.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 1024;
    final effectiveVersion = _release?.tagName.isNotEmpty == true
        ? _release!.tagName
        : (widget.version ?? currentMeta.defaultVersion ?? '');

    return Container(
      height: KobaltTokens.navBarHeight,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
      decoration: BoxDecoration(
        color: KobaltTokens.background.withValues(alpha: 0.85),
        border: const Border(
          bottom: BorderSide(color: KobaltTokens.surfaceBorder, width: 1),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: KobaltTokens.maxWidth),
          child: Row(
            children: [
              // 1. Бренд (Лого + Название + Автоматический бейдж версии) — прижат влево
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Scrollable.ensureVisible(
                      context,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.customLogo ??
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: effectiveGradient,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: currentMeta.gradientColors.first.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                currentMeta.fallbackIcon,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      const SizedBox(width: 12),
                      Text(
                        currentMeta.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: KobaltTokens.textPrimary,
                          fontFamily: KobaltTokens.fontFamily,
                        ),
                      ),
                      if (effectiveVersion.isNotEmpty && screenWidth >= 640) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: currentMeta.gradientColors.first.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: currentMeta.gradientColors.first.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            effectiveVersion,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: currentMeta.gradientColors.first,
                              fontFamily: KobaltTokens.fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // 2. Навигационные ссылки по разделам — по центру страницы
              if (isDesktop && widget.navLinks != null && widget.navLinks!.isNotEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final link in widget.navLinks!) ...[
                      _NavBarItem(label: link.label, onTap: link.onTap),
                      const SizedBox(width: 20),
                    ],
                  ],
                ),
                const Spacer(),
              ],

              // 3. Действия (тема, язык, GitHub, Скачать) — прижаты вправо
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Встроенный переключатель темы (Светлая / Тёмная)
                  if (widget.onThemeToggle != null) ...[
                    IconButton(
                      onPressed: widget.onThemeToggle,
                      icon: Icon(
                        (widget.isDark ?? true) ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        size: 18,
                      ),
                      tooltip: widget.isRussian
                          ? ((widget.isDark ?? true) ? 'Светлая тема' : 'Тёмная тема')
                          : ((widget.isDark ?? true) ? 'Light theme' : 'Dark theme'),
                      color: KobaltTokens.textSecondary,
                    ),
                    const SizedBox(width: 4),
                  ],

                  // Дополнительные кнопки
                  if (widget.extraActions != null) ...[
                    ...widget.extraActions!,
                    const SizedBox(width: 6),
                  ],

                  // Сдвоенный переключатель языка [ RU | EN ]
                  _buildLangToggle(effectiveAccent),
                  const SizedBox(width: 8),

                  // Кнопка GitHub (контурная на широких экранах, иконка на мобильных)
                  if (screenWidth >= 1100)
                    OutlinedButton.icon(
                      onPressed: widget.onGitHubTap ?? () => _openUrl(currentMeta.repoUrl),
                      icon: const Icon(Icons.code_rounded, size: 16),
                      label: const Text('GitHub'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: KobaltTokens.textPrimary,
                        side: const BorderSide(color: KobaltTokens.surfaceBorder),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  else
                    IconButton(
                      onPressed: widget.onGitHubTap ?? () => _openUrl(currentMeta.repoUrl),
                      icon: const Icon(Icons.code_rounded, size: 18),
                      tooltip: 'GitHub',
                      color: KobaltTokens.textSecondary,
                    ),

                  // Кнопка Скачать (акцентная, автоматически открывает релиз, если нет скролла)
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: widget.onDownloadTap ??
                        () => _openUrl(_release?.downloadUrl ?? '${currentMeta.repoUrl}/releases/latest'),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: Text(
                      widget.downloadLabel ?? (widget.isRussian ? 'Скачать' : 'Download'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: effectiveAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 16 : 12,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangToggle(Color effectiveAccent) {
    return Container(
      decoration: BoxDecoration(
        color: KobaltTokens.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KobaltTokens.surfaceBorder),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLangItem('RU', widget.isRussian, widget.onLanguageToggle, effectiveAccent),
          _buildLangItem('EN', !widget.isRussian, widget.onLanguageToggle, effectiveAccent),
        ],
      ),
    );
  }

  Widget _buildLangItem(
    String label,
    bool isSelected,
    VoidCallback onTap,
    Color effectiveAccent,
  ) {
    return GestureDetector(
      onTap: isSelected ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? effectiveAccent.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? effectiveAccent : KobaltTokens.textMuted,
            fontFamily: KobaltTokens.fontFamily,
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NavBarItem({required this.label, required this.onTap});

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _isHovered ? KobaltTokens.textPrimary : KobaltTokens.textSecondary,
            fontFamily: KobaltTokens.fontFamily,
          ),
        ),
      ),
    );
  }
}

