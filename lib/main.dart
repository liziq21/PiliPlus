import 'dart:io';

import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/services/account_service.dart';
import 'package:PiliPlus/services/logger.dart';
import 'package:PiliPlus/services/service_locator.dart';
import 'package:PiliPlus/utils/cache_manage.dart';
import 'package:PiliPlus/utils/date_util.dart';
import 'package:PiliPlus/utils/request_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:catcher_2/catcher_2.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await GStorage.init();
  Get.lazyPut(AccountService.new);
  HttpOverrides.global = _CustomHttpOverrides();

  await Future.wait([
    CacheManage.autoClearCache(),
    if (Pref.horizontalScreen)
      SystemChrome.setPreferredOrientations(
        //支持竖屏与横屏
        [
          DeviceOrientation.portraitUp,
          // DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      )
    else
      SystemChrome.setPreferredOrientations(
        //支持竖屏
        [
          DeviceOrientation.portraitUp,
        ],
      ),
    setupServiceLocator(),
  ]);

  Request();
  Request.setCookie();

  SmartDialog.config.toast = SmartConfigToast(
    displayType: SmartToastType.onlyRefresh,
  );

  if (Pref.enableLog) {
    // 异常捕获 logo记录
    String buildConfig =
        '''\n
Build Time: ${DateUtil.format(BuildConfig.buildTime, format: DateUtil.longFormatDs)}
Commit Hash: ${BuildConfig.commitHash}''';
    final Catcher2Options debugConfig = Catcher2Options(
      SilentReportMode(),
      [
        FileHandler(await LoggerUtils.getLogsPath()),
        ConsoleHandler(
          enableDeviceParameters: false,
          enableApplicationParameters: false,
          enableCustomParameters: true,
        ),
      ],
      customParameters: {
        'BuildConfig': buildConfig,
      },
    );

    final Catcher2Options releaseConfig = Catcher2Options(
      SilentReportMode(),
      [
        FileHandler(await LoggerUtils.getLogsPath()),
        ConsoleHandler(
          enableCustomParameters: true,
        ),
      ],
      customParameters: {
        'BuildConfig': buildConfig,
      },
    );

    Catcher2(
      debugConfig: debugConfig,
      releaseConfig: releaseConfig,
      runAppFunction: () {
        runApp(const MyApp());
      },
    );
  } else {
    runApp(const MyApp());
  }

  // 小白条、导航栏沉浸
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  RequestUtils.syncHistoryStatus();
  PiliScheme.init();
}

class _CustomHttpOverrides extends HttpOverrides {
  final badCertificateCallback = kDebugMode || Pref.badCertificateCallback;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context)
      // ..maxConnectionsPerHost = 32
      ..idleTimeout = const Duration(seconds: 15);
    if (badCertificateCallback) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    }
    return client;
  }
}
