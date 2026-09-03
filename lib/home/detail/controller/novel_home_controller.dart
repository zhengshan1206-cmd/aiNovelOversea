

import 'package:get/get.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/ui/dialog/by_dialog_util.dart';
import 'package:novel_oversea/core/ui/dialog/loading_dialog.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/widget/by_refresh.dart';
import 'package:novel_oversea/global/routes/routes_provider_track.dart';
import 'package:novel_oversea/home/brief/bean/novel_bean.dart';
import 'package:novel_oversea/home/brief/controller/novel_brief_provider.dart';
import 'package:novel_oversea/home/brief/page/novel_brief_page.dart';
import 'package:novel_oversea/home/chapter/bean/novel_chapter_bean.dart';
import 'package:novel_oversea/home/chapter/controller/novel_detail_provider.dart';
import 'package:novel_oversea/home/chapter/page/novel_detail_page.dart';
import 'package:novel_oversea/home/core/controller/words_controller.dart';
import 'package:novel_oversea/home/core/request/novel_request.dart';
import 'package:novel_oversea/home/detail/controller/novel_manager_controller.dart';
import 'package:novel_oversea/me/user/user.dart';
import 'package:provider/provider.dart';
import '../../../core/network/novel_apis.dart';
import '../../../global/launch/controller/launch_controller.dart';
import '../../../global/routes/app_pages.dart';

///小说详情页来源
enum NovelHomeSourceType {
  ///默认模式，用户小说详情页
  normal,

  ///广场页
  square,

  ///引导页
  guide,
}

class NovelHomeController extends GetxController {

  ///内容状态
  Rx<MultiStatusType> statusType = MultiStatusType.statusContent.obs;

  ///启动页进入选择的小说类型
  int? selectNovelType;
  //用户个人进入时为小说id， 其他用户启动页或者浏览同款小说时为广场ID
  int novelID;

  NovelHomeController({
    this.selectNovelType,
    required this.novelID,
  });

  ///取小说数据
  var novelBean = Rx<NovelBean?>(null);

  var guideNovelBean = Rx<GuideNovelBean?>(null);

  ///小说正文列表
  RxList<ChapterBean> itemList = <ChapterBean>[].obs;

  ///当前小说的状态（生成中或者生成失败）
  ChapterBean? currentBean;

  ///是否正序倒序显示章节
  Rx<bool> reverse = false.obs;

  ///字数
  WordsController? words;

  ///用户
  UserController user = Get.find<UserController>();

  ///小说管理
  final NovelManagerController manager = Get.find<NovelManagerController>();

  final RefreshManager refreshManager = RefreshManager();
  
  @override
  void onInit() {
    super.onInit();
    fetchLaunchData();
  }

  ///加载启动数据
  void fetchLaunchData() {
    LaunchController launchController = Get.find<LaunchController>();

    ///是否有启动接口
    if (launchController.isLaunched.value) {
      statusType.value = MultiStatusType.statusContent;
      loadPageData();
    } else {
      statusType.value = MultiStatusType.statusLoading;
      launchController.appLaunch(
        onSuccess: (p0) {
          statusType.value = MultiStatusType.statusContent;
          loadPageData();
        },
        onFail: () {
          statusType.value = MultiStatusType.statusNoNetWork;
        },
      );
    }
  }

  ///加载小说管理页面数据
  void loadPageData() {
    words = Get.find<WordsController>();
    loadData(isFirstLoad: true);
  }

  ///加载小说数据
  void loadData({bool? isFirstLoad = false}) {
    refreshManager.pageHelper.resetPage();
    fetchNovelDetail(isFirstLoad: isFirstLoad!);
    fetchGeneratingChapter();
  }

