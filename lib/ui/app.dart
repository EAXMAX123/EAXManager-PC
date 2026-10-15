import 'package:flutter/material.dart';

import '../app_info.dart';
import '../data/settings_store.dart';
import '../state/app_services.dart';
import '../services/platform_service.dart';
import 'pages/about_page.dart';
import 'pages/downloads_page.dart';
import 'pages/home_page.dart';
import 'pages/library_page.dart';
import 'pages/settings_page.dart';
import 'theme.dart';
import 'widgets/desktop_window_frame.dart';
import 'widgets/mascot_navigation_bar.dart';
import 'widgets/retained_tabs.dart';
import 'widgets/sponsor_chip.dart';

class JmReaderApp extends StatelessWidget {
  const JmReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: AppServices.I.settings,
      builder: (context, settings, _) {
        return MaterialApp(
          title: AppInfo.name,
          debugShowCheckedModeBanner: false,
          themeAnimationDuration: const Duration(milliseconds: 200),
          themeMode: switch (settings.themeMode) {
            'light' => ThemeMode.light,
            'dark' => ThemeMode.dark,
            _ => ThemeMode.system,
          },
          theme: AppTheme.build(
            brightness: Brightness.light,
            seed: settings.themeSeed,
          ),
          darkTheme: AppTheme.build(
            brightness: Brightness.dark,
            seed: settings.themeSeed,
          ),
          home: AppTheme.backgroundDecor(
            imagePath: settings.backgroundColor,
            // 电脑上套一层自绘标题栏（最小化/最大化/关闭），手机不需要
            child: PlatformService.isDesktop
                ? const DesktopWindowFrame(child: RootShell())
                : const RootShell(),
          ),
        );
      },
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _titles = ['发现', '书架', '下载', '设置', '关于'];

  /// 防止「自动检查」和「手动检查」同时把提示条弹两遍
  bool _updateBannerOpen = false;

  @override
  void initState() {
    super.initState();
    AppServices.I.pendingUpdate.addListener(_onUpdateFound);
  }

  @override
  void dispose() {
    AppServices.I.pendingUpdate.removeListener(_onUpdateFound);
    super.dispose();
  }

  /// 检查到新版本：窗口底部弹一条黑条，点「去下载」再走浏览器
  Future<void> _onUpdateFound() async {
    final update = AppServices.I.pendingUpdate.value;
    if (update == null || _updateBannerOpen || !mounted) return;
    _updateBannerOpen = true;
    // 记下来，下次启动不再自动弹同一个版本
    await AppServices.I.markUpdateNotified(update.version);
    AppServices.I.pendingUpdate.value = null;
    if (!mounted) {
      _updateBannerOpen = false;
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1B1B1F),
        elevation: 8,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 15),
        showCloseIcon: true,
        closeIconColor: Colors.white70,
        content: Row(
          children: [
            const Icon(Icons.system_update_alt, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '发现新版本 v${update.version}（当前 ${AppInfo.version}）',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (update.notes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        update.notes,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else if (update.url.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        '这次没给下载地址，到交流群里问一下最新安装包',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        action: update.url.isEmpty
            ? null
            : SnackBarAction(
                label: '去下载',
                textColor: const Color(0xFF9CC7FF),
                onPressed: () async {
                  // 先挑一条真能下到的线路（GitHub 直连在国内基本不通）
                  final target = await AppServices.I.resolveDownloadUrl(
                    update.url,
                  );
                  await PlatformService.openUrl(target);
                },
              ),
      ),
    );
    _updateBannerOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    // 只有设置了背景图才把页面背景透明化去透出图片；
    // 否则保持主题底色，避免露出 Android 窗口背景（深色模式下是纯黑）
    final hasImage = AppTheme.hasBackgroundImage(
      AppServices.I.settings.value.backgroundColor,
    );
    // 电脑上窗口是横着的，导航放左边比压在底下顺手，也能少占一条边
    final wide = MediaQuery.sizeOf(context).width >= 900;

    final content = RetainedTabs(
      index: _index,
      builders: [
        (_) => const HomePage(),
        (_) => const LibraryPage(),
        (_) => const DownloadsPage(),
        (_) => const SettingsPage(),
        (_) => const AboutPage(),
      ],
    );

    void select(int index) {
      if (index == _index) return;
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() => _index = index);
    }

    if (wide) {
      return Scaffold(
        backgroundColor: hasImage ? Colors.transparent : null,
        body: Row(
          children: [
            MascotNavigationRail(
              selectedIndex: _index,
              onDestinationSelected: select,
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
            ),
            Expanded(
              child: Column(
                children: [
                  _desktopHeader(context, hasImage),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1360),
                        child: content,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: hasImage ? Colors.transparent : null,
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 160),
          child: Text(_titles[_index], key: ValueKey(_index)),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: SponsorChip(),
          ),
        ],
        backgroundColor: hasImage ? Colors.transparent : null,
        // 标题压小、贴左上角，给下方的 TabBar / 内容让出空间
        toolbarHeight: 48,
        titleSpacing: 12,
        centerTitle: false,
        titleTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: content,
      bottomNavigationBar: MascotNavigationBar(
        selectedIndex: _index,
        onDestinationSelected: select,
      ),
    );
  }

  /// 电脑端顶栏：左边是当前页标题，右边还是那颗求赞助
  Widget _desktopHeader(BuildContext context, bool hasImage) {
    final theme = Theme.of(context);
    return Container(
      height: 54,
      color: hasImage
          ? theme.colorScheme.surface.withValues(alpha: 0.88)
          : null,
      padding: const EdgeInsets.only(left: 20, right: 14),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 160),
            child: Text(
              _titles[_index],
              key: ValueKey(_index),
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          const SponsorChip(),
        ],
      ),
    );
  }
}
