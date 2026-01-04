import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsSearchBox extends StatelessWidget {
  const StatsSearchBox({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.2)), borderRadius: BorderRadius.circular(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(flex: 2, child: TextField(style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "RIOT ID", hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red))))),
            const SizedBox(width: 16),
            Expanded(flex: 1, child: TextField(style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "#TAG", hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red))))),
          ]),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4655), padding: const EdgeInsets.symmetric(vertical: 16), foregroundColor: Colors.white, shape: const BeveledRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10)))), child: const Text("SEARCH", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5))),
        ],
      ),
    );
  }
}


class ProfileCardMock extends StatelessWidget {
  const ProfileCardMock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1F2933), Color(0xFF0F1923)]),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          "Enter Riot ID to View Stats",
          style: GoogleFonts.oswald(color: Colors.white24, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(); 
  }
}

class MatchHistoryList extends StatelessWidget {
  const MatchHistoryList({super.key});
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
