/*
 * @Author: duncy
 * @Date: 2025-10-09 16:11:28
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-11-03 18:32:16
 * @FilePath: /novel_oversea/lib/home/create/view/image_picker.dart
 * @Description: 
 */
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/home/create/bean/novel_category_bean.dart';
import 'package:novel_oversea/home/create/controller/create_category_controller.dart';

class RotatingImagePicker extends StatefulWidget {
  final double imageWidth;
  final double imageHeight;

  const RotatingImagePicker({
    super.key,
    this.imageWidth = 120,
    this.imageHeight = 180,
  });

  @override
  State<RotatingImagePicker> createState() => _RotatingImagePickerState();
}

class _RotatingImagePickerState extends State<RotatingImagePicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late PageController _controller;
  double _currentPage = 1.0;

  final CreateCategoryController cateController = Get.find<CreateCategoryController>();

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 1, viewportFraction: 218 / 375);
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page ?? 0.0;
      });
    });

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 300), (){
        _controller.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: widget.imageHeight + 70,
          child: Transform.translate(
            offset: Offset(0, 35),
            child: PageView.builder(
              controller: _controller,
              itemCount: cateController.categoryList.length,
              onPageChanged:(value) {
                cateController.index.value = value;
              },
              itemBuilder: (context, index) {
                final delta = index - _currentPage;
                final isCurrent = delta.abs() < 0.5;
                final angle = -delta * pi / 12; // 控制旋转角度
                final scale = isCurrent ? 1.0 : 0.8;
                final transX = 30 * delta;
                final transY = -40 * delta.abs();
                NovelCategoryBean bean = cateController.categoryList[index];
                return Center(
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..scaleAdjoint(scale)
                      ..translateByDouble(transX, transY, 0, 1.0)
                      ..rotateZ(angle),
                    child: Stack(
                      children: [
                        if (isCurrent)
                          Positioned.fill(
                            child: Container(
                              width: widget.imageWidth,
                              height: widget.imageHeight,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white24,
                                    blurRadius: 15,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/home/create/icon_home_partner_selected.png',
                                ),
                              ),
                            ),
                          ),
                        Opacity(
                          opacity: 1 - min(delta.abs(), 1) * 0.7,
                          child: Container(
                            width: widget.imageWidth,
                            height: widget.imageHeight,
                            padding: EdgeInsets.all(9),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              // child: Image.asset(
                              //   bean.icon,
                              //   fit: BoxFit.cover,
                              // ),
                              child: bean.icon.isEmpty ? Image.asset(
                                    'assets/home/create/icon_home_create_partner_0.png',
                                    fit: BoxFit.cover,
                                  ) : CachedNetworkImage(
                                imageUrl: bean.icon,
                                errorWidget: (context, error, p0) {
                                  return Image.asset(
                                    'assets/home/create/icon_home_create_partner_0.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            ),
                          ),
                        ),
                        Positioned(
                                bottom: 9,
                                left: 9,
                                right: 9,
                                child: _buildBlurView(bean.name)
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          child: AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -_floatAnimation.value),
                child: child,
              );
            },
            child: Center(
              child: Image.asset(
                'assets/home/create/icon_home_partner_diamond.png',
                width: 54,
                height: 54,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///毛玻璃效果
  Widget _buildBlurView(String name) {
    return SizedBox(
      height: 44.w,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0x003F86AF),
                  Color(0x3F3F86AF),
                ],
                begin: AlignmentGeometry.topCenter,
                end: AlignmentGeometry.bottomCenter,
              ),
              
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Center(child: ByText.text(text: name))),
        ),
      ),
    );
  }
}
