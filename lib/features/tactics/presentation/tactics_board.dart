import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;
import '../domain/tactics_models.dart';
import '../data/tactics_data.dart';
import 'tactics_providers.dart';

class TacticsBoard extends ConsumerStatefulWidget {
  const TacticsBoard({super.key});

  @override
  ConsumerState<TacticsBoard> createState() => _TacticsBoardState();
}

class _TacticsBoardState extends ConsumerState<TacticsBoard> {
  final GlobalKey mapKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      appBar: isLandscape ? null : _buildAppBar(),
      body: SafeArea(
        child: isLandscape 
          ? Row(
              children: [
                Expanded(flex: 3, child: _buildMapArea()),
                Container(width: 1, color: Colors.white24),
                Expanded(flex: 1, child: _buildControlPanel(isMobile: false)),
              ],
            )
          : Column(
              children: [
                if(isLandscape) _buildAppBar(),
                Expanded(child: _buildMapArea()),
                _buildControlPanel(isMobile: true),
              ],
            ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isDrawing = ref.watch(drawingModeProvider);
    final currentColor = ref.watch(penColorProvider);
    return AppBar(
      backgroundColor: const Color(0xFF0F1923),
      title: const Text("TACTICS", style: TextStyle(color: Colors.white, fontFamily: 'Valorant')),
      actions: [
        PopupMenuButton<MapModel>(
          icon: const Icon(Icons.map, color: Colors.white),
          onSelected: (map) => ref.read(currentMapProvider.notifier).state = map,
          itemBuilder: (context) => TacticsData.kMapsRoster.map((map) => PopupMenuItem(value: map, child: Text(map.name))).toList(),
        ),
        IconButton(
          icon: Icon(isDrawing ? Icons.pan_tool : Icons.edit, color: isDrawing ? currentColor : Colors.white),
          onPressed: () => ref.read(drawingModeProvider.notifier).state = !isDrawing,
        ),
        IconButton(icon: const Icon(Icons.undo, color: Colors.white), onPressed: () => ref.read(sketchesProvider.notifier).undo()),
        IconButton(icon: const Icon(Icons.delete_forever, color: Colors.redAccent), onPressed: () {
          ref.read(sketchesProvider.notifier).clear();
          ref.read(placedAgentsProvider.notifier).clear();
          ref.read(placedAbilitiesProvider.notifier).clear();
        }),
      ],
    );
  }

  Widget _buildMapArea() {
    final isDrawing = ref.watch(drawingModeProvider);
    final sketches = ref.watch(sketchesProvider);
    final currentMap = ref.watch(currentMapProvider);
    final placedAgents = ref.watch(placedAgentsProvider);
    final placedAbilities = ref.watch(placedAbilitiesProvider);
    final selectedAgent = ref.watch(selectedPlacedAgentProvider);

    return InteractiveViewer(
      panEnabled: !isDrawing,
      scaleEnabled: !isDrawing,
      minScale: 0.5,
      maxScale: 10.0,
      boundaryMargin: const EdgeInsets.all(1000),
      child: Center(
        child: SizedBox(
          width: 2000, height: 2000,
          child: Stack(
            key: mapKey,
            fit: StackFit.expand,
            children: [
              RepaintBoundary(child: Image.asset(currentMap.displayIconUrl, fit: BoxFit.contain)),
              RepaintBoundary(child: CustomPaint(painter: SketchesPainter(sketches))),
              if (isDrawing) const DrawingGestureDetector(),

              ...placedAbilities.map((pa) => Positioned(
                left: pa.position.dx, top: pa.position.dy,
                child: _DraggablePlacedAbility(placedAbility: pa, mapKey: mapKey),
              )),

              ...placedAgents.map((pa) => Positioned(
                left: pa.position.dx, top: pa.position.dy,
                child: _DraggablePlacedAgent(placedAgent: pa, mapKey: mapKey),
              )),

              if (!isDrawing)
                Positioned.fill(
                  child: DragTarget<Object>(
                    onAcceptWithDetails: (details) {
                      final RenderBox? renderBox = mapKey.currentContext?.findRenderObject() as RenderBox?;
                      if (renderBox != null) {
                        final localOffset = renderBox.globalToLocal(details.offset);
                        final data = details.data;
                        if (data is AgentModel) {
                          ref.read(placedAgentsProvider.notifier).addAgent(PlacedAgent(id: const Uuid().v4(), agent: data, position: Offset(localOffset.dx - 16, localOffset.dy - 16)));
                        } else if (data is AgentAbility && selectedAgent != null) {
                           double offX = data.shape == AbilityShape.icon ? 20 : data.defaultSize.width/2;
                           double offY = data.shape == AbilityShape.icon ? 20 : data.defaultSize.height/2;
                           ref.read(placedAbilitiesProvider.notifier).addAbility(PlacedAbility(id: const Uuid().v4(), ability: data, position: Offset(localOffset.dx - offX, localOffset.dy - offY), color: selectedAgent.agent.color, currentSize: data.defaultSize));
                        }
                      }
                    },
                    builder: (c, _, __) => Container(color: Colors.transparent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel({required bool isMobile}) {
    final selectedAgent = ref.watch(selectedPlacedAgentProvider);
    final selectedAbilityId = ref.watch(selectedPlacedAbilityProvider);
    final placedAbilities = ref.watch(placedAbilitiesProvider);
    
    final selectedPlacedAbility = selectedAbilityId != null && placedAbilities.any((e) => e.id == selectedAbilityId)
      ? placedAbilities.firstWhere((e) => e.id == selectedAbilityId) : null;
    
    final globalScale = ref.watch(globalAgentScaleProvider);

    return Container(
      width: isMobile ? double.infinity : 300,
      decoration: BoxDecoration(color: const Color(0xFF1F2933), border: isMobile ? const Border(top: BorderSide(color: Colors.white24)) : const Border(left: BorderSide(color: Colors.white24))),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedPlacedAbility != null) ...[
              Text("${selectedPlacedAbility.ability.name}", style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Row(children: [
                const Icon(Icons.rotate_right, color: Colors.grey, size: 20),
                Expanded(child: Slider(value: selectedPlacedAbility.rotation, min: 0, max: 2 * math.pi, activeColor: Colors.white, onChanged: (v) => ref.read(placedAbilitiesProvider.notifier).updateRotation(selectedPlacedAbility.id, v))),
              ]),
              if (selectedPlacedAbility.ability.isResizable) ...[
                Row(children: [
                  const Icon(Icons.aspect_ratio, color: Colors.grey, size: 20),
                  Expanded(child: Slider(
                    label: "Boyut",
                    value: selectedPlacedAbility.ability.shape == AbilityShape.rectangle ? selectedPlacedAbility.currentSize.height : selectedPlacedAbility.currentSize.width, 
                    min: 10, max: 800, activeColor: Colors.greenAccent, 
                    onChanged: (v) {
                        if (selectedPlacedAbility.ability.shape == AbilityShape.rectangle) {
                          ref.read(placedAbilitiesProvider.notifier).extendLength(selectedPlacedAbility.id, v);
                        } else {
                          double multiplier = v / selectedPlacedAbility.ability.defaultSize.width;
                          ref.read(placedAbilitiesProvider.notifier).updateSize(selectedPlacedAbility.id, multiplier);
                        }
                    }
                  )),
                ]),
              ],
              ElevatedButton.icon(onPressed: (){ ref.read(placedAbilitiesProvider.notifier).remove(selectedPlacedAbility.id); ref.read(selectedPlacedAbilityProvider.notifier).state = null; }, icon: const Icon(Icons.delete, color: Colors.white), label: const Text("Sil", style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.red)),
            ] else if (selectedAgent != null) ...[
              Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => ref.read(selectedPlacedAgentProvider.notifier).state = null),
                Expanded(child: Text(selectedAgent.agent.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: (){ ref.read(placedAgentsProvider.notifier).remove(selectedAgent.id); ref.read(selectedPlacedAgentProvider.notifier).state = null; })
              ]),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedAgent.agent.abilities.length,
                  separatorBuilder: (c,i) => const SizedBox(width: 10),
                  itemBuilder: (c, i) {
                    final ability = selectedAgent.agent.abilities[i];
                    return Draggable<AgentAbility>(
                      data: ability,
                      feedback: _AbilityFeedback(ability: ability, color: selectedAgent.agent.color, size: ability.defaultSize),
                      child: Container(
                        width: 60, height: 60, padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
                        child: Image.asset(ability.iconUrl, color: Colors.white),
                      ),
                    );
                  },
                ),
              )
            ] else ...[
              Row(children: [
                const Text("Boyut:", style: TextStyle(color: Colors.grey)),
                Expanded(child: Slider(value: globalScale, min: 0.5, max: 2.0, activeColor: Colors.orange, onChanged: (v) => ref.read(globalAgentScaleProvider.notifier).state = v)),
              ]),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: TacticsData.kAgentsRoster.length,
                  separatorBuilder: (c,i) => const SizedBox(width: 10),
                  itemBuilder: (c, i) {
                    final agent = TacticsData.kAgentsRoster[i];
                    return Draggable<AgentModel>(
                      data: agent,
                      feedback: Opacity(opacity: 0.7, child: _AgentAvatar(agent: agent, radius: 25)),
                      child: Column(children: [_AgentAvatar(agent: agent, radius: 25), const SizedBox(height: 5), Text(agent.name, style: const TextStyle(color: Colors.white, fontSize: 10))]),
                    );
                  },
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}

// --- RENDER WIDGETLARI (GÜNCELLENDİ: ValoPlant Tarzı) ---
class _DraggablePlacedAbility extends ConsumerWidget {
  final PlacedAbility placedAbility;
  final GlobalKey mapKey;
  const _DraggablePlacedAbility({required this.placedAbility, required this.mapKey});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(selectedPlacedAbilityProvider) == placedAbility.id;
    final size = placedAbility.currentSize;
    final color = placedAbility.color;
    final shape = placedAbility.ability.shape;
    
    Widget content;
    if (shape == AbilityShape.icon) {
      content = Container(width: 40, height: 40, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(5), border: Border.all(color: isSelected ? Colors.white : color)), child: Image.asset(placedAbility.ability.iconUrl, color: color));
    } else {
      // VALOPLANT TARZI RENDER
      content = Container(
        width: size.width, height: size.height,
        decoration: BoxDecoration(
          // Yarı saydam dolgu
          color: color.withOpacity(0.25),
          // Belirgin kenarlık (Seçiliyse beyaz, değilse ajanın rengi)
          border: Border.all(color: isSelected ? Colors.white : color.withOpacity(0.9), width: 2.5),
          // Şekil belirleme
          shape: shape == AbilityShape.circle ? BoxShape.circle : BoxShape.rectangle,
          // Dikdörtgenler için hafif yuvarlak köşe
          borderRadius: shape == AbilityShape.rectangle ? BorderRadius.circular(6) : null,
        ),
        // Ortadaki İkon
        child: Center(child: Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle), child: Padding(padding: const EdgeInsets.all(4), child: Image.asset(placedAbility.ability.iconUrl, color: Colors.white)))),
      );
    }

    return GestureDetector(
      onTap: (){ ref.read(selectedPlacedAbilityProvider.notifier).state = placedAbility.id; ref.read(selectedPlacedAgentProvider.notifier).state = null; },
      child: Draggable<PlacedAbility>(
        data: placedAbility,
        feedback: Transform.rotate(angle: placedAbility.rotation, child: Opacity(opacity: 0.7, child: content)),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          final RenderBox? box = mapKey.currentContext?.findRenderObject() as RenderBox?;
          if(box != null) {
            final local = box.globalToLocal(details.offset);
            double offX = shape == AbilityShape.icon ? 20 : size.width/2;
            double offY = shape == AbilityShape.icon ? 20 : size.height/2;
            ref.read(placedAbilitiesProvider.notifier).updatePosition(placedAbility.id, Offset(local.dx - offX, local.dy - offY));
          }
        },
        child: Transform.rotate(angle: placedAbility.rotation, child: content),
      ),
    );
  }
}

class _DraggablePlacedAgent extends ConsumerWidget {
  final PlacedAgent placedAgent;
  final GlobalKey mapKey;
  const _DraggablePlacedAgent({required this.placedAgent, required this.mapKey});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalScale = ref.watch(globalAgentScaleProvider);
    final size = 32.0 * globalScale; 
    
    return GestureDetector(
      onTap: (){ ref.read(selectedPlacedAgentProvider.notifier).state = placedAgent; ref.read(selectedPlacedAbilityProvider.notifier).state = null; },
      child: Draggable<PlacedAgent>(
        data: placedAgent,
        feedback: Opacity(opacity: 0.7, child: _AgentAvatar(agent: placedAgent.agent, radius: size/2)),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          final RenderBox? box = mapKey.currentContext?.findRenderObject() as RenderBox?;
          if(box != null) {
             final local = box.globalToLocal(details.offset);
             ref.read(placedAgentsProvider.notifier).updatePosition(placedAgent.id, Offset(local.dx - size/2, local.dy - size/2));
          }
        },
        child: _AgentAvatar(agent: placedAgent.agent, radius: size/2),
      ),
    );
  }
}

class _AgentAvatar extends StatelessWidget {
  final AgentModel agent;
  final double radius;
  const _AgentAvatar({required this.agent, required this.radius});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: agent.color, width: 2), color: Colors.black),
      child: CircleAvatar(radius: radius, backgroundColor: Colors.transparent, backgroundImage: AssetImage(agent.iconUrl)),
    );
  }
}

