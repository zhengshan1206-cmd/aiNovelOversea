/*
 * @Author: duncy
 * @Date: 2025-09-25 09:22:21
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-09-25 09:22:32
 * @FilePath: /novel_oversea/lib/core/util/util.dart
 * @Description: 
 */
import 'dart:math';

class Util {

  // 生成 [min, max) 范围内的随机整数（不包含 max）
  static int randomInt(int min, int max) {
  if (min >= max) return min;
  return min + Random().nextInt(max - min);
}
}