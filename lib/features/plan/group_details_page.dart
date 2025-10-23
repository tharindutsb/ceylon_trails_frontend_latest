import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../state/plan_provider.dart';
import '../../core/models/person.dart';
import '../../core/router/app_router.dart';
import '../../widgets/animated_gradient_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/mobility_picker.dart';

class GroupDetailsPage extends StatefulWidget {
  const GroupDetailsPage({super.key});
  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final plan = context.watch<PlanProvider>();
    final g = plan.group;
    final cs = Theme.of(context).colorScheme;

    return AnimatedGradientScaffold(
      appBar: AppBar(title: const Text('Group Details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
        children: [
          Row(
            children: [
              Text('Your group',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _openEditor(context),
                icon: const Icon(Icons.add),
                label: const Text('Add person'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // People list
          if (g.people.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: const [
                  Icon(Icons.family_restroom_rounded,
                      size: 64, color: Colors.white54),
                  SizedBox(height: 10),
                  Text('No people yet',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            )
          else
            ...g.people.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cs.primary.withOpacity(.15),
                        child: Text('${p.age}',
                            style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text('${p.age} years'),
                      subtitle: Text(mobilityLabel(p.mobility)),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _openEditor(context, initial: p),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => plan.removePerson(p.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),

          const SizedBox(height: 10),

          // Planned start
          ListTile(
            title: const Text('Planned start (optional)'),
            subtitle: Text(g.plannedStartHHMM ?? 'Not set'),
            trailing: IconButton(
              icon: const Icon(Icons.schedule),
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  plan.setPlannedStart(
                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 16),

          // Next
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              if (g.people.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add at least one person')),
                );
                return;
              }
              Navigator.pushNamed(context, AppRoutes.choose);
            },
            child: const Text('Next: Choose Location'),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, {Person? initial}) async {
    final createdOrUpdated = await showModalBottomSheet<Person>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PersonEditor(initial: initial),
    );
    if (createdOrUpdated != null && mounted) {
      final plan = context.read<PlanProvider>();
      if (initial == null) {
        plan.addPerson(createdOrUpdated);
      } else {
        plan.updatePerson(createdOrUpdated);
      }
    }
  }
}

class _PersonEditor extends StatefulWidget {
  const _PersonEditor({this.initial});
  final Person? initial;

  @override
  State<_PersonEditor> createState() => _PersonEditorState();
}

class _PersonEditorState extends State<_PersonEditor> {
  late int age;
  late Mobility mobility;
  late TextEditingController _ageCtl;

  @override
  void initState() {
    super.initState();
    age = widget.initial?.age ?? 30;
    mobility = widget.initial?.mobility ?? Mobility.fullyMobile;
    _ageCtl = TextEditingController(text: age.toString());
  }

  @override
  void dispose() {
    _ageCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEdit = widget.initial != null;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                isEdit ? 'Edit person' : 'Add person',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            Text('Age', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      age = age > 1 ? age - 1 : 1;
                      _ageCtl.text = age.toString();
                    });
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 96),
                  child: TextField(
                    controller: _ageCtl,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null && n >= 1 && n <= 109) {
                        setState(() => age = n);
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      age = age < 109 ? age + 1 : 109;
                      _ageCtl.text = age.toString();
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Mobility', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            MobilityPicker(
              value: mobility,
              onChanged: (m) => setState(() => mobility = m),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final p = Person(
                    id: widget.initial?.id ??
                        DateTime.now().microsecondsSinceEpoch.toString(),
                    age: age,
                    mobility: mobility,
                  );
                  Navigator.pop(context, p);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.black,
                ),
                child: Text(isEdit ? 'Save' : 'Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