// --- FEEDBACK WIDGET (Sürüklerken görünen) ---
class _AbilityFeedback extends StatelessWidget {
  final AgentAbility ability;
  final Color color;
  final Size size;
  const _AbilityFeedback({required this.ability, required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    if(ability.shape == AbilityShape.icon) return const Icon(Icons.add, color: Colors.white);
    return Container(
      width: size.width, height: size.height,
      decoration: BoxDecoration(
        color: color.withOpacity(0.25), // ValoPlant tarzı şeffaflık
        border: Border.all(color: color.withOpacity(0.9), width: 2.5), // Belirgin kenarlık
        shape: ability.shape == AbilityShape.circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: ability.shape == AbilityShape.rectangle ? BorderRadius.circular(6) : null,
      ),
      child: Center(child: Icon(Icons.add, color: Colors.white.withOpacity(0.7))),
    );
  }
}

class SketchesPainter extends CustomPainter {
  final List<Sketch> sketches;
  SketchesPainter(this.sketches);
  @override
  void paint(Canvas canvas, Size size) {
    for (var s in sketches) {
      final p = Paint()..color = s.color..strokeWidth = s.strokeWidth..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
      final path = Path();
      if(s.points.isNotEmpty) { path.moveTo(s.points[0].dx, s.points[0].dy); for(int i=1; i<s.points.length; i++) path.lineTo(s.points[i].dx, s.points[i].dy); }
      canvas.drawPath(path, p);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawingGestureDetector extends ConsumerStatefulWidget {
  const DrawingGestureDetector({super.key});
  @override
  ConsumerState<DrawingGestureDetector> createState() => _DGDState();
}
class _DGDState extends ConsumerState<DrawingGestureDetector> {
  List<Offset> pts = [];
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (d)=>pts=[d.localPosition], onPanUpdate: (d)=>setState(()=>pts.add(d.localPosition)),
      onPanEnd: (d){ ref.read(sketchesProvider.notifier).addSketch(Sketch(points: List.from(pts), color: ref.read(penColorProvider))); setState(()=>pts=[]); },
      child: CustomPaint(painter: SketchesPainter([if(pts.isNotEmpty) Sketch(points: pts, color: ref.read(penColorProvider))]), child: Container(color: Colors.transparent)),
    );
  }
}