
import 'package:novel_oversea/core/network/apis.dart';

class NovelApis extends APIs {
  /*
    付费页
  */
  /// 获取VIP套餐列表
  static const String vip = "novel/order/happys";

  /// 积分套餐列表
  static const String token = "novel/integral/happys";

  /// 创建vip订单
  static const String orderCreate = "novel/order/create";

  /// 创建积分订单
  static const String tokenCreate = "novel/integral/create";

  /// 查询vip订单
  static const String orderQuery = "novel/order/query";

  /// 查询积分订单
  static const String tokenQuery = "novel/integral/query";

  /// vip订单补单
  static const String orderRepair = "novel/order/repair";

  /// iOS恢复购买
  static const String iOSRestorePurchase = "novel/order/iosRestorePurchase";

  ///公用
  /// 启动接口（游客登陆）- 获取 token
  static const String launch = 'novel/login/tourist';

  ///firebase第三方登录
  static const String firebaseLogin = 'novel/login/firebase';

  ///firebase第三方绑定
  static const String firebaseBinding = 'api/user/bindFirebase';

  /*
    首页
  */

  ///创作广场列表
  static const String homeNovelList =
      'novel/CreativeSquare/getCreativeSquareList';

  ///获取所有小说的生成进度
  static const String novelProgress = 'novel/aiNovel/getAllProgress';

  ///获取未完成的小说
  static const String unCompleteNovel = 'novel/aiNovel/tryNovelWindow';

  /*
    长文小说
  */
  ///获取小说类型
  static const String novelCategory = 'novel/config/getNovelType';

  ///获取小说对话回执
  static const String novelChatURL = 'novel/aiNovel/getChatGenerateConfig';

  ///获取小说类型
  static const String novelChatConfig = 'novel/aiNovel/queryChatGenerateConfig';

  ///长文小说配置页
  static const String novelConfig = 'novel/config/getNovelConfig';

  ///创建长文小说
  static const String novelCreate = 'novel/aiNovel/saveInfo';

  ///创建小说内容/AI帮我写、AI润色
  static const String novelCreateAIContent = 'novel/aiNovel/getRandomDesc';

  ///重新生成长文小说灵感
  static const String retryBrief = 'novel/aiNovel/retryCreateInspiration';

  ///获取小说列表记录
  static const String novelRecord = 'novel/aiNovel/getAiNovelList';

  ///获取小说详情
  static const String novelInfo = 'novel/aiNovel/getAiNovelInfo';
  static const String novelSquareInfo = 'novel/creativeSquare/getNovelInfo';

  ///创建小说大纲
  static const String createOutline = 'novel/aiNovel/createOutline';

  ///获取小说大纲列表
  static const String outlineList = 'novel/aiNovel/getOutlineList';

  ///获取小说大纲详情
  static const String outlineInfo = 'novel/aiNovel/getOutlineDetails';

  ///创建小说细纲章节
  static const String createChapter = 'novel/aiNovel/createChapterOverview';

  ///获取小说细纲章节列表
  static const String chapterList = 'novel/aiNovel/getChapterOverviewList';

  ///获取小说细纲详情
  static const String chapterInfo = 'novel/aiNovel/getChapterOverviewDetails';

  ///生成正文，一键成文
  static const String createNovelContent = 'novel/aiNovel/createMainBodyTask';

  ///正文生成失败，重新生成
  static const String retryNovelContent = 'novel/aiNovel/retryStartMainTask';

  ///获取小说正文章节列表
  static const String novelDetailList = 'novel/aiNovel/getMainBodyList';

  ///小说
  static const String novelSquareDetailList =
      'novel/creativeSquare/getNovelChapterList';

  ///广场小说
  static const String novelGuideDetailList =
      'novel/startGuide/getNovelChapterList';

  ///引导页小说

  ///获取小说当前正在生成的章节信息
  static const String generatingChapter = 'novel/aiNovel/getRunningChapterInfo';

  ///获取小说正文详情
  static const String novelDetailInfo = 'novel/aiNovel/getMainBodyDetails';
  static const String novelSquareDetailInfo =
      'novel/creativeSquare/getNovelChapterDetails';

  ///广场小说
  static const String novelGuideChapterDetails =
      'novel/startGuide/getNovelChapterDetails';

  ///引导页小说

  ///长文小说字数计算
  static const String novelWords = 'novel/aiNovel/calculateTotalWords';

  ///断更小说
  static const String pauseNovel = 'novel/aiNovel/stopMainBodyTask';

  ///继续生成暂停小说
  static const String continuePausedNovel =
      'novel/aiNovel/continueMainBodyTask';

  ///下载小说
  static const String downloadNovel = 'novel/aiNovel/exportAiNovel';

  ///修改小说信息
  static const String editNovelInfo = 'novel/aiNovel/editNovelInfo';

