/*
 * @Author: duncy
 * @Date: 2025-12-10 09:35:41
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-04 14:22:20
 * @FilePath: /novel_oversea/lib/home/main/dialog/home_banner_view.dart
 * @Description: 
 */


import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomeBannerView extends StatelessWidget {
  HomeBannerView({super.key, required this.height, this.onTap});

  final double height;

  final List imageList = [1, 2, 3, 4];

  final Function(int index)? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0),
      clipBehavior: Clip.none,
      child: CarouselSlider(
        options: CarouselOptions(
          height: height, 
          viewportFraction: 1.3,
          autoPlayInterval: Duration(seconds: 3),
          autoPlay: true,
        ),
        items: imageList.map((i) {
          return GestureDetector(onTap: () {
            onTap?.call(i);
          }, child: _buildImageItem(i));
        }).toList(),
      ),
    );
  }

  Widget _buildImageItem(int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scaleByDouble(0.85, 0.85, 0.85, 1)
              ..translateByDouble(-70, 10, 0, 1.0)
              ..rotateZ(pi/15),
            child: Opacity(
              opacity: 0.3,
              child: Image.asset('assets/home/main/0$index-01.png'),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scaleByDouble(0.85, 0.85, 0.85, 1)
              ..translateByDouble(70, 10, 0, 1.0)
              ..rotateZ(pi/15),
            child: Opacity(
              opacity: 0.3,
              child: Image.asset('assets/home/main/0$index-03.png'),
            ),
          ),
        ),
        Center(
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scaleByDouble(0.85, 0.85, 0.85, 1)
              ..translateByDouble(0, 0, 0, 1.0)
              ..rotateZ(-pi/15),
            child: Image.asset('assets/home/main/0$index-02.png'),
          ),
        ),
      ],
    );
  }
}
