import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/network/http_utils.dart';
import 'package:novel_oversea/core/network/novel_apis.dart';
import 'package:novel_oversea/core/ui/dialog/by_dialog_util.dart';
import 'package:novel_oversea/core/ui/dialog/loading_dialog.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/util/util.dart';
import 'package:novel_oversea/home/brief/controller/novel_brief_provider.dart';
import 'package:novel_oversea/home/brief/page/novel_brief_page.dart';
import 'package:novel_oversea/home/core/controller/words_controller.dart';
import 'package:novel_oversea/home/create/bean/novel_create_bean.dart';
import 'package:novel_oversea/home/create/view/content_random_view.dart';
import 'package:novel_oversea/me/user/user.dart';
import 'package:provider/provider.dart';
import '../../../global/routes/routes_provider_track.dart';

// 扩展方法实现,获取选择的值对应的key值
extension ListMapExtension on List<String> {
  List<String> mapValues(Map<String, dynamic> sourceMap) {
    return where((key) => sourceMap.containsValue(key))
        .map((key) => sourceMap.keys.firstWhere((e) => sourceMap[e] == key))
        .toList();
  }
}

enum CreationType {
  longNovel,
  shortNovel;
}

extension CreationTypeExt on CreationType {
  String get title {
    switch (this) {
      case CreationType.longNovel:
        return "LongNovel";
      case CreationType.shortNovel:
        return "ShortNovel";
    }
  }
}

// 扩展String类转换为 CreationType
extension StringToColor on String {
  CreationType? toCreationType() {
    return CreationType.values.firstWhere((e) => e.name == this,
        orElse: () => CreationType.longNovel);
  }
}

class NovelCreateController extends GetxController {
  ///写同款参数
  Map? writeArgs;

  ///小说类型
  final CreationType? type;

  ///是否是专业版
  final bool? isProfessional;

  ///是否显示引导遮罩
  final bool? isGuide;

  NovelCreateController({
    this.type = CreationType.longNovel,
    this.writeArgs,
    this.isProfessional = true,
    this.isGuide = false,
    required source,
  });

  ///创建参数
  Map<String, dynamic> params = {};

  ///内容状态
  Rx<MultiStatusType> statusType = MultiStatusType.statusContent.obs;

  ///记录当前单选组的选择内容，以父级key为键值，选择的内容为值存储
  RxMap<String, dynamic> selectedValues = <String, dynamic>{}.obs;

  ///是否是专业版
  Rx<bool> isProfessionalMode = true.obs;

  ///创建数据列表
  RxList<NovelCreateBean> itemList = <NovelCreateBean>[].obs;

  ///字数信息
  final WordsController words = Get.find<WordsController>();

  final userController = Get.find<UserController>();

  ///选择的章节数
  Rx<int> chapterNum = 10.obs;

  ///选择结果数据
  RxMap<String, String> selectResult = <String, String>{}.obs;

  ///需要检测的违禁词内容(故事简介)
  Map<String, dynamic> novelBrief = {};

  ///绑定的globalKey，用于滚动到指定组件位置
  Map<String, GlobalKey> itemKeys = {};

  ScrollController scroll = ScrollController();

  ///主角数量
  Rx<int> roleCount = 1.obs;

  ///角色
  int roleIndex = -1;

  @override
  void onInit() {
    super.onInit();
    isProfessionalMode.value = isProfessional!;
    userController.reloadUserInfo();
    fetchNovelConfig();
    FirebaseAnalytics.instance.logEvent(
      name: 'novel_create_page_view',
      parameters: {
        'type': type == CreationType.longNovel ? 'long_novel' : 'short_novel',
      },
    );
  }

  ///获取组件globolKey
  GlobalKey getItemKey(String key) {
    if (!itemKeys.containsKey(key)) {
      itemKeys[key] = GlobalKey(debugLabel: key);
    }
    return itemKeys[key]!;
  }

  ///设置请求参数名
  String setFuncName() {
    if (type == CreationType.shortNovel) {
      if (isProfessionalMode.value) {
        return 'short_novel_professional';
      } else {
        return 'short_novel_basic';
      }
    } else if (type == CreationType.longNovel) {
      if (isProfessionalMode.value) {
        return 'long_novel_professional';
      } else {
        return 'long_novel_basic';
      }
    }
    return '';
  }