  ///修改小说章节信息
  static const String editChapterInfo = 'novel/aiNovel/editMainBodyInfo';

  ///删除小说
  static const String deleteNovel = 'novel/aiNovel/deleteNovel';

  ///违禁词检测
  static const String checkNovel = 'novel/aiNovel/checkAiNovel';

  ///违禁词检测列表
  static const String novelIllegalWordsList = 'novel/aiNovel/getCheckList';

  ///引导页获取引导小说
  static const String guideNovel = 'novel/startGuide/getNovelInfo';


  /*
    短故事小说
  */
  ///创建短故事小说(灵感)
  static const String shortStoryCreate = 'novel/shortAiNovel/saveInfo';

  ///短故事小说列表
  static const String shortStoryList = 'novel/shortAiNovel/getShortNovelList';

  ///短故事小说详情
  static const String shortStoryInfo = 'novel/shortAiNovel/getShortNovelInfo';

  ///短故事小说灵感重试
  static const String shortStoryRetryBrief =
      'novel/shortAiNovel/startInspiration';

  ///创建短故事小说正文
  static const String shortStoryCreateContent =
      'novel/shortAiNovel/startContent';

  ///短故事小说正文列表
  static const String shortStoryContentList =
      'novel/shortAiNovel/getContentList';

  ///短故事小说导出下载
  static const String shortStoryDownload =
      'novel/shortAiNovel/exportShortAiNovel';

  ///短故事小说分享，获取小说链接
  static const String shortStoryShare = 'novel/shortAiNovel/shareShortAiNovel';

  ///创建短故事小说内容/AI帮我写、AI润色
  static const String shortStoryAIContent = 'novel/shortAiNovel/getRandomDesc';

  ///删除短故事小说
  static const String shortStoryDelete = 'novel/shortAiNovel/deleteShortNovel';

  ///短故事小说各模块字数预估
  static const String shortStoryWords =
      'novel/shortAiNovel/calculateTotalWords';

  /*
    短故事、笔名、小说名、文案等小说工具类
  */
  ///获取标签配置信息
  static const String sendCreator = 'novel/aiText/getConfig';

  ///创建小说
  static const String createNovel = 'novel/aiText/saveInfo';

  ///获取AI文本内容详情
  static const String textDetail = 'novel/aiText/getAiTextDetails';

  ///获取列表页
  static const String creationRecord = 'novel/aiText/getAiTextList';

  ///导出文件
  static const String exportFile = 'novel/aiText/exportAiText';

  ///删除记录
  static const String deleteRecord = 'novel/aiText/delAiText';

  ///获取指定多个小说名、笔名数据
  static const String mutiNames = 'novel/aiText/getListByIds';

  ///流式输出
  static const String toolStreaming = 'novel/aiText/getAiTextStream';

  /*
    个人中心
  */

  ///协议列表
  static const String novelAppMenus = 'api/user/novelAppMenus';

  ///赠送字数
  static const String giftWordPack = 'novel/novel/giftWordPack';

  ///记录统计
  static const String getNovelCreateCount = 'novel/novel/getNovelCreateCount';

  ///获取公共配置
  static const String getCommonConfig = 'novel/config/getCommonConfig';

  ///升级更新
  static const String appUpgrade = 'api/upgrade/index';

  ///获取积分消耗列表
  static const String getIntegralConsumeList = 'novel/AiNovel/getWordsPackLog';

  ///获取是否可以试用
  static const String isAllowTryout = "novel/aiNovel/isAllowTryout";

  /*
    支付相关
  */

  ///vip运营配置
  static const String vipOperationPage = "api/PayPage/getPayPageMaterial";

  /*
    广场
  */

  ///获取分类列表
  static const String getCategoryList = 'api/comConfig/getCategoryList';

  ///获取攻略列表
  static const String getStrategyGuideList =
      'api/comConfig/getStrategyGuideList';

  ///获取攻略详情
  static const String getStrategyGuideDetail =
      'api/comConfig/getStrategyGuideDetail';

  ///AI小说广场-获取攻略列表表
  static const String getNovelGuideList = 'api/comConfig/getNovelGuideList';

  ///封面列表
  static const String getCoverList = "novel/novel/getCoverList";

  ///提交生成小说封面任务
  static const String generateCover = "novel/novel/generateCover";

  ///续写小说接口
  static const String continueWrite = "novel/aiNovel/novelContinue";

  ///通知文案
  static const String getNoticeList = "novel/config/getNoticeList";

  /*
   签到相关
  */

  /// 签到任务列表
  static const String checkinTask = "novel/TaskCenter/getTaskList";

  /// 签到
  static const String checkin = "novel/TaskCenter/checkIn";

  /// 签到任务领取奖励
  static const String checkinReward = "novel/TaskCenter/claimReward";

  /// 签到任务领取奖励记录
  static const String checkinRewardRecord = "novel/TaskCenter/rewardRecords";
  
}
