import 'package:get/get.dart';

class AccountController extends GetxController {
  static AccountController get to => Get.find();

  var apiKey = "".obs;
  var userId = "".obs;

  void setApiKey(String value) {
    apiKey.value = value;
  }

  void setUserId(String value) {
    userId.value = value;
  }
}
