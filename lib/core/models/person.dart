/// Person model and mobility enum used in Group details and predictions.

enum Mobility {
  fullyMobile,
  assisted,
  wheelchair,
  limitedEndurance,
  childCarried,
}

String mobilityLabel(Mobility m) {
  switch (m) {
    case Mobility.fullyMobile:
      return 'Fully mobile';
    case Mobility.assisted:
      return 'Assisted';
    case Mobility.wheelchair:
      return 'Wheelchair';
    case Mobility.limitedEndurance:
      return 'Limited endurance';
    case Mobility.childCarried:
      return 'Child carried';
  }
}

class Person {
  final String id;
  final int age;
  final Mobility mobility;

  const Person({
    required this.id,
    required this.age,
    required this.mobility,
  });

  Person copyWith({
    String? id,
    int? age,
    Mobility? mobility,
  }) {
    return Person(
      id: id ?? this.id,
      age: age ?? this.age,
      mobility: mobility ?? this.mobility,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'age': age,
        'mobility': mobility.name,
      };

  factory Person.fromMap(Map<String, dynamic> m) => Person(
        id: m['id'] as String,
        age: (m['age'] as num).toInt(),
        mobility: Mobility.values
            .firstWhere((e) => e.name == (m['mobility'] as String)),
      );

  @override
  String toString() => 'Person($id, $age, ${mobility.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person &&
          other.id == id &&
          other.age == age &&
          other.mobility == mobility;

  @override
  int get hashCode => Object.hash(id, age, mobility);
}
