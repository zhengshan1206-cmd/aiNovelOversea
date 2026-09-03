/*
 * @Author: duncy
 * @Date: 2025-12-23 10:08:49
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-20 10:21:41
 * @FilePath: /novel_oversea/lib/global/initiliazation/adjust_manager.dart
 * @Description: 
 */

import 'dart:io';

import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_attribution.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event_failure.dart';
import 'package:adjust_sdk/adjust_event_success.dart';
import 'package:adjust_sdk/adjust_session_failure.dart';
import 'package:adjust_sdk/adjust_session_success.dart';

import '../../core/network/apis.dart';
import '../../core/network/http_utils.dart';
import '../../core/service/logger_service.dart';

class AdjustManager {

  static const String _appToken = '5idm6reqb8u8';
  // static const String _fbAppId = '612526268552934';
  static const AdjustEnvironment _environment = AdjustEnvironment.production;
  static const AdjustLogLevel _logLevel = AdjustLogLevel.verbose;

  ///是否已经上传归因数据
  bool _uploaded = false;

  void init({String? appid, String? fbAppID}) {
    if(appid == null || appid.isEmpty) {
      appid = _appToken;
      LoggerService.sendLog(url: '/novel/log/create?security=aohlpsihnt53kasdhflkihn', tag: 'adjust', log: "Adjust Appid为空");
      // return;
    }
    AdjustConfig config = AdjustConfig(appid, _environment);
    config.logLevel = _logLevel;
    if(fbAppID != null && fbAppID.isNotEmpty) {
      config.fbAppId = fbAppID;
    }
    config.attConsentWaitingInterval = 30;
    // configure session callbacks
    config.sessionSuccessCallback = _handleSessionSuccess;
    config.sessionFailureCallback = _handleSessionFailure;
    // configure event callbacks
    config.eventSuccessCallback = _handleEventSuccess;
    config.eventFailureCallback = _handleEventFailure;
    
    // configure deeplink callback
    config.deferredDeeplinkCallback = _handleDeferredDeeplink;
    
    // configure SKAN callback
    config.skanUpdatedCallback = _handleSkanUpdate;
    Adjust.initSdk(config);
    Adjust.getAttribution().then((attribution) {
      _uploadAdjustData(attribution);
    });

    if(Platform.isIOS) {
      Adjust.requestAppTrackingAuthorization();
    }
  }

  /// handle SKAN updates
  void _handleSkanUpdate(Map<String, String> skanData) {
    print('[AdjustExample]: Received SKAN update information!');
    
    final skanFields = {
      'conversion_value': 'Conversion value',
      'coarse_value': 'Coarse value',
      'lock_window': 'Lock window',
      'error': 'Error',
    };

    skanFields.forEach((key, description) {
      if (skanData[key] != null) {
        print('[AdjustExample]: $description: ${skanData[key]}');
      }
    });
  }

  /// handle deferred deeplinks
  void _handleDeferredDeeplink(String? uri) {
    print('[AdjustExample]: Received deferred deeplink: $uri');
  }

  /// handle successful event tracking
  void _handleEventSuccess(AdjustEventSuccess eventSuccess) {
    print('[AdjustExample]: Event tracking success!');
    _logEventData('Success', eventSuccess.eventToken, eventSuccess.message, 
                 eventSuccess.timestamp, eventSuccess.adid, eventSuccess.callbackId, 
                 eventSuccess.jsonResponse, null);
  }

  /// handle failed event tracking
  void _handleEventFailure(AdjustEventFailure eventFailure) {
    print('[AdjustExample]: Event tracking failure!');
    _logEventData('Failure', eventFailure.eventToken, eventFailure.message, 
                 eventFailure.timestamp, eventFailure.adid, eventFailure.callbackId, 
                 eventFailure.jsonResponse, eventFailure.willRetry);
  }

