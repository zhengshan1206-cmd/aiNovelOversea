

import 'package:get/get.dart';
import 'package:novel_oversea/home/create/controller/create_chat_controller.dart';

class CreateChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateChatController>(
      () => CreateChatController(),
    );
  }
}