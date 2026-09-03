import 'package:flutter/material.dart';
import 'package:novel_oversea/core/service/animate/animate_service.dart';
import 'package:novel_oversea/core/util/extentions.dart';

class AnimationDemoWidget extends StatefulWidget {

  const AnimationDemoWidget({super.key}); 
  @override
  State<AnimationDemoWidget> createState() => _AnimationDemoWidgetState();
}

class _AnimationDemoWidgetState extends State<AnimationDemoWidget> with TickerProviderStateMixin {
  late AnimationService _scaleAnimationService; // 缩放动画服务
  late ColorAnimationService _colorAnimationService; // 颜色动画服务
  late AnimationService _transAnimationService; // 颜色动画服务
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 初始化动画服务（传入vsync和参数）
    _scaleAnimationService = AnimationService(
      vsync: this,
      duration: Duration(milliseconds: 500),
      begin: 0,
      end: 1,
    );

    // 初始化动画服务（传入vsync和参数）
    _transAnimationService = AnimationService(
      vsync: this,
      duration: Duration(milliseconds: 500),
      begin: 80,
      end: 120,
    );

    _colorAnimationService = ColorAnimationService(
      vsync: this,
      duration: Duration(milliseconds: 500),
      begin: Colors.blue,
      end: Colors.red,
    );

    // 1. 初始化动画控制器（时长1秒，绑定当前页面的生命周期）
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // 2. 定义动画值范围：将0.0~1.0映射到控制点y坐标的波动范围（如从80到120）
    _animation = Tween<double>(begin: 80, end: 120).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // 动画曲线：先慢后快再慢，更自然
      ),
    )..addStatusListener((status) {
        // 3. 动画结束后反向播放，实现循环波动
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          // _controller.forward();
        }
      });
  }

  @override
  void dispose() {
    // 释放动画资源（关键步骤）
    _scaleAnimationService.dispose();
    _colorAnimationService.dispose();
    _transAnimationService.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Animate")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 使用AnimatedBuilder监听动画值变化
            AnimatedBuilder(
              // animation: Listenable.merge([
              //   _scaleAnimationService.animation,
              //   _colorAnimationService.colorAnimation,
              //   _transAnimationService.animation
              // ]),
              animation: _controller,
              builder: (context, child) {
                // return Container(
                //       width: 200,
                //       height: 200,
                //       color: _colorAnimationService.colorAnimation.value, // 颜色值
                //       alignment: Alignment.center,
                //       child: child,
                // );
                return CustomPaint(
                  size: const Size(300, 200), // 绘制区域大小
                  painter: WavePainter(controlY: _animation.value), // 传入控制点y坐标
                );
              },
              child: CustomPaint(
                size: const Size(200, 200), // 绘制区域大小
                painter: WavePainter(controlY: _transAnimationService.animation.value), // 传入控制点y坐标
              ),
              // child: Text(
              //   "动画效果",
              //   style: TextStyle(color: Colors.white, fontSize: 20),
              // ),
            ),
            SizedBox(height: 40),
            // 控制按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _colorAnimationService.start();
                    _scaleAnimationService.start();
                    _transAnimationService.start();
                    _controller.forward();
                  },
                  child: Text("开始",style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _colorAnimationService.reverse();
                    _scaleAnimationService.reverse();
                    _transAnimationService.reverse();
                    _controller.reverse();
                  },
                  child: Text("反向",style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _colorAnimationService.repeat();
                    _scaleAnimationService.repeat();
                    _transAnimationService.repeat();
                    _controller.repeat();
                  },
                  child: Text("重复",style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 自定义画笔：根据传入的controlY（动画值）绘制波动的二阶贝塞尔曲线
class WavePainter extends CustomPainter {
  final double controlY; // 二阶曲线的控制点y坐标（由动画驱动）

  WavePainter({required this.controlY});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 配置画笔（填充样式，蓝色半透明）
    final Paint paint = Paint()
      ..color = Colors.blue.withAlphaValue(0.5)
      ..style = PaintingStyle.fill; // 填充曲线下方区域，形成波浪效果

    // 2. 定义贝塞尔曲线路径（拼接多个二阶曲线形成波浪）
    final Path path = Path();
    // 起点：左上角外侧（x=-50，y=100）
    path.moveTo(0, 100);

    // 第一个二阶曲线：控制点y由动画值决定
    path.quadraticBezierTo(
      size.width / 4, // 控制点x（左1/4处）
      controlY, // 控制点y（动画动态变化）
      size.width / 2, // 终点x（中间）
      100, // 终点y（回到基线）
    );

    // 第二个二阶曲线：与第一个对称，形成完整波浪
    path.quadraticBezierTo(
      size.width * 3 / 4, // 控制点x（右1/4处）
      200 - controlY, // 控制点y（与第一个对称，形成起伏）
      size.width, // 终点x（右侧外侧）
      100, // 终点y（回到基线）
    );

    // 3. 封闭路径（连接到底部，形成填充区域）
    path.lineTo(size.width, size.height); // 右侧到底部
    path.lineTo(0, size.height); // 左侧到底部
    path.close(); // 闭合路径

    // 4. 绘制路径
    canvas.drawPath(path, paint);
  }

  // 5. 重绘判断：当controlY变化时才重绘（优化性能）
  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return controlY != oldDelegate.controlY;
  }
}


// 动画多个参数：起点x、终点x、两个控制点x
class CubicBezierPainter extends CustomPainter {
  final double offsetX; // 整体x方向偏移量（由动画驱动）

  CubicBezierPainter({required this.offsetX});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.purple
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    // 起点x随offsetX变化（从左到右移动）
    path.moveTo(50 + offsetX, 100);
    // 三阶曲线：两个控制点x也随offsetX变化
    path.cubicTo(
      100 + offsetX, 50, // 第一个控制点
      150 + offsetX, 150, // 第二个控制点
      200 + offsetX, 100, // 终点
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CubicBezierPainter oldDelegate) {
    return offsetX != oldDelegate.offsetX;
  }
}

// 在动画中使用：offsetX从-200→200，实现曲线从左到右移动
// _animation = Tween<double>(begin: -200, end: 200).animate(_controller);

