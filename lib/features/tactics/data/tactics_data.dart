import 'package:flutter/material.dart';
import '../domain/tactics_models.dart';

class TacticsData {
  
  static String _localAgent(String id) => "assets/agents/$id.png";
  static String _localAbility(String agentId, String slot) => "assets/abilities/${agentId}_$slot.png";
  static String _localMap(String id) => "assets/maps/$id.png";

  static AgentModel _buildAgent({
    required String id, 
    required String name, 
    required String role, 
    required Color color, 
    Map<String, AgentAbility>? customAbilities, 
  }) {
    List<AgentAbility> abilities = [
      customAbilities?['C'] ?? AgentAbility(name: "Ability C", type: "Basic", iconUrl: _localAbility(id, "c")),
      customAbilities?['Q'] ?? AgentAbility(name: "Ability Q", type: "Basic", iconUrl: _localAbility(id, "q")),
      customAbilities?['E'] ?? AgentAbility(name: "Signature E", type: "Signature", iconUrl: _localAbility(id, "e")),
      customAbilities?['X'] ?? AgentAbility(name: "Ultimate X", type: "Ultimate", iconUrl: _localAbility(id, "x")),
    ];

    return AgentModel(id: id, name: name, role: role, color: color, iconUrl: _localAgent(id), abilities: abilities);
  }

