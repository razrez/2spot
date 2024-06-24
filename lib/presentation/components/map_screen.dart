import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../data/location_service.dart';
import '../../domain/entity/coordinates.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final YandexMapController _mapController;
  var _mapZoom = 0.0;

  Future<void> _initPermission() async {
    if (!await LocationService().checkPermission()) {
      await LocationService().requestPermission();
    }
    await _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    AppLatLong location;
    const defLocation = KazanLocation();
    try {
      location = await LocationService().getCurrentLocation();
    } catch (_) {
      location = defLocation;
    }

    _moveToCurrentLocation(location);
  }

  Future<void> _moveToCurrentLocation(AppLatLong appLatLong,) async {
    await _mapController.moveCamera(
      animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: appLatLong.lat,
            longitude: appLatLong.long,
          ),
          zoom: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Текущее местоположение'),
      ),
      body: YandexMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        mapObjects: [
          _getClusterizedCollection(
            placemarks: _getPlacemarkObjects(context),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initPermission().ignore();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  ClusterizedPlacemarkCollection _getClusterizedCollection({
    required List<PlacemarkMapObject> placemarks,
  }) {
    return ClusterizedPlacemarkCollection(
        mapId: const MapObjectId('clusterized-1'),
        placemarks: placemarks,
        radius: 50,
        minZoom: 15,
        onClusterAdded: (self, cluster) async {
          return cluster.copyWith(
            appearance: cluster.appearance.copyWith(
              opacity: 1.0,
              icon: PlacemarkIcon.single(
                PlacemarkIconStyle(
                  image: BitmapDescriptor.fromAssetImage(
                    'assets/icons/map_point.png',
                  ),
                ),
              ),
            ),
          );
        },
        onClusterTap: (self, cluster) async {
          await _mapController.moveCamera(
            animation: const MapAnimation(
                type: MapAnimationType.linear, duration: 0.3),
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: cluster.placemarks.first.point,
                zoom: _mapZoom + 1,
              ),
            ),
          );
        });
  }

}


/// Метод для генерации точек на карте
List<MapPoint> _getMapSpots() {
  return [
    MapPoint(name: 'Москва', location: MoscowLocation()),
    MapPoint(name: 'Казань', location: KazanLocation()),
    MapPoint(name: 'Лондон', location: AppLatLong(lat: 51.507351, long: -0.127696)),
    MapPoint(name: 'Рим', location: AppLatLong(lat: 41.887064, long: 12.504809)),
    MapPoint(name: 'Париж', location: AppLatLong(lat: 48.856663, long: 2.351556)),
    MapPoint(name: 'Стокгольм', location: AppLatLong(lat: 59.347360, long: 18.341573)),
  ];
}


/// Метод для генерации объектов маркеров для отображения на карте
List<PlacemarkMapObject> _getPlacemarkObjects(BuildContext context) {
  return _getMapSpots()
      .map((point) => PlacemarkMapObject(
    mapId: MapObjectId('MapObject $point'),
    point: Point(latitude: point.location.lat, longitude: point.location.long),
    opacity: 1,
    icon: PlacemarkIcon.single(
      PlacemarkIconStyle(
        image: BitmapDescriptor.fromAssetImage(
          'assets/icons/map_point.png',
        ),
        scale: 2,
      ),
    ),
    onTap: (_, __) => showModalBottomSheet(
      context: context,
      builder: (context) => _ModalBodyView(
        point: point,
      ),
    ),
  ),
  ).toList();
}


/// Содержимое модального окна с информацией о точке на карте
class _ModalBodyView extends StatelessWidget {
  const _ModalBodyView({required this.point});

  final MapPoint point;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(point.name, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          Text(
            '${point.location.lat}, ${point.location.long}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}