  ///更新选择结果数据
  void updateResultData(String key, dynamic value, {NovelCreateBean? item}) {
    String select = '';
    if (value is List && value.isNotEmpty) {
      select = value.first;
    } else if (value is String) {
      select = value;
    } else if (value is int) {
      select = '$value';
    }
    selectResult[key] = select;
    if (key == 'description') {
      novelBrief['content'] = value;
      novelBrief['item'] = item;
    }
  }

  ///需要显示的结果数据
  List<String> gettResultDataKeys() {
    List<String> keys = selectResult.keys.toList();
    // 1. 筛选所有前缀的元素
    List<String> allPrefixItems =
        keys.where((item) => item.startsWith('Role ')).toList();
    if (allPrefixItems.length <= 2) {
      return keys;
    }
    // 4. 找到第一个带前缀元素的索引（作为插入位置）
    int firstPrefixIndex = keys.indexOf(allPrefixItems.first);
    List<String> remainItems =
        keys.where((item) => !allPrefixItems.contains(item)).toList();
    // 5. 插入“需要移动的元素”到第一个前缀元素之后
    remainItems.insertAll(firstPrefixIndex, allPrefixItems);
    return remainItems;
  }

  ///初始化数据内容
  void initContent(List<NovelCreateBean> beans, {bool? isRandom = false}) {
    params = {'func': setFuncName(), "values": {}};
    ///如果有参数时
    if (writeArgs != null) {
      params['values'] = writeArgs;
    }
    final items = beans;
    for (NovelCreateBean item in items) {
      if ([1, 11, 21].contains(item.style)) {
        ///带参数时
        if (writeArgs != null && writeArgs!.keys.contains(item.key)) {
          item.selectedValue = writeArgs![item.key];
        } else {
          if (item.selectedValue == null || item.selectedValue.isEmpty) {
            item.selectedValue = item.normal;
            params['values'][item.key] = item.normal;
          }
        }
        updateResultData(item.name!, item.selectedValue, item: item);
      } else if ([32, 42].contains(item.style)) {
        ///带参数时
        if (writeArgs != null && writeArgs!.keys.contains(item.key)) {
          final itemKey = writeArgs![item.key];
          List<String> values = [];
          for (final key in itemKey) {
            if (item.items!.containsKey(key)) {
              values.add(item.items![key]);
            }
          }
          item.selectedValue = values;
        } else {
          ///如果是items类型，取第一个值
          String? itemKey = item.items?.keys.isNotEmpty == true
              ? item.items!.keys
                  .toList()[getIndex(isRandom!, 0, item.items!.keys.length)]
              : '';
          params['values'][item.key] = [itemKey];
          // 同步更新Item对象的selectedValue
          final String value = item.items![itemKey];
          item.selectedValue = [value];
        }
        updateResultData(item.name!, item.selectedValue);
      }

      ///数量选择
      else if ([22].contains(item.style)) {
        if (writeArgs != null && writeArgs!.containsKey(item.key)) {
          int? value;
          try {
            value = int.parse(writeArgs![item.key]);
          } catch (e) {
            value = writeArgs![item.key];
          }
          item.selectedValue = value;
        } else {
          int normal = item.min!;
          if (item.normal != null && item.normal!.isNotEmpty) {
            try {
              normal = int.parse(item.normal!);
            } catch (e) {
              throw ('');
            }
          }

          ///数量选择在最小和默认值之间随机
          item.selectedValue =
              isRandom! ? Util.randomInt(item.min!, normal + 1) : normal;
          params['values'][item.key] = item.selectedValue;

          ///更新章节数以预估消耗字数
          if (item.key == 'chapter_count') {
            chapterNum.value = item.selectedValue;
          }
        }
        updateResultData(item.name!, item.selectedValue);
      }

      ///单选组,取第一个数
      else if ([51].contains(item.style)) {
        String tagName = '';
        if (writeArgs != null && writeArgs!.containsKey(item.key)) {
          selectedValues[item.key!] = writeArgs![item.key!].first;
          final results = item.modules!
              .where((e) => writeArgs![item.key!].first.keys.contains(e.key!));
          final NovelCreateBean? bean =
              results.isNotEmpty ? results.first : null;
          if (bean != null) {
            final String key = writeArgs![item.key!].first[bean.key!].first;
            tagName = bean.items![key];
          }
        } else {
          NovelCreateBean bean =
              item.modules![getIndex(isRandom!, 0, item.modules!.length)];
          final key = bean.items?.keys
              .toList()[getIndex(isRandom, 0, bean.items!.keys.length)];
          final firstTag = [
            {
              bean.key: [key]
            }
          ];
          tagName = bean.items![key];
          if (selectedValues[item.key] == null) {
            selectedValues[item.key!] = {};
          }
          selectedValues[item.key!] = firstTag.first;
          params['values'][item.key] = firstTag;
        }
        updateResultData(item.name!, [tagName]);
      } else if ([61].contains(item.style)) {
        ///主角设定
        if (item.key == 'protagonists') {
          roleIndex = itemList.indexOf(item);
          if (writeArgs != null && writeArgs!.containsKey(item.key)) {
            item.selectedValue = writeArgs![item.key];
          }
          roleCount.value = item.selectedValue != null
              ? item.selectedValue.length
              : item.modules?.length;
          List roles = [];
          for (int i = 0; i < roleCount.value; i++) {
            ///无写同款时
            if (item.selectedValue == null) {
              final role = {
                'gender': ['male'],
                'name': ''
              };
              roles.add(role);
              updateResultData('Role ${i + 1}', 'male');
            }

            ///有写同款时
            else {
              final role = item.selectedValue[i];
              String sex = role['gender'].first;
              sex = sex == 'male'
                  ? 'male'
                  : sex == 'female'
                      ? 'female'
                      : 'generic';
              String name = role['name'] ?? '';
              updateResultData('Role ${i + 1}', '$sex $name');
            }
          }
          item.selectedValue ??= roles;
          params['values'][item.key!] = item.selectedValue;
        }
      }
      itemList[items.indexOf(item)] = item;
    }
  }

