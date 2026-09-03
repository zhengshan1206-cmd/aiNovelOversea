import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:novel_oversea/core/common/assets_data.dart';
import 'package:novel_oversea/core/common/event/common_event.dart';
import 'package:novel_oversea/core/ui/view/audio/byhy_audio_player.dart';
import 'package:novel_oversea/core/ui/view/by_common_utils.dart';
import 'package:novel_oversea/core/ui/view/by_widgets_util.dart';
import 'package:novel_oversea/core/ui/view/video/byhy_video_clip_preview.dart';
import 'package:novel_oversea/core/util/byhy_download_util.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

///视频播放组件
class VideoPlayerWidget extends StatefulWidget {
  final String url;
  final String? coverUrl;
  final bool autoPlay;
  final int? offset;
  final bool userInteractive;
  final bool mute;
  final double? aspectRatio;
  final Duration? maxDuration;
  final bool showFullScreenButton;
  final bool showVideoProgress;
  const VideoPlayerWidget({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.offset,
    this.userInteractive = true,
    this.coverUrl,
    this.mute = false,
    this.aspectRatio,
    this.maxDuration,
    this.showVideoProgress = true,
    this.showFullScreenButton = false,
  });

  @override
  State<VideoPlayerWidget> createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with WidgetsBindingObserver {
  CachedVideoPlayerPlusController? _cachedVideoPlayerPlusController;
  VideoPlayerController? _localController;
  late bool isPlaying = widget.autoPlay;
  // bool _showControls = true;
  // Timer? _hideTimer;
  bool _isBuffering = false;
  bool _hasError = false;
  int _retryCount = 0;
  static const int maxRetries = 3;

  ui.Image? _thumbImage;

  void changeMuteStatus(bool status) {
    _cachedVideoPlayerPlusController?.setVolume(status ? 0.0 : 1.0);
  }

  void stopPlay() {
    _localController?.pause();
    _cachedVideoPlayerPlusController?.pause();
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void resumePlay() {
    _localController?.play();
    _cachedVideoPlayerPlusController?.play();
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  late StreamSubscription<PauseVideoEvent> streamSubscription;

  // void _startHideTimer() {
  //   _hideTimer?.cancel();
  //   _hideTimer = Timer(const Duration(seconds: 3), () {
  //     if (mounted) {
  //       setState(() {
  //         _showControls = false;
  //       });
  //     }
  //   });
  // }

  // void _toggleControls() {
  //   setState(() {
  //     _showControls = !_showControls;
  //   });
  //   if (_showControls) {
  //     _startHideTimer();
  //   }
  // }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _initializeVideoController() async {
    try {
      if (widget.url.startsWith("http")) {
        _cachedVideoPlayerPlusController =
            CachedVideoPlayerPlusController.networkUrl(
          Uri.parse(widget.url),
        );

        await _cachedVideoPlayerPlusController!.initialize();

        if (!mounted) return;

        _cachedVideoPlayerPlusController?.setVolume(widget.mute ? 0.0 : 1);

        if (widget.offset != null && widget.offset! > 0) {
          final duration = _cachedVideoPlayerPlusController!.value.duration;
          if (duration.inSeconds > widget.offset!) {
            await _cachedVideoPlayerPlusController!
                .seekTo(Duration(seconds: widget.offset!));
          }
        }

        await _cachedVideoPlayerPlusController!.setLooping(true);

        if (widget.maxDuration != null) {
          _cachedVideoPlayerPlusController!.addListener(_checkDuration);
        }

        if (mounted) {
          setState(() {
            _hasError = false;
            _isBuffering = false;
          });

          if (widget.autoPlay) {
            _cachedVideoPlayerPlusController?.play();
          } else {
            _cachedVideoPlayerPlusController?.pause();
          }
        }
      } else {
        _localController = VideoPlayerController.file(File(widget.url));
        await _localController!.initialize();

        if (!mounted) return;

        await _localController!.setLooping(true);

        if (widget.offset != null && widget.offset! > 0) {
          final duration = _localController!.value.duration;
          if (duration.inSeconds > widget.offset!) {
            await _localController!.seekTo(Duration(seconds: widget.offset!));
          }
        }

        if (widget.maxDuration != null) {
          _localController!.addListener(_checkDuration);
        }

        if (mounted) {
          setState(() {
            _hasError = false;
            _isBuffering = false;
          });

          if (widget.autoPlay) {
            _localController?.play();
          } else {
            _localController?.pause();
          }
        }
      }
    } catch (e) {
      print("视频初始化失败: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }

      if (_retryCount < maxRetries) {
        _retryCount++;
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            _initializeVideoController();
          }
        });
      }
    }
  }

