import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/tactics_models.dart';
import '../data/tactics_data.dart';

// GLOBAL SCALE (Genel Ajan Boyutu)
final globalAgentScaleProvider = StateProvider<double>((ref) => 1.0);

final currentMapProvider = StateProvider<MapModel>((ref) => TacticsData.kMapsRoster.first);
final drawingModeProvider = StateProvider<bool>((ref) => false);
final penColorProvider = StateProvider<Color>((ref) => Colors.white);
final selectedPlacedAgentProvider = StateProvider<PlacedAgent?>((ref) => null);
final selectedPlacedAbilityProvider = StateProvider<String?>((ref) => null);

// --- SKETCHES MANAGER ---
class SketchesNotifier extends StateNotifier<List<Sketch>> {
  SketchesNotifier() : super([]);
  void addSketch(Sketch sketch) => state = [...state, sketch];
  void undo() { if (state.isNotEmpty) state = state.sublist(0, state.length - 1); }
  void clear() => state = [];
}
final sketchesProvider = StateNotifierProvider<SketchesNotifier, List<Sketch>>((ref) => SketchesNotifier());

// --- PLACED AGENTS MANAGER ---
class PlacedAgentsNotifier extends StateNotifier<List<PlacedAgent>> {
  PlacedAgentsNotifier() : super([]);
  
  void addAgent(PlacedAgent agent) => state = [...state, agent];
  
  void updatePosition(String id, Offset newPos) {
    state = [for (final a in state) if (a.id == id) PlacedAgent(id: a.id, agent: a.agent, position: newPos, scale: a.scale) else a];
  }
  
  // Ajan Boyutunu Güncelleme
  void updateScale(String id, double scale) {
    state = [for (final a in state) if (a.id == id) PlacedAgent(id: a.id, agent: a.agent, position: a.position, scale: scale) else a];
  }
  
  void remove(String id) => state = state.where((a) => a.id != id).toList();
  void clear() => state = [];
}
final placedAgentsProvider = StateNotifierProvider<PlacedAgentsNotifier, List<PlacedAgent>>((ref) => PlacedAgentsNotifier());

// --- PLACED ABILITIES MANAGER ---
class PlacedAbilitiesNotifier extends StateNotifier<List<PlacedAbility>> {
  PlacedAbilitiesNotifier() : super([]);
  
  void addAbility(PlacedAbility ability) => state = [...state, ability];
  
  void updatePosition(String id, Offset newPos) {
    state = [for (final a in state) if (a.id == id) PlacedAbility(id: a.id, ability: a.ability, position: newPos, color: a.color, rotation: a.rotation, currentSize: a.currentSize) else a];
  }
  
  void updateRotation(String id, double angle) {
    state = [for (final a in state) if (a.id == id) PlacedAbility(id: a.id, ability: a.ability, position: a.position, color: a.color, rotation: angle, currentSize: a.currentSize) else a];
  }

  // YETENEK BOYUTLANDIRMA (Scale)
  void updateSize(String id, double multiplier) {
    state = [for (final a in state) 
      if (a.id == id) 
        PlacedAbility(
          id: a.id, ability: a.ability, position: a.position, color: a.color, rotation: a.rotation, 
          // Orijinal boyutu çarpanla çarpıyoruz
          currentSize: Size(a.ability.defaultSize.width * multiplier, a.ability.defaultSize.height * (a.ability.shape == AbilityShape.circle ? multiplier : 1.0))
        ) 
      else a];
  }
  
  // YETENEK UZATMA (Breach Stun vb.)
  void extendLength(String id, double newLength) {
     state = [for (final a in state) 
      if (a.id == id) 
        PlacedAbility(
          id: a.id, ability: a.ability, position: a.position, color: a.color, rotation: a.rotation, 
          currentSize: Size(a.currentSize.width, newLength) // Sadece boyu (veya eni) değiştir
        ) 
      else a];
  }

  void remove(String id) => state = state.where((a) => a.id != id).toList();
  void clear() => state = [];
}
final placedAbilitiesProvider = StateNotifierProvider<PlacedAbilitiesNotifier, List<PlacedAbility>>((ref) => PlacedAbilitiesNotifier());