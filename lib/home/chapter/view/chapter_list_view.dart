
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novel_oversea/core/ui/widget/by_button.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/home/core/request/novel_request.dart';
import 'package:novel_oversea/home/outline/page/novel_outline_page.dart';
import 'package:novel_oversea/me/user/user.dart';
import '../../../global/ui/colors.dart';
import '../bean/novel_chapter_bean.dart';

class ChapterListView extends StatelessWidget {
  ChapterListView(
      {super.key,
      this.action,
      this.length = 0,
      this.reverse = false,
      this.showReverse = true,
      this.reverseAction,
      this.retry,
      this.itemList});

  ///小说正文
  final List<ChapterBean>? itemList;

  ///事件action,当前章节数据与点击的序列号
  final Function(ChapterBean, int)? action;

  ///长度
  final int? length;

  ///正序与倒序
  final bool? reverse;

  ///是否显示正序倒序
  final bool? showReverse;

  ///正倒序action
  final Function(bool)? reverseAction;

  ///重新生成
  final Function()? retry;

  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return _buildChapterView();
  }

  ///生成章节目录
  Widget _buildChapterView() {
    return Container(
      decoration: BoxDecoration(
        color: ByColor.colorBg2,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        children: [
          if(showReverse!)
          Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              height: 45.w,
              child: Row(
                children: [
                  ByText.text(
                    text: 'Contents',
                    textColor: Colors.white,
                    fontSize: 15,
                  ),
                  const Spacer(),
                  ByButton.iconButton(
                    title: reverse! ? 'Ascending' : 'Reverse',
                    icon: Image.asset(
                      'assets/global/common/icon_switch_column.png',
                      width: 15,
                      height: 15,
                      fit: BoxFit.cover,
                    ),
                    backgroundColor: Colors.transparent,
                    titleColor: ByColor.colorC1,
                    fontSize: 13.sp,
                    onPressed: () {
                      reverseAction?.call(!reverse!);
                    },
                  ),
                ],
              ),
            ),
          SizedBox(
            height: length! * 66.w,
            child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: length!,
                itemBuilder: (context, index) {
                  return ChapterListCell(
                    bean: itemList![index],
                    action: () {
                      final int row = index;
                      action?.call(itemList![row], row);
                    },);
                },
                separatorBuilder: (context, index) {
                  return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Container(
                            height: 1,
                            decoration: const BoxDecoration(
                              color: Color(0xFF26272E),
                            ),
                          ),
                        );
                }),
          ),
        ],
      ),
    );
  }

  
}

class ChapterListCell extends StatefulWidget {
  const ChapterListCell({
    super.key,
    required this.bean,
    this.action});

  final ChapterBean bean;
  final Function()? action;

  @override
  State<ChapterListCell> createState() => _ChapterListCellState();
}

class _ChapterListCellState extends State<ChapterListCell> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildChapterCell();
  }

  ///章节cell
  Widget _buildChapterCell() {
    ChapterBean bean = widget.bean;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      height: 65.w,
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.bean.stage == 7)
                    Image.asset(
                      'assets/global/common/icon_novel_warning.png',
                      width: 16.w,
                      height: 16.w,
                    ),
                  if (widget.bean.stage == 7)
                    SizedBox(
                      width: 4.w,
                    ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: 250.w
                    ),
                    child: ByText.text(
                      text: 'Chapter ${bean.index} ${bean.title}',
                      textColor: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 4.w,
              ),
              Row(
                children: [
                  ByText.text(
                    text: '${bean.words ?? 0} characters',
                    textColor: ByColor.colorF2,
                    fontSize: 12,
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  Container(
                    width: 1,
                    height: 12.w,
                    color: const Color(0x664D4E56),
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  ByText.text(
                    text: bean.createTime ?? '',
                    textColor: ByColor.colorF2,
                    fontSize: 12,
                  ),
                ],
              )
            ],
          ),
          const Spacer(),
          _chooseNovelInfoStatus(bean),
        ],
      ),
    );
  }

  Widget _chooseNovelInfoStatus(ChapterBean bean) {
    switch (bean.stage) {
      ///生成失败
      case 7:
      case 8:
        return SizedBox(
          width: 72.w,
          height: 24.w,
          child: ByButton.textButton(
              titleColor: Colors.black,
              padding: const EdgeInsets.all(0),
              title: 'Retry',
              fontSize: 12,
              onPressed: () {
                ChapterRequest.retryChapter(
                  bean.novelID!, bean.id!,
                  onSuccess: () {
                    setState(() {
                      bean.stage = 5;
                    });
                  },
                );
              }),
        );

      ///生成中
      case 5:
        return GestureDetector(
            onTap: () => widget.action?.call(),
            child: const GenerateProgressView(
              progress: -1,
            ));

      ///等待生成
      case 1:
      case 2:
      case 3:
        return Container();
      case 4:
        return ByText.text(
            textColor: ByColor.colorF2, text: 'Pending');

      ///正常完成状态
      case 6:
        return SizedBox(
          width: 72.w,
          height: 24.w,
          child: ByButton.textButton(
              backgroundColor: ByColor.color2E3038,
              titleColor: ByColor.colorC1,
              padding: const EdgeInsets.all(0),
              title: 'View',
              fontSize: 12,
              onPressed: () {
                // userController.checkPreLogin(actionCallback: () {
                //   action?.call(bean, index);
                // });
                widget.action?.call();
              }),
        );
      default:
        return Container();
    }
  }
}
