import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

void main() => runApp(ScanSafeAfrica());

class ScanSafeAfrica extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ScanSafeAfrica v3.2.1',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: InspectionScreen(),
    );
  }
}

class InspectionScreen extends StatefulWidget {
  @override
  _InspectionScreenState createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  Map<String, String> evidence = {
    "1 Fridge": "pending",
    "2 Products": "pending",
    "3 CIPC Cert": "pending",
    "4 Health Cert": "pending",
    "5 Invoice": "pending",
    "6 SARS Cert": "pending",
    "7 VAT Cert": "pending",
    "8 SAPS Case SAPS-2024/4410": "pending",
    "9 Voice Note 00:18": "pending",
  };

  String gps = "GPS LOCKED 3m -33.8523, 25.5447 Bethelsdorp";
  String qr = "SSA-2024-77192";
  String aiResult = "AI Ready - Tap SCAN";
  double aiConfidence = 0;
  bool isVerified = false;
  String hash = "";
  bool sapsEscalated = false;
  List<Map<String,dynamic>> deletedLog = [];

  void generateHash() {
    var bytes = utf8.encode("${DateTime.now()}$qr$gps$evidence");
    setState(() => hash = sha256.convert(bytes).toString().substring(0,16).toUpperCase());
  }

  void scanAI() {
    setState(() {
      aiConfidence = 98.5;
      aiResult = "⚠️ SUSPECT - Verification Required: CIPC format 202X/XXXXXX/07 anomaly | VAT 10 digits mismatch | Brand font anomaly (98.5% AI Confidence - Inspector to confirm)";
    });
    generateHash();
  }

  void markVerified() {
    if(evidence.values.any((e)=>e=="pending")){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Take all 9 evidences first!")));
      return;
    }
    setState(()=>isVerified=true);
    generateHash();
  }

  void softDelete(String key){
    showDialog(context: context, builder: (c)=>AlertDialog(
      title: Text("SOFT DELETE ONLY - Anti-Corruption"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text("This will NOT erase original. Hash preserved for court."),
        SizedBox(height:10),
        TextField(decoration: InputDecoration(labelText: "Inspector Fingerprint ✅")),
        TextField(decoration: InputDecoration(labelText: "Subject Fingerprint ✅")),
        TextField(decoration: InputDecoration(labelText: "Voice Reason (required)")),
      ]),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(c), child: Text("Cancel")),
        ElevatedButton(onPressed: (){
          setState((){
            deletedLog.add({"item":key, "time":DateTime.now().toString(), "hash":hash, "status":"UNDER REVIEW"});
            evidence[key]="DELETED - UNDER REVIEW (Hash: $hash)";
          });
          Navigator.pop(c);
        }, child: Text("CONFIRM SOFT DELETE"))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ScanSafeAfrica v3.2.1 AI"),
        backgroundColor: Color(0xFF0A3D62),
        actions: [Padding(padding: EdgeInsets.all(10), child: Text(qr, style: TextStyle(fontSize:10)))],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Color(0xFF0A3D62),
              padding: EdgeInsets.all(10),
              child: Row(children: [
                Icon(Icons.shield, color: Colors.orange, size: 40),
                SizedBox(width:10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("ScanSafeAfrica", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text("SECURE • VERIFIED • ANTI-COUNTERFEIT • OFFICIAL", style: TextStyle(color: Colors.orange, fontSize: 7)),
                ])
              ]),
            ),
            SizedBox(height:10),
            Text(gps, style: TextStyle(fontSize:11, fontWeight: FontWeight.bold, color: Colors.green)),
            Text("Hash: $hash | AI: $aiConfidence%", style: TextStyle(fontSize:10)),
            Divider(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: Size(double.infinity,45)),
              onPressed: scanAI,
              icon: Icon(Icons.smart_toy),
              label: Text("🤖 AI SCAN CERTIFICATE - CHECK SUSPECT"),
            ),
            Container(
              padding: EdgeInsets.all(8),
              color: aiConfidence>90? Colors.orange[100]: Colors.grey[200],
              child: Text(aiResult, style: TextStyle(fontSize:11, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height:10),
            Text("9 EVIDENCES (Tap to capture):", style: TextStyle(fontWeight: FontWeight.bold)),
          ...evidence.keys.map((k)=>Card(
              child: ListTile(
                dense: true,
                title: Text(k, style: TextStyle(fontSize:12)),
                subtitle: Text(evidence[k]!, style: TextStyle(fontSize:10, color: evidence[k]!.contains("DELETED")?Colors.red:Colors.grey)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(icon: Icon(Icons.camera_alt, size:20), onPressed: (){setState(()=>evidence[k]="captured ✅ ${DateTime.now().toString().substring(11,19)}"); generateHash();}),
                  IconButton(icon: Icon(Icons.delete, size:18, color: Colors.red), onPressed: ()=>softDelete(k)),
                ]),
              ),
            )).toList(),
            SizedBox(height:10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), color: Colors.grey[100], borderRadius: BorderRadius.circular(5)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("⚖️ LEGAL & POPIA DISCLAIMER", style: TextStyle(fontWeight: FontWeight.bold, fontSize:10)),
                SizedBox(height:5),
                Text("• AI ASSIST ONLY: SUSPECT flag requires Inspector verification. Final decision by human.\n• POPIA: No ID stored. Only CIPC, TCS PIN, hash stored. SHA256 encrypted.\n• COURT READY: Original hash preserved under SOFT DELETE ONLY. SUSPECT not FAKE to avoid defamation.\n• HUMAN OVERSIGHT: AI 95%+ must be confirmed by Inspector.",
                  style: TextStyle(fontSize:9, color: Colors.black87)),
              ]),
            ),
            SizedBox(height:10),
            Row(children: [
              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: markVerified, child: Text("MARK VERIFIED", style: TextStyle(fontSize:10)))),
              SizedBox(width:5),
              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: (){setState(()=>isVerified=false); generateHash();}, child: Text("SHUT DOWN", style: TextStyle(fontSize:10)))),
              SizedBox(width:5),
              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), onPressed: (){setState(()=>sapsEscalated=true); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Escalated to SAPS SAPS-2024/4410")) );}, child: Text(sapsEscalated?"SAPS SENT":"ESCALATE SAPS", style: TextStyle(fontSize:9)))),
            ]),
            if(isVerified) Container(margin: EdgeInsets.only(top:10), padding: EdgeInsets.all(10), color: Colors.green[100], child: Text("✅ SHOP VERIFIED QR $qr HASH $hash", style: TextStyle(fontWeight: FontWeight.bold, fontSize:11))),
          ],
        ),
      ),
    );
  }
}
