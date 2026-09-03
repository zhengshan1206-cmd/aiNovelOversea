/*
 * @Author: cold-x
 * @Date: 2025-06-06 16:28:52
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-17 14:01:56
 * @FilePath: /novel_oversea/lib/home/record/controller/base_record_controller.dart
 * @Description: 
 */

import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/dialog/by_dialog_util.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/home/create/controller/novel_create_controller.dart';

class BaseRecordController extends GetxController {
  ///创建类型
  final CreationType type;
  BaseRecordController({required this.type});


  ///内容状态
  Rx<MultiStatusType> statusType = MultiStatusType.statusContent.obs;

  ///是否处于管理状态
  Rx<bool> isManaging = false.obs;

  ///管理是否全选
  Rx<bool> allSelected = false.obs;

  ///记录列表
  RxList<dynamic> recordList = <dynamic>[].obs;

  ///删除记录表ids
  ///用于删除记录时传递的ids
  RxList<int> deleteRecordIds = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (![CreationType.longNovel, CreationType.shortNovel].contains(type)) {
      fetchRecordList(true); // 初始化时获取记录列表
    }
  }


  ///点击列表事件
  void clickCellEvent(dynamic record) {
    if (isManaging.value) {
      // 如果处于管理状态，更新删除记录ID
      updateDeleteRecordIds(record.id!);
    }
  }


  ///获取底部按钮显示文字
  String updateManagingText() {
    if (isManaging.value) {
      return allSelected.value ? "取消全选" : "全选";
    } else {
      return "管理";
    }
  }

  ///取消管理
  void cancelManaging() {
    isManaging.value = false;
    allSelected.value = false; // 取消全选状态
    deleteRecordIds.clear(); // 清空删除记录ID列表
  }

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
      for (var record in recordList) {
        deleteRecordIds.add(record.id!);
      }
    }
  }

  ///更新当前选择的删除记录
  void updateDeleteRecordIds(int id) {
    if (deleteRecordIds.contains(id)) {
      deleteRecordIds.remove(id);
      allSelected.value = false; // 取消全选状态
    } else {
      deleteRecordIds.add(id);
      if (deleteRecordIds.length == recordList.length) {
        allSelected.value = true; // 如果删除记录数量等于总记录数量，则全选
      }
    }
  }

  ///删除记录action
  void deleteRecordAction({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    if (deleteRecordIds.isEmpty) {
      Toast.showText(text: "Please select the delete books.");
      return;
    }
    ByDialogUtil.showPopScopeDialog(
      context: Get.context!,
      contents: 'Do you confirm delete these books?',
      confirmBtnTitle: 'Confirm Delete',
      reverse: false,
      confirmCallback: () {
        deleteRecord();
      });
  }

  ///批量删除记录请求
  void deleteRecord({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    
  }

  ///获取记录列表
  void fetchRecordList(bool isRefresh) {
    
  }
}
