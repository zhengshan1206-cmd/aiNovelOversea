
import 'package:get/get.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/ui/dialog/loading_dialog.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/widget/by_refresh.dart';
import 'package:novel_oversea/home/brief/bean/novel_bean.dart';
import 'package:novel_oversea/home/brief/controller/novel_brief_provider.dart';
import 'package:novel_oversea/home/brief/page/novel_brief_page.dart';
import 'package:novel_oversea/home/create/controller/novel_create_controller.dart';
import 'package:novel_oversea/home/record/controller/base_record_controller.dart';
import 'package:provider/provider.dart';
import '../../../core/network/novel_apis.dart';
import '../../../global/routes/app_pages.dart';
import '../../../global/routes/routes_provider_track.dart';

class NovelRecordController extends BaseRecordController {
  NovelRecordController({required super.type});
  RxList<NovelBean> novelList = <NovelBean>[].obs;

  final RefreshManager refreshManager= RefreshManager();

  @override
  void onReady() {
    super.onReady();
    fetchNovelRecordList(true);
  }

  @override
  ///更新记录管理状态
  void updateManagingStatus() {
    ///如果当前不是管理状态，点击后进入管理状态
    if (!isManaging.value) {
      isManaging.value = true;
      return;
    }
    // 如果当前是管理状态，点击后点击全选删除
    allSelected.value = !allSelected.value;
    // 取消全选状态，清空删除记录ID列表
    deleteRecordIds.clear();
    if (allSelected.value) {
      // 全选状态下，添加所有记录的ID到删除列表
      for (var record in novelList) {
        ///暂停或者已完结的小说才能被删除
        if (record.pauseStatus == 1 || record.stage == 10) {
          deleteRecordIds.add(record.id!);
        }
      }
    }
  }

  @override

  ///更新当前选择的删除记录
  void updateDeleteRecordIds(int id) {
    if (deleteRecordIds.contains(id)) {
      deleteRecordIds.remove(id);
      allSelected.value = false; // 取消全选状态
    } else {
      deleteRecordIds.add(id);
      if (deleteRecordIds.length == novelList.length) {
        allSelected.value = true; // 如果删除记录数量等于总记录数量，则全选
      }
    }
  }

  @override
  ///删除小说
  void deleteRecord(
      {void Function()? onSuccess,
      void Function(int p1, String p2)? onFailed}) {
    LoadingDialog().show(message: 'Book Deleting...');
    HttpUtils.post(
      NovelApis.deleteNovel,
      {'ids': deleteRecordIds},
      showMsgWhenFailed: false,
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          // 删除成功后，更新记录列表
          novelList
              .removeWhere((record) => deleteRecordIds.contains(record.id));
          Toast.showText(text: "Deleted Success");
          cancelManaging();
          onSuccess?.call();
          if (novelList.isEmpty) {
            statusType.value = MultiStatusType.statusEmpty;
          }
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        Toast.showText(text: msg);
      },
    );
  }

  ///根据状态值获取记录左上角标签显示
  String setStatusTag(NovelBean bean) {
    if (bean.pauseStatus != 2 && bean.stage! != 10) {
      return 'Stopped';
    }
    if (bean.contentStage == 4) {
      return 'Content Failed';
    }
    if (bean.chapterStage == 4) {
      return 'Chapter Failed';
    }
    switch (bean.stage) {
      case 3:
        return 'Inspiration Failed';
      case 6:
        return 'Outline Failed';
      case 9:
        return 'Stopped';
      default:
        return 'Finished';
    }
  }

  ///跳转页面
  void gotoPage(
    NovelBean bean, {
    bool? goNovelHome = false,
    int? stage,
  }) {

    ///当前想要操作的小说ID
    int clickID = bean.id!;
    if (goNovelHome == true) {
      Get.toNamed(Routes.novelHome, arguments: {
        'id': clickID,
        "stage": stage,
      })!
          .then((_) {
        updateNovel(clickID);
      });
      return;
    }

    ///进入灵感生成页
    if (bean.stage! <= 4) {
      final provider = BriefDetailProvider();
      ProviderPageTrackerManager.trackProviderPage(
        pageId: '/novel_brief_page',
        widget: ChangeNotifierProvider(
          create: (context) => provider,
          child: NovelBriefPage(novelID: clickID),
        ),
        after: () {
          updateNovel(clickID);
        },
      );
    }

    ///大纲页
    else if (bean.stage! <= 8) {
      Get.toNamed(Routes.novelCreateOutline, arguments: {'novelID': clickID})!
          .then((_) {
        updateNovel(clickID);
      });
    }
  }

  ///用户操作完小说后更新该小说的状态
  void updateNovel(int novelID) {
    HttpUtils.get(
      NovelApis.novelInfo,
      {'id': novelID},
      success: (data) {
        if (data['status'] == 200) {
          NovelBean novelBean = NovelBean.fromJson(data['data']);
          try {
            ///被删除
            if (novelBean.id == null) {
              novelList.removeWhere(
                (record) => record.id == novelID,
              );
              if (novelList.isEmpty) {
                statusType.value = MultiStatusType.statusEmpty;
              }
              return;
            }
            int index =
                novelList.indexWhere((element) => element.id == novelID);
            if (index != -1) {
              novelList[index] = novelBean; // 更新列表中的对应项
            }
          } catch (e) {
            throw Exception('更新小说状态失败: $e');
          }
        }
      },
    );
  }

  ///获取记录列表
  void fetchNovelRecordList(bool isRefresh,) {
    if (isRefresh) {
      if (novelList.isEmpty) {
        statusType.value = MultiStatusType.statusLoading;
      }
      refreshManager.pageHelper.resetPage(); // 如果是刷新操作，清空当前列表
    }
    HttpUtils.get(
      NovelApis.novelRecord,
      {
        'page_size': refreshManager.pageHelper.row, // 每页数量
        'page': refreshManager.pageHelper.page, // 页数
        'type': type == CreationType.longNovel ? 1 : 2
      },
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"]["data"] ?? [];
          List<NovelBean> beans = List<NovelBean>.from(items.map(
            (ele) => NovelBean.fromJson(ele),
          ));
          if (isRefresh) {
            novelList.value = beans; // 刷新时清空列表
          } else {
            novelList.addAll(beans); // 加载更多时追加数据
          }

          if (novelList.isEmpty) {
            statusType.value = MultiStatusType.statusEmpty;
          } else {
            statusType.value = MultiStatusType.statusContent;
          }
          refreshManager.pageHelper.addPage();

          final hasMore =
              beans.length < refreshManager.pageHelper.row ? false : true;
          refreshManager.refreshSuccess(isRefresh, hasMore);
        } else {
          if (novelList.isEmpty) {
            statusType.value = MultiStatusType.statusNoNetWork;
          }
        }
      },
      fail: (code, msg) {
        if (novelList.isEmpty) {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
        // refreshManager.refreshFailed(isRefresh);
        Toast.showText(text: msg);
      },
    );
  }
}
