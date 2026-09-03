/*
 * @Author: cold-x
 * @Date: 2025-05-14 17:05:39
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-31 20:17:00
 * @FilePath: /novel_oversea/lib/me/aboutus/controller/about_us_controller.dart
 * @Description: 
 */

import 'package:get/get.dart';
import 'package:novel_oversea/core/cache/daily_cache_manager.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/global/const/const_string.dart';
import 'package:novel_oversea/global/const/consts.dart';
import 'package:novel_oversea/me/aboutus/bean/version_update_bean.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/network/file_download.dart';
import '../../../core/network/novel_apis.dart';
import '../../../core/util/by_package_utils.dart';
// import 'package:path_provider/path_provider.dart';

class AboutUsController extends GetxController {


  List<String> aboutUsList = [
    "版本更新",
    "Privacy Policy",
    "User Agreement",
    "Member Service Agreement",
  ];

  // Rx<VersionUpdateBean>? bean;
  var bean = Rx<VersionUpdateBean?>(null);

  ///当前App版本号
  Rx<String> version = ''.obs;
  ///apk下载进度
  Rx<int> progress = 0.obs;
  ///apk下载安装状态 0、默认状态  1、下载中  2、安装中
  Rx<int> isLoadingApk = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getVersion();
  }


  ///是否需要弹窗
  Future<bool> checkUpgrade() async{
    if(bean.value != null){
      ///强制更新
      if(bean.value?.type == 3) {
        return true;
      }
      ///强提示更新
      else if(bean.value?.type == 2) {
        ///获取更新频次
        DailyManagerType type = bean.value!.frequency.toDailyManagerType();
        bool showDialog = await DailyManager.shouldShowPopup(ConstString.kAppVersionDialog, type: type);
        if(showDialog) {
          DailyManager.recordPopupDate(ConstString.kAppVersionDialog, type: type);
          return true;
        }
      }
    }
    return false;
  }

  ///获取当前版本号信息
  void getVersion() async {
    version.value = await ByPackageUtils.version();
  }

  //跳转到对应的页面
  void jumpToPage(int index) {
    switch (index) {
      case 0:
        showUpdateDialog();
        break;
      case 1:
        Get.toNamed('/privacy');
        break;
      case 2:
        Get.toNamed('/userAgreement');
        break;
      case 3:
        Get.toNamed('/vipAgreement');
        break;
    }
  }

  void fetchVersionInfo({
    void Function()? onSuccess
  }) {
    HttpUtils.get(
      NovelApis.appUpgrade,
      {},
      success: (data) {
        if(data['status'] == 200) {
          if(data['data']!.isNotEmpty) {
            bean.value = VersionUpdateBean.fromJson(data['data']);
          }
          onSuccess?.call();
        }
      });
  }

  // 显示版本更新对话框
  void showUpdateDialog() async {
    if (bean.value != null) {
      // 版本更新
      // 跳转到 App Store（外部应用模式）
      launchUrl(
        Uri.parse(Consts.appStoreUrl),
        mode:
            LaunchMode.externalApplication,
      );
      // Get.dialog(
      //   VersionUpdatePage(),
      //   barrierDismissible: false
      // );
      return;
    }
    Toast.showText(text: 'The version is new.');
  }

  void downLoadApp(String url, {void Function()? onSuccess}) async{
    isLoadingApk.value = 1;
    FileDownloader.downloadWordFile(
        url: url,
        fileName: 'xsczjl.apk',
        onProgress: (p0) {
          progress.value = (p0 * 100).floor();
          print('_____下载中___${progress.value}');
        },
        done: (file) {
          isLoadingApk.value = 2;
          _installApk(file, onSuccess: onSuccess);
        },
        failed: () {
          isLoadingApk.value = 0;
          Toast.showText(text: 'Download Failed');
        });
  }

  Future<void> _installApk(String filePath, {void Function()? onSuccess}) async {
    // 检查文件是否存在
    // final file = File(filePath);
    // if (!await file.exists()) {
    //   throw Exception('APK文件不存在');
    // }
    // // 打开文件以触发安装
    // final result = await OpenFilex.open(filePath);
    // if (result.type != ResultType.done) {
    //   throw Exception('无法打开安装文件: ${result.message}');
    // }
    // onSuccess?.call();
    // isLoadingApk.value = 0;
  }
}