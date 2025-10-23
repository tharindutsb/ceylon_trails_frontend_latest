/// Location model + enums + helper labels used throughout UI screens.

enum LocType { nature, cultural, religious }

enum Terrain { flat, hilly, mixed }

enum Access { full, partial, limited }

enum Heat { low, medium, high }

String locTypeLabel(LocType t) {
  switch (t) {
    case LocType.nature:
      return 'nature';
    case LocType.cultural:
      return 'cultural';
    case LocType.religious:
      return 'religious';
  }
}

String terrainLabel(Terrain t) {
  switch (t) {
    case Terrain.flat:
      return 'flat';
    case Terrain.hilly:
      return 'hilly';
    case Terrain.mixed:
      return 'mixed';
  }
}

String accessLabel(Access a) {
  switch (a) {
    case Access.full:
      return 'full';
    case Access.partial:
      return 'partial';
    case Access.limited:
      return 'limited';
  }
}

String heatLabel(Heat h) {
  switch (h) {
    case Heat.low:
      return 'low';
    case Heat.medium:
      return 'medium';
    case Heat.high:
      return 'high';
  }
}

class LocationItem {
  final String id;
  final String name;
  final LocType type;
  final Terrain terrain;
  final Access access;
  final Heat heat;

  /// Preferred visiting window (HH:MM)
  final String prefStart;
  final String prefEnd;

  /// Optional UX additions
  final String? desc;
  final String? imageUrl;
  final double? rating;
  final String? city;

  /// A suggested duration you might show in Review & Predict (minutes)
  final int suggestedDurationMin;

  const LocationItem({
    required this.id,
    required this.name,
    required this.type,
    required this.terrain,
    required this.access,
    required this.heat,
    required this.prefStart,
    required this.prefEnd,
    this.desc,
    this.imageUrl,
    this.rating,
    this.city,
    this.suggestedDurationMin = 90,
  });

  LocationItem copyWith({
    String? id,
    String? name,
    LocType? type,
    Terrain? terrain,
    Access? access,
    Heat? heat,
    String? prefStart,
    String? prefEnd,
    String? desc,
    String? imageUrl,
    double? rating,
    String? city,
    int? suggestedDurationMin,
  }) {
    return LocationItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      terrain: terrain ?? this.terrain,
      access: access ?? this.access,
      heat: heat ?? this.heat,
      prefStart: prefStart ?? this.prefStart,
      prefEnd: prefEnd ?? this.prefEnd,
      desc: desc ?? this.desc,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      city: city ?? this.city,
      suggestedDurationMin: suggestedDurationMin ?? this.suggestedDurationMin,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type.name,
        'terrain': terrain.name,
        'access': access.name,
        'heat': heat.name,
        'prefStart': prefStart,
        'prefEnd': prefEnd,
        'desc': desc,
        'imageUrl': imageUrl,
        'rating': rating,
        'city': city,
        'suggestedDurationMin': suggestedDurationMin,
      };

  factory LocationItem.fromMap(Map<String, dynamic> m) => LocationItem(
        id: m['id'] as String,
        name: m['name'] as String,
        type: LocType.values.firstWhere((e) => e.name == m['type']),
        terrain: Terrain.values.firstWhere((e) => e.name == m['terrain']),
        access: Access.values.firstWhere((e) => e.name == m['access']),
        heat: Heat.values.firstWhere((e) => e.name == m['heat']),
        prefStart: m['prefStart'] as String,
        prefEnd: m['prefEnd'] as String,
        desc: m['desc'] as String?,
        imageUrl: m['imageUrl'] as String?,
        rating: (m['rating'] as num?)?.toDouble(),
        city: m['city'] as String?,
        suggestedDurationMin:
            (m['suggestedDurationMin'] as num?)?.toInt() ?? 90,
      );
}
