
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'dart:math';

import 'package:novel_oversea/core/ui/page/base_page.dart';
import 'package:novel_oversea/core/ui/view/muti_status_view.dart';
import 'package:novel_oversea/core/ui/view/video/byhy_video_player_view.dart';
import 'package:novel_oversea/core/ui/widget/by_text.dart';
import 'package:novel_oversea/core/util/by_screen_utils.dart';
import 'package:novel_oversea/core/util/extentions.dart';
import 'package:novel_oversea/global/ui/colors.dart';
import 'package:novel_oversea/me/user/user.dart';
import 'package:novel_oversea/tutorial/controller/tutorial_details_controller.dart';


///广场列表详情页面
// ignore: must_be_immutable
class TutorialDetailPage extends BasePage {
  final int id;
  final String pageTitle;

  TutorialDetailPage({
    super.key,
    this.id = 0,
    this.pageTitle = "Detail",
  }) {
    _controller = Get.put(TutorialDetailController(id: id));
  }

  late final TutorialDetailController _controller;
  final userController = Get.find<UserController>();

  @override
  String get title => _controller.detailsData.value?.name ?? pageTitle;

  @override
  bool get hasAppBar => false;

  ///图文列表 - 仅在图文模式下显示
  Widget _textListView() {
    if (_controller.detailsData.value?.type != 1) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HtmlWidget(
            _controller.detailsData.value?.content ?? "",
            customStylesBuilder: (element) {
              if (element.localName == 'img') {
                return {
                  'width': '100%', // 宽度占满父容器
                  'height': 'auto', // 高度自适应
                  'max-width': '100%', // 最大宽度不超过父容器
                };
              }
              return null; // 使用默认样式
            },
            onTapImage: (imageMetadata) {
              String url = '';
              for (var image in imageMetadata.sources) {
                url = image.url;
              }
              if(_controller.imgList.isEmpty || url.isEmpty) {
                return;
              }
              int index = _controller.imgList.indexOf(NetworkImage(url));
              MultiImageProvider multiImageProvider = MultiImageProvider(_controller.imgList, initialIndex: index);
              showImageViewerPager(
                Get.context!,
                multiImageProvider,
                useSafeArea: true,
                infinitelyScrollable: true,
                onViewerDismissed: (index) {

                },
              );
            },
          ),
        ],
      ),
    );
  }

  ///视频内容 - 仅在视频模式下显示
  Widget _videoContent() {
    if (_controller.detailsData.value?.type != 2) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: 540.h,
            minHeight: 200.h,
          ),
          child: Stack(
            children: [
              VideoPlayerWidget(
                url: _controller.detailsData.value?.videoUrl ?? "",
                autoPlay: true,
                maxDuration: _controller.userInfo?.isVip == 0 &&
                        _controller.detailsData.value?.isFree == 2
                    ? Duration(
                        seconds: _controller.detailsData.value?.lookTime ?? 10)
                    : null,
                showFullScreenButton: true,
              ),
              if (_controller.userInfo?.isVip == 0 &&
                  _controller.detailsData.value?.isFree == 2)
                Positioned(
                  top: 58,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(30, 31, 36, 0.24),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 21,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: ByColor.linearGradientMultiple(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF82D7FF),
                                  const Color(0xFFBFE0FF),
                                  const Color(0xFFDCC8FF),
                                ],
                                stops: const [0.1, 0.35, 0.92],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ByText.text(
                              text:  "Try Watching...",
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              textColor: ByColor.colorF7,
                            ),
                          ),
                          const SizedBox(width: 12),
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Try ",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ByColor.colorF1,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      '${_controller.detailsData.value?.lookTime ?? 10}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: ByColor.colorF5,
                                  ),
                                ),
                                const TextSpan(
                                  text: "s  ,",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ByColor.colorF1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              ByText.text(
                                text: "Open VIP for more",
                                fontSize: 13.sp,
                                textColor: ByColor.colorF1,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              // Positioned.fill(child: Container(
              //   decoration: BoxDecoration(
              //     color: Colors.black.withAlphaValue(0.5),
              //   ),
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       ByText.text(
              //         text: 'End of Trial',
              //         fontSize: 17.sp,
              //         fontWeight: FontWeight.w600,
              //         textColor: ByColor.colorF1,
              //       ),
              //       SizedBox(height: 8.h),
              //       ByButton.textButton(
              //         title: 'Watch full HD episode',
              //         fontSize: 15.sp,
              //         fontWeight: FontWeight.w600,
              //         titleColor: ByColor.colorF7,
              //         backgroundColor: ByColor.colorC1,
              //         padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.w),
              //         onPressed: () {
              //           ///跳转付费页
              //           userController.checkPreLogin(
              //             source: 'square_detail',
              //             actionCallback: () {
              //               userController.jumpToPayPage(source: 'square_detail');
              //             },
              //           );
              //         },
              //       ),
              //     ],
              //   ),
              // )),
            
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ByText.text(
                        text:  _controller.detailsData.value?.name ?? "",
                        fontSize: 17,
                        textColor: ByColor.colorF1,
                        // overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: HtmlWidget(
                  _controller.detailsData.value?.content ?? "",
                ),
              ),
              const SizedBox(height: 56),
            ],
          ),
        ),
      ],
    );
  }

  ///底部VIP提示 - 仅在图文模式下显示
  Widget _vipHint() {
    if (_controller.detailsData.value?.type != 1 ||
        _controller.userInfo?.isVip == 1 ||
        _controller.detailsData.value?.isFree == 1) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox.shrink(),
        Container(
          height: 210.w,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                const Color(0xFF0C130B),
                const Color(0xFF0C130B),
                const Color(0x000C130B).withAlphaValue(0),
              ],
              stops: const [0, 0.45, 1],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                  "assets/tutorial/icon_tutorial_crown.png",
                  width: 50.w,
                  height: 50.w,
                  fit: BoxFit.fill,
                ),
            ],
          ),
        ),
        Container(
          height: 56.w,
          color: ByColor.colorBg1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/tutorial/icon_tutorial_vip_decoration.png",
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 4),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment(0.5, -0.5),
                  end: Alignment(-0.5, 0.5),
                  transform: GradientRotation(126 * pi / 180),
                  colors: [
                    Color(0xFFFFAA45),
                    Color(0xFFFFFDFA),
                    Color(0xFFA2FFFF),
                  ],
                  stops: [0.1922, 0.5168, 0.8414],
                ).createShader(bounds),
                child: ByText.text(
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  text: "You need VIP access to \nview the following content",
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(pi),
                child: Image.asset(
                  "assets/tutorial/icon_tutorial_vip_decoration.png",
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            ///跳转付费页
            userController.checkPreLogin(
              source: 'square_detail',
              actionCallback: () {
                userController.jumpToPayPage(source: 'square_detail');
              },
            );
          },
          child: Container(
            width: double.infinity,
            color: ByColor.colorBg1,
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              bottom: 70 + ByScreenUtils.bottomSafeHeight,
              top: 4,
            ),
            child: SizedBox(
              height: 48.w,
              child: Stack(
                children: [
                  Image.asset(
                    "assets/tutorial/btn_tutorial_vip_bg.png",
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                  Center(
                    child: ByText.text(
                      text: 'UNBLOCK',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      textColor: ByColor.colorF7,
                    ),
                  ),
                  Positioned(
                    right: 20.w,
                    top: 16.w,
                    bottom: 16.w,
                    child: Image.asset(
                      'assets/home/create/icon_home_create_continue.png',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///底部按钮 - 仅在视频模式下显示
  Widget _bottomButton() {
    if (_controller.detailsData.value?.type != 2 ||
        _controller.userInfo?.isVip == 1 ||
        _controller.detailsData.value?.isFree == 1) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => {
          userController.checkPreLogin(
              source: 'square_detail',
              actionCallback: () {
                userController.jumpToPayPage(source: 'square_detail');
              })
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: ByColor.colorBg1,
          child: Container(
            height: 48.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: ByColor.colorC1
            ),
            child: Center(
              child: ByText.text(
                  text: 'Watch full HD episode',
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  textColor: ByColor.colorF7,
                ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    Get.log("arguments===> ${Get.arguments}");

    return Obx(() {
      if (_controller.showLoading.value) {
        return const Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ByColor.colorC1),
          strokeWidth: 2,
        ));
      }

      if (_controller.detailsData.value?.type == 2) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light, // 状态栏白色字体
          child: Scaffold(
            backgroundColor: ByColor.colorBg1,
            // 不要 appBar
            body: SafeArea(
              top: true,
              bottom: false,
              child: MultiStatusView(
                currentStatus: _controller.statusType.value,
                action: () {
                  _controller.getStrategyGuideDetail();
                },
                child: Stack(
                  children: [
                    ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _videoContent(),
                      ],
                    ),
                    _bottomButton(),
                    // 如需自定义返回按钮，可用 Positioned 放在左上角
                    Positioned(
                      top: 10,
                      left: 15,
                      child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlphaValue(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              "assets/global/common/btn_close.png",
                              width: 40,
                              height: 40,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        // 图文模式布局
        return Scaffold(
          backgroundColor: ByColor.colorBg1,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Get.back();
              },
              child: Container(
                width: 30,
                alignment: Alignment.center,
                child: Image.asset(
                        "assets/global/common/btn_back.png",
                        width: 16,
                        height: 16,
                      ),
              ),
            ),
            title: Obx(() => ByText.text(
              text: _controller.showTitle.value,
              textColor: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            )),
            centerTitle: true,
          ),
          body: MultiStatusView(
            currentStatus: _controller.statusType.value,
            action: () {
              _controller.getStrategyGuideDetail();
            },
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView(
                    // physics: _controller.detailsData.value?.type == 1 &&
                    //         _controller.userInfo?.isVip == 0
                    //     ? const NeverScrollableScrollPhysics()
                    //     : const AlwaysScrollableScrollPhysics(),
                    physics: _controller.detailsData.value?.type == 1 &&
                            _controller.userInfo?.isVip == 0 &&
                            _controller.detailsData.value?.isFree == 2
                        ? const NeverScrollableScrollPhysics()
                        : const AlwaysScrollableScrollPhysics(),
                    controller: _controller.scrollController,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Image.network(
                                _controller.detailsData.value?.authorAvatar ??
                                    "",
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 32,
                                    height: 32,
                                    color: ByColor.colorBg2,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 260.w),
                              child: ByText.text(
                                  text: _controller
                                          .detailsData.value?.authorName ??
                                      "",
                                  textColor: ByColor.colorF2,
                                  maxLines: 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _textListView(),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _vipHint(),
                ),
              ],
            ),
          ),
        );
      }
    });
  }
}
