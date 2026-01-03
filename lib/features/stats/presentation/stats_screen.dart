import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String kHenrikApiKey = "HDEV-0bb83bde-47fd-4ecb-b851-291230919c4d";

class MatchStats {
  final String mapName;
  final String mode;
  final String result;
  final String score; 
  final String kda;
  final String agentIconUrl;
  final Color color;

  MatchStats({
    required this.mapName, required this.mode, required this.result, required this.score, required this.kda, required this.agentIconUrl, required this.color,
  });
}

class PlayerStats {
  final String name;
  final String tag;
  final String region;
  final int accountLevel;
  final String cardLargeUrl;
  final String rankName;
  final String rankIconUrl; 
  final int currentRR; 
  final double kdRatio;
  final String winRate;
  final String headshotRate;
  final List<MatchStats> recentMatches;

  PlayerStats({
    required this.name, required this.tag, required this.region, required this.accountLevel, required this.cardLargeUrl, required this.rankName, required this.rankIconUrl, required this.currentRR, required this.kdRatio, required this.winRate, required this.headshotRate, required this.recentMatches,
  });
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  PlayerStats? _playerStats;

  Future<void> _fetchStats() async {
    final name = _nameController.text.trim();
    final tag = _tagController.text.trim();

    if (name.isEmpty || tag.isEmpty) {
      setState(() => _errorMessage = "Lütfen İsim ve Tag girin.");
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; _errorMessage = null; _playerStats = null; });

