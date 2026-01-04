import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/core/constants/api_constants.dart';

class StorageService extends GetxService {
  static StorageService get instance => Get.find<StorageService>();

  late Box _box;

  Future<StorageService> init() async {
    _box = Hive.box('authBox');
    return this;
  }

  Future<void> saveToken(String token) async {
    await _box.put(ApiConstants.jwtTokenKey, token);
  }

  Future<String?> getToken() async {
    return _box.get(ApiConstants.jwtTokenKey);
  }

  Future<void> saveUser(UserModel user) async {
    await _box.put(ApiConstants.userDataKey, user.toJson());
  }

  Future<UserModel?> getUser() async {
    final userData = _box.get(ApiConstants.userDataKey);
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}