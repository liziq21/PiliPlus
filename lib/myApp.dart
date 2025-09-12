import 'dart:io';

import 'package:PiliPlus/build_config.dart';
import 'package:PiliPlus/common/widgets/custom_toast.dart';
import 'package:PiliPlus/models/common/theme/theme_color_type.dart';
import 'package:PiliPlus/router/app_pages.dart';
import 'package:PiliPlus/utils/app_scheme.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/theme_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static ThemeData? darkThemeData;

  @override
  Widget build(BuildContext context) {
    Color brandColor = colorThemeTypes[Pref.customColor].color;
    bool isDynamicColor = Pref.dynamicColor;
    FlexSchemeVariant variant = FlexSchemeVariant.values[Pref.schemeVariant];

    // 强制设置高帧率
    if (Platform.isAndroid) {
      late List<DisplayMode> modes;
      FlutterDisplayMode.supported.then((value) {
        modes = value;
        var storageDisplay = GStorage.setting.get(SettingBoxKey.displayMode);
        DisplayMode? displayMode;
        if (storageDisplay != null) {
          displayMode = modes.firstWhereOrNull(
            (e) => e.toString() == storageDisplay,
          );
        }
        displayMode ??= DisplayMode.auto;
        FlutterDisplayMode.setPreferredMode(displayMode);
      });
    }
    
    return DynamicColorBuilder(
      builder: ((ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme? lightColorScheme;
        ColorScheme? darkColorScheme;
        if (lightDynamic != null && darkDynamic != null && isDynamicColor) {
          // dynamic取色成功
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // dynamic取色失败，采用品牌色
          lightColorScheme = SeedColorScheme.fromSeeds(
            primaryKey: brandColor,
            brightness: Brightness.light,
            variant: variant,
            // dynamicSchemeVariant: dynamicSchemeVariant,
            // tones: FlexTones.soft(Brightness.light),
          );
          darkColorScheme = SeedColorScheme.fromSeeds(
            primaryKey: brandColor,
            brightness: Brightness.dark,
            variant: variant,
            // dynamicSchemeVariant: dynamicSchemeVariant,
            // tones: FlexTones.soft(Brightness.dark),
          );
        }

        // 图片缓存
        // PaintingBinding.instance.imageCache.maximumSizeBytes = 1000 << 20;
        
        return GetMaterialApp(
          // showSemanticsDebugger: true,
          title: 'PiliPlus',
          theme: ThemeUtils.getThemeData(
            colorScheme: lightColorScheme,
            isDynamic: lightDynamic != null,
            variant: variant,
          ),
          darkTheme: ThemeUtils.getThemeData(
            colorScheme: darkColorScheme,
            isDynamic: darkDynamic != null,
            isDark: true,
            variant: variant,
          ),
          themeMode: Pref.themeMode,
          localizationsDelegates: const [
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          locale: const Locale("zh", "CN"),
          supportedLocales: const [Locale("zh", "CN"), Locale("en", "US")],
          fallbackLocale: const Locale("zh", "CN"),
          getPages: Routes.getPages,
          initialRoute: '/',
          builder: FlutterSmartDialog.init(
            toastBuilder: (String msg) => CustomToast(msg: msg),
            loadingBuilder: (msg) => LoadingWidget(msg: msg),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(Pref.defaultTextScale),
                ),
                child: child!,
              );
            },
          ),
          navigatorObservers: [
            FlutterSmartDialog.observer,
            PageUtils.routeObserver,
          ],
        );
      }),
    );
  }
}