  ///进入小说正文页
  void gotoNovelInfoPage(int chapterID,
      {bool isSquare = false, bool isGuide = false, int? stage}) {
    final provider = NovelDetailProvider();
    provider.novelID = novelID;
    provider.contentID = chapterID;
    provider.isSquare = isSquare;
    provider.isGuide = isGuide;
    provider.stage = stage;
    ProviderPageTrackerManager.trackProviderPage(
      pageId: '/novel_detail_page', 
      widget: ChangeNotifierProvider(
          create: (context) => provider,
          child: const NovelDetailPage(),
        ),
      after: () {
        loadData();
      },);
  }

  ///跳转页面
  void gotoPage() {
    ///进入灵感生成页
    if (novelBean.value!.stage! <= 4) {
      final provider = BriefDetailProvider();
      ProviderPageTrackerManager.trackProviderPage(
      pageId: '/novel_brief_page', 
      pushType: 1,
      widget: ChangeNotifierProvider(
          create: (context) => provider,
          child: NovelBriefPage(
              novelID: novelBean.value!.id!,
            ),
        ),
      after: () {
        loadData();
      },);
    } else if (novelBean.value!.stage! <= 8) {
      Get.toNamed(Routes.novelCreateOutline,
          arguments: {'novelID': novelBean.value!.id!})?.then((_) {
        loadData();
      });
    }
  }

  ///是否能继续生成小说
  bool canContinueGenerateNovel() {
    if (user.userInfoBean.value!.wordsPack! - novelBean.value!.continueWords! > 0) {
      return true;
    }
    return false;
  }

  ///小说是否断更
  bool isPaused() {
    ///暂停中或者暂停都算断更
    if ((novelBean.value!.pauseStatus! == 1 ||
            novelBean.value!.pauseStatus! == 3) &&
        novelBean.value!.stage != 10) {
      return true;
    }
    return false;
  }

  ///检查是否有生成失败的细纲和正文
  void checkNovelStatus() {
    if (currentBean?.stage == 7 || currentBean?.stage == 8) {
      ByDialogUtil.showPopScopeDialog(
        context: Get.context!,
        cancelBtnTitle: 'Cancel',
        confirmBtnTitle: 'Retry',
        contents: currentBean?.stage == 8
            ? 'Your credits is not enough, chapter has generated fail, please charge'
            : 'Chapter has generated fail, need retry.\nThe failed mission would not comsume credits.',
        confirmCallback: () {
          ///重新生成失败章节
          ChapterRequest.retryChapter(novelID, currentBean!.id!);
        },
        cancelCallback: () {
          Get.back();
        },
      );
    }
  }

  ///灵感是否生成失败
  void briefGenerateFailed() {
    if (novelBean.value!.stage! == 3) {
      ByDialogUtil.showPopScopeDialog(
        context: Get.context!,
        confirmBtnTitle: 'Retry',
        confirmCallback: () {
          retryBrief(novelBean.value!.id!);
        },
        cancelCallback: () {
          Get.back();
        },
      );
    }
  }

  ///小说封面重新生成
  // void redrawNovelCover() {
  //   Get.log("===novelBean=== ${novelBean.value!.toJson()}");
  //   Get.toNamed(
  //     Routes.novelCoverRedraw,
  //     arguments: {
  //       'cover': novelBean.value!.cover!,
  //       'id': novelBean.value!.id!,
  //       'module': module,
  //     },
  //   );
  // }

