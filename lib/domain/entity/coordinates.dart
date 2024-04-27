class AppLatLong {
  final double lat;
  final double long;

  const AppLatLong({
    required this.lat,
    required this.long,
  });
}

class MoscowLocation extends AppLatLong {
  const MoscowLocation({
    super.lat = 55.7522200,
    super.long = 37.6155600,
  });
}

class KazanLocation extends AppLatLong {
  const KazanLocation({
    super.lat = 55.78874,
    super.long = 49.12214,
  });
}