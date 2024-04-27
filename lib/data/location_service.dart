import 'package:geolocator/geolocator.dart';

import '../domain/entity/coordinates.dart';

abstract class AppLocation {
  Future<AppLatLong> getCurrentLocation();

  Future<bool> requestPermission();

  Future<bool> checkPermission();
}

class LocationService implements AppLocation{
  final defLocation = const KazanLocation();

  // Future<void> checkPermission() async {
  //   LocationPermission permission = await Geolocator.checkPermission();
  //
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //
  //     if (permission == LocationPermission.denied) {
  //       // Handle the case where the user denied the permission
  //       return;
  //     }
  //   }
  // }


  @override
  Future<AppLatLong> getCurrentLocation() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium).then((value) {
      return AppLatLong(lat: value.latitude, long: value.longitude);
    }).catchError(
          (_) => defLocation,
    );
  }

  @override
  Future<bool> requestPermission() {
    return Geolocator.requestPermission()
        .then((value) =>
    value == LocationPermission.always ||
        value == LocationPermission.whileInUse)
        .catchError((_) => false);
  }

  @override
  Future<bool> checkPermission() {
    return Geolocator.checkPermission()
        .then((value) =>
    value == LocationPermission.always ||
        value == LocationPermission.whileInUse)
        .catchError((_) => false);
  }


}