  ///单选组时获取选择标签名
  List<String>? getMultipleTags(NovelCreateBean item,
      {NovelCreateBean? parentBean, List<String>? tagList}) {
    List<String>? tags =
        tagList ?? item.items?.values.map((e) => e.toString()).toList();

    ///默认为第一个
    List<String> selectedTags = item.selectedValue ?? [tags![0]];

    ///单选组时其他非选置空，选择的高亮
    if (parentBean?.style == 51 &&
        selectedValues.keys.contains(parentBean?.key)) {
      ///置空所有选项
      selectedTags = [];

      ///设置选择的选项
      if (selectedValues[parentBean?.key]!.keys.contains(item.key)) {
        final selectedKeys = selectedValues[parentBean?.key]?[item.key];
        for (String key in selectedKeys) {
          selectedTags.add(item.items?[key]);
        }
      }
    }
    return selectedTags;
  }

  ///随机生成
  void randomGenerate() {
    writeArgs = null;
    initContent(itemList, isRandom: true);
  }

  ///获取生成序列
  int getIndex(bool isRandom, int min, int max) {
    if (!isRandom) {
      return 0;
    } else {
      return Util.randomInt(min, max);
    }
  }

  ///切换专业版和普通版
  void toggleMode() {
    ByDialogUtil.showPopScopeDialog(
      context: Get.context!,
      confirmBtnTitle: '确定切换',
      contents: isProfessionalMode.value ?  "切换至普通版已填写的内容将会清空" : "切换至专业版已填写的内容将会清空",
      confirmCallback: () {
        writeArgs = null;
        selectResult.value = {};
        updateIsProfessionnal(!isProfessionalMode.value);
      }
      );
  }

  ///更新模式,是否是专业版
  void updateIsProfessionnal(bool isProfessional) {
    isProfessionalMode.value = isProfessional;
    fetchNovelConfig();
  }

  ///AI帮我写，AI润色
  void gotoAIWrite(NovelCreateBean item) {
    userController.checkPreLogin(
      source: 'novel_create_ai_write',
      actionCallback: () {
        ///非vip跳付费页
        if (!userController.isVip) {
          userController.jumpToPayPage(source: 'novel_create_ai_write');
          return;
        }
        var args = params;

        ///字数限制
        final int words = max((item.max! * 0.8).floor(), item.min!);
        args['word_num'] = words;
        showModalBottomSheet(
          context: Get.context!,
          isDismissible: false,
          enableDrag: false,
          isScrollControlled: true,
          builder: (context) {
            return ContentRandomView(
              args: args,
              interface: NovelApis.novelCreateAIContent,
              userAction: (p0) {
                updateChooseData(null, p0, item);
              },
            );
          },
        );
      },
    );
  }

