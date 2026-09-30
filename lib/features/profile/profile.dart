import '../../core/constants/age_group.dart';

/// Bola tanlashi mumkin bo'lgan avatarlar.
const kAvatars = ['🐱', '🐶', '🦊', '🐼', '🐸', '🐵', '🐰', '🦁'];

class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.avatar,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int age;
  final String avatar;
  final DateTime createdAt;

  AgeGroup get ageGroup => AgeGroup.fromAge(age);

  Map<String, Object> toMap() => {
        'id': id,
        'name': name,
        'age': age,
        'avatar': avatar,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Profile.fromMap(Map<dynamic, dynamic> map) => Profile(
        id: map['id'] as String,
        name: map['name'] as String,
        age: map['age'] as int,
        avatar: map['avatar'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      );
}
