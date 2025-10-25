// lib/core/seed/locations_seed.dart
//
// Rich demo seed data for Choose / Review / Build Schedule flows.
// Uses LocationItem and enums from core/models/location.dart

import '../models/location.dart';

final List<LocationItem> kSeedLocations = <LocationItem>[
  // ====== KANDY ======
  LocationItem(
    id: 'rb_peradeniya',
    name: 'Royal Botanic Gardens, Peradeniya',
    type: LocType.nature,
    terrain: Terrain.flat,
    access: Access.full,
    heat: Heat.high,
    prefStart: '08:00',
    prefEnd: '11:00',
    desc:
        'Expansive gardens with orchids and palm avenues. Shaded paths; great for families.',
    imageUrl:
        'https://images.unsplash.com/photo-1558981806-ec527fa84c39?q=80&w=1600',
    rating: 4.6,
    voteCount: 1247,
    city: 'Kandy',
    suggestedDurationMin: 90,
  ),
  LocationItem(
    id: 'temple_tooth',
    name: 'Sri Dalada Maligawa (Temple of the Tooth)',
    type: LocType.religious,
    terrain: Terrain.flat,
    access: Access.full,
    heat: Heat.medium,
    prefStart: '08:00',
    prefEnd: '11:00',
    desc:
        'Sacred Buddhist temple housing the tooth relic. Mornings are calmer for rituals.',
    imageUrl:
        'https://images.unsplash.com/photo-1539185441755-769473a23570?q=80&w=1600',
    rating: 4.8,
    voteCount: 2156,
    city: 'Kandy',
    suggestedDurationMin: 78,
  ),
  LocationItem(
    id: 'kandy_lake_walk',
    name: 'Kandy Lake Walk',
    type: LocType.nature,
    terrain: Terrain.flat,
    access: Access.full,
    heat: Heat.high,
    prefStart: '16:00',
    prefEnd: '18:30',
    desc:
        'Easy stroll around Kandy Lake. Perfect at golden hour; city and temple views.',
    imageUrl:
        'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?q=80&w=1600',
    rating: 4.5,
    voteCount: 892,
    city: 'Kandy',
    suggestedDurationMin: 68,
  ),
  LocationItem(
    id: 'udawatta_kelle',
    name: 'Udawatta Kele Sanctuary',
    type: LocType.nature,
    terrain: Terrain.hilly,
    access: Access.partial,
    heat: Heat.medium,
    prefStart: '08:00',
    prefEnd: '10:30',
    desc:
        'Forest above the city with birdlife and canopy views. Some uneven paths.',
    imageUrl:
        'https://images.unsplash.com/photo-1483794344563-d27a8d18014e?q=80&w=1600',
    rating: 4.3,
    voteCount: 634,
    city: 'Kandy',
    suggestedDurationMin: 80,
  ),
  LocationItem(
    id: 'bahirawakanda',
    name: 'Bahirawakanda Vihara Buddha Statue',
    type: LocType.religious,
    terrain: Terrain.hilly,
    access: Access.partial,
    heat: Heat.medium,
    prefStart: '16:30',
    prefEnd: '18:30',
    desc:
        'Hilltop Buddha with sweeping city views. Some steps and steep road sections.',
    imageUrl:
        'https://images.unsplash.com/photo-1548013146-72479768bada?q=80&w=1600',
    rating: 4.7,
    voteCount: 1456,
    city: 'Kandy',
    suggestedDurationMin: 60,
  ),
  LocationItem(
    id: 'cultural_dance',
    name: 'Kandyan Cultural Dance Show',
    type: LocType.cultural,
    terrain: Terrain.flat,
    access: Access.full,
    heat: Heat.low,
    prefStart: '17:30',
    prefEnd: '19:00',
    desc:
        'Traditional drumming, costumes, and fire-walking performance. Indoor seating.',
    imageUrl:
        'https://images.unsplash.com/photo-1520975858868-6d69b983c6e8?q=80&w=1600',
    rating: 4.4,
    voteCount: 723,
    city: 'Kandy',
    suggestedDurationMin: 75,
  ),

  // ====== SIGIRIYA / DAMBULLA ======
  LocationItem(
    id: 'sigiriya_rock',
    name: 'Sigiriya Rock Fortress',
    type: LocType.cultural,
    terrain: Terrain.hilly,
    access: Access.partial,
    heat: Heat.high,
    prefStart: '07:00',
    prefEnd: '09:30',
    desc:
        'UNESCO site. Iconic rock citadel with frescoes. Many steps; best early morning.',
    imageUrl:
        'https://images.unsplash.com/photo-1600059832058-5b5503fcd1da?q=80&w=1600',
    rating: 4.8,
    voteCount: 3245,
    city: 'Sigiriya',
    suggestedDurationMin: 120,
  ),
  LocationItem(
    id: 'pidurangala',
    name: 'Pidurangala Rock Hike',
    type: LocType.nature,
    terrain: Terrain.hilly,
    access: Access.partial,
    heat: Heat.high,
    prefStart: '05:30',
    prefEnd: '08:00',
    desc:
        'Sunrise hike facing Sigiriya Rock. Scramble at top; bring a headlamp early.',
    imageUrl:
        'https://images.unsplash.com/photo-1591604466107-ec97de577aff?q=80&w=1600',
    rating: 4.7,
    voteCount: 1876,
    city: 'Sigiriya',
    suggestedDurationMin: 100,
  ),
  LocationItem(
    id: 'dambulla_caves',
    name: 'Dambulla Cave Temple',
    type: LocType.religious,
    terrain: Terrain.hilly,
    access: Access.partial,
    heat: Heat.medium,
    prefStart: '08:00',
    prefEnd: '10:30',
    desc:
        'Rock temples with gilded Buddha statues and murals. Hill climb involved.',
    imageUrl:
        'https://images.unsplash.com/photo-1566511443741-b0b8a2a4e8d2?q=80&w=1600',
    rating: 4.6,
    voteCount: 1567,
    city: 'Dambulla',
    suggestedDurationMin: 90,
  ),

  // ====== GALLE / SOUTH ======
  LocationItem(
    id: 'galle_fort',
    name: 'Galle Fort Ramparts Walk',
    type: LocType.cultural,
    terrain: Terrain.flat,
    access: Access.full,
    heat: Heat.high,
    prefStart: '16:30',
    prefEnd: '18:30',
    desc:
        'UNESCO fort town with colonial streets and rampart sunsets. Cafés and boutiques.',
    imageUrl:
        'https://images.unsplash.com/photo-1593175278720-9b5f8d8eabe3?q=80&w=1600',
    rating: 4.7,
    voteCount: 2134,
    city: 'Galle',
    suggestedDurationMin: 75,
  ),
  LocationItem(
    id: 'unawatuna_beach',
    name: 'Unawatuna Beach',
    type: LocType.nature,
    terrain: Terrain.flat,
    access: Access.full,
    heat: Heat.high,
    prefStart: '16:00',
    prefEnd: '18:30',
    desc:
        'Popular sandy bay; swimming and casual dining. Shade limited mid-day.',
    imageUrl:
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1600',
    rating: 4.5,
    voteCount: 1789,
    city: 'Galle',
    suggestedDurationMin: 120,
  ),
  LocationItem(
    id: 'jungle_beach',
    name: 'Jungle Beach (light trail)',
    type: LocType.nature,
    terrain: Terrain.mixed,
    access: Access.partial,
    heat: Heat.high,
    prefStart: '08:00',
    prefEnd: '10:30',
    desc:
        'Small cove reached via short trail. Calm waters; a few uneven sections.',
    imageUrl:
        'https://images.unsplash.com/photo-1545420331-8cf36410d3f3?q=80&w=1600',
    rating: 4.3,
    voteCount: 456,
    city: 'Galle',
    suggestedDurationMin: 90,
  ),

  // ====== COLOMBO ======
  LocationItem(
    id: 'gangaramaya',
    name: 'Gangaramaya Temple',
    type: LocType.religious,
    terrain: Terrain.flat,
    access: Access.full,
    heat: Heat.medium,
    prefStart: '09:00',
    prefEnd: '11:30',
    desc:
        'Eclectic Buddhist temple with museum artifacts and Beira Lake pavilion.',
    imageUrl:
        'https://images.unsplash.com/photo-1527596428171-e04c408e060b?q=80&w=1600',
    rating: 4.4,
    voteCount: 987,
    city: 'Colombo',
    suggestedDurationMin: 60,
  ),
  LocationItem(
    id: 'galle_face',
    name: 'Galle Face Green (sunset)',
    type: LocType.nature,
    terrain: Terrain.flat,
    access: Access.full,
    heat: Heat.medium,
    prefStart: '17:00',
    prefEnd: '19:00',
    desc: 'Seaside promenade popular for kites, street food, and sunsets.',
    imageUrl:
        'https://images.unsplash.com/photo-1482192505345-5655af888cc4?q=80&w=1600',
    rating: 4.3,
    voteCount: 1234,
    city: 'Colombo',
    suggestedDurationMin: 60,
  ),
  LocationItem(
    id: 'national_museum',
    name: 'National Museum of Colombo',
    type: LocType.cultural,
    terrain: Terrain.flat,
    access: Access.full,
    heat: Heat.low,
    prefStart: '10:00',
    prefEnd: '16:00',
    desc: 'Sri Lanka\'s largest museum with art and archaeology collections.',
    imageUrl:
        'https://images.unsplash.com/photo-1563720223185-11003d5163f3?q=80&w=1600',
    rating: 4.4,
    voteCount: 1567,
    city: 'Colombo',
    suggestedDurationMin: 80,
  ),
];

/// Quick helpers

/// Best experiences by rating (default top 4)
List<LocationItem> getBestExperiences([int take = 4]) {
  final list = List<LocationItem>.from(kSeedLocations)
    ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
  return list.take(take).toList();
}

/// Filter by city (case-insensitive)
List<LocationItem> getLocationsByCity(String city) {
  final c = city.toLowerCase();
  return kSeedLocations
      .where((e) => (e.city ?? '').toLowerCase() == c)
      .toList();
}

/// Filter by type
List<LocationItem> getLocationsByType(LocType t) =>
    kSeedLocations.where((e) => e.type == t).toList();
