
// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:novel_oversea/core/service/app_permisson/byhy_permission_utils.dart';
import 'package:novel_oversea/core/ui/dialog/byhy_assets_picker_dialog.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/core/ui/view/video/byhy_video_clip_preview.dart';
import 'package:novel_oversea/core/util/by_nav_router_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

void byDebugPrint(Object? obj, {String? tag}) => ByCommonUtils.debugPrintObj(obj, tag: tag);


///贝因公共插件
class ByCommonUtils {
  ///选择音频文件弹窗
  static void pickAssetsWithAudio(
      BuildContext context, {
        int? maxCount,
        void Function(List<AssetEntity> asstes)? onSelectedCallback,
      }) async {
    final status = await ByPermissionUtils.audios();
    if (!status) return;
    AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: maxCount ?? 9,
        requestType: RequestType.audio,
      ),
    ).then((result) async {
      if (result == null) return;
      onSelectedCallback?.call(result);
    });
  }

  ///选择系统资源文件弹窗
  static void pickAssets(
      BuildContext context, {
        int? maxCount,
        RequestType? type,

        /// 时长限制，单位：秒
        int? durationLimit,
        int? durationLimitMin,
        void Function(List<AssetEntity> asstes)? onSelectedCallback,
        void Function()? onCancelCallback,
      }) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (ctx) {
        return ByHyAssetsPickerDialog(
          onSelected: (int idx) async {
            ByNavRouterUtils.goBack(ctx);
            if (idx == 0) {
              switch (type) {
                case RequestType.video:
                  final status = await ByPermissionUtils.videos();
                  if (!status) return;

                case RequestType.image:
                  final status = await ByPermissionUtils.photos();
                  if (!status) return;

                default:
              }

              final List<AssetEntity> result = await AssetPicker.pickAssets(
                context,
                pickerConfig: AssetPickerConfig(
                  maxAssets: maxCount ?? 9,
                  requestType: type ?? RequestType.common,
                  filterOptions: durationLimit == null
                      ? null
                      : FilterOptionGroup(
                    videoOption: FilterOption(
                      durationConstraint: DurationConstraint(
                        min: Duration(seconds: durationLimitMin ?? 0),
                        max: Duration(seconds: durationLimit),
                      ),
                    ),
                  ),
                ),
              ) ??
                  [];
              onSelectedCallback?.call(result);
            } else {
              final status = await ByPermissionUtils.camera();
              if (!status) {
                onCancelCallback?.call();
                return;
              }
              final AssetEntity? result = await pickFromCamera(
                context,
                enableRecording:
                [RequestType.video, RequestType.common].contains(type),
                onlyEnableRecording: RequestType.video == type,
              );
              if (result != null) {
                onSelectedCallback?.call([result]);
              } else {
                onCancelCallback?.call();
              }
            }
          },
          onCancel: onCancelCallback == null
              ? null
              : (index) {
            onCancelCallback.call();
          },
        );
      },
    );
  }

  /// image/video
  static void pickAssetsOnType(
      BuildContext context, {
        int? maxCount,
        void Function(List<AssetEntity> asstes)? onSelectedCallback,
      }) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (ctx) {
        return ByHyAssetsPickerDialog(onSelected: (int idx) async {
          ByNavRouterUtils.goBack(ctx);

          if (idx == 0) {
            final status = await ByPermissionUtils.photos();
            if (!status) return;
            final List<AssetEntity> result = await AssetPicker.pickAssets(
              context,
              pickerConfig: AssetPickerConfig(
                maxAssets: maxCount ?? 9,
                requestType:
                idx == 0 ? RequestType.image : RequestType.video,
              ),
            ) ??
                [];
            onSelectedCallback?.call(result);
          } else {
            final status = await ByPermissionUtils.camera();
            if (!status) return;
            final AssetEntity? result = await pickFromCamera(
              context,
              enableRecording: idx == 1,
              onlyEnableRecording: idx == 1,
            );
            if (result != null) {
              onSelectedCallback?.call([result]);
            }
          }
        });
      },
    );
  }

  /// image/video
  static void pickAssetsOnTypeVideo(
      BuildContext context, {
        int? maxCount,
        void Function(List<AssetEntity> asstes)? onSelectedCallback,
      }) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (ctx) {
        return ByHyAssetsPickerDialog(onSelected: (int idx) async {
          ByNavRouterUtils.goBack(ctx);

          if (idx == 0) {
            final status = await ByPermissionUtils.videos();
            if (!status) return;
            final List<AssetEntity> result = await AssetPicker.pickAssets(
              context,
              pickerConfig: AssetPickerConfig(
                maxAssets: maxCount ?? 9,
                requestType: RequestType.video,
              ),
            ) ??
                [];
            onSelectedCallback?.call(result);
          } else {
            final status = await ByPermissionUtils.camera();
            if (!status) return;
            final AssetEntity? result = await pickFromCamera(
              context,
              enableRecording: true,
              onlyEnableRecording: true,
            );
            if (result != null) {
              onSelectedCallback?.call([result]);
            }
          }
        });
      },
    );
  }

  /// image/video
  static void pickAssetsOnTypeCommon(
      BuildContext context, {
        int? maxCount,
        void Function(List<AssetEntity> asstes)? onSelectedCallback,
      }) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (ctx) {
        return ByHyAssetsPickerDialog(onSelected: (int idx) async {
          ByNavRouterUtils.goBack(ctx);

          if (idx == 0) {
            final status = await ByPermissionUtils.photos();
            if (!status) return;
            final List<AssetEntity> result = await AssetPicker.pickAssets(
              context,
              pickerConfig: AssetPickerConfig(
                maxAssets: maxCount ?? 9,
                requestType:
                idx == 0 ? RequestType.common : RequestType.video,
              ),
            ) ??
                [];
            onSelectedCallback?.call(result);
          } else {
            final status = await ByPermissionUtils.camera();
            if (!status) return;
            final AssetEntity? result = await pickFromCamera(
              context,
              enableRecording: true,
              onlyEnableRecording: idx == 1,
            );
            if (result != null) {
              onSelectedCallback?.call([result]);
            }
          }
        });
      },
    );
  }

  static void pickAssetsByType(
      BuildContext context, {
        int? maxCount,
        required RequestType type,
        void Function(List<AssetEntity> asstes)? onSelectedCallback,
        bool needMicroPhone = false,
      }) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (ctx) {
        return ByHyAssetsPickerDialog(
          albumTitle: type == RequestType.audio ? "音频" : null,
          onSelected: (int idx) async {
            ByNavRouterUtils.goBack(ctx);
            if (idx == 0) {
              switch (type) {
                case RequestType.video:
                  final status = await ByPermissionUtils.videos();
                  if (!status) return;
                  break;
                case RequestType.image:
                  final status = await ByPermissionUtils.photos();
                  if (!status) return;
                  break;
                case RequestType.audio:
                  final status = await ByPermissionUtils.audios();
                  if (!status) return;
                default:
              }

              /// 你也可以将类似的逻辑应用在其他常见的相册上。
              final List<AssetEntity> result = await AssetPicker.pickAssets(
                context,
                pickerConfig: AssetPickerConfig(
                  maxAssets: maxCount ?? 9,
                  requestType: type,
                  pathNameBuilder: (AssetPathEntity entity) {
                    // 获取原始路径名，如果为空则使用默认的"未知文件"
                    final String originalPath = entity.name;
                    // 定义一个映射表，将英文相册名映射为中文
                    final Map<String, String> pathMapping = {
                      'Camera Roll': '相机胶卷',
                      'Screenshots': '截图',
                      'Downloads': '下载',
                      'Recents': '最近项目',
                      'Favorites': '收藏',
                      'Selfies': '自拍',
                      'Live Photos': '实况照片',
                      'Portrait': '人像',
                      'Panoramas': '全景照片',
                      'Bursts': '连拍快照',
                      'Animated': '动图',
                      'Recently Saved': '最近的日子',
                      'Recent': '最近项目',
                      'Camera': '相册',
                      'Pictures': '图册',
                      'Videos':'视频',

                    };
                    String newPath = originalPath;
                    // 遍历映射表，将原始路径中的英文替换为中文
                    pathMapping.forEach((key, value) {
                      newPath = newPath.replaceAll(key, value);
                    });
                    return newPath;
                  },
                ),
              ) ??
                  [];
              onSelectedCallback?.call(result);
            } else {
              bool needMicroPhone2 = needMicroPhone;
              if (type == RequestType.video) {
                needMicroPhone2 = true;
              }
              final status = await ByPermissionUtils.camera(
                  needMicroPhone: needMicroPhone2);
              if (!status) return;
              final AssetEntity? result = await pickFromCamera(
                context,
                enableRecording:
                [RequestType.video, RequestType.common].contains(type),
                onlyEnableRecording: type == RequestType.video,
              );
              if (result == null) {
                Toast.showText(text: "拍摄失败！");
                return;
              }
              onSelectedCallback?.call([result]);
            }
          },
        );
      },
    );
  }

  static void pickAssetsForVideoByType(
      BuildContext context, {
        int? maxCount,
        required RequestType type,
        void Function(List<AssetEntity> asstes, {List<String>? urls})?
        onSelectedCallback,
        bool needMicroPhone = false,
      }) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (ctx) {
        return ByHyAssetsPickerDialog(
          albumTitle: type == RequestType.audio ? "音频" : null,
          onSelected: (int idx) async {
            ByNavRouterUtils.goBack(ctx);
            if (idx == 0) {
              switch (type) {
                case RequestType.video:
                  final status = await ByPermissionUtils.videos();
                  if (!status) return;
                  break;
                case RequestType.image:
                  final status = await ByPermissionUtils.photos();
                  if (!status) return;
                  break;
                case RequestType.audio:
                  final status = await ByPermissionUtils.audios();
                  if (!status) return;
                default:
              }

              /// 你也可以将类似的逻辑应用在其他常见的相册上。
              final List<AssetEntity> result = await AssetPicker.pickAssets(
                context,
                pickerConfig: AssetPickerConfig(
                  maxAssets: maxCount ?? 9,
                  requestType: type,
                  pathNameBuilder: (AssetPathEntity entity) {
                    // 获取原始路径名，如果为空则使用默认的"未知文件"
                    final String originalPath = entity.name;
                    // 定义一个映射表，将英文相册名映射为中文
                    final Map<String, String> pathMapping = {
                      'Camera Roll': '相机胶卷',
                      'Screenshots': '截图',
                      'Downloads': '下载',
                      'Recents': '最近项目',
                      'Favorites': '收藏',
                      'Selfies': '自拍',
                      'Live Photos': '实况照片',
                      'Portrait': '人像',
                      'Panoramas': '全景照片',
                      'Bursts': '连拍快照',
                      'Animated': '动图',
                      'Recently Saved': '最近的日子',
                      'Recent': '最近项目',
                      'Camera': '相册',
                      'Pictures': '图册',
                      'Videos':'视频',
                    };
                    String newPath = originalPath;
                    // 遍历映射表，将原始路径中的英文替换为中文
                    pathMapping.forEach((key, value) {
                      newPath = newPath.replaceAll(key, value);
                    });
                    return newPath;
                  },
                ),
              ) ??
                  [];
              onSelectedCallback?.call(result);
            } else if (idx == 1) {
              bool needMicroPhone2 = needMicroPhone;
              if (type == RequestType.video) {
                needMicroPhone2 = true;
              }
              final status = await ByPermissionUtils.camera(
                  needMicroPhone: needMicroPhone2);
              if (!status) return;
              final AssetEntity? result = await pickFromCamera(
                context,
                enableRecording:
                [RequestType.video, RequestType.common].contains(type),
                onlyEnableRecording: type == RequestType.video,
              );
              if (result == null) {
                Toast.showText(text: "拍摄失败！");
                return;
              }
              onSelectedCallback?.call([result]);
            } else if (idx == 2) {
              // final drawBean = await showMyPicturePicker(context);
              // if (drawBean != null) {
              //   debugPrint("我的创作===>${drawBean.picUrl}");
              //   onSelectedCallback?.call([], urls: [drawBean.picUrl]);
              // }
            }
          },
        );
      },
    );
  }

  static Future<List<AssetEntity>> pickAudio(
      BuildContext context, {
        int? maxCount,
        int? durationLimit,
        int? durationLimitMin,
      }) async {
    final status = await ByPermissionUtils.audios(
      message: '暂无音频权限，请前往设置开启权限',
    );
    // final status = await ByPermissionUtils.iosAudios(message: '暂无音频权限，请前往设置开启权限',);
    if (!status) return [];
    final List<AssetEntity> result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: maxCount ?? 9,
        requestType: RequestType.audio,
        filterOptions: durationLimit == null
            ? null
            : FilterOptionGroup(
          videoOption: FilterOption(
            durationConstraint: DurationConstraint(
              min: Duration(seconds: durationLimitMin ?? 0),
              max: Duration(seconds: durationLimit),
            ),
          ),
        ),
      ),
    ) ??
        [];
    return result;
  }

  static Future<List<AssetEntity>> pickVideos(
      BuildContext context, {
        int? maxCount,
        int? durationLimit,
        int? durationLimitMin,
      }) async {
    final status = await ByPermissionUtils.videos();
    if (!status) return [];
    final List<AssetEntity> result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: maxCount ?? 9,
        requestType: RequestType.video,
        filterOptions: durationLimit == null
            ? null
            : FilterOptionGroup(
          videoOption: FilterOption(
            durationConstraint: DurationConstraint(
              min: Duration(seconds: durationLimitMin ?? 0),
              max: Duration(seconds: durationLimit),
            ),
          ),
        ),
        pathNameBuilder: (AssetPathEntity entity) {
          // 获取原始路径名，如果为空则使用默认的"未知文件"
          final String originalPath = entity.name;
          // 定义一个映射表，将英文相册名映射为中文
          final Map<String, String> pathMapping = {
            'Camera Roll': '相机胶卷',
            'Screenshots': '录屏',
            'Downloads': '下载',
            'Recents': '最近项目',
            'Favorites': '收藏',
            'Selfies': '自拍',
            'Live Photos': '实况照片',
            'Portrait': '人像',
            'Panoramas': '全景照片',
            'Bursts': '连拍快照',
            'Animated': '动图',
            'Recently Saved': '最近的日子',
            'Movies': '电影',
            'Recent': '最近项目',
            'Videos':'视频',
          };
          String newPath = originalPath;
          // 遍历映射表，将原始路径中的英文替换为中文
          pathMapping.forEach((key, value) {
            newPath = newPath.replaceAll(key, value);
          });
          return newPath;
        },
      ),
    ) ??
        [];
    return result;
  }

  static Future<AssetEntity?> pickFromCamera(
      BuildContext c, {
        bool onlyEnableRecording = false,
        bool enableRecording = false,
      }) async {
    return CameraPicker.pickFromCamera(
      c,
      pickerConfig: CameraPickerConfig(
        enableRecording: enableRecording,
        onlyEnableRecording: onlyEnableRecording,
      ),
    );
  }

  /// 获取随机整数（默认包含最大最小值）
  static int getRandomInt(int min, int max,
      {bool inclusiveMin = true, bool inclusiveMax = true}) {
    assert(min <= max,
    'Min must be less than or equal to Max，Invalid arguments: min=$min, max=$max');
    int minVal = inclusiveMin ? min : min + 1;
    int maxVal = inclusiveMax ? max : max - 1;
    return minVal + Random.secure().nextInt(maxVal - minVal + 1);
  }

  static void debugPrintObj(
      Object? object, {
        String? tag = "======= :\n",
      }) {
    // print("${tag ?? ''}${const JsonEncoder.withIndent(" ").convert(object)}");
    if (kDebugMode) {
      debugPrint(
          "${tag ?? ''}${const JsonEncoder.withIndent(" ").convert(object)}");
    }
  }

  /// 获取随机小数（默认包含最大最小值）
  static double getRandomDouble(double min, double max,
      {bool inclusiveMin = true, bool inclusiveMax = true}) {
    assert(min <= max,
    'Min must be less than or equal to Max，Invalid arguments: min=$min, max=$max');
    double minVal = inclusiveMin ? min : min + 0.0000000001;
    double maxVal = inclusiveMax ? max : max - 0.0000000001;
    return minVal + Random.secure().nextDouble() * (maxVal - minVal);
  }

  /// 打开链接
  static Future<void> launchWebURL(String url) async {
    final Uri uri = Uri.parse(url);
    bool launch =  await launchUrl(uri);
    if(!launch) {
      Toast.showText(text: 'Open url error.');
    }
  }

  /// 调起拨号页
  static Future<void> launchTelURL(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // ByHyProgressHUD.showText('拨号失败！');
    }
  }

  // static String timestamp2DatetimeString(int timestamp) {
  //   // 将时间戳转换为 DateTime 对象
  //   DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

  //   // 格式化日期
  //   return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  // }

  /// 退出应用程序
  static void exitAndroidApp() async {
    // await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    await SystemNavigator.pop();
  }

  /// 退出应用程序
  static void exitApp() {
    exit(0);
  }

  static Timer? _debounceTimer;

  /// 防抖 (传入所要防抖的方法/回调与延迟时间)
  static void debounce(Function func, [int delay = 500]) {
    if (_debounceTimer != null) {
      _debounceTimer?.cancel();
    }
    _debounceTimer = Timer(Duration(milliseconds: delay), () {
      func.call();
      _debounceTimer = null;
    });
  }

  /// 防抖 (传入所要防抖的方法/回调与延迟时间)
  static dynamic debounce2(Function func, [int delay = 500]) {
    Timer? timer;
    return () {
      if (timer != null) {
        timer?.cancel();
      }
      timer = Timer(Duration(milliseconds: delay), () {
        func.call();
        timer = null;
      });
    };
  }

  /// 录入框防抖 (传入所要防抖的方法/回调与延迟时间)
  static dynamic debounceInput(Function(dynamic) func, [int delay = 500]) {
    Timer? timer;
    return (dynamic value) {
      if (timer != null) {
        timer?.cancel();
      }
      timer = Timer(Duration(milliseconds: delay), () {
        func.call(value);
        timer = null;
      });
    };
  }

  static Timer? _throttleTimer;
  static bool _throttleFlag = true;

  /// 节流 (传入所要节流的方法/回调与延迟时间)
  static void throttle(Function func, [int delay = 500]) {
    if (_throttleFlag) {
      func.call();
      _throttleFlag = false;
      return;
    }
    if (_throttleTimer != null) {
      return;
    }
    _throttleTimer = Timer(Duration(milliseconds: delay), () {
      func.call();
      _throttleTimer = null;
    });
  }

  /// 节流 (传入所要节流的方法/回调与延迟时间)
  static dynamic throttle2(Function func, [int delay = 500]) {
    Timer? timer;
    bool firstTime = true;
    return () {
      if (firstTime) {
        func.call();
        firstTime = false;
        return;
      }
      if (timer != null) {
        return;
      }
      timer = Timer(Duration(milliseconds: delay), () {
        func.call();
        timer = null;
      });
    };
  }

  /// 节流 (传入所要节流的方法/回调与延迟时间)
  static dynamic throttle3(Function func, [int delay = 500]) {
    Timer? timer;
    bool isExecuting = false;
    return () {
      if (isExecuting) return;
      isExecuting = true;
      timer?.cancel();
      timer = Timer(Duration(milliseconds: delay), () {
        func.call();
        isExecuting = false;
      });
    };
  }

  static void exportVideoPage(
      BuildContext context,
      String path, {
        String? title,
      }) {
    try {
      ByNavRouterUtils.push(
        context,
        VideoClipPreview(
          path,
          title: title,
        ),
      );
    } catch (e) {
      byDebugPrint(e);
    }
  }

  // static subFunctionCase(BuildContext context, SubFunction data,
  //     {bool fromChat = false}) async {
  //   final url = data.jumpUrl;
  //   debugPrint(
  //       "subFunctionCase>>>>>>>>>>>>>  id:${data.id} title:${data.title} url:${data.jumpUrl} params:${data.jumpParam} type:${data.type} ");
  //   final params = data.jumpParam;
  //   if (data.type == 1 || data.type == 2) {
  //     /// 路由跳转
  //     // if (fromChat) {
  //     //   RouteUtils.gotoPage(context, "/$url",
  //     //       params: {"fromChat": fromChat, ...params});
  //     // } else {
  //     //   RouteUtils.gotoPage(context, "/$url", params: params);
  //     // }
  //     RouteUtils.gotoPage(context, "/$url", params: params);
  //   } else if (data.type == 3) {
  //     //  if (checkPermissions) {
  //     //     final status = await ByPermissionUtils.videos();
  //     //     if (!status) return;
  //     //   }
  //   } else if (data.type == 4) {
  //     if (url.contains("tuixiaoguo")) {
  //       // _openUrl(url);
  //       ByNavRouterUtils.jumpWebViewPage(context, data.des, url);
  //     } else {
  //       ByNavRouterUtils.jumpWebViewPage(context, data.des, url);
  //     }
  //   }
  // }


}