import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/seed/locations_seed.dart';
import '../../core/models/location.dart';
import '../../state/plan_provider.dart';
import '../../widgets/animated_gradient_scaffold.dart';

class ChooseLocationPage extends StatefulWidget {
  const ChooseLocationPage({super.key});
  @override
  State<ChooseLocationPage> createState() => _ChooseLocationPageState();
}

class _ChooseLocationPageState extends State<ChooseLocationPage> {
  String q = '';
  int filterIndex = 0; // 0: all, 1: nature, 2: cultural, 3: religious

  List<LocationItem> get _filtered {
    final text = q.trim().toLowerCase();
    LocType? filter;
    if (filterIndex == 1) filter = LocType.nature;
    if (filterIndex == 2) filter = LocType.cultural;
    if (filterIndex == 3) filter = LocType.religious;

    return kSeedLocations.where((e) {
      final okType = filter == null || e.type == filter;
      final okText = text.isEmpty || e.name.toLowerCase().contains(text);
      return okType && okText;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final plan = context.read<PlanProvider>();
    final best = _filtered.take(4).toList();
    final cs = Theme.of(context).colorScheme;

    return AnimatedGradientScaffold(
      appBar: AppBar(
        title: const Text('Choose Location'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1D29),
              const Color(0xFF2D1B69),
              const Color(0xFF11998E),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          children: [
            // Enhanced Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search places…',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: Icon(Icons.search, color: cs.primary),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onChanged: (v) => setState(() => q = v),
              ),
            ),
            const SizedBox(height: 20),

            // Enhanced Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _enhancedChip(
                      0, 'All', Icons.all_inclusive, const Color(0xFF6EE7F2)),
                  const SizedBox(width: 12),
                  _enhancedChip(
                      1, 'Nature', Icons.park_rounded, const Color(0xFF4CAF50)),
                  const SizedBox(width: 12),
                  _enhancedChip(2, 'Cultural', Icons.museum_rounded,
                      const Color(0xFFFF9800)),
                  const SizedBox(width: 12),
                  _enhancedChip(3, 'Religious', Icons.temple_buddhist_rounded,
                      const Color(0xFF9C27B0)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Best Experiences Section
            if (best.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.star, color: cs.primary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Best Experiences',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: best.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, i) {
                    final loc = best[i];
                    return _buildExperienceCard(loc, plan);
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Popular Choices Section
            Row(
              children: [
                Icon(Icons.location_on, color: cs.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Popular choices',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._filtered.map((loc) => _buildLocationCard(loc, plan)),
          ],
        ),
      ),
    );
  }

  Widget _enhancedChip(int i, String label, IconData icon, Color color) {
    final selected = filterIndex == i;
    return GestureDetector(
      onTap: () => setState(() => filterIndex = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: selected ? color : Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(LocationItem loc, PlanProvider plan) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.network(
                loc.imageUrl ??
                    'https://images.unsplash.com/photo-1549880338-65ddcdfd017b?q=80&w=1200&auto=format&fit=crop',
                fit: BoxFit.cover,
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${loc.prefStart}–${loc.prefEnd}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _select(plan, loc),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Select',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(LocationItem loc, PlanProvider plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openDetails(context, plan, loc),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Location Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: loc.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(loc.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: loc.imageUrl == null
                        ? Colors.grey.withOpacity(0.3)
                        : null,
                  ),
                  child: loc.imageUrl == null
                      ? const Icon(Icons.location_on, color: Colors.white54)
                      : null,
                ),
                const SizedBox(width: 16),
                // Location Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildTag(
                              locTypeLabel(loc.type), const Color(0xFF4CAF50)),
                          _buildTag(terrainLabel(loc.terrain),
                              const Color(0xFFFF9800)),
                          _buildTag(
                              accessLabel(loc.access), const Color(0xFF2196F3)),
                          _buildTag(
                              heatLabel(loc.heat), const Color(0xFFFF5722)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.white.withOpacity(0.7),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pref: ${loc.prefStart}–${loc.prefEnd}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Select Button
                ElevatedButton(
                  onPressed: () => _select(plan, loc),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Select',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _select(PlanProvider plan, LocationItem loc) {
    plan.setSelected(loc); // remember selection
    Navigator.pushNamed(context, AppRoutes.review); // go to review/predict
  }

  void _openDetails(BuildContext context, PlanProvider plan, LocationItem loc) {
    Navigator.pushNamed(
      context,
      AppRoutes.review, // show details + predictions there
      arguments: loc,
    );
  }
}
