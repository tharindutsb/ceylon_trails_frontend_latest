/// Group model – holds the people and an optional planned start time.

import 'person.dart';

class Group {
  final List<Person> people;

  /// HH:MM 24h (e.g. "08:00")
  String? plannedStartHHMM;

  Group({
    List<Person>? people,
    this.plannedStartHHMM,
  }) : people = List<Person>.from(people ?? const []);

  // Mutations used by PlanProvider
  void addPerson(Person p) {
    people.add(p);
  }

  void removePerson(String personId) {
    people.removeWhere((e) => e.id == personId);
  }

  void updatePerson(Person p) {
    final i = people.indexWhere((e) => e.id == p.id);
    if (i != -1) people[i] = p;
  }

  // Convenience counts for analytics / prediction
  int get nFullyMobile =>
      people.where((p) => p.mobility == Mobility.fullyMobile).length;
  int get nAssisted =>
      people.where((p) => p.mobility == Mobility.assisted).length;
  int get nWheelchair =>
      people.where((p) => p.mobility == Mobility.wheelchair).length;
  int get nLimitedEndurance =>
      people.where((p) => p.mobility == Mobility.limitedEndurance).length;
  int get nChildCarried =>
      people.where((p) => p.mobility == Mobility.childCarried).length;

  Map<String, dynamic> toMap() => {
        'plannedStartHHMM': plannedStartHHMM,
        'people': people.map((e) => e.toMap()).toList(),
      };

  factory Group.fromMap(Map<String, dynamic> m) => Group(
        plannedStartHHMM: m['plannedStartHHMM'] as String?,
        people: (m['people'] as List<dynamic>? ?? const [])
            .map((e) => Person.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
      );
}
