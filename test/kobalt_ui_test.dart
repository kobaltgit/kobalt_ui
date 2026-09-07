import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kobalt_ui/kobalt_ui.dart';

void main() {
  group('KobaltRegistry', () {
    test('contains all 6 ecosystem projects', () {
      expect(KobaltRegistry.allProjects.length, equals(6));
    });

    test('all projects have valid latestReleaseUrl and defaultVersion', () {
      for (final project in KobaltRegistry.allProjects) {
        expect(project.latestReleaseUrl, contains('/releases/latest'));
        expect(project.defaultVersion, isNotNull);
        expect(project.defaultVersion, startsWith('v'));
      }
    });
  });

  group('KobaltRelease', () {
    test('parses json and selects primary installer asset', () {
      final json = {
        'tag_name': 'v2.0.1',
        'html_url': 'https://github.com/kobaltgit/minibin/releases/tag/v2.0.1',
        'assets': [
          {
            'name': 'MiniBin_v2.0.1.zip',
            'browser_download_url': 'https://github.com/kobaltgit/minibin/releases/download/v2.0.1/MiniBin_v2.0.1.zip',
            'size': 5000000,
          },
          {
            'name': 'MiniBin_v2.0.1_x64_en-US.msi',
            'browser_download_url': 'https://github.com/kobaltgit/minibin/releases/download/v2.0.1/MiniBin_v2.0.1_x64_en-US.msi',
            'size': 6000000,
          },
        ],
      };

      final release = KobaltRelease.fromJson(json);
      expect(release.tagName, equals('v2.0.1'));
      expect(release.primaryAsset?.name, equals('MiniBin_v2.0.1_x64_en-US.msi'));
      expect(release.downloadUrl, equals('https://github.com/kobaltgit/minibin/releases/download/v2.0.1/MiniBin_v2.0.1_x64_en-US.msi'));
    });
  });

  group('KobaltNavBar Widget', () {
    testWidgets('renders brand title and theme switcher', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool isDark = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return KobaltNavBar(
                  project: KobaltProjectId.peekIt,
                  version: 'v1.0.0',
                  isRussian: true,
                  onLanguageToggle: () {},
                  isDark: isDark,
                  onThemeToggle: () => setState(() => isDark = !isDark),
                  navLinks: [
                    KobaltNavLink(label: 'Возможности', onTap: () {}),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Verify Brand name is rendered
      expect(find.text('PeekIt'), findsOneWidget);
      // Verify Nav link is rendered
      expect(find.text('Возможности'), findsOneWidget);
      // Verify Theme toggle icon button is rendered
      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

      // Tap theme toggle
      await tester.tap(find.byIcon(Icons.light_mode_rounded));
      await tester.pumpAndSettle();

      // Should switch to dark mode icon
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    });
  });
}
