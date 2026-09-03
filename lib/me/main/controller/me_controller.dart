
import 'package:get/get.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/network/novel_apis.dart';
import 'package:novel_oversea/core/service/words.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/global/launch/controller/launch_manager.dart';
import 'package:novel_oversea/me/main/bean/record_bean.dart';
import 'package:novel_oversea/me/user/user.dart';
import 'package:novel_oversea/me/user/user_bean.dart';

class MeController extends GetxController {
  ///用户信息
  final UserController _userController = Get.find<UserController>();

  // 将 userInfo 转换为响应式数据
  final Rx<UserInfoBean?> _userInfo = Rx<UserInfoBean?>(null);
  UserInfoBean? get userInfo => _userInfo.value;

  ///记录统计
  Rx<RecordBean?> recordBean = Rx<RecordBean?>(null);


  @override
  void onInit() {
    super.onInit();
    // 初始化时获取用户信息
    _updateUserInfo();
    // 监听 UserController 中的 userInfoBean 变化
    ever(_userController.userInfoBean, _updateUserInfo);
  }

  // 更新用户信息
  void _updateUserInfo([UserInfoBean? info]) {
    _userInfo.value = info ?? _userController.userInfoBean.value;
    getNovelCreateCount();
  }

  ///获取用户当前字数包字数
  ///是否需要显示详细字数
  String getUserWords({bool? needDetail = false}) {
    final words = userInfo?.wordsPack != null ? '${userInfo?.wordsPack}' : '0';
    if (needDetail!) {
      return words;
    }
    return WordsService.wordsDisplay(words);
  }

  ///根据标题匹配跳转协议
  void getProtocolByTitle(String title) {
    GlobalController.instance.config.goPrivacyPageWithTitle(title);
  }

  ///记录统计
  void getNovelCreateCount() {
    HttpUtils.post(NovelApis.getNovelCreateCount, {}, success: (data) {
      recordBean.value = RecordBean.fromJson(data['data']);
    }, fail: (code, msg) {
      Toast.showText(text: msg);
    });
  }

  ///更新信息
  void updateUserInfo() {
    _userController.reloadUserInfo();
    _updateUserInfo();
  }

  ///获取用户vip类型
  String getUserVipTypeString() {
    return userInfo?.vipLevel != null && userInfo!.vipLevel <= 30
        ? 'monthly'
        : userInfo?.vipLevel != null &&
              userInfo!.vipLevel > 30 &&
              userInfo!.vipLevel <= 365
        ? 'year'
        : 'lifelong';
  }
}
