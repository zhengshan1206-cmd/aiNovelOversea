/*
 * @Author: cold-x
 * @Date: 2025-07-04 10:57:28
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-03-02 09:26:36
 * @FilePath: /novel_oversea/lib/core/network/channel.dart
 * @Description: 
 */
///渠道类型 不同项目 配置不同渠道
enum ChannelType {

  ///AppStore
  test("e82066b41090724c", 2186),

  ///Google Play
  google("19358d47f6050c23", 2162),
  // google("e82066b41090724c", 2186),

  ///AppStore
  apple("b0290d027a7b4d05", 2163);

  final String channel;
  final num code;

  const ChannelType(this.channel, this.code);
}
