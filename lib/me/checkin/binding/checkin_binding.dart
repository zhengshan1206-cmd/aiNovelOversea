import 'package:get/get.dart';
import '../controller/checkin_controller.dart';

class CheckinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CheckinController());
  }
}