
import 'package:get/get.dart';
import 'package:novel_oversea/tutorial/controller/tutorial_details_controller.dart';

class TutorialDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TutorialDetailController(id: Get.arguments["id"] ?? 0));
  }
}
