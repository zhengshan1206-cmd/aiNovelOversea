


import 'package:flutter/material.dart';
import 'package:novel_oversea/home/photo_hero.dart';

class PhotoHeroPage extends StatelessWidget {
  const PhotoHeroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新页面')),
      body: Container(
        // 将背景设置为蓝色以强调这是一个新路由。
        color: Colors.lightGreenAccent,
        padding: const EdgeInsets.all(16),
        alignment: Alignment.topLeft,
        child: PhotoHero(
          tag: 'assets_one',
          width: 100.0,
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
