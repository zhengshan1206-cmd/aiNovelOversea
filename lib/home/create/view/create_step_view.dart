
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/home/create/controller/novel_create_controller.dart';

enum NovelCreateStepType {
  /// 灵感生成
  brief(0),

  // 章节大纲生成
  outline(1),

  /// 章节细纲
  chapter(2),

  /// 一键成文
  novel(3);

  const NovelCreateStepType(
    this.rawValue,
  );

  final int rawValue;

  String get title {
    switch (this) {
      case NovelCreateStepType.brief:
        return "breif";
      case NovelCreateStepType.outline:
        return "outline";
      case NovelCreateStepType.chapter:
        return "chapter";
      case NovelCreateStepType.novel:
        return "content";
    }
  }

  static NovelCreateStepType fromRawValue(int rawValue) {
    for (var element in NovelCreateStepType.values) {
      if (element.rawValue == rawValue) {
        return element;
      }
    }
    return NovelCreateStepType.brief;
  }
}

class CreateStepView extends StatelessWidget {
  const CreateStepView({
    super.key,
    this.type = CreationType.longNovel,
    required this.currentStep,
  });

  final int currentStep;
  ///创建类型
  final CreationType? type; 

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.w,
      padding: EdgeInsets.symmetric(vertical: 8.w),
      decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.w),
            border: Border.all(
              color: ByColor.colorBg2,
              width: 1.5
            ),
          ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children:  _buildStepItems(context),
      ),
    );
  }

  ///长短篇小说，共4步
  List<Widget> _buildStepItems(BuildContext context) {
    final List<Widget> res = [];
    List<Widget> items = NovelCreateStepType.values.map(
      (step) {
        final undo = step.rawValue > currentStep;
        return _buildStepTitle(step.title, step.rawValue, undo);
      },
    ).toList();

    res.addAll(items);

    for (var element in NovelCreateStepType.values.reversed) {
      if (element.rawValue > 0) {
        final undo = element.rawValue > currentStep;
        res.insert(
          element.rawValue,
          _buildStepDivider(undo)
        );
      }
    }
    return res;
  }

  /// 创建步骤的标题与图标
  Widget _buildStepTitle(String title, int step ,bool undo) {
    return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w,),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                      _getImageName(step, undo),
                      width: 20.w,
                      height: 20.w,
                    ),
              // SizedBox(width: 4.w),
              // ByText.text(
              //   text: title,
              //   fontSize: 12.sp,
              //   textColor: !undo
              //       ? Colors.white
              //       : ByColor.colorF2,
              // )
            ],
          ),
        );
  }

  ///获取图片名
  String _getImageName(int step, bool undo) {
    return "assets/home/novel/icon_create_step_${step}_${undo ? 'undo' : 'finished'}.png";
  }

  /// 创建步骤的分割线
  Widget _buildStepDivider(bool undo) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Center(
        child: Image.asset(
          "assets/home/novel/icon_step_arrow_${undo ? "undo" : "finished"}.png",
          fit: BoxFit.fitHeight,
          height: 8.w,
        ),
      ),
    );
  }
}
