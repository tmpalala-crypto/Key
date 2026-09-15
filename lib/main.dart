import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() => runApp(ScanSafeAfricaApp());

class ScanSafeAfricaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: FieldInspectionPage());
  }
}

class FieldInspectionPage extends StatefulWidget {
  @override
  _FieldInspectionPageState createState() => _FieldInspectionPageState();
}

class _FieldInspectionPageState extends State<FieldInspectionPage> {
  bool gpsLocked = false;
  String gpsText = "GPS SEARCHING... Tap TEST UNLOCK if inside";
  String auditReason = "";
  String hashOriginal = sha256.convert(utf8.encode("INVOICE_07Dec2024_ORIGINAL")).toString();
  List<Offset?> inspectorPoints = [];
  List<Offset?> ownerPoints = [];

  void showDeleteFlow() {
    TextEditingController reasonCtrl = TextEditingController();
    bool f1=false,f2=false,voice=false;
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => StatefulBuilder(builder: (ctx,setD) => AlertDialog(
      title: Text("DELETED UNDER REVIEW - ANTI-FRAUD", style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w900)),
      content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Original Hash (Court Copy Preserved):", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
        Text(hashOriginal.substring(0,30)+"...", style: TextStyle(fontSize: 8, fontFamily: 'monospace')),
        SizedBox(height: 10),
        Text("WHY DELETED? Follow-up required:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        TextField(controller: reasonCtrl, maxLines: 3, decoration: InputDecoration(hintText: "e.g. Flagged - duplicate invoice, suspected fraud...", border: OutlineInputBorder())),
        CheckboxListTile(value: f1, onChanged: (v) { setD(() => f1=v!); }, title: Text("Inspector Fingerprint", style: TextStyle(fontSize: 11)), secondary: Icon(Icons.fingerprint, color: Colors.green)),
        CheckboxListTile(value: f2, onChanged: (v) { setD(() => f2=v!); }, title: Text("Supervisor Fingerprint 2", style: TextStyle(fontSize: 11)), secondary: Icon(Icons.fingerprint, color: Colors.blue)),
        CheckboxListTile(value: voice, onChanged: (v) => setD(() => voice=v!), title: Text("Voice Reason 00:18 Recorded", style: TextStyle(fontSize: 11)), secondary: Icon(Icons.mic, color: Colors.orange)),
      ])),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(ctx), child: Text("CANCEL")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: (f1&&f2&&voice&&reasonCtrl.text.length>5)? () {
            setState(() => auditReason = reasonCtrl.text);
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("🔴 STAMPED: DELETED UNDER REVIEW - Reason: ${reasonCtrl.text}"), backgroundColor: Colors.red, duration: Duration(seconds: 5)));
          } : null,
          child: Text("CONFIRM + STAMP"),
        )
      ],
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F4F7),
      body: SingleChildScrollView(child: Column(children: [
        Container(width: double.infinity, padding: EdgeInsets.only(top: 45, bottom: 12), color: Color(0xFF0A2A5E), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset('assets/logo.png', width: 50, height: 50, errorBuilder: (c,e,s)=>Icon(Icons.shield, color: Colors.white, size: 40)), SizedBox(width: 10), Text("ScanSafeAfrica", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))])),
        Container(width: double.infinity, color: Color(0xFF0D5CFF), padding: EdgeInsets.symmetric(vertical: 5), child: Text("SECURE VERIFIED • CIPC • HEALTH • SARS • VAT • SAPS • BRAND", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),

        if (!gpsLocked)
          Container(width: double.infinity, color: Colors.red, padding: EdgeInsets.all(10), child: Text("🚨 GPS INACTIVE - TAP ORANGE BUTTON BELOW TO UNLOCK FOR TEST", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),

        Padding(padding: EdgeInsets.all(12), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("FIELD INSPECTION v3.2.1", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)), Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: gpsLocked?Colors.blue.shade100:Colors.red.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: gpsLocked?Colors.blue:Colors.red)), child: Text(gpsText, style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold)))]),
          SizedBox(height: 8),
          Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: gpsLocked?Colors.green.shade100:Colors.red.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: gpsLocked?Colors.green:Colors.red)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(gpsLocked?Icons.check_circle:Icons.error, size: 14, color: gpsLocked?Colors.green:Colors.red), SizedBox(width: 4), Text(gpsLocked?"Compliance: COMPLIANT - GPS ACTIVE":"Compliance: BLOCKED - TAP TEST UNLOCK", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))])),

          SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.camera_alt_outlined), SizedBox(width: 6), Text("Evidence Capture", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]), Text("9/9 Captured", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))]),
          SizedBox(height: 8),
          GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: NeverScrollableScrollPhysics(), crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85, children: [
            _card(Icons.image, "PHOTO FRIDGE", "Captured"),
            _card(Icons.fact_check, "PHOTO PRODUCTS (BRAND)", "Captured"),
            _card(Icons.description, "PHOTO CIPC", "CIPC ACTIVE"),
            _card(Icons.note_add, "PHOTO HEALTH CERT", "HEALTH ACTIVE"),
            _cardDel(),
            _card(Icons.description, "PHOTO SARS CERT", "SARS ACTIVE"),
            _card(Icons.description, "PHOTO VAT CERT", "VAT ACTIVE"),
            _card(Icons.description, "PHOTO SAPS CASE", "SAPS ACTIVE"),
            _card(Icons.mic, "RECORD VOICE NOTE", "Captured • 00:18", isVoice: true),
          ]),

          SizedBox(height: 12),
          Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Color(0xFFFFE8CC), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("TCS PIN: •••• 7823", style: TextStyle(fontWeight: FontWeight.bold)), ElevatedButton(onPressed: (){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SARS VERIFIED - GPS ${gpsText} - All Depts ACTIVE"))); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: Text("VERIFY >"))])),

          Container(margin: EdgeInsets.only(top: 8), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red)), child: Column(children: [
            Container(padding: EdgeInsets.all(6), color: Colors.red, child: Row(children: [Icon(Icons.warning, color: Colors.white, size: 16), SizedBox(width: 6), Expanded(child: Text("ALL DEPARTMENTS ACTIVE - AUDIT TRAIL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)))])),
            Padding(padding: EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("✅ CIPC ACTIVE • ✅ HEALTH ACTIVE • ✅ SARS ACTIVE • ✅ VAT ACTIVE", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              Text("✅ SAPS ACTIVE • ✅ BRAND ACTIVE • ✅ SCANSAFE ACTIVE", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              Text("• Original hash: ${hashOriginal.substring(0,16)}... preserved 🔒", style: TextStyle(fontSize: 9)),
              if (auditReason.isNotEmpty) Text("• FOLLOW-UP: ${auditReason}", style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
            ]))
          ])),

          SizedBox(height: 12),
          Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)), child: Column(children: [
            Text("SIGNATURES ACTIVE - DRAW WITH FINGER", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
            SizedBox(height: 10),
            Row(children: [
              Expanded(child: Column(children: [Container(width: 75, height: 75, color: Colors.black, child: Icon(Icons.qr_code, color: Colors.white, size: 65)), SizedBox(height: 4), Text("SSA-2024-77192", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold))])),
              Container(width: 1, height: 180, color: Colors.grey.shade300),
              Expanded(flex: 2, child: Column(children: [
                Text("Inspector Signature", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onPanUpdate: (d) => setState(() => inspectorPoints.add(d.localPosition)),
                  onPanEnd: (d) => inspectorPoints.add(null),
                  child: Container(height: 60, width: 120, decoration: BoxDecoration(border: Border.all(color: Colors.grey), color: Colors.white), child: CustomPaint(painter: SignaturePainter(inspectorPoints))),
                ),
                Row(children: [TextButton(onPressed: ()=>setState(()=>inspectorPoints=[]), child: Text("Clear", style: TextStyle(fontSize: 9))), ElevatedButton(onPressed: (){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Inspector Signed + Fingerprint OK"))); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: Text("SAVE", style: TextStyle(fontSize: 9)))]),
                Text("Owner Signature", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onPanUpdate: (d) => setState(() => ownerPoints.add(d.localPosition)),
                  onPanEnd: (d) => ownerPoints.add(null),
                  child: Container(height: 60, width: 120, decoration: BoxDecoration(border: Border.all(color: Colors.grey), color: Colors.white), child: CustomPaint(painter: SignaturePainter(ownerPoints))),
                ),
                Row(children: [TextButton(onPressed: ()=>setState(()=>ownerPoints=[]), child: Text("Clear", style: TextStyle(fontSize: 9))), ElevatedButton(onPressed: (){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Owner Signed + Fingerprint OK"))); }, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0A2A5E)), child: Text("SAVE", style: TextStyle(fontSize: 9)))]),
              ])),
            ])
          ])),

          SizedBox(height: 16),
          if (!gpsLocked)
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 10),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    gpsLocked = true;
                    gpsText = "GPS LOCKED • 33.9249°S 18.4241°E • TEST MODE";
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("🔓 GPS UNLOCKED FOR TEST - ALL DEPARTMENTS NOW ACTIVE!"), backgroundColor: Colors.orange));
                },
                icon: Icon(Icons.lock_open),
                label: Text("UNLOCK GPS FOR TEST (INDOOR MODE)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, minimumSize: Size(double.infinity, 50)),
              ),
            ),

          ElevatedButton.icon(
            onPressed: gpsLocked? (){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SCAN ACTIVE - CIPC HEALTH SARS VAT SAPS BRAND ALL ACTIVE - GPS ${gpsText}"), backgroundColor: Colors.blue)); } : (){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tap UNLOCK GPS FOR TEST above first!"), backgroundColor: Colors.red)); },
            icon: Icon(Icons.qr_code_scanner, size: 28),
            label: Text(gpsLocked? "SCAN ACTION • ALL DEPARTMENTS ACTIVE ✓" : "SCAN BLOCKED • UNLOCK GPS FIRST", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            style: ElevatedButton.styleFrom(backgroundColor: gpsLocked? Color(0xFF0D5CFF) : Colors.grey, foregroundColor: Colors.white, minimumSize: Size(double.infinity, 58), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
          SizedBox(height: 20),
        ])),
      ])),
    );
  }

  Widget _card(IconData icon, String title, String status, {bool isVoice=false}) {
    return Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)), padding: EdgeInsets.all(8), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 30, color: isVoice?Colors.orange:Color(0xFF0A2A5E)), SizedBox(height: 4), Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8)), SizedBox(height: 2), Text(status, style: TextStyle(color: Colors.green, fontSize: 7, fontWeight: FontWeight.bold))]));
  }

  Widget _cardDel() {
    return GestureDetector(
      onTap: showDeleteFlow,
      child: Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.red), borderRadius: BorderRadius.circular(8)), padding: EdgeInsets.all(8), child: Stack(children: [
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.description, size: 30, color: Color(0xFF0A2A5E)), SizedBox(height: 4), Text("PHOTO INVOICE", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8))]),
        Positioned.fill(child: Container(color: Colors.white.withOpacity(0.88), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Transform.rotate(angle: -0.25, child: Container(padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 1.5)), child: Text("DELETED —\nUNDER REVIEW", textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 8)))), SizedBox(height: 2), Text("Tap for reason", style: TextStyle(fontSize: 6, color: Colors.blue))])) )
      ])),
    );
  }
}

class SignaturePainter extends CustomPainter {
  List<Offset?> points;
  SignaturePainter(this.points);
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.black..strokeWidth = 2..strokeCap = StrokeCap.round;
    for (int i=0; i<points.length-1; i++) {
      if (points[i]!=null && points[i+1]!=null) canvas.drawLine(points[i]!, points[i+1]!, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
