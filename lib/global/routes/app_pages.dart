
import 'package:get/get.dart';
import 'package:novel_oversea/global/launch/page/launch_page.dart';
import 'package:novel_oversea/global/login/binbing/login_binding.dart';
import 'package:novel_oversea/global/login/controller/login_controller.dart';
import 'package:novel_oversea/global/login/page/login_page.dart';
import 'package:novel_oversea/global/login/page/login_phone_page.dart';
import 'package:novel_oversea/global/pay/binding/pay_binding.dart';
import 'package:novel_oversea/global/pay/page/pay_center_page.dart';
import 'package:novel_oversea/home/chapter/binding/novel_chapter_binding.dart';
import 'package:novel_oversea/home/chapter/page/novel_chapter_page.dart';
import 'package:novel_oversea/home/create/binding/choose_partner_binding.dart';
import 'package:novel_oversea/home/create/binding/create_chat_binding.dart';
import 'package:novel_oversea/home/create/binding/novel_create_binding.dart';
import 'package:novel_oversea/home/create/page/create_chat_page.dart';
import 'package:novel_oversea/home/create/page/create_partner_page.dart';
import 'package:novel_oversea/home/create/page/novel_create_page.dart';
import 'package:novel_oversea/home/detail/binding/novel_home_binding.dart';
import 'package:novel_oversea/home/detail/page/novel_home_page.dart';
import 'package:novel_oversea/home/main/page/new_user_pay_page.dart';
import 'package:novel_oversea/home/outline/binding/novel_outline_binding.dart';
import 'package:novel_oversea/home/outline/page/novel_outline_page.dart';
import 'package:novel_oversea/home/record/binding/novel_record_binding.dart';
import 'package:novel_oversea/home/record/page/novel_record_page.dart';
import 'package:novel_oversea/me/aboutus/binding/abount_us_binding.dart';
import 'package:novel_oversea/me/aboutus/page/about_us_page.dart';
import 'package:novel_oversea/me/checkin/binding/checkin_binding.dart';
import 'package:novel_oversea/me/checkin/page/checkin_page.dart';
import 'package:novel_oversea/me/credits/credits_list_page.dart';
import 'package:novel_oversea/me/main/page/feedback.dart';
import 'package:novel_oversea/me/setup/binding/setup_binding.dart';
import 'package:novel_oversea/me/setup/page/setup_page.dart';
import 'package:novel_oversea/me/setup/page/survey_page.dart';
import 'package:novel_oversea/tutorial/binding/tutorial_detail_binding.dart';
import 'package:novel_oversea/tutorial/page/tutorial_detail_page.dart';

import '../main/main_page.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    /*
    全局路由
    */

    ///启动页
    GetPage(
      name: Routes.launch,
      page: () => const LaunchPage(),
    ),

    // ///启动失败页
    // GetPage(
    //   name: Routes.launchFail,
    //   page: () => const LaunchErrorPage(),
    // ),

    // /首页
    GetPage(
        name: Routes.main,
        page: () => MainPage(),
        transition: Transition.noTransition),

    // ///首页独立路由
    // GetPage(
    //     name: Routes.home,
    //     page: () => HomePage(),
    //     transition: Transition.noTransition),

    // ///广场独立路由
    // GetPage(
    //     name: Routes.square,
    //     page: () => SquarePage(),
    //     binding: SquareBinding(),
    //     transition: Transition.noTransition),

    // ///我的独立路由
    // GetPage(
    //     name: Routes.profile,
    //     page: () => ProfilePage(),
    //     binding: ProfileBinding(),
    //     transition: Transition.noTransition),

    ///登录页
    GetPage(
      name: Routes.login,
      page: () => LoginPage(),
      binding: LoginBinding(),
      transition: Transition.downToUp
    ),

    ///登录手机页
    GetPage(
      name: Routes.loginPhone,
      page: () => LoginPhonePage(
        type: LoginType.phone,
      ),
      binding: LoginBinding(),
    ),

    ///引导页
    // GetPage(
    //   name: Routes.guide,
    //   page: () => const GuidePage(),
    //   // binding: GuideBinding(),
    // ),

    /*
      小说主页路由
    */
    ///小说主页
    GetPage(
      name: Routes.novelHome,
      page: () => NovelHomePage(),
      binding: NovelHomeBinding(),
    ),

    ///小说列表记录页
    GetPage(
      name: Routes.novelRecord,
      page: () => NovelRecordPage(),
      binding: NovelRecordBinding(),
    ),

    ///小说创作页
    GetPage(
      name: Routes.novelCreate,
      page: () => NovelCreatePage(),
      binding: NovelCreateBinding(),
    ),

    ///小说创作分类页
    GetPage(
      name: Routes.novelCreateCategory,
      page: () => ChoosePartnerPage(),
      binding: ChoosePartnerBinding(),
    ),

    ///小说创作对话页
    GetPage(
      name: Routes.novelCreateChat,
      page: () => CreateChatPage(),
      binding: CreateChatBinding(),
    ),

    ///小说创作页/大纲页
    GetPage(
      name: Routes.novelCreateOutline,
      page: () => NovelOutlinePage(),
      binding: NovelOutlineBinding(),
    ),

    ///小说创作页/细纲页
    GetPage(
      name: Routes.novelCreateChapter,
      page: () => NovelChapterPage(),
      binding: NovelChapterBinding(),
    ),

    // ///短故事、文案等创作页(短故事、推广文案、短视频脚本等)
    // GetPage(
    //   name: Routes.toolCreation,
    //   page: () => ToolCreatePage(),
    //   binding: ToolCreateBinding(),
    // ),

    // ///创作记录页
    // GetPage(
    //   name: Routes.record,
    //   page: () => BaseRecordPage(),
    //   binding: RecordBinding(),
    // ),

    // ///个人中心
    // GetPage(
    //   name: Routes.userProfile,
    //   page: () => ProfilePage(),
    //   binding: ProfileBinding(),
    // ),

    ///设置
    GetPage(
      name: Routes.setting,
      page: () => SetupPage(),
      binding: SetupBinding(),
    ),

    ///用户反馈
    GetPage(
      name: Routes.feedback,
      page: () => FeedbackPage(),
    ),

    ///关于我们
    GetPage(
      name: Routes.aboutUs,
      page: () => AboutUsPage(),
      binding: AboutUsBinding(),
    ),

    ///付费页
    GetPage(
      name: Routes.payCenterPage,
      page: () => PayCenterPage(),
      binding: PayBinding(),
      transition: Transition.downToUp,
    ),

    // ///支付成功
    // GetPage(
    //   name: Routes.memberPaySuccess,
    //   page: () => MemberPaySuccessPage(),
    //   binding: MemberPaySuccessBinding(),
    // ),

    ///攻略详情
    GetPage(
        name: Routes.tutorialDetail,
        page: () => TutorialDetailPage(),
        binding: TutorialDetailBinding()),
    
    ///积分消耗列表页
    GetPage(
        name: Routes.creditsItemList,
        page: () => CreditsListPage(),
    ),

    ///新用户支付页
    GetPage(
        name: Routes.newUserPayPage,
        page: () => NewUserPayPage(),
        transition: Transition.downToUp
    ),

    ///签到页
    GetPage(
      name: Routes.checkinPage, 
      page: () => CheckinPage(),
      binding: CheckinBinding()),

    ///调查问卷
    GetPage(
      name: Routes.surveyPage, 
      page: () => SurveyPage()),
  ];
}

class RouterUtil {
  static String initialRoute() => nextRoute();

  static String nextRoute() {
    return Routes.launch;
  }
}
