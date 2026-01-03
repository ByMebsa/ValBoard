import 'package:flutter/material.dart';

// Yetenek Şekilleri (Gerçekçi görünüm için)
enum AbilityShape { icon, circle, rectangle, cone }

class AgentAbility {
  final String name;
  final String type; // Basic, Signature, Ultimate
  final String iconUrl;
  final AbilityShape shape; // Şekli ne? (Daire, Kare, İkon)
  final Size defaultSize; // Varsayılan boyutu (örn: Smoke 150x150)
  final bool isResizable; // Boyutu değiştirilebilir mi?

  AgentAbility({
    required this.name,
    required this.type,
    required this.iconUrl,
    this.shape = AbilityShape.icon,
    this.defaultSize = const Size(50, 50),
    this.isResizable = false,
  });
}

class AgentModel {
  final String id;
  final String name;
  final String role;
  final Color color;
  final String iconUrl;
  final List<AgentAbility> abilities;

  AgentModel({
    required this.id, 
    required this.name, 
    required this.role, 
    required this.color, 
    required this.iconUrl, 
    required this.abilities
  });
}

class MapModel {
  final String id;
  final String name;
  final String displayIconUrl;
  final String splashUrl;

  MapModel({required this.id, required this.name, required this.displayIconUrl, required this.splashUrl});
}

// Yerleştirilen Ajan (Scale özelliği eklendi)
class PlacedAgent {
  final String id;
  final AgentModel agent;
  final Offset position;
  final double scale; // Ajanın kendi büyüklüğü

  PlacedAgent({required this.id, required this.agent, required this.position, this.scale = 1.0});
}

// Yerleştirilen Yetenek (Boyut ve Şekil özelliği eklendi)
class PlacedAbility {
  final String id;
  final AgentAbility ability;
  final Offset position;
  final Color color;
  final double rotation;
  final Size currentSize; // O anki boyutu (Smoke'u büyüttüysen buraya kaydolur)

  PlacedAbility({
    required this.id,
    required this.ability,
    required this.position,
    required this.color,
    this.rotation = 0.0,
    required this.currentSize,
  });
}

class Sketch {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  Sketch({required this.points, required this.color, this.strokeWidth = 3.0});
}