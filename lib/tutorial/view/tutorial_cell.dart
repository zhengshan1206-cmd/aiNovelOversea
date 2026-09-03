/*
 * @Author: duncy
 * @Date: 2025-09-26 14:14:15
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-09-26 15:19:18
 * @FilePath: /novel_oversea/lib/tutorial/view/tutorial_cell.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/tutorial/bean/tutorial_bean.dart';

class StrategyListItem extends StatelessWidget {
  final StrategyListBean strategy;
  final VoidCallback? onTap;

  const StrategyListItem({
    super.key,
    required this.strategy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: ByColor.colorBg1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ByColor.colorF1.withAlphaValue(0.15),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            strategy.iconUrl,
            width: double.infinity,
            height: 140.w,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 140.w,
                color: ByColor.colorBg2,
                child: const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: double.infinity,
                height: 140.w,
                color: ByColor.colorBg2,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(ByColor.colorC1),
                    strokeWidth: 2,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
