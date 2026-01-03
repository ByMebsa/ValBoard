import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print("🚀 ValoBoard V8.0 Varlık İndirici Başlatılıyor...");

  // 1. Klasörleri Oluştur
  await _createDir('assets/agents');
  await _createDir('assets/abilities');
  await _createDir('assets/maps');

  // 2. Ajanları ve Yetenekleri Çek (Otomatik)
  await _fetchAndDownloadAgents();

  // 3. Haritaları Çek (Otomatik)
  await _fetchAndDownloadMaps();

  print("\n✅ İŞLEM TAMAMLANDI!");
  print("👉 Şimdi terminale 'flutter clean' yazıp projeyi tekrar başlat.");
}

Future<void> _fetchAndDownloadAgents() async {
  print("\n--- Ajanlar ve Yetenekler İndiriliyor ---");
  final url = Uri.parse('https://valorant-api.com/v1/agents?isPlayableCharacter=true&language=en-US');
  
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List agents = data['data'];

      for (var agent in agents) {
        String name = _cleanName(agent['displayName']);
        String iconUrl = agent['displayIcon'];
        
        print("İndiriliyor: $name...");
        
        // Ajan İkonunu İndir
        await _downloadFile(iconUrl, 'assets/agents/$name.png');

        // Yetenekleri İndir
        List abilities = agent['abilities'];
        for (var ability in abilities) {
          String slot = ability['slot'].toString().toLowerCase(); // Grenade, Ability1, Ability2, Ultimate
          String? abilityIcon = ability['displayIcon'];
          
          // Slot ismini kısalt (C, Q, E, X mantığı için dosya adı ayarla)
          String shortSlot = "u"; // Bilinmeyen
          if (slot == "ability1") shortSlot = "c"; // Genelde C
          if (slot == "ability2") shortSlot = "q"; // Genelde Q
          if (slot == "grenade") shortSlot = "e";  // Signature
          if (slot == "ultimate") shortSlot = "x"; // Ulti
          
          if (abilityIcon != null) {
            await _downloadFile(abilityIcon, 'assets/abilities/${name}_$shortSlot.png');
          }
        }
      }
    }
  } catch (e) {
    print("HATA (Ajanlar): $e");
  }
}

Future<void> _fetchAndDownloadMaps() async {
  print("\n--- Haritalar İndiriliyor ---");
  final url = Uri.parse('https://valorant-api.com/v1/maps');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List maps = data['data'];

      for (var map in maps) {
        String name = _cleanName(map['displayName']);
        String? displayIcon = map['displayIcon']; // Genelde harita kuşbakışı
        String? listViewIcon = map['listViewIcon']; // Bazı haritalarda bu daha iyi

        // The Range (Poligon) haritasını atla
        if (name.contains("range") || name.contains("training")) continue;

        if (displayIcon != null) {
          print("Harita İndiriliyor: $name");
          await _downloadFile(displayIcon, 'assets/maps/$name.png');
        }
      }
    }
  } catch (e) {
    print("HATA (Haritalar): $e");
  }
}

// Dosya indirme yardımcısı
Future<void> _downloadFile(String url, String path) async {
  if (await File(path).exists()) {
    // Zaten varsa indirme (Hız kazandırır)
    return; 
  }
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await File(path).writeAsBytes(response.bodyBytes);
    }
  } catch (e) {
    print(" -> İndirme Hatası ($path): $e");
  }
}

// Klasör oluşturma yardımcısı
Future<void> _createDir(String path) async {
  final dir = Directory(path);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
}

// İsim temizleyici (KAY/O -> kayo, boşlukları sil, küçük harf yap)
String _cleanName(String original) {
  return original.toLowerCase().replaceAll(' ', '').replaceAll('/', '').replaceAll("'", "");
}