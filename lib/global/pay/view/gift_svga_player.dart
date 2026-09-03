/*
 * @Author: duncy
 * @Date: 2025-10-27 14:27:51
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-28 11:54:59
 * @FilePath: /novel_oversea/lib/global/pay/view/gift_svga_player.dart
 * @Description: 
 */


import 'package:flutter/material.dart';
import 'package:flutter_svga/flutter_svga.dart';

class GiftSvgaPlayer extends StatefulWidget {
  const GiftSvgaPlayer({super.key,});

  @override
  State<GiftSvgaPlayer> createState() => _GiftSvgaPlayerState();
}

class _GiftSvgaPlayerState extends State<GiftSvgaPlayer> with SingleTickerProviderStateMixin {
  late SVGAAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SVGAAnimationController(vsync: this);
    playSvga(0, true);
    Future.delayed(Duration(milliseconds: 3150), () {
      playSvga(1, true);
      Future.delayed(Duration(milliseconds: 2080), () {
        playSvga(2, false);
      });
    });
  }

  void playSvga(int index, bool isOnce) {
    if(!mounted) {
      return;
    }
    SVGAParser.shared.decodeFromAssets('assets/pay/svga_pay_gift_$index.svga').then((
      video,
    ) {
      _controller.videoItem = video;
      if(isOnce) {
        _controller.forward();
      }
      else {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SVGAImage(_controller);
  }
}