  // --- FULL AJAN LİSTESİ ---
  static final List<AgentModel> kAgentsRoster = [
    _buildAgent(id: 'astra', name: 'Astra', role: 'Controller', color: const Color(0xFF7E49A2),
      customAbilities: {
        'X': AgentAbility(name: "Cosmic Divide", type: "Ultimate", iconUrl: _localAbility('astra', 'x'), shape: AbilityShape.rectangle, defaultSize: const Size(20, 1000), isResizable: true),
        'E': AgentAbility(name: "Nebula", type: "Signature", iconUrl: _localAbility('astra', 'e'), shape: AbilityShape.circle, defaultSize: const Size(180, 180), isResizable: true),
      }
    ),
    // --- BREACH GÜNCELLENDİ (Referans Çizime Göre Tam Boyutlar) ---
    _buildAgent(id: 'breach', name: 'Breach', role: 'Initiator', color: const Color(0xFFD36E35),
      customAbilities: {
        // C (Aftershock): Orta boy daire (Çizimdeki C'ye uygun)
        'C': AgentAbility(name: "Aftershock", type: "Basic", iconUrl: _localAbility('breach', 'c'), shape: AbilityShape.circle, defaultSize: const Size(140, 140), isResizable: true),
        // Q (Flashpoint): Küçük daire (Çizimdeki Q'ya uygun)
        'Q': AgentAbility(name: "Flashpoint", type: "Basic", iconUrl: _localAbility('breach', 'q'), shape: AbilityShape.circle, defaultSize: const Size(60, 60), isResizable: true),
        // E (Fault Line): Çok UZUN ve DAR dikdörtgen (Çizimdeki E'ye uygun)
        'E': AgentAbility(name: "Fault Line", type: "Signature", iconUrl: _localAbility('breach', 'e'), shape: AbilityShape.rectangle, defaultSize: const Size(60, 400), isResizable: true),
        // X (Rolling Thunder): Çok BÜYÜK ve GENİŞ dikdörtgen (Çizimdeki X'e uygun)
        'X': AgentAbility(name: "Rolling Thunder", type: "Ultimate", iconUrl: _localAbility('breach', 'x'), shape: AbilityShape.rectangle, defaultSize: const Size(300, 400), isResizable: true),
      }
    ),
    _buildAgent(id: 'brimstone', name: 'Brimstone', role: 'Controller', color: const Color(0xFFEB953F),
      customAbilities: {
        'E': AgentAbility(name: "Sky Smoke", type: "Signature", iconUrl: _localAbility('brimstone', 'e'), shape: AbilityShape.circle, defaultSize: const Size(160, 160), isResizable: true),
        'X': AgentAbility(name: "Orbital Strike", type: "Ultimate", iconUrl: _localAbility('brimstone', 'x'), shape: AbilityShape.circle, defaultSize: const Size(250, 250), isResizable: true),
      }
    ),
    _buildAgent(id: 'chamber', name: 'Chamber', role: 'Sentinel', color: const Color(0xFFC9AE73)),
    _buildAgent(id: 'clove', name: 'Clove', role: 'Controller', color: const Color(0xFFEAA8E2)),
    _buildAgent(id: 'cypher', name: 'Cypher', role: 'Sentinel', color: const Color(0xFFD5925A)),
    _buildAgent(id: 'deadlock', name: 'Deadlock', role: 'Sentinel', color: const Color(0xFF8CB8C1)),
    _buildAgent(id: 'fade', name: 'Fade', role: 'Initiator', color: const Color(0xFF4C5B63),
      customAbilities: {
        'X': AgentAbility(name: "Nightfall", type: "Ultimate", iconUrl: _localAbility('fade', 'x'), shape: AbilityShape.rectangle, defaultSize: const Size(200, 200), isResizable: true),
        'E': AgentAbility(name: "Haunt", type: "Signature", iconUrl: _localAbility('fade', 'e'), shape: AbilityShape.circle, defaultSize: const Size(80, 80), isResizable: true),
      }
    ),
    _buildAgent(id: 'gekko', name: 'Gekko', role: 'Initiator', color: const Color(0xFFC3E86C)),
    _buildAgent(id: 'harbor', name: 'Harbor', role: 'Controller', color: const Color(0xFF286D6B)),
    _buildAgent(id: 'iso', name: 'Iso', role: 'Duelist', color: const Color(0xFFBC9AF9)),
    _buildAgent(id: 'jett', name: 'Jett', role: 'Duelist', color: const Color(0xFF90E3FD)),
    _buildAgent(id: 'kayo', name: 'KAY/O', role: 'Initiator', color: const Color(0xFF637A99),
       customAbilities: {'E': AgentAbility(name: "ZERO/POINT", type: "Signature", iconUrl: _localAbility('kayo', 'e'), shape: AbilityShape.circle, defaultSize: const Size(200, 200), isResizable: true)}
    ),
    _buildAgent(id: 'killjoy', name: 'Killjoy', role: 'Sentinel', color: const Color(0xFFF3CE49),
      customAbilities: {'X': AgentAbility(name: "Lockdown", type: "Ultimate", iconUrl: _localAbility('killjoy', 'x'), shape: AbilityShape.circle, defaultSize: const Size(450, 450), isResizable: true)}
    ),
    _buildAgent(id: 'neon', name: 'Neon', role: 'Duelist', color: const Color(0xFF474596)),
    _buildAgent(id: 'omen', name: 'Omen', role: 'Controller', color: const Color(0xFF495579),
       customAbilities: {'E': AgentAbility(name: "Dark Cover", type: "Signature", iconUrl: _localAbility('omen', 'e'), shape: AbilityShape.circle, defaultSize: const Size(160, 160), isResizable: true)}
    ),
    _buildAgent(id: 'phoenix', name: 'Phoenix', role: 'Duelist', color: const Color(0xFFF8F8F8)),
    _buildAgent(id: 'raze', name: 'Raze', role: 'Duelist', color: const Color(0xFFF48348),
       customAbilities: {'X': AgentAbility(name: "Showstopper", type: "Ultimate", iconUrl: _localAbility('raze', 'x'), shape: AbilityShape.circle, defaultSize: const Size(100, 100), isResizable: true)}
    ),
    _buildAgent(id: 'reyna', name: 'Reyna', role: 'Duelist', color: const Color(0xFFE56399)),
    _buildAgent(id: 'sage', name: 'Sage', role: 'Sentinel', color: const Color(0xFF57CBB5),
       customAbilities: {'Q': AgentAbility(name: "Slow Orb", type: "Basic", iconUrl: _localAbility('sage', 'q'), shape: AbilityShape.circle, defaultSize: const Size(150, 150), isResizable: true)}
    ),
    _buildAgent(id: 'skye', name: 'Skye', role: 'Initiator', color: const Color(0xFF8EB976)),
    _buildAgent(id: 'sova', name: 'Sova', role: 'Initiator', color: const Color(0xFF4E84B8)),
    _buildAgent(id: 'tejo', name: 'Tejo', role: 'Initiator', color: const Color(0xFF6B8E23),
      customAbilities: {
        'E': AgentAbility(name: "Guided Salvo", type: "Signature", iconUrl: _localAbility('tejo', 'e'), shape: AbilityShape.circle, defaultSize: const Size(120, 120), isResizable: true),
        'X': AgentAbility(name: "Targeting Strike", type: "Ultimate", iconUrl: _localAbility('tejo', 'x'), shape: AbilityShape.circle, defaultSize: const Size(280, 280), isResizable: true),
      }
    ),
    _buildAgent(id: 'veto', name: 'Veto', role: 'Sentinel', color: const Color(0xFF8B0000),
      customAbilities: {
        'E': AgentAbility(name: "Suppression Zone", type: "Signature", iconUrl: _localAbility('veto', 'e'), shape: AbilityShape.rectangle, defaultSize: const Size(200, 200), isResizable: true),
        'X': AgentAbility(name: "Ultimate Veto", type: "Ultimate", iconUrl: _localAbility('veto', 'x'), shape: AbilityShape.circle, defaultSize: const Size(400, 400), isResizable: true),
      }
    ),
    _buildAgent(id: 'viper', name: 'Viper', role: 'Controller', color: const Color(0xFF309C59),
      customAbilities: {
        'E': AgentAbility(name: "Toxic Screen", type: "Signature", iconUrl: _localAbility('viper', 'e'), shape: AbilityShape.rectangle, defaultSize: const Size(10, 800), isResizable: true),
        'Q': AgentAbility(name: "Poison Cloud", type: "Basic", iconUrl: _localAbility('viper', 'q'), shape: AbilityShape.circle, defaultSize: const Size(140, 140), isResizable: true),
        'X': AgentAbility(name: "Viper's Pit", type: "Ultimate", iconUrl: _localAbility('viper', 'x'), shape: AbilityShape.circle, defaultSize: const Size(350, 350), isResizable: true),
      }
    ),
    _buildAgent(id: 'vyse', name: 'Vyse', role: 'Sentinel', color: const Color(0xFF6A4E85)),
    _buildAgent(id: 'waylay', name: 'Waylay', role: 'Duelist', color: const Color(0xFFFFD700),
      customAbilities: {
        'E': AgentAbility(name: "Light Step", type: "Signature", iconUrl: _localAbility('waylay', 'e'), shape: AbilityShape.circle, defaultSize: const Size(100, 100), isResizable: true),
      }
    ),
    _buildAgent(id: 'yoru', name: 'Yoru', role: 'Duelist', color: const Color(0xFF3D4EAD)),
  ];