  /// helper method to log event data
  void _logEventData(String type, String? eventToken, String? message, 
                    String? timestamp, String? adid, String? callbackId, 
                    String? jsonResponse, bool? willRetry) {
    if (eventToken != null) print('[AdjustExample]: Event token: $eventToken');
    if (message != null) print('[AdjustExample]: Message: $message');
    if (timestamp != null) print('[AdjustExample]: Timestamp: $timestamp');
    if (adid != null) print('[AdjustExample]: Adid: $adid');
    if (callbackId != null) print('[AdjustExample]: Callback ID: $callbackId');
    if (willRetry != null) print('[AdjustExample]: Will retry: $willRetry');
    if (jsonResponse != null) print('[AdjustExample]: JSON response: $jsonResponse');
  }

  /// handle successful session tracking
  void _handleSessionSuccess(AdjustSessionSuccess sessionSuccess) {
    print('____[AdjustExample]: Session tracking success!');
    _logSessionData('Success', sessionSuccess.message, sessionSuccess.timestamp, 
                   sessionSuccess.adid, sessionSuccess.jsonResponse);
  }

  /// handle failed session tracking
  void _handleSessionFailure(AdjustSessionFailure sessionFailure) {
    print('____[AdjustExample]: Session tracking failure!');
    _logSessionData('Failure', sessionFailure.message, sessionFailure.timestamp, 
                   sessionFailure.adid, sessionFailure.jsonResponse);
    
    if (sessionFailure.willRetry != null) {
      print('[AdjustExample]: Will retry: ${sessionFailure.willRetry}');
    }
  }


  /// helper method to log session data
  void _logSessionData(String type, String? message, String? timestamp, 
                      String? adid, String? jsonResponse) {
    if (message != null) print('____[AdjustExample]: Message: $message');
    if (timestamp != null) print('____[AdjustExample]: Timestamp: $timestamp');
    if (adid != null) print('____[AdjustExample]: Adid: $adid');
    if (jsonResponse != null) print('____[AdjustExample]: JSON response: $jsonResponse');
  }

  /// 数据转换
  Future<Map> _covertAdjustData(AdjustAttribution attribution) async{
    final attributionFields = {
        'trackerToken': attribution.trackerToken,
        'trackerName': attribution.trackerName,
        'campaign': attribution.campaign,
        'network': attribution.network,
        'creative': attribution.creative,
        'adgroup': attribution.adgroup,
        'clickLabel': attribution.clickLabel,
        'costType': attribution.costType,
        'costAmount': attribution.costAmount?.toString(),
        'costCurrency': attribution.costCurrency,
        'fbInstallReferrer': attribution.fbInstallReferrer,
      };
    try {
      attributionFields['googleAdId'] = await _getGoogleAdId();
      attributionFields['adid'] = await _getAdjustIdentifier();
      attributionFields['idfa'] = await _getIdfa();
      attributionFields['idfv'] = await _getIdfv();
    }
    catch(e) {
      attributionFields['googleAdId'] = '';
      attributionFields['adid'] = '';
      attributionFields['idfa'] = '';
      attributionFields['idfv'] = '';
    }
    print('_________Adjust归因 ------>>>>>$attributionFields');
    return attributionFields;
  }

  // get Google Advertising ID
  Future<String> _getGoogleAdId() async{
    if(Platform.isIOS) {
      return '';
    }
    return await Adjust.getGoogleAdId() ?? '';
  }

  /// get Adjust identifier
  Future<String> _getAdjustIdentifier() async{
    return await Adjust.getAdid() ?? '';
  }

  /// get IDFA (iOS)
  Future<String> _getIdfa() async{
    if(Platform.isAndroid) {
      return '';
    }
    return await Adjust.getIdfa() ?? '';
  }

  /// get IDFV (iOS)
  Future<String> _getIdfv() async{
    if(Platform.isAndroid) {
      return '';
    }
    return await Adjust.getIdfv() ?? '';
  }

  ///上传归因数据
  void _uploadAdjustData(AdjustAttribution attribution) async{
    final args = await _covertAdjustData(attribution);
    if(_uploaded || args.isEmpty) {
      return;
    }
    HttpUtils.post(
      APIs.adjustReport, 
      args,
      showMsgWhenFailed: false,
      success: (data){
        _uploaded = true;
      },
      fail: (code, msg) {
        LoggerService.sendLog(url: '/novel/log/create?security=aohlpsihnt53kasdhflkihn', tag: 'adjust', log: msg);
      },
    );
  }
}