    try {
      final headers = {"Authorization": kHenrikApiKey};

      // 1. HESAP SORGUSU (YEDEKLİ SİSTEM)
      // Önce normal sorgu, olmazsa tek tek bölgeleri dene
      Map<String, dynamic>? accData;
      String region = "";

      // İlk Deneme: Account V1
      var accRes = await http.get(Uri.parse("https://api.henrikdev.xyz/valorant/v1/account/$name/$tag"), headers: headers);
      
      if (accRes.statusCode == 200) {
        accData = jsonDecode(accRes.body)['data'];
        region = accData!['region'];
      } else {
        // Hata verdiyse MMR endpointinden bölge tahmin etmeye çalış (Fallback)
        // Sırasıyla bölgeleri dene: eu, na, ap, kr
        final regions = ['eu', 'na', 'ap', 'kr'];
        for (var r in regions) {
          final mmrTest = await http.get(Uri.parse("https://api.henrikdev.xyz/valorant/v2/mmr/$r/$name/$tag"), headers: headers);
          if (mmrTest.statusCode == 200) {
            region = r;
            // Fake Account Data oluştur (Çünkü account endpoint çalışmadı ama MMR çalıştı)
            accData = {
              'name': name, 'tag': tag, 'account_level': 0, 
              'card': {'wide': 'https://media.valorant-api.com/playercards/9fb348bc-41a0-91ad-8a3e-818035c4e561/wideart.png'} // Varsayılan Kart
            };
            break; 
          }
        }
      }

      if (region.isEmpty || accData == null) {
        throw Exception("Hesap bulunamadı (Tüm bölgeler denendi).");
      }

      // 2. RANK BİLGİSİ
      final mmrRes = await http.get(Uri.parse("https://api.henrikdev.xyz/valorant/v2/mmr/$region/$name/$tag"), headers: headers);
      
      String rankName = "Unranked";
      String rankIcon = "";
      int currentRR = 0;

      if (mmrRes.statusCode == 200) {
        final mmrData = jsonDecode(mmrRes.body)['data'];
        if (mmrData['current_data'] != null) {
           rankName = mmrData['current_data']['currenttierpatched'] ?? "Unranked";
           rankIcon = mmrData['current_data']['images']?['small'] ?? "";
           currentRR = mmrData['current_data']['ranking_in_tier'] ?? 0;
        }
      }

      // 3. MAÇ GEÇMİŞİ
      final matchesRes = await http.get(Uri.parse("https://api.henrikdev.xyz/valorant/v3/matches/$region/$name/$tag?size=5"), headers: headers);
      
      List<MatchStats> recentMatches = [];
      double totalKills = 0, totalDeaths = 0, totalHeadshots = 0, totalShots = 0;
      int wins = 0;
      int rankedMatchCount = 0;

      if (matchesRes.statusCode == 200) {
        final matchesList = jsonDecode(matchesRes.body)['data'] as List;
        for (var match in matchesList) {
          final mode = match['metadata']['mode'] ?? "Unknown";
          if (mode == "Deathmatch") continue; // DM istatistiği bozmasın

          final player = (match['players']['all_players'] as List).firstWhere(
            (p) => p['name'].toString().toLowerCase() == name.toLowerCase() && p['tag'].toString().toLowerCase() == tag.toLowerCase(),
            orElse: () => null
          );

          if (player != null) {
            bool isWin = false;
            String team = player['team'].toString().toLowerCase();
            if (match['teams'] != null && match['teams'][team] != null) {
               isWin = match['teams'][team]['has_won'] ?? false;
            }
            if (isWin) wins++;

            rankedMatchCount++;
            totalKills += player['stats']['kills'];
            totalDeaths += player['stats']['deaths'];
            totalHeadshots += player['stats']['headshots'];
            totalShots += (player['stats']['bodyshots'] + player['stats']['legshots'] + player['stats']['headshots']);
            
            int rw = match['teams'][team]['rounds_won'] ?? 0;
            int rl = match['teams'][team]['rounds_lost'] ?? 0;

            recentMatches.add(MatchStats(
              mapName: match['metadata']['map'],
              mode: mode,
              result: isWin ? "VICTORY" : "DEFEAT",
              score: "$rw - $rl",
              kda: "${player['stats']['kills']}/${player['stats']['deaths']}/${player['stats']['assists']}",
              agentIconUrl: player['assets']['agent']['small'],
              color: isWin ? Colors.greenAccent : Colors.redAccent,
            ));
          }
        }
      }

      double kd = totalDeaths == 0 ? totalKills : (totalKills / totalDeaths);
      String winRateStr = rankedMatchCount == 0 ? "0%" : "${((wins / rankedMatchCount) * 100).toStringAsFixed(0)}%";
      String hsRateStr = totalShots == 0 ? "0%" : "${((totalHeadshots / totalShots) * 100).toStringAsFixed(0)}%";

      setState(() {
        _playerStats = PlayerStats(
          name: accData!['name'],
          tag: accData['tag'],
          region: region.toUpperCase(),
          accountLevel: accData['account_level'],
          cardLargeUrl: accData['card']['wide'], // Wide kart daha iyi
          rankName: rankName,
          rankIconUrl: rankIcon,
          currentRR: currentRR,
          kdRatio: kd,
          winRate: winRateStr,
          headshotRate: hsRateStr,
          recentMatches: recentMatches,
        );
      });

    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1923),
        title: const Text("AGENT STATS", style: TextStyle(fontFamily: 'Valorant', color: Colors.white, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ARAMA KUTUSU
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(flex: 2, child: TextField(controller: _nameController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "RIOT ID", labelStyle: TextStyle(color: Colors.white54), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF4655)))))),
                      const SizedBox(width: 16),
                      const Text("#", style: TextStyle(color: Colors.white54, fontSize: 20)),
                      const SizedBox(width: 16),
                      Expanded(flex: 1, child: TextField(controller: _tagController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "TAG", labelStyle: TextStyle(color: Colors.white54), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF4655)))))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _fetchStats, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4655), shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("SEARCH AGENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))),
                ],
              ),
            ),

            const SizedBox(height: 30),

            if (_errorMessage != null)
              Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), border: Border.all(color: Colors.redAccent)), child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent))),

            if (_playerStats != null)
              Column(
                children: [
                  // PROFİL KARTI
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(_playerStats!.cardLargeUrl),
                        fit: BoxFit.cover, // Resmi sığdırır
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                      ),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 20, left: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                                Text(_playerStats!.name, style: GoogleFonts.oswald(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, shadows: [const Shadow(blurRadius: 10, color: Colors.black)])),
                                const SizedBox(width: 5),
                                Text("#${_playerStats!.tag}", style: GoogleFonts.oswald(color: const Color(0xFFFF4655), fontSize: 20, fontWeight: FontWeight.bold, shadows: [const Shadow(blurRadius: 10, color: Colors.black)])),
                              ]),
                              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)), child: Text("Lvl ${_playerStats!.accountLevel} • ${_playerStats!.region}", style: const TextStyle(color: Colors.white70, fontSize: 12))),
                            ],
                          ),
                        ),
                        if (_playerStats!.rankIconUrl.isNotEmpty)
                          Positioned(
                            top: 20, right: 20,
                            child: Column(
                              children: [
                                Image.network(_playerStats!.rankIconUrl, width: 70, height: 70),
                                Text(_playerStats!.rankName, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 14, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
                                Text("${_playerStats!.currentRR} RR", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // İSTATİSTİKLER (GRID)
                  Row(
                    children: [
                      _buildStatBox("K/D", _playerStats!.kdRatio.toStringAsFixed(2), Colors.orangeAccent),
                      const SizedBox(width: 10),
                      _buildStatBox("WIN %", _playerStats!.winRate, Colors.greenAccent),
                      const SizedBox(width: 10),
                      _buildStatBox("HS %", _playerStats!.headshotRate, Colors.cyanAccent),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // SON MAÇLAR
                  const Align(alignment: Alignment.centerLeft, child: Text("LAST 5 MATCHES", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5))),
                  const SizedBox(height: 10),
                  
                  ..._playerStats!.recentMatches.map((match) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: const Color(0xFF1F2933), border: Border(left: BorderSide(color: match.color, width: 4)), borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: Image.network(match.agentIconUrl, width: 40, height: 40),
                      title: Row(
                        children: [
                          Text(match.mapName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)), child: Text(match.mode, style: const TextStyle(color: Colors.white54, fontSize: 10))),
                        ],
                      ),
                      subtitle: Text(match.result, style: TextStyle(color: match.color, fontWeight: FontWeight.bold, fontSize: 12)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(match.score, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(match.kda, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border(top: BorderSide(color: color, width: 3))),
        child: Column(children: [Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10))]),
      ),
    );
  }
}