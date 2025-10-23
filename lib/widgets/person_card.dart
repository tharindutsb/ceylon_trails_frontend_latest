import 'package:flutter/material.dart';
import '../core/models/person.dart';

/// Compact person row with age + mobility + actions.
class PersonCard extends StatelessWidget {
  const PersonCard({
    super.key,
    required this.person,
    this.onEdit,
    this.onRemove,
  });

  final Person person;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.07)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primary.withOpacity(.15),
          child: Text('${person.age}',
              style: const TextStyle(color: Colors.white)),
        ),
        title: Text('${person.age} years'),
        subtitle: Text(mobilityLabel(person.mobility)),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
            IconButton(
                onPressed: onRemove, icon: const Icon(Icons.delete_outline)),
          ],
        ),
      ),
    );
  }
}