  void _checkDuration() {
    if (widget.maxDuration == null) return;

    if (_cachedVideoPlayerPlusController != null) {
      if (_cachedVideoPlayerPlusController!.value.position >=
          widget.maxDuration!) {
        _cachedVideoPlayerPlusController!.seekTo(Duration.zero);
        _cachedVideoPlayerPlusController!.pause();
        setState(() {
          isPlaying = false;
        });
      }
    } else if (_localController != null) {
      if (_localController!.value.position >= widget.maxDuration!) {
        _localController!.seekTo(Duration.zero);
        _localController!.pause();
        setState(() {
          isPlaying = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    byDebugPrint("--------VideoPlayerWidgetState initState", tag: "播放的url:");
    _loadThumbImage();
    _initializeVideoController();

    streamSubscription = eventBus.on<PauseVideoEvent>().listen((event) {
      if (_cachedVideoPlayerPlusController != null) {
        _cachedVideoPlayerPlusController!.pause();
      }
      if (_localController != null) {
        _localController!.pause();
      }
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  Future<void> _loadThumbImage() async {
    final ByteData data =
        await rootBundle.load('assets/tutorial/slider_icon.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    setState(() {
      _thumbImage = frame.image;
    });
  }

  @override
  void dispose() {
    byDebugPrint("--------VideoPlayerWidgetState dispose", tag: "播放的url:");
    if (widget.maxDuration != null) {
      _cachedVideoPlayerPlusController?.removeListener(_checkDuration);
      _localController?.removeListener(_checkDuration);
    }
    _cachedVideoPlayerPlusController?.dispose();
    _localController?.dispose();
    streamSubscription.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (widget.userInteractive == false) return;

    if (ByAudioPlayer.sharedInstance.isPlaying) {
      ByAudioPlayer.sharedInstance.pause();
    }

    if (isPlaying) {
      _cachedVideoPlayerPlusController?.pause();
    } else {
      _cachedVideoPlayerPlusController?.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ByColor.colorC1),
        strokeWidth: 2,
      ));
    }

    if (widget.url.startsWith("http")) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: Stack(
          children: [
            (_cachedVideoPlayerPlusController?.value.isInitialized ?? false)
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      // final aspectRatio = widget.aspectRatio ??
                      //     _cachedVideoPlayerPlusController!.value.aspectRatio;
                      final maxHeight = constraints.maxHeight;
                      final maxWidth = constraints.maxWidth;

                      return Stack(
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final videoAspectRatio =
                                  _cachedVideoPlayerPlusController!
                                      .value.aspectRatio;
                              final containerAspectRatio = maxWidth / maxHeight;

                              // 计算自适应高度
                              double adaptiveHeight;
                              if (videoAspectRatio > containerAspectRatio) {
                                // 视频更宽，以宽度为准，高度自适应
                                adaptiveHeight = maxWidth / videoAspectRatio;
                              } else {
                                // 视频更高，以高度为准，但不超过最大高度
                                adaptiveHeight = maxHeight;
                              }

                              return SizedBox(
                                width: maxWidth,
                                height: adaptiveHeight,
                                child: ClipRect(
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: _cachedVideoPlayerPlusController!
                                          .value.size.width,
                                      height: _cachedVideoPlayerPlusController!
                                          .value.size.height,
                                      child: CachedVideoPlayerPlus(
                                          _cachedVideoPlayerPlusController!),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          if (_isBuffering)
                            const Center(
                                child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  ByColor.colorC1),
                              strokeWidth: 2,
                            )),
                          if(widget.showVideoProgress)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              width: double.infinity,
                              color: Colors.black.withAlphaValue(0.5),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 5.h),
                                    child: Row(
                                      children: [
                                        ValueListenableBuilder<
                                            CachedVideoPlayerPlusValue>(
                                          valueListenable:
                                              _cachedVideoPlayerPlusController!,
                                          builder: (context, value, child) {
                                            return Text(
                                              _formatDuration(value.position),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: ValueListenableBuilder<
                                              CachedVideoPlayerPlusValue>(
                                            valueListenable:
                                                _cachedVideoPlayerPlusController!,
                                            builder: (context, value, child) {
                                              final position = value
                                                  .position.inMilliseconds
                                                  .toDouble();
                                              final duration = value
                                                  .duration.inMilliseconds
                                                  .toDouble();

                                              return SliderTheme(
                                                data: SliderThemeData(
                                                  trackHeight: 3,
                                                  trackShape:
                                                      const _CustomSliderTrackShape(),
                                                  thumbShape: _CustomThumbShape(
                                                      image: _thumbImage),
                                                  overlayShape:
                                                      SliderComponentShape
                                                          .noOverlay,
                                                  inactiveTrackColor:
                                                      Colors.transparent,
                                                  activeTrackColor:
                                                      Colors.transparent,
                                                ),
                                                child: Slider(
                                                  value: position.clamp(
                                                      0,
                                                      widget.maxDuration
                                                              ?.inMilliseconds
                                                              .toDouble() ??
                                                          duration),
                                                  min: 0,
                                                  max: widget.maxDuration
                                                          ?.inMilliseconds
                                                          .toDouble() ??
                                                      duration,
                                                  onChanged: (newValue) {
                                                    if (widget.maxDuration !=
                                                            null &&
                                                        newValue >
                                                            widget.maxDuration!
                                                                .inMilliseconds) {
                                                      return;
                                                    }
                                                    _cachedVideoPlayerPlusController
                                                        ?.seekTo(
                                                      Duration(
                                                          milliseconds:
                                                              newValue.toInt()),
                                                    );
                                                  },
                                                  onChangeEnd: (newValue) {
                                                    if (isPlaying) {
                                                      _cachedVideoPlayerPlusController
                                                          ?.play();
                                                    }
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        ValueListenableBuilder<
                                            CachedVideoPlayerPlusValue>(
                                          valueListenable:
                                              _cachedVideoPlayerPlusController!,
                                          builder: (context, value, child) {
                                            return Text(
                                              _formatDuration(value.duration),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            );
                                          },
                                        ),
                                        widget.showFullScreenButton
                                            ? GestureDetector(
                                                onTap: () {
                                                  // 暂停当前播放
                                                  if (widget.url
                                                      .startsWith("http")) {
                                                    _cachedVideoPlayerPlusController
                                                        ?.pause();
                                                  } else {
                                                    _localController?.pause();
                                                  }
                                                  setState(() {
                                                    isPlaying = false;
                                                  });

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          VideoClipPreview(
                                                        widget.url,
                                                        maxDuration:
                                                            widget.maxDuration,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.w,
                                                      vertical: 5.h),
                                                  child: Image.asset(
                                                    "assets/tutorial/home_full_icon.png",
                                                    width: 15,
                                                    height: 15,
                                                  ),
                                                ),
                                              )
                                            : SizedBox(width: 12.w),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : widget.coverUrl != null
                    ? CachedNetworkImage(imageUrl: widget.coverUrl!)
                    : ByWidgetsUtil.activityIndicator(),
            Positioned.fill(
              child: Offstage(
                offstage: isPlaying,
                child: Center(
                  child: Image.asset(
                    AssetsData.iconVideoPlay,
                    width: 40.w,
                    height: 40.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isPlaying) {
          _localController?.pause();
        } else {
          _localController?.play();
        }
        setState(() {
          isPlaying = !isPlaying;
        });
      },
      child: Stack(
        children: [
          (_localController?.value.isInitialized ?? false)
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    // final aspectRatio = _localController!.value.aspectRatio;
                    final maxHeight = constraints.maxHeight;
                    final maxWidth = constraints.maxWidth;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final videoAspectRatio =
                            _localController!.value.aspectRatio;
                        final containerAspectRatio = maxWidth / maxHeight;

                        // 计算自适应高度
                        double adaptiveHeight;
                        if (videoAspectRatio > containerAspectRatio) {
                          // 视频更宽，以宽度为准，高度自适应
                          adaptiveHeight = maxWidth / videoAspectRatio;
                        } else {
                          // 视频更高，以高度为准，但不超过最大高度
                          adaptiveHeight = maxHeight;
                        }

                        return SizedBox(
                          width: maxWidth,
                          height: adaptiveHeight,
                          child: ClipRect(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: _localController!.value.size.width,
                                height: _localController!.value.size.height,
                                child: VideoPlayer(_localController!),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              : ByDownloadUtil.videoCover(widget.url),
          Positioned.fill(
            child: Offstage(
              offstage:
                  isPlaying || (_localController?.value.isInitialized == false),
              child: Center(
                child: Image.asset(
                  AssetsData.iconVideoPlay,
                  width: 40.w,
                  height: 40.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _CustomSliderTrackShape extends SliderTrackShape {
  const _CustomSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = 3;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final double trackHeight = 3;
    final double trackRadius = 2;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    final Rect trackRect =
        Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);

    // 底色
    final Paint inactivePaint = Paint()
      ..color = const Color.fromRGBO(255, 255, 255, 0.45)
      ..style = PaintingStyle.fill;
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, Radius.circular(trackRadius)),
      inactivePaint,
    );

    // 已过进度渐变
    final double progress = (thumbCenter.dx - trackLeft) / trackWidth;
    if (progress > 0) {
      final Rect progressRect = Rect.fromLTWH(
          trackLeft, trackTop, trackWidth * progress, trackHeight);
      final Paint activePaint = Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF98FC4A),
            Color(0xFF0BBA92),
            Color(0xFF0181FC),
          ],
          stops: [0.0, 0.505, 1.0],
        ).createShader(progressRect);
      context.canvas.drawRRect(
        RRect.fromRectAndRadius(progressRect, Radius.circular(10)),
        activePaint,
      );
    }
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final double thumbRadius = 7.5;
  final ui.Image? image;
  const _CustomThumbShape({required this.image});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size(thumbRadius * 2, thumbRadius * 2);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    if (image != null) {
      final Canvas canvas = context.canvas;
      final paint = Paint();
      canvas.drawImageRect(
        image!,
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
        Rect.fromCenter(
            center: center, width: thumbRadius * 2, height: thumbRadius * 2),
        paint,
      );
    }
  }
}
