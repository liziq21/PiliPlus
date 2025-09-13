import 'dart:io' show Platform;

//import 'package:PiliPlus/build_config.dart';
import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/ua_type.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class Update {
  // 检查更新
  static Future<void> checkUpdate([bool isAuto = true]) async {
    
    
  }

  // 下载适用于当前系统的安装包
  static Future<void> onDownload(data) async {}
    
}
