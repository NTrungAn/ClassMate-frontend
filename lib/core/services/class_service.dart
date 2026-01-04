import 'package:get/get.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/models/class_model.dart';

class ClassService extends GetxService {
  static ClassService get instance => Get.find<ClassService>();

  Future<List<ClassSection>> getMyClasses() async {
    final response = await ApiService.instance.get(ApiConstants.myClasses);

    if (response != null && response is List) {
      return response
          .map<ClassSection>((item) => ClassSection.fromJson(item))
          .toList();
    }

    return [];
  }

  Future<ClassSection?> getClassById(int id) async {
    final response =
    await ApiService.instance.get('${ApiConstants.classById}/$id');

    if (response != null && response is Map<String, dynamic>) {
      return ClassSection.fromJson(response);
    }

    return null;
  }

  Future<bool> joinClass(String classCode) async {
    final response = await ApiService.instance.post(
      ApiConstants.enrollClass,
      {'classCode': classCode},
    );

    return response != null;
  }
}
