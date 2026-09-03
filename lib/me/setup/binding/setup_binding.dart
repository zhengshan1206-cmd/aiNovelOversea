
import 'package:get/get.dart';
import 'package:novel_oversea/me/setup/controller/setup_controller.dart';

class SetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SetupController());
  }
}
