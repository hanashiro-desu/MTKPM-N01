import 'package:moviego/models/cinema_model.dart';

const List<CinemaModel> demoCinemas = [
  CinemaModel(
    id: 'c1',
    name: 'CGV Vincom Center',
    address: '123 Lê Văn Việt, Quận 9',
    phone: '0909123456',
    image: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=900&q=80',
    rooms: [
      RoomModel(id: 'r1', name: 'Room 1', type: 'IMAX', seatCount: 80),
      RoomModel(id: 'r2', name: 'Room 2', type: '2D', seatCount: 60),
    ],
  ),
  CinemaModel(
    id: 'c2',
    name: 'Lotte Cinema',
    address: '45 Nguyễn Huệ, Quận 1',
    phone: '0909888777',
    image: 'https://images.unsplash.com/photo-1513106580091-1d82408b8cd6?auto=format&fit=crop&w=900&q=80',
    rooms: [
      RoomModel(id: 'r3', name: 'Room 3', type: '3D', seatCount: 70),
      RoomModel(id: 'r4', name: 'Room 4', type: 'VIP', seatCount: 50),
    ],
  ),
  CinemaModel(
    id: 'c3',
    name: 'Galaxy Cinema',
    address: '88 Hàm Nghi, Quận 3',
    phone: '0909000111',
    image: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=900&q=80',
    rooms: [
      RoomModel(id: 'r5', name: 'Room 5', type: '4DX', seatCount: 90),
    ],
  ),
];
