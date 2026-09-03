class APIs {

  /// 注销账户
  static const String accountCancellations = 'api/user/accountCancellations';

  /// 启动接口（游客登陆）- 获取 token
  static const String deviceInfo = 'api/user/device';

  /// 微信登陆
  static const String loginByWX = 'api/login/wx';

  /// 一键登录
  static const String oneclickv2 = 'api/login/oneclickv2';

  /// 获取归因付费页样式
  static const String payStyle = 'api/PayPage/getPayPageConfig';

  /// 获取登陆验证码
  static const String sendVCode = "api/login/sendCode";

  /// 手机号登陆
  static const String loginByPhone = "api/login/phone";

  /// 退出登陆
  static const String logout = "api/user/logout";

  /// 自功能列表
  static const String showcaseList = "api/HomeConfig/showcaseList";

  /// 推小果列表
  static const String homeHotlist = "api/tuixiaoguo/hotlist";

  /// 推小果URL
  static const String tuixiaoguoUrl = "api/Navigation/getTuixiaoguoUrl";

  /// 检查DNS
  static const String dnsCheck = "api/dns/check";

  /// 首页广播
  static const String homeBroadcast = "api/tuixiaoguo/broadcast";

  /// 首页banner
  static const String homeBanner = "api/HomeConfig/bannerList";

  /// 个人信息
  static const String loadUserInfo = "api/user/info";

  /// 设置项目
  static const String loadSettingIems = "api/user/menus";

  ///====================== VIP ======================

  /// 获取VIP套餐列表
  static const String vipHappys = "novel/vip/happys";

  /// 获取VIP权益列表
  static const String vipRights = "api/vip/rights";

  /// 获取文案提取列表
  static const String getExtractTextList = "api/ExtractText/getExtractTextList";

  /// 判断支付后是否展示客服引导弹窗
  static const checkVipGuidStaus = "api/vip/page";

  /// 创建VIP支付订单
  static const String createVipOrder = "api/vip/order";
  static const String getConfig = "api/SuperConfigs/listByGroup";
  static const String queryOrderStatus = "api/vip/query";
  static const String imageErase = "api/FileErase/imageErase";
  static const String getEraseRecords = "api/FileErase/getEraseList";

  /// 视频提取
  static const String parseShareUrl = "api/video/parseShareUrl";

  static const String videoIntroList = "api/video/videoIntroList";
  static const String speakerList = "api/dubbing/speakerList";
  static const String vipPage = "api/vip/page";
  static const String voiceStyle = "api/Commentary/getOptimizeStyles";
  static const String optimizeText = "api/Commentary/optimizeText";

  /// 文字转语音
  static const String createDubbingTask = "api/dubbing/ttsV1";

  /// 绑定手机号
  static const String bindPhone = "api/user/bindphonev2";

  /// 一键登录绑定手机号
  static const String onekeyBindPhone = "api/user/oneClickBindPhone";

  /// 视频管理列表
  static const String videoList = "api/video/getMyVideoParamsV2";

  /// 获取首页变现案例tab配置
  static const String getTabsConfig = "api/HomeConfig/getExampleTabsConfig";

  /// 鉴黄
  static const String contentsRisk = "api/risk/risk";

  /// 删除图片
  static const String batchDeletePictures = "api/QiumiImage/deleteOrders";

  /// 获取作品数量
  static const String getWorksCount = "api/user/getWorksCount";

  /// 获取用户作品
  static const String getUserWorks = 'api/user/getWorksCountArr';

  /// 推文广场
  static const String videoSquareList = "api/HomeConfig/videoSquareList";

  /// ***************************************** 智能混剪 *****************************************
  /// ***************************************** 积分权益 *****************************************

  /// 积分套餐列表
  static const scoreHappys = "api/IntegralVip/happys";

  /// 积分页面数据
  static const scoresInfo = "api/IntegralVip/page";

  /// 积分日志
  static const scoreRecords = "api/IntegralVip/logs";

  /// 创建订单
  static const createOrder = "api/IntegralVip/order";

  /// 积分创建订单
  static const createOrderv2 = "api/IntegralVip/orderv2";

  /// 查询订单状态
  static const queryOrder = "api/IntegralVip/query";

  ///公告
  static const String noticeData = "api/common/notice";

  ///ios-支付相关
  static const iosOrder = "api/vip/orderv2";
  static const iosRepair = "api/vip/iosRepair";

  ///攻略列表
  static const String strategyGuideList = "api/ComConfig/strategyGuideList";

  ///埋点上报
  static const String eventReport = "api/event/report";

  ///巨量引擎上报
  static const String seReport = "api/SolarEngine/reportAttrDetail";

  ///adjust归因上报
  static const String adjustReport = "api/Adjust/reportAttrDetail";
}
