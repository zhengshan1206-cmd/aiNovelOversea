/*
 * @Author: duncy
 * @Date: 2025-09-23 16:30:19
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-09-23 16:44:18
 * @FilePath: /novel_oversea/lib/home/photo_hero.dart
 * @Description: 
 */
import 'package:flutter/material.dart';

class PhotoHero extends StatelessWidget {
  const PhotoHero({
    super.key,
    required this.tag,
    this.onTap,
    required this.width,
  });

  final String tag;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Hero(
        tag: tag,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Image.asset(
              'assets/icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}