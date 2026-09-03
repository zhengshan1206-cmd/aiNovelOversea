/*
 * @Author: cold-x
 * @Date: 2025-06-09 11:11:43
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-04 15:59:50
 * @FilePath: /novel_oversea/lib/core/util/by_device_info_utils.dart
 * @Description: 
 */
import 'dart:io';

import 'package:adjust_sdk/adjust.dart';
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:novel_oversea/core/cache/byhy_aes_storage_utils.dart';
import 'package:novel_oversea/core/network/const_keys.dart';
import 'package:tuple/tuple.dart';

import 'dart:ui' as ui;
import 'dart:async';
import 'dart:convert';

// import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;

class ByDeviceInfoUtils {
  static String getPosition() {
    return ByStorageUtils.getString(ConstKeys.kPosition) ?? '';
  }

  static void savePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     return Future.error('Location services are disabled.');
  //   }
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try
  //       // requesting permissions again (this is also where
  //       // Android's shouldShowRequestPermissionRationale
  //       // returned true. According to Android guidelines
  //       // your App should show an explanatory UI now.
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  // if (permission == LocationPermission.deniedForever) {
  //   // Permissions are denied forever, handle appropriately. 
  //   return Future.error(
  //     'Location permissions are permanently denied, we cannot request permissions.');
  // } 
  // // When we reach here, permissions are granted and we can
  // // continue accessing the position of the device.
  // print('_______定位权限: $permission');
  // final geo = await Geolocator.getCurrentPosition(
  //   locationSettings: AndroidSettings(
  //     accuracy: LocationAccuracy.medium,
  //     timeLimit: Duration(seconds: 5),
  //     forceLocationManager: true
  //   )
  // );
  // print('_______定位地址: ${geo.longitude},${geo.latitude}');
  // await ByStorageUtils.saveString(ConstKeys.kPosition, '${geo.longitude},${geo.latitude}');
}

  /// 获取系统时区字符串（例如 "Asia/Shanghai"）
  /// 获取当前时区偏移量（Duration），等价于 DateTime.now().timeZoneOffset
  static String getTimeZone() {
    // try {
    //   final tz = DateTime.now().timeZoneName;
    //   return tz;
    // } catch (e) {
    //   return 'unknown';
    // }
    return ByStorageUtils.getString(ConstKeys.kTimeZone) ?? '';
  }

  static void saveTimeZone() async{
    int hour = DateTime.now().timeZoneOffset.inHours;
    final String timezone = 'UTC${hour >=0 ? '+' : ''}$hour';
    await ByStorageUtils.saveString(ConstKeys.kTimeZone, timezone);
  }

  /// 从设备 Locale 获取国家代码（优先）
  /// 返回类似 "CN", "US"，若没有则返回 ''
  static String? getCountryFromLocale() {
    try {
      final locale = ui.PlatformDispatcher.instance.locale; // Flutter 3.7+ 推荐方式
      final country = locale.countryCode;
      return country;
    } catch (e) {
      return '';
    }
  }

  /// 从设备 Locale 获取语言代码（优先）
  /// 返回类似 "en", "zh"，若没有则返回 ''
  static String? getLanguageFromLocale() {
    try {
      final locale = ui.PlatformDispatcher.instance.locale; // Flutter 3.7+ 推荐方式
      final language = locale.languageCode;
      return language;
    } catch (e) {
      return '';
    }
  }

  /// 获取IP国家信息
  static String? getIpCountry() {
    final String country = ByStorageUtils.getString(ConstKeys.kIpCountry) ?? '';
    return country;
  }

  /// 使用 GeoIP 服务根据公网 IP 获取国家（更准确，但需公网）
  /// 示例使用 ipapi.co（免费接口有限制），也可替换为 ipinfo.io 或其它服务
  static Future<void> saveAddressByIp() async {
    try {
      final url = Uri.parse('https://ipinfo.io/json?token=c3e241f2ecc269');
      final resp = await http.get(url).timeout(Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        final country = j['country'] as String?;
        if (country != null) {
          await ByStorageUtils.saveString(ConstKeys.kIpCountry, country);
        }
        // final lon = j['loc'].split(',')[1];
        // final lat = j['loc'].split(',')[0];
        // if (lat != null && lon != null) {
        //   await ByStorageUtils.saveString(ConstKeys.kPosition, '$lon,$lat');
        // }
        print('_______ipData==>>>>>>>>$j');
      }
    } catch (e) {
      // ignore
    }
  }

  dynamic loadDeviceInfo() {
    if (Platform.isAndroid) return DeviceInfoPlugin().androidInfo;
    return DeviceInfoPlugin().iosInfo;
  }

  /// 使用 AndroidId 替代 UUID
  static Future<Tuple2<String, String>> deviceInfo() async {
    if (Platform.isAndroid) {
      // final data = await ChannelOperate.getAppDeviceInfo();
      String androidId = "";
      String oaid = "";
      androidId = await AndroidId().getId() ?? "";
      // if (data != null) {
      //   androidId = data["androidId"];
      //   oaid = data["oId"];
      // } else {
      //   final AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
      //   androidId = info.id;
      // }
      return Tuple2(oaid, androidId);
    }
    final IosDeviceInfo info = await DeviceInfoPlugin().iosInfo;
    return Tuple2("", info.identifierForVendor ?? "");
  }

  static Future<dynamic> getUserDiviceInfo() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final appVersion = ByStorageUtils.getString(ConstKeys.kAppVersion) ?? "1.0.0";
      final di = await deviceInfo();
      final googleAdid = await Adjust.getGoogleAdId() ?? '';
      final adid = await Adjust.getAdid() ?? '';
      return {
        "uuid": di.item2,
        "android": di.item2,
        "imei": di.item2,
        "oaid": di.item1,
        "brand": androidInfo.brand,
        "sys_version": androidInfo.version.release,
        "model": androidInfo.model,
        "app_versions": appVersion,
        "google_ad_id": googleAdid,
        "adjust_adid": adid,
      };
    }else if (Platform.isIOS){
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      final appVersion = ByStorageUtils.getString(ConstKeys.kAppVersion) ?? "1.0.0";
      final di = await deviceInfo();
      final idfa = await Adjust.getIdfa() ?? '';
      final idfv = await Adjust.getIdfv() ?? '';
      final adid = await Adjust.getAdid() ?? '';
      // int systemBootTime = await  BdaSignal.systemBootTime();
      // String appInstallTime = await  BdaSignal.appInstallTime();
      // String asaToken = await BdaSignal.adToken();
      ///这里oaid 在ios里取的是idfv
      // String oaid = await BdaSignal.idfv();

      // final status = await AppTrackingTransparency.requestTrackingAuthorization();
      // String systemInitialTime = await BdaSignal.getDeviceInitialTime();


      // String idfa =  await AppTrackingTransparency.getAdvertisingIdentifier();
      // log("进入到ios 获取信息 idfa=== $idfa  系统更新时间==> $appInstallTime 系统启动时间==> $systemBootTime  系统初始化时间==> $systemInitialTime");

      return {
        "uuid": di.item2,
        "boot_time": "",
        "mb_time": "",
        "asa_token":'',
        "sys_version": iosInfo.systemVersion,
        "oaid":"",
        "app_versions": appVersion,
        "model": iosInfo.utsname.machine,
        "brand": "apple",
        "idfa": idfa,
        "idfv": idfv,
        "adjust_adid": adid,
        "boot_init_time":'',
      };
    }
    return {
      "uuid": "",
      "android": "",
      "imei": "",
      "oaid": "",
      "brand": "",
      "sys_version": "",
      "model": "",
      "app_versions": "",
    };
  }
}