  ///校验必填项
  String? validateRequiredFields() {
    if (itemList.isEmpty) return null;
    for (NovelCreateBean item in itemList) {
      // 只对is_requisite==1的必填项进行校验
      if (item.isRequire == 1 && !itemFinished(item)) {
        return "请设定${item.name}";
      }
    }
    return null;
  }

  ///判断子选项是否完成
  bool itemFinished(NovelCreateBean item) {
    if (!params['values'].keys.contains(item.key)) {
      return false;
    }
    final value = params['values'][item.key];
    if (value is String && value.isEmpty) {
      return false;
    }
    return true;
  }

  ///校验输入数是否在范围内
  String? validateInputRange() {
    if (itemList.isEmpty) return null;
    for (NovelCreateBean item in itemList) {
      if (item.style == 22) {
        final value = params['values'][item.key];
        if (value < item.min! || value > item.max!) {
          return "${item.name}必须在${item.min}到${item.max}之间";
        }
      }
    }
    return null;
  }

  ///更新选择数据
  void updateChooseData(
      NovelCreateBean? parentBean, dynamic value, NovelCreateBean bean) {
    ///有内嵌
    if (parentBean != null) {
      selectedValues[parentBean.key!] = {bean.key: value};
      String tagName = '';
      var childParams = params['values'][parentBean.key] ?? [];

      ///如果内嵌选择没有初始化或者为单选项只能有一个数据值时
      if (childParams.isEmpty || parentBean.style == 51) {
        childParams = [
          {bean.key!: value}
        ];
        params['values'][parentBean.key] = childParams;
      }

      ///有选择时替换旧的选择值
      else {
        final results = childParams.where((e) => e.keys.contains(bean.key));
        final result = results.isNotEmpty ? results.first : null;

        ///更新已经选的数据值
        if (result != null) {
          childParams.remove(result);
          result[bean.key] = value;
          childParams.add(result);
        }

        ///添加没有选择的数据
        else {
          childParams.add({bean.key!: value});
        }
      }
      tagName = bean.items![childParams.first.values.first.first];
      updateResultData(parentBean.name!, [tagName]);
    }

    ///没有内嵌的时候直接更新数据
    else {
      ///男女选择
      if (bean.style == 61 && bean.key == 'protagonists') {
        for (var role in value) {
          String sex = role['gender'].first;
          sex = sex == 'male'
              ? 'male'
              : sex == 'female'
                  ? 'female'
                  : 'generic';
          String name = role['name'] ?? '';
          updateResultData('Role ${value.indexOf(role) + 1}', '$sex $name');
        }
        params['values'][bean.key!] = value;
        bean.selectedValue = value;
        return;
      }

      ///标签更新
      else if (bean.style == 32) {
        final String tmp = bean.items![value.first];
        bean.selectedValue = [tmp];
      } else {
        bean.selectedValue = value;
      }

      ///主角数量选择
      if (bean.key! == 'protagonist_count') {
        final List roles = params['values']['protagonists'];
        if (value > bean.max) {
          Toast.showText(text: 'Role number cannot greater than${bean.max}，Please adjust');
        } else {
          ///新增主角
          if (roleCount.value < value) {
            for (int i = 0; i < value - roleCount.value; i++) {
              roles.add({
                'gender': ['male'],
                'name': ''
              });
              updateResultData('Role ${roleCount.value + i + 1}', 'male');
            }
          }
          ///减少删除主角
          else if (roleCount.value > value) {
            for (int i = 0; i < roleCount.value - value; i++) {
              if (selectResult.containsKey('Role ${roleCount.value - i}')) {
                selectResult.remove('Role ${roleCount.value - i}');
              }
              roles.removeLast();
            }
          }
          final NovelCreateBean roleItem = itemList[roleIndex];
          roleCount.value = value;
          roleItem.selectedValue = roles;
          itemList[roleIndex] = roleItem;
        }
      }

      ///更新章节数以预估消耗字数
      if (bean.key! == 'chapter_count') {
        chapterNum.value = value;
      }
      if (bean.key! == 'enable_thinking') {
        if (value.first == 'enable') {
          ///短故事开启深度思考
          chapterNum.value = -1;
        } else {
          ///短故事关闭深度思考
          chapterNum.value = 0;
        }
      }
      params['values'][bean.key!] = value;
      updateResultData(bean.name!, bean.selectedValue, item: bean);
      if ([1, 11, 21].contains(bean.style)) {
        final int index = itemList.indexOf(bean);
        itemList[index] = bean;
      }

      Get.log('________$params');
      update();
    }
  }

