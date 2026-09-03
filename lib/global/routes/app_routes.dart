/*
 * @Author: cold-x
 * @Date: 2025-05-28 14:34:40
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-15 18:36:50
 * @FilePath: /novel_oversea/lib/global/routes/app_routes.dart
 * @Description: 
 */
part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  /*
    全局路由定义
  */

  ///启动页
  static const launch = '/launch';

  ///启动失败页
  static const launchFail = '/launch_fail';

  ///主页
  static const main = '/main';

  ///首页
  static const home = '/home';

  ///广场
  static const square = '/square';

  ///我的
  static const profile = '/profile';

  ///登录
  static const login = '/login';
  static const loginPhone = '/login_phone';

  /*
    首页广场页路由定义
  */
  ///广场专区
  static const squareZone = '/square_zone';

  ///广场列表详情
  static const tutorialDetail = '/strategy_details_page';

  /*
    小说主页路由
  */

  ///小说主页
  static const novelHome = '/novel_home';

  ///小说列表记录页
  static const novelRecord = '/novel_record';

  ///小说创作页
  static const novelCreate = '/novel_create';

  ///小说创作分类页
  static const novelCreateCategory = '/novel_create_category';

  ///小说创作对话页
  static const novelCreateChat = '/novel_create_chat';

  ///小说创作页/灵感页
  static const novelCreateBrief = '/novel_create_brief';

  ///小说创作页/大纲页
  static const novelCreateOutline = '/novel_create_outline';

  ///小说创作页/大纲生成页、流式输出页
  static const novelCreateOutlineDetail = '/novel_create_outline_detail';

  ///小说创作页/细纲页
  static const novelCreateChapter = '/novel_create_chapter';

  ///小说创作页/章节细纲生成页、流式输出页
  static const novelCreateChapterDetail = '/novel_create_chapter_detail';

  ///小说创作页/一键成文页
  static const novelCreateNovel = '/novel_create_novel';

  ///短篇创作
  static const shortNovel = '/short_novel';

  ///创作记录页
  static const record = '/record';

  /*
    个人中心
  */

  ///个人中心页
  static const userProfile = '/user_profile';

  ///引导页
  static const guide = '/guide';

  ///违禁词页
  static const illegalWords = '/illegal_words';

  ///设置
  static const setting = '/setting';

  ///消息
  static const message = '/message';

  ///关于我们
  static const aboutUs = '/aboutUs';

  ///用户反馈
  static const feedback = '/feedback';

  ///新版付费页
  static const payCenterPage = '/pay_center_page';

  ///支付成功
  static const memberPaySuccess = '/member_pay_success';

  ///积分商品消耗列表页
  static const creditsItemList = '/credits_item_list';

  ///新用户支付页
  static const newUserPayPage = '/new_user_pay_page';

  ///签到页
  static const checkinPage = '/checkin';

  ///调查问卷
  static const surveyPage = '/survey';
}
