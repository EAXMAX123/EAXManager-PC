/// 应用信息
///
/// 改版本号时这里和 pubspec.yaml 的 version 要一起改。
library;

class AppInfo {
  AppInfo._();

  static const String name = 'EAX管理器';

  /// 纯 ASCII 的名字
  ///
  /// 只能用在 HTTP 请求头这类地方——头里塞中文会让整个请求非法，
  /// 服务器直接不收，表现出来就是「连不上」。
  static const String asciiName = 'EAXManager';

  static const String version = '1.0.0';
  static const int buildNumber = 1;

  /// 更新信息地址：放「最新版本号是多少」的那个小文件
  ///
  /// 电脑版自己的仓库，里面只放电脑版的压缩包。手机版的更新挂在另一个
  /// 仓库（EAXMAX123/EAXManager）上，两边互不相干，所以这里检查更新
  /// 只会看到电脑版的版本号，不会把人指去下安卓包。
  ///
  /// 用户没在设置里填别的就用这个。同一个仓库的 jsDelivr 入口会自动
  /// 作为备用一起试，见 UpdateService。
  static const String updateCheckUrl =
      'https://raw.githubusercontent.com/EAXMAX123/EAXManager-PC/main/update.json';

  /// 没填自定义地址时用的就是上面那个
  static const String defaultUpdateCheckUrl = updateCheckUrl;

  /// 形如 v1.0.1
  static String get versionText => 'v$version';

  /// 形如 v1.0.1 (2)
  static String get fullVersionText => 'v$version ($buildNumber)';
}
