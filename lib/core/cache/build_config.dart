/*
 * @Author: cold-x
 * @Date: 2025-06-04 09:23:08
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-16 10:42:16
 * @FilePath: /novel_oversea/lib/core/cache/build_config.dart
 * @Description: 
 */

import 'package:novel_oversea/core/network/channel.dart';

import 'environment.dart';
import 'environment_config.dart';

class BuildConfig {
  late final Environment environment;
  late final EnvironmentConfig config;
  late final ChannelType channelType;
  bool _lock = false;

  static final BuildConfig instance = BuildConfig._internal();

  BuildConfig._internal();

  factory BuildConfig.instantiate({
    required Environment envType,
    required EnvironmentConfig envConfig,
    required ChannelType channelType,
  }) {
    if (instance._lock) return instance;

    instance.environment = envType;
    instance.config = envConfig;
    instance.channelType = channelType;
    instance._lock = true;

    return instance;
  }
}
