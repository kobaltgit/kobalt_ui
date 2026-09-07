import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/kobalt_project.dart';
import '../theme/kobalt_tokens.dart';

class KobaltFooterLink {
  final String label;
  final String url;

  const KobaltFooterLink({required this.label, required this.url});
}

class KobaltFooter extends StatelessWidget {
  final KobaltProjectId project;
  final KobaltProjectMeta? customProject;
  final String? version;
  final bool isRussian;
  final Color? accentColor;
  final Gradient? accentGradient;
  final Widget? customLogo;
  final String? customDescription;
  final List<KobaltFooterLink>? extraLinks;
  final VoidCallback? onBackToTop;

  const KobaltFooter({
    super.key,
    required this.project,
    this.customProject,
    this.version,
    this.isRussian = true,
    this.accentColor,
    this.accentGradient,
    this.customLogo,
    this.customDescription,
    this.extraLinks,
    this.onBackToTop,
  });

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _defaultBackToTop(BuildContext context) {
    if (onBackToTop != null) {
      onBackToTop!();
    } else {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMeta = customProject ?? KobaltRegistry.getById(project);
    final sisterProjects = KobaltRegistry.getSisterProjects(project);
    final effectiveAccent = accentColor ?? currentMeta.gradientColors.first;
    final effectiveGradient = accentGradient ??
        LinearGradient(
          colors: currentMeta.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 960;
    final isTablet = screenWidth >= 640 && screenWidth < 960;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF04060B),
        border: Border(
          top: BorderSide(color: KobaltTokens.surfaceBorder, width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : (isTablet ? 32 : 20),
        vertical: isDesktop ? 64 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: KobaltTokens.maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Колонка 1: Бренд и описание утилиты
                    Expanded(
                      flex: 4,
                      child: _buildBrandColumn(currentMeta, effectiveGradient),
                    ),
                    const SizedBox(width: 48),

                    // Колонка 2: Экосистема Kobalt Tools
                    Expanded(
                      flex: 4,
                      child: _buildEcosystemColumn(sisterProjects, effectiveAccent),
                    ),
                    const SizedBox(width: 48),

                    // Колонка 3: Ресурсы и разработка
                    Expanded(
                      flex: 3,
                      child: _buildResourcesColumn(currentMeta, effectiveAccent),
                    ),
                  ],
                )
              else ...[
                _buildBrandColumn(currentMeta, effectiveGradient),
                const SizedBox(height: 40),
                const Divider(color: KobaltTokens.surfaceBorderSubtle),
                const SizedBox(height: 32),
                _buildEcosystemColumn(sisterProjects, effectiveAccent),
                const SizedBox(height: 36),
                const Divider(color: KobaltTokens.surfaceBorderSubtle),
                const SizedBox(height: 32),
                _buildResourcesColumn(currentMeta, effectiveAccent),
              ],

              const SizedBox(height: 48),
              const Divider(color: KobaltTokens.surfaceBorder, height: 1),
              const SizedBox(height: 24),

              // Нижняя полоса: Копирайт + Стек + Наверх
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 20,
                runSpacing: 12,
                children: [
                  Text(
                    isRussian
                        ? '© 2026 Kobalt Tools. Открытый исходный код под лицензией MIT.'
                        : '© 2026 Kobalt Tools. Open source under MIT License.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: KobaltTokens.textMuted,
                      fontFamily: KobaltTokens.fontFamily,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isRussian ? 'Сделано на Flutter Web & Rust' : 'Built with Flutter Web & Rust',
                        style: const TextStyle(
                          fontSize: 12,
                          color: KobaltTokens.textMuted,
                          fontFamily: KobaltTokens.fontFamily,
                        ),
                      ),
                      const SizedBox(width: 16),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _defaultBackToTop(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isRussian ? 'Наверх' : 'Back to top',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: effectiveAccent,
                                  fontFamily: KobaltTokens.fontFamily,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_upward_rounded,
                                size: 14,
                                color: effectiveAccent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandColumn(KobaltProjectMeta currentMeta, Gradient effectiveGradient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                        color: currentMeta.gradientColors.first.withValues(alpha: 0.3),
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: KobaltTokens.textPrimary,
                fontFamily: KobaltTokens.fontFamily,
              ),
            ),
            if (version != null) ...[
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
        const SizedBox(height: 16),
        Text(
          customDescription ?? currentMeta.getBio(isRussian),
          style: const TextStyle(
            fontSize: 13,
            height: 1.6,
            color: KobaltTokens.textSecondary,
            fontFamily: KobaltTokens.fontFamily,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildTechBadge('Rust 2021'),
            _buildTechBadge('Tauri v2'),
            _buildTechBadge('Svelte 5'),
            _buildTechBadge('Win32 API'),
          ],
        ),
      ],
    );
  }

  Widget _buildEcosystemColumn(List<KobaltProjectMeta> sisterProjects, Color effectiveAccent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRussian ? 'Экосистема Kobalt Tools' : 'Kobalt Tools Ecosystem',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: KobaltTokens.textPrimary,
            letterSpacing: 0.2,
            fontFamily: KobaltTokens.fontFamily,
          ),
        ),
        const SizedBox(height: 16),
        ...sisterProjects.map((p) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SisterProjectLink(
              project: p,
              isRussian: isRussian,
              accentColor: effectiveAccent,
              onTap: () => _openUrl(p.siteUrl),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResourcesColumn(KobaltProjectMeta currentMeta, Color effectiveAccent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRussian ? 'Проект и ресурсы' : 'Project & Resources',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: KobaltTokens.textPrimary,
            letterSpacing: 0.2,
            fontFamily: KobaltTokens.fontFamily,
          ),
        ),
        const SizedBox(height: 16),
        _buildFooterTextLink(
          isRussian ? 'GitHub Репозиторий' : 'GitHub Repository',
          currentMeta.repoUrl,
          effectiveAccent,
        ),
        const SizedBox(height: 10),
        _buildFooterTextLink(
          isRussian ? 'Релизы и версии' : 'Releases & Changelog',
          currentMeta.releasesUrl,
          effectiveAccent,
        ),
        const SizedBox(height: 10),
        _buildFooterTextLink(
          isRussian ? 'Сообщить об ошибке' : 'Report an Issue',
          currentMeta.issuesUrl,
          effectiveAccent,
        ),
        const SizedBox(height: 10),
        _buildFooterTextLink(
          isRussian ? 'Свободная лицензия MIT' : 'MIT License',
          currentMeta.licenseUrl,
          effectiveAccent,
        ),
        if (extraLinks != null) ...[
          for (final link in extraLinks!) ...[
            const SizedBox(height: 10),
            _buildFooterTextLink(link.label, link.url, effectiveAccent),
          ],
        ],
      ],
    );
  }

  Widget _buildFooterTextLink(String label, String url, Color effectiveAccent) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _openUrl(url),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: KobaltTokens.textSecondary,
            fontFamily: KobaltTokens.fontFamily,
          ),
        ),
      ),
    );
  }

  Widget _buildTechBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: KobaltTokens.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: KobaltTokens.surfaceBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: KobaltTokens.textMuted,
          fontFamily: KobaltTokens.fontFamily,
        ),
      ),
    );
  }
}

class _SisterProjectLink extends StatefulWidget {
  final KobaltProjectMeta project;
  final bool isRussian;
  final Color accentColor;
  final VoidCallback onTap;

  const _SisterProjectLink({
    required this.project,
    required this.isRussian,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_SisterProjectLink> createState() => _SisterProjectLinkState();
}

class _SisterProjectLinkState extends State<_SisterProjectLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.project.iconEmoji,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 8),
            Text(
              widget.project.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _isHovered ? widget.accentColor : KobaltTokens.textPrimary,
                fontFamily: KobaltTokens.fontFamily,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '— ${widget.project.getTagline(widget.isRussian)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: _isHovered ? KobaltTokens.textSecondary : KobaltTokens.textMuted,
                  fontFamily: KobaltTokens.fontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

