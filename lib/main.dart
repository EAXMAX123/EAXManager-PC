import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app_info.dart';
import 'services/reader_window.dart';
import 'state/app_services.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 这个进程是来当阅读窗口的：只要一页阅读器，别的都不干
  final args = ReaderWindowArgs.fromEnvironment();
  if (args != null) {
    await runReaderWindow(args);
    return;
  }

  await _setupDesktopWindow();
  await AppServices.I.init();
  runApp(const JmReaderApp());
}

/// 电脑上把窗口摆好：合适的大小、标题，还有下次打开时回到上次的位置
///
/// 手机上这些完全没有，直接跳过。
Future<void> _setupDesktopWindow() async {
  if (Platform.isAndroid || Platform.isIOS) return;

  await windowManager.ensureInitialized();

  const fallback = Size(1360, 880);
  var size = fallback;
  Offset? position;
  try {
    final prefs = await SharedPreferences.getInstance();
    final width = prefs.getDouble('windowWidth');
    final height = prefs.getDouble('windowHeight');
    if (width != null && height != null) {
      size = Size(
        width.clamp(1000, 1900).toDouble(),
        height.clamp(660, 1100).toDouble(),
      );
    }
    final left = prefs.getDouble('windowLeft');
    final top = prefs.getDouble('windowTop');
    if (left != null && top != null) position = Offset(left, top);
  } on Object {
    // 读不到就用默认大小，不影响启动
  }

  final options = WindowOptions(
    size: size,
    minimumSize: const Size(1000, 660),
    // 不让插件自己居中：高分屏上它算出来的位置会把窗口顶到屏幕外，
    // 第一次开就放到左上角一点，之后每次都用用户自己拖到的位置。
    center: false,
    backgroundColor: Colors.transparent,
    title: AppInfo.name,
    // 不用系统那条标题栏：三个按钮交给 DesktopWindowFrame 自己画，
    // 免得某些机器上系统只画出关闭键、最小化和最大化是空白。
    titleBarStyle: TitleBarStyle.hidden,
  );

  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.setPosition(position ?? const Offset(60, 60));
    await windowManager.focus();
  });

  await windowManager.setPreventClose(true);
  windowManager.addListener(_DesktopWindowKeeper.instance);
}

/// 关窗前把窗口大小和位置记下来，然后立刻结束进程
///
/// 不用 windowManager.destroy()：它只是往消息队列塞一个退出消息，引擎自己
/// 收尾有时候要十几秒，这十几秒里窗口还白着挂在屏幕上点不动，看着就跟卡死
/// 一样。该存的都存完了，直接把这个进程收掉最干净，窗口立刻消失。
class _DesktopWindowKeeper with WindowListener {
  _DesktopWindowKeeper._();

  static final _DesktopWindowKeeper instance = _DesktopWindowKeeper._();

  /// 关窗流程只走一次：连点几下 ✕ 也只结束一次
  bool _closing = false;

  /// 从阅读窗口切回来时把书架刷一遍
  ///
  /// 阅读窗口是另一个进程，它写的阅读进度只有重新查一遍数据库才看得见，
  /// 不然书架上还停在上次读到的位置。
  @override
  void onWindowFocus() {
    unawaited(_refreshShelf());
  }

  Future<void> _refreshShelf() async {
    try {
      await AppServices.I.reloadLibrary();
    } on Object {
      // 还没初始化完就算了，下次切回来再刷
    }
  }

  @override
  void onWindowClose() async {
    if (_closing) return;
    _closing = true;

    try {
      // 窗口问不到大小位置也不能一直等，一秒多还没回就照旧用默认值
      await _rememberGeometry().timeout(const Duration(milliseconds: 1200));
    } on Object {
      // 记不住就算了，下次用默认大小
    }

    exit(0);
  }

  Future<void> _rememberGeometry() async {
    final prefs = await SharedPreferences.getInstance();
    final size = await windowManager.getSize();
    final position = await windowManager.getPosition();
    await prefs.setDouble('windowWidth', size.width);
    await prefs.setDouble('windowHeight', size.height);
    await prefs.setDouble('windowLeft', position.dx);
    await prefs.setDouble('windowTop', position.dy);
  }
}