  ///用户作品
  ///获取小说详情
  void fetchNovelDetail({
    bool isFirstLoad = false,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    if (isFirstLoad) {
      statusType.value = MultiStatusType.statusLoading;
    }
    HttpUtils.get(
      NovelApis.novelInfo,
      {'id': novelID},
      success: (data) {
        // refreshSuccess(true, true);
        if (data['status'] == 200) {
          novelBean.value = NovelBean.fromJson(data['data']);

          ///管理页
          manager.bean = novelBean.value;
          manager.title.value = novelBean.value!.title!;

          ///小说完成时进行违禁词检测
          if (novelBean.value?.stage == 10) {
            manager.checkNovel();
          }
          briefGenerateFailed();
          statusType.value = MultiStatusType.statusContent;
          onSuccess?.call();
          fetchNovelInfoList();
        } else {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
      },
      fail: (code, msg) {
        statusType.value = MultiStatusType.statusNoNetWork;
        onFailed?.call(code, msg);
        Toast.showText(text: msg);
      },
    );
  }

  ///获取章节细纲列表页
  void fetchNovelInfoList({
    bool? isReverse = false,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    HttpUtils.get(
      NovelApis.novelDetailList,
      {
        'id': novelID,
        'page': refreshManager.pageHelper.page,
        'page_size': refreshManager.pageHelper.row,
        'order_type': isReverse! ? 'desc' : 'asc'
      },
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"]['data'] ?? [];
          List<ChapterBean> beans = List<ChapterBean>.from(items.map(
            (ele) => ChapterBean.fromJson(ele),
          ));
          if (refreshManager.pageHelper.page == 1) {
            itemList.value = beans;
            if (currentBean?.id != null &&
                currentBean!.id != itemList.first.id) {
              if (itemList.first.stage == 5) {
                itemList.removeAt(0);
              }
              itemList.insert(0, currentBean!);
            }
          } else {
            itemList.addAll(beans);
          }
          reverse.value = isReverse;
          refreshManager.pageHelper.addPage();
          final hasMore = beans.length < refreshManager.pageHelper.row ? false : true;
          refreshManager.refreshSuccess(false, hasMore);
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        onFailed?.call(code, msg);
        Toast.showText(text: msg);
      },
    );
  }

  ///暂停小说
  void pauseNovel({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    ByDialogUtil.showPopScopeDialog(
      context: Get.context!,
      contents: 'Pause the book generation, the expected words will be return back to your account, you can continue it later',
      cancelBtnTitle: 'Cancel',
      confirmBtnTitle: 'Confirm Pause',
      reverse: false,
      isDanger: true,
      confirmCallback: () {
        LoadingDialog().show(message: 'Pausing...');
        HttpUtils.post(
          NovelApis.pauseNovel,
          {'id': novelID},
          showMsgWhenFailed: false,
          success: (data) {
            LoadingDialog().dismiss();
            if (data['status'] == 200) {
              Toast.showText(text: 'Novel Paused');
              fetchNovelDetail();
              onSuccess?.call();
            }
          },
          fail: (code, msg) {
            LoadingDialog().dismiss();
            Toast.showText(text: msg);
          },
        );
      },
    );
  }

  ///继续生成暂停小说
  void continuePausedNovel({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    LoadingDialog().show(message: 'Cancel Pausing...');
    HttpUtils.post(
      NovelApis.continuePausedNovel,
      {'id': novelID},
      showMsgWhenFailed: false,
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          fetchNovelDetail();
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        Toast.showText(text: msg);
      },
    );
  }

  ///获取当前正在生成的章节数id
  void fetchGeneratingChapter({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    HttpUtils.get(
      NovelApis.generatingChapter,
      {
        'id': novelID,
      },
      success: (data) {
        if (data['status'] == 200) {
          currentBean = ChapterBean.fromJson(data['data']);
          if (currentBean?.id != null) {
            if (itemList.isEmpty || itemList.first.id != currentBean?.id) {
              if (currentBean!.index! > 1) {
                ///如果当前生成的章节不是第一章，则将其插入到第一章之前
                itemList.insert(0, currentBean!);
              }

              ///检查小说状态
              checkNovelStatus();
            }
          }
        }
      },
      fail: (code, msg) {
        onFailed?.call(code, msg);
        Toast.showText(text: msg);
      },
    );
  }

  ///重新生成灵感
  void retryBrief(
    int novelID, {
    void Function()? success,
  }) {
    LoadingDialog().show(message: 'Inspiration generating...');
    HttpUtils.post(
      NovelApis.retryBrief,
      {'id': novelID},
      showMsgWhenFailed: false,
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          success?.call();
        } else {
          Toast.showText(text: 'Inspiration generation failed');
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        Toast.showText(text: msg);
      },
    );
  }
}