  static final List<MapModel> kMapsRoster = [
    MapModel(id: 'ascent', name: 'Ascent', displayIconUrl: _localMap('ascent'), splashUrl: ''),
    MapModel(id: 'bind', name: 'Bind', displayIconUrl: _localMap('bind'), splashUrl: ''),
    MapModel(id: 'haven', name: 'Haven', displayIconUrl: _localMap('haven'), splashUrl: ''),
    MapModel(id: 'split', name: 'Split', displayIconUrl: _localMap('split'), splashUrl: ''),
    MapModel(id: 'icebox', name: 'Icebox', displayIconUrl: _localMap('icebox'), splashUrl: ''),
    MapModel(id: 'breeze', name: 'Breeze', displayIconUrl: _localMap('breeze'), splashUrl: ''),
    MapModel(id: 'fracture', name: 'Fracture', displayIconUrl: _localMap('fracture'), splashUrl: ''),
    MapModel(id: 'pearl', name: 'Pearl', displayIconUrl: _localMap('pearl'), splashUrl: ''),
    MapModel(id: 'lotus', name: 'Lotus', displayIconUrl: _localMap('lotus'), splashUrl: ''),
    MapModel(id: 'sunset', name: 'Sunset', displayIconUrl: _localMap('sunset'), splashUrl: ''),
    MapModel(id: 'abyss', name: 'Abyss', displayIconUrl: _localMap('abyss'), splashUrl: ''),
  ];
}