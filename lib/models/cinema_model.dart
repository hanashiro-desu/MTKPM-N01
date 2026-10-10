

class CinemaModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String image;
  final List<RoomModel> rooms;

  const CinemaModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.image,
    required this.rooms,
  });

  /// Dòng bảng `cinemas` (kèm `rooms(*)` nếu select lồng).
  factory CinemaModel.fromRow(Map<String, dynamic> row) {
    final rooms = (row['rooms'] as List<dynamic>? ?? const [])
        .map((e) => RoomModel.fromRow(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return CinemaModel(
      id: row['id'].toString(),
      name: (row['name'] ?? '').toString(),
      address: (row['address'] ?? '').toString(),
      phone: (row['phone'] ?? '').toString(),
      image: (row['image_url'] ?? '').toString(),
      rooms: rooms,
    );
  }

  Map<String, dynamic> toRow() => {
        'id': id,
        'name': name,
        'address': address,
        'phone': phone,
        'image_url': image,
      };
}

class RoomModel {
  final String id;
  final String name;
  final String type;
  final int seatCount;

  const RoomModel({
    required this.id,
    required this.name,
    required this.type,
    required this.seatCount,
  });

  factory RoomModel.fromRow(Map<String, dynamic> row) => RoomModel(
        id: row['id'].toString(),
        name: (row['name'] ?? '').toString(),
        type: (row['type'] ?? '2D').toString(),
        seatCount: (row['seat_count'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toRow(String cinemaId) => {
        'id': id,
        'cinema_id': cinemaId,
        'name': name,
        'type': type,
        'seat_count': seatCount,
      };
}
