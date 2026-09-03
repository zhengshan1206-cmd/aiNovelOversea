/*
 * @Author: cold-x
 * @Date: 2025-06-05 15:00:35
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-11 17:45:17
 * @FilePath: /fastcreationmaster/lib/home/long_novel/page/novel_base_page.dart
 * @Description: 长文小说基础页
 */

import 'package:flutter/material.dart';
import 'package:novel_oversea/core/ui/page/base_page.dart';
import 'package:novel_oversea/home/create/controller/novel_create_controller.dart';
import 'package:novel_oversea/home/create/view/create_step_view.dart';

// ignore: must_be_immutable
class NovelBasePage extends BasePage {
  NovelBasePage({
    super.key,
  });

  @override
  String get title => '长文小说';

  ///类型
  CreationType type = CreationType.longNovel;

  NovelCreateStepType stepType = NovelCreateStepType.brief;

  ///头部进度视图
  Widget buildStepView(){
    return CreateStepView(currentStep: stepType.rawValue);
  }
}
