

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/home/core/controller/words_controller.dart';
import 'package:novel_oversea/home/core/view/bottom_view.dart';
import 'package:novel_oversea/home/create/bean/novel_create_bean.dart';
import 'package:novel_oversea/home/create/view/novel_create_cell.dart';
import 'package:novel_oversea/home/core/page/novel_base_page.dart';

import '../../../global/routes/app_pages.dart';
import '../../../global/ui/colors.dart';
import '../../main/view/guide_mask_view.dart';
import '../controller/novel_create_controller.dart';

// ignore: must_be_immutable
class NovelCreatePage extends NovelBasePage {
  NovelCreatePage({super.key});

  @override
  NovelCreateController get controller => Get.find<NovelCreateController>();

  @override
  String get title => controller.type!.title;

  @override
  Widget buildActions(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(12.w),
        child: ByText.text(
          bgColor: Colors.transparent,
          textColor: ByColor.colorC1,
          fontWeight: FontWeight.w500,
          fontSize: 14.sp,
          text: 'Record',
        ),
      ),
      onTap: () {
          Get.toNamed(Routes.novelRecord, arguments: {'type': controller.type});
      },
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Obx(() => MultiStatusView(
      currentStatus: controller.statusType.value,
      action: () {
        controller.fetchNovelConfig();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          children: [
            buildStepView(),
            SizedBox(
              height: 12.w,
            ),
            _buildItemsView(),
            if(!controller.isGuide!)
            Obx(() => BottomView(
              padding: 0,
              words: controller.words.getWords(WordsType.total, controller.chapterNum.value, novelType: controller.type!),
              nextBtnText: controller.type == CreationType.longNovel ? 'Create Book' : 'Create Story',
              ///下一步
              nextStep: (){
                controller.createNovel();
            },)),
          ],
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !controller.isGuide!,
      child: Stack(
        children: [
          super.build(context),
          if (controller.isGuide!) 
            GuideBottomMaskView(
              btnTitle: 'Create Story',
              offY: 20.w,
              onMaskTap: () {
                controller.createNovel(checkTryout: true);
              }),
        ],
      ),
    );
  }

  ///随机生成
  Widget autoGenerateView() {
    return Container(
      height: 44.w,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      decoration: BoxDecoration(
          color: ByColor.colorBg2,
          borderRadius: BorderRadius.circular(10.w),
          border: Border.all(color: ByColor.color2E3038, width: 1.w)),
      child: Padding(
        padding: EdgeInsets.all(12.0.w),
        child: Row(
          children: [
            ByText.text(
                textColor: Colors.white, fontSize: 14, text: 'No idea? try random!'),
            const Spacer(),
            GestureDetector(
              onTap: () {
                ///随机生成
                controller.randomGenerate();
              },
              child: Row(
                children: [
                  ByText.text(
                      textColor: controller.isProfessionalMode.value ? ByColor.colorPro : ByColor.colorC1,
                      fontSize: 14,
                      text: 'Random'),
                  SizedBox(
                    width: 4.w,
                  ),
                  Image.asset(
                    'assets/home/novel/icon_novel_detail.png',
                    width: 12.w,
                    height: 12.w,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  ///创建元素
  Widget _buildItemsView() {
    return Expanded(
      child: CustomScrollView(
        controller: controller.scroll,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: autoGenerateView(),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 12.w,
          ),
        ),
        //结果展示页
        const SliverToBoxAdapter(
          child: CreateResultView(),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 12.w,
          ),
        ),
        // 列表项
        Obx(() => SliverToBoxAdapter(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.itemList.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                NovelCreateBean item = controller.itemList[index];
                  return Padding(
                    padding: EdgeInsets.only(top: index == 0 ? 0 : 6.w, bottom: 6.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w,),
                      decoration: BoxDecoration(
                        color: ByColor.colorBg2,
                        borderRadius: BorderRadius.circular(10.w),
                      ),
                      child: _buildCell(index, item)),
                  );
              },
            ),
        )),
      ],
    ));
  }


  ///创建cell，当内嵌cell时需要传入父级的Key来更新选择数据
  Widget _buildCell(int index, NovelCreateBean item, {NovelCreateBean? parentBean}) {
    switch (item.style) {
      ///文本和数字输入框
      case 1:
      case 11:
      case 21:
        return NovelTextInputCell(
          key: controller.getItemKey(item.name!),
          title: item.name,
          max: item.max,
          min: item.min,
          normalValue: item.selectedValue,
          hintText: item.placeholder,
          type: item.style == 1
              ? InputType.text
              : item.style == 21
                  ? InputType.number
                  : InputType.longText,
          inputValueChanged: (p0) {
            controller.updateChooseData(null, p0, item);
          },
          createAction: () {
            controller.gotoAIWrite(item);
          },
        );
      ///数量选择
      case 22:
        return ChapterNumChooseCell(
          key: controller.getItemKey(item.name!),
          title: item.name,
          min: item.min,
          max: item.max,
          isPro: controller.isProfessionalMode.value,
          selectedValue: item.selectedValue,
          numChanged: (p0) {
            controller.updateChooseData(null, p0, item);
          },
        );

      ///标签选择框
      case 32:
      case 42:
        final tags = item.items?.values.map((e) => e.toString()).toList();
        final selectedTags = controller.getMultipleTags(item, parentBean: parentBean);
        return TagsCreateCell(
          title: item.name,
          key: controller.getItemKey(item.name!),
          tags: tags,
          isPro: controller.isProfessionalMode.value,
          selectedItems: selectedTags,
          expanded: index != 0 || parentBean?.style == 51,
          selectStrings: (value) {
            controller.updateChooseData(parentBean, value.mapValues(item.items!), item);
          },
        );
      ///内嵌选择
      case 51:
        List<NovelCreateBean>? itemList2 = item.modules;
        return ListView.builder(
            key: controller.getItemKey(item.name!),
            shrinkWrap: true,
            itemCount: itemList2!.length + 1,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.w,),
                    ByText.text(
                      textColor: ByColor.colorF1, fontSize: 16, fontWeight: FontWeight.w500, text: item.name!),
                  ],
                );
              }
              NovelCreateBean bean = itemList2[index - 1];
              return Obx(() =>_buildCell(index - 1, bean, parentBean: item));
            });
      ///角色类型选择
      case 61:
        return RoleCreateCell(
          key: controller.getItemKey(item.name!),
          count: controller.roleCount.value,
          title: item.name,
          selectedValue: item.selectedValue,
          changed: (p0) {
            controller.updateChooseData(null, p0, item);
          },);
      default:
        return Container();
    }
  }
}
