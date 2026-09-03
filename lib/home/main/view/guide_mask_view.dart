// 通用引导遮罩组件
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/util/by_screen_utils.dart';
import '../../../global/launch/view/guide_last_step_view.dart';
import '../../core/view/bottom_view.dart';


class GuideBottomMaskView extends StatelessWidget {

  final VoidCallback? onMaskTap; // 点击遮罩的回调
  final Color maskColor; // 遮罩颜色（半透明）
  final String btnTitle;
  final double offY;

  const GuideBottomMaskView({
    super.key,
    this.onMaskTap,
    this.btnTitle = 'CONTINUE',
    this.offY = 0,
    this.maskColor = const Color.fromRGBO(0, 0, 0, 0.5),
  });

  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: maskColor,
      child: Stack(
        children: [
          Positioned(
            left: 12.w,
            right: 12.w,
            bottom: offY,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BottomView(
                  padding: 0,
                  showWords: false,
                  nextBtnText: btnTitle,
                  nextStep: () {
                    onMaskTap?.call();
                  },
                ),
              ],
            ),
          ),
          Positioned(
            right: 0.w, 
            bottom: -33.5.w + offY + ByScreenUtils.bottomSafeHeight ,
            child: FingerScaleAnimateView()),
        ],
      ),
    );
  }
}

class GuideMask extends StatelessWidget {
  final GlobalKey targetKey; // 目标组件的GlobalKey
  final VoidCallback? onMaskTap; // 点击遮罩的回调
  final Widget? guideWidget; // 引导提示组件（可选）
  final Color maskColor; // 遮罩颜色（半透明）

  const GuideMask({
    super.key,
    required this.targetKey,
    this.onMaskTap,
    this.guideWidget,
    this.maskColor = const Color.fromRGBO(0, 0, 0, 0.7),
  });

  @override
  Widget build(BuildContext context) {
    // 获取目标组件的位置和尺寸
    final RenderBox? targetBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetBox == null) {
      return const SizedBox.shrink(); // 组件未渲染时不显示遮罩
    }
    // 计算目标组件在全局坐标系中的位置和尺寸
    final Offset targetOffset = targetBox.localToGlobal(Offset.zero);
    final Size targetSize = targetBox.size;
    // 校准目标Rect（向外扩展1px，避免坐标偏差）
    final Rect targetRect = Rect.fromLTWH(
      targetOffset.dx - 1,
      targetOffset.dy - 1,
      targetSize.width + 2,
      targetSize.height + 2,
    );
    return GestureDetector(
      // 监听遮罩层所有点击
      onTapDown: (TapDownDetails details) {
        final Offset tapGlobalPos = details.globalPosition; // 点击的全局坐标
        // 判断点击坐标是否落在目标Rect内（镂空区域）
        if (targetRect.contains(tapGlobalPos)) {
          onMaskTap?.call(); // 触发镂空区域回调
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // 全屏遮罩（带镂空）
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: MaskPainter(
              maskColor: maskColor,
              targetRect: targetRect,
              borderRadius: 8, // 匹配目标组件的圆角
            ),
          ),

          Positioned(
            left: targetOffset.dx + targetSize.width - 74.w,
            top: targetOffset.dy + targetSize.height/2 - 10.w,
            child: FingerScaleAnimateView()),
          // 引导提示组件（可选）
          if (guideWidget != null) guideWidget!,
        ],
      ),
    );
  }
}

// 自定义画笔：绘制带镂空的遮罩
class MaskPainter extends CustomPainter {
  final Color maskColor; // 遮罩颜色
  final Rect targetRect; // 目标组件的矩形区域（镂空）
  final double borderRadius; // 镂空区域的圆角

  const MaskPainter({
    required this.maskColor,
    required this.targetRect,
    this.borderRadius = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 保存画布状态，创建临时图层
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // 2. 绘制全屏遮罩（原逻辑）
    final maskPaint = Paint()..color = maskColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), maskPaint);

    // 3. 绘制镂空区域（使用Clear模式，完全清除该区域的遮罩）
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear // 核心：清除模式，而非颜色叠加
      ..style = PaintingStyle.fill;

    // 绘制圆角矩形的镂空区域（完全透明）
    canvas.drawRRect(
      RRect.fromRectAndRadius(targetRect, Radius.circular(borderRadius)),
      clearPaint,
    );

    // 4. 恢复画布状态，应用图层
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MaskPainter oldDelegate) {
    return oldDelegate.maskColor != maskColor ||
        oldDelegate.targetRect != targetRect ||
        oldDelegate.borderRadius != borderRadius;
  }
}