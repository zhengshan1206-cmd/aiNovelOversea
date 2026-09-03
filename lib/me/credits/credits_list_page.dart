

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/page/base_page.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/widget/by_refresh.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/me/credits/credits_list_controller.dart';

// ignore: must_be_immutable
class CreditsListPage extends BasePage {
  CreditsListPage({super.key});

  final String _getxTag = UniqueKey().toString();

  @override
  String get title => 'Credits Items List';

  @override
  CreditsListController get controller => Get.put(CreditsListController(), tag: _getxTag);

  @override
  Widget buildBody(BuildContext context) {
    return Obx(() => MultiStatusView(
      emptyActionType: EmptyActionType.all,
        emptyText: 'No Records',
        currentStatus: controller.statusType.value,
        action: () {
          controller.fetchCreditsItemList(true);
        },
      child: ByRefresh.refresh(
        controller: controller.refreshManager.refreshController,
        onRefresh: () {
          controller.fetchCreditsItemList(true);
        },
        onLoad: () {
          controller.fetchCreditsItemList(false);
        },
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w,),
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.w),
              color: ByColor.colorBg2,
            ),
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(
                height: 1.h,
                color: ByColor.colorBg3,
              ),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
              final item = controller.dataList[index];
              return SizedBox(
                height: 76.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ByText.text(
                          text: item.itemDesc ?? '',
                        ),
                        SizedBox(height: 8.h),
                        ByText.text(
                          text: item.createAt ?? '',
                          fontSize: 12.sp,
                          textColor: ByColor.colorF2,
                        ),
                      ],
                    ),
                    ByText.text(
                      text: '${item.wordsNum}',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold
                    ),
                  ],
                ),
              );
            },
            itemCount: controller.dataList.length,),
          ),
        ),
      ),
    ));
  }
}