  // 3. 统一的滚动方法：接收目标key，滚动到对应位置
  void scrollToTarget(String target) {
    GlobalKey targetKey = itemKeys[target] ?? getItemKey('主角设定');
    // 确保目标组件已构建
    if (targetKey.currentContext != null) {
      // 获取目标组件的位置信息
      final RenderBox renderBox =
          targetKey.currentContext!.findRenderObject() as RenderBox;
      final Offset offset = renderBox.localToGlobal(Offset.zero);

      // 执行滚动（带动画）
      scroll.animateTo(
        offset.dy + scroll.offset - kToolbarHeight - 104.w, // 减去导航栏高度，使目标对齐顶部
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
      );
    }
  }

  ///获取小说配置数据
  void fetchNovelConfig({
    void Function(dynamic)? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    statusType.value = MultiStatusType.statusLoading;
    HttpUtils.get(
      NovelApis.novelConfig,
      {
        "func": setFuncName(),
      },
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"] ?? [];
          List<NovelCreateBean> beans = List<NovelCreateBean>.from(items.map(
            (ele) => NovelCreateBean.fromJson(ele),
          ));
          itemList.value = beans;

          ///初始化参数数据
          initContent(beans);
          // typeItems.value = bean;
          statusType.value = MultiStatusType.statusContent;
          onSuccess?.call(data);
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

  ///创建小说
  void createNovel({
    bool checkTryout = false,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    bool canTry = false;
    if (checkTryout) {
      canTry = userController.couldTry;
    }
    ///加入延迟，否则输入框焦点会后执行
    Future.delayed(const Duration(microseconds: 1), () {
      // 添加空值校验（随机生成时跳过校验）
      String? validationError = validateRequiredFields();
      if (validationError != null) {
        Toast.showText(text: validationError);
        return;
      }
      // 添加范围值校验
      validationError = validateInputRange();
      if (validationError != null) {
        Toast.showText(text: validationError);
        return;
      }
       
      ///非会员并且无试用次数跳转至vip
      // if (!userController.isVip && !canTry) {
      //     userController.jumpToPayPage(source: 'novel_create');
      //     return;
      //   }

      ///字数检测
      if (!words.isWordsEnable(WordsType.total, chapterNum.value,
              novelType: type!) && !canTry) {
        userController.jumpToPayPage(source: 'novel_create_words');
        return;
      }
      createNovelRequest(canTry: canTry, onSuccess: onSuccess, onFailed: onFailed);
    });
  }

  ///创建小说请求
  void createNovelRequest({
    bool canTry = false,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    params['is_try_out'] = canTry ? 1 : 2;
    LoadingDialog().show(message: 'Book Creating...');
    HttpUtils.post(
      // type == CreationType.shortStory
      //     ? NovelApis.shortStoryCreate
      //     : NovelApis.novelCreate,
      NovelApis.novelCreate,
      params,
      showMsgWhenFailed: false,
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          userController.couldTry = false;
          int novelID = data['data']['id'];
          final provider = BriefDetailProvider();
          provider.type = type!;
          if(canTry) {
            provider.isFirstCreate = true;
          }
          ProviderPageTrackerManager.trackProviderPage(
            pageId: '/novel_brief_page',
            pushType: 1,
            widget: ChangeNotifierProvider(
              create: (context) => provider,
              child: NovelBriefPage(novelID: novelID),
            ),
          );
          FirebaseAnalytics.instance.logEvent(
            name: 'novel_created',
            parameters: {
              'type': type == CreationType.longNovel ? 'long_novel' : 'short_novel',
            },
          );
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        onFailed?.call(code, msg);
        if (code == 1003) {
          ByDialogUtil.showPopScopeDialog(
            context: Get.context!,
            contents: 'Your package is not enough, please charge',
            // contents: 'Your package is lack, Please charge${WordsService.wordsDisplay('${user.userInfo!.preDeductWp ?? 0}', unit: '万')}字，您目前的可用字数不足。',
            confirmBtnTitle: 'Charge',
            cancelBtnTitle: 'Cancel',
            confirmCallback: () {
              userController.jumpToPayPage(source: 'novel_create_words_unable');
            }
            );
          return;
        }
        /// 没有试用次数
        if (code == 1011) {
          Get.back();
        }
        Toast.showText(text: msg);
      },
    );
  }
}
