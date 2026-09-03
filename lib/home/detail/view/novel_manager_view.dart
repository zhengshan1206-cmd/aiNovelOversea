/*
 * @Author: cold-x
 * @Date: 2025-06-16 11:15:32
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-12-11 14:55:54
 * @FilePath: /novel_oversea/lib/home/detail/view/novel_manager_view.dart
 * @Description: 小说首页管理页
 */




import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/view/progress_bar.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/by_screen_utils.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/detail/controller/novel_manager_controller.dart';

class NovelManagerView extends StatelessWidget {
  NovelManagerView({
    super.key});
  final NovelManagerController controller = Get.find<NovelManagerController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 213.w + ByScreenUtils.bottomSafeHeight,
      color: ByColor.colorBg1,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            height: 50.w,
            child: Row(children: [
              ByText.text(
                fontSize: 17,
                textColor: Colors.white,
                fontWeight: FontWeight.w500,
                text: 'Manage',),
              const Spacer(),
              GestureDetector(
                onTap: () => Get.back(),
                child: Image.asset(
                  'assets/global/common/btn_close.png',
                  width: 30,
                  height: 30,
                ),
              )
            ],),
          ),

          Padding(
            padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 16.w),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              clipBehavior: Clip.none,
              shrinkWrap: true,
              itemCount: controller.titles.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 7,
                crossAxisSpacing: 0,
                childAspectRatio: 375 / 150, // 宽高比
              ),
              itemBuilder: (context, index) {
                return _buildItem(index,);
              },
            ),
          ),
        ],
      ),
    );
  }

  ///管理items页
  Widget _buildItem(int index) {
    NovelManagerItem item = controller.items[index];
    return Obx(() => Opacity(
      opacity: item.isActive.value || item.downloading.value ? 1.0 : 0.3,
      child: GestureDetector(
        onTap: () => controller.clickManagerItemIndex(index),
        child: Column(
          children: [
            ///正在下载时
            item.downloading.value ? _loadingProgress(item) :
            Image.asset(
              'assets/home/novel/btn_novel_manager_$index.png',
              width: 33.w,
              height: 33.w,
            ),
            SizedBox(
              height: 7.w,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ByText.text(textColor: ByColor.colorF2, text: item.title),

                ///有违禁词时带红点
                // if(item.isActive.value && index == 3)
                // SizedBox(width: 4.w,),
                // if(item.isActive.value && index == 3)
                // Container(
                //   width: 6,
                //   height: 6,
                //   decoration: BoxDecoration(
                //     color: ByColor.colorG4,
                //     borderRadius: BorderRadius.circular(3),
                //   ),
                // )
              ],
            ),
          ],
        ),
      ),
    ));
  }

  ///管理进度下载页
  Widget _loadingProgress(NovelManagerItem item) {
    return Column(
      children: [
        ByText.text(
          textColor: ByColor.colorC1, 
          text: '${item.progress}%'),
        SizedBox(height: 10.w,),
        SizedBox(
          width: 50.w,
          height: 4.w,
          child: ProgressBar(
            progress: item.progress.value/100,
          )),
      ],
    );
  }
}