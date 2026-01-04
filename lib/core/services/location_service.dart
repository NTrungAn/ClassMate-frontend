import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService extends GetxService {
  static LocationService get instance => Get.find<LocationService>();

  Future<String> getCurrentLocationName() async {
    try {
      // Kiểm tra quyền vị trí
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return "Chưa cấp quyền truy cập vị trí";
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return "Đã từ chối vĩnh viễn quyền truy cập vị trí";
      }

      // Lấy vị trí hiện tại
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      );

      // Chuyển tọa độ thành địa chỉ - sửa tham số localeIdentifier
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // Xây dựng tên địa điểm
        String locationName = '';

        // Thử các cấp độ địa điểm từ chi tiết đến tổng quát
        if (place.street != null && place.street!.isNotEmpty) {
          locationName = place.street!;
        }

        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          if (locationName.isNotEmpty) {
            locationName += ', ${place.subLocality}';
          } else {
            locationName = place.subLocality!;
          }
        }

        if (place.locality != null && place.locality!.isNotEmpty) {
          if (locationName.isNotEmpty) {
            locationName += ', ${place.locality}';
          } else {
            locationName = place.locality!;
          }
        }

        if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          if (locationName.isEmpty || !locationName.contains(place.subAdministrativeArea!)) {
            if (locationName.isNotEmpty) {
              locationName += ', ${place.subAdministrativeArea}';
            } else {
              locationName = place.subAdministrativeArea!;
            }
          }
        }

        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          if (locationName.isEmpty || !locationName.contains(place.administrativeArea!)) {
            if (locationName.isNotEmpty) {
              locationName += ', ${place.administrativeArea}';
            } else {
              locationName = place.administrativeArea!;
            }
          }
        }

        // Thêm quốc gia nếu có
        if (place.country != null && place.country!.isNotEmpty) {
          if (locationName.isNotEmpty && !locationName.contains(place.country!)) {
            locationName += ', ${place.country}';
          } else if (locationName.isEmpty) {
            locationName = place.country!;
          }
        }

        // Nếu không lấy được địa điểm cụ thể, trả về tọa độ
        if (locationName.isEmpty) {
          locationName = "Vị trí: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
        }

        return locationName;
      }

      return "Không thể xác định địa điểm";
    } on Exception catch (e) {
      print("Location error: $e");
      return "Lỗi khi lấy vị trí";
    } catch (e) {
      print("Location error: $e");
      return "Không thể lấy vị trí hiện tại";
    }
  }

  // Kiểm tra xem có quyền truy cập vị trí không
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // Yêu cầu quyền truy cập vị trí
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // Lấy vị trí gần đúng (chỉ có thành phố/tỉnh)
  Future<String> getSimpleLocation() async {
    try {
      if (!await hasLocationPermission()) {
        await requestLocationPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 5),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // Ưu tiên lấy tên thành phố/tỉnh
        if (place.locality != null && place.locality!.isNotEmpty) {
          return place.locality!;
        }

        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          return place.administrativeArea!;
        }

        if (place.country != null && place.country!.isNotEmpty) {
          return place.country!;
        }
      }

      return "Vị trí không xác định";
    } catch (e) {
      return "Không thể lấy vị trí";
    }
  }

  // Lấy tọa độ
  Future<Map<String, double>?> getCoordinates() async {
    try {
      if (!await hasLocationPermission()) {
        await requestLocationPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      return null;
    }
  }
}