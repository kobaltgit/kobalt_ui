import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/kobalt_project.dart';
import '../theme/kobalt_tokens.dart';

class KobaltNavLink {
  final String label;
  final VoidCallback onTap;

  const KobaltNavLink({required this.label, required this.onTap});
}

class KobaltNavBar extends StatelessWidget {
  final KobaltProjectId project;
  final String? version;
  final bool isRussian;
  final VoidCallback onLanguageToggle;
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
    this.version,
    this.isRussian = true,
    required this.onLanguageToggle,
    this.accentColor,
    this.accentGradient,
    this.customLogo,
    this.navLinks,
    this.onDownloadTap,
    this.downloadLabel,
    this.onGitHubTap,
    this.extraActions,
  });

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMeta = KobaltRegistry.getById(project);
    final effectiveAccent = accentColor ?? currentMeta.gradientColors.first;
    final effectiveGradient = accentGradient ??
        LinearGradient(
          colors: currentMeta.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 1024;

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
              // Бренд (Лого + Название + Бейдж версии)
              Flexible(
                child: MouseRegion(
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
                        customLogo ??
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
                        Flexible(
                          child: Text(
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
                        ),
                        if (version != null && screenWidth >= 640) ...[
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
                              version!,
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
              ),

              const SizedBox(width: 16),

              // Навигационные ссылки по разделам (на десктопе)
              if (isDesktop && navLinks != null) ...[
                for (final link in navLinks!) ...[
                  _NavBarItem(label: link.label, onTap: link.onTap),
                  const SizedBox(width: 18),
                ],
                const SizedBox(width: 6),
              ],

              // Дополнительные кнопки (например, переключатель темы)
              if (extraActions != null) ...[
                ...extraActions!,
                const SizedBox(width: 6),
              ],

              // Сдвоенный переключатель языка [ RU | EN ]
              _buildLangToggle(effectiveAccent),
              const SizedBox(width: 8),

              // Кнопка GitHub (контурная на десктопе, иконка на планшетах/мобильных)
              if (isDesktop)
                OutlinedButton.icon(
                  onPressed: onGitHubTap ?? () => _openUrl(currentMeta.repoUrl),
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
                  onPressed: onGitHubTap ?? () => _openUrl(currentMeta.repoUrl),
                  icon: const Icon(Icons.code_rounded, size: 18),
                  tooltip: 'GitHub',
                  color: KobaltTokens.textSecondary,
                ),
              const SizedBox(width: 8),

              // Кнопка Скачать (акцентная)
              if (onDownloadTap != null)
                ElevatedButton.icon(
                  onPressed: onDownloadTap,
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: Text(
                    downloadLabel ?? (isRussian ? 'Скачать' : 'Download'),
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
          _buildLangItem('RU', isRussian, onLanguageToggle, effectiveAccent),
          _buildLangItem('EN', !isRussian, onLanguageToggle, effectiveAccent),
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

