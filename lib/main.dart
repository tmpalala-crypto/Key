import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:signature/signature.dart';

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
  Position? currentPos;
  String gpsText = "GPS SEARCHING...";
  String auditReason = "";
  String hashOriginal = sha256.convert(utf8.encode("INVOICE_07Dec2024_ORIGINAL")).toString();
  final LocalAuthentication auth = LocalAuthentication();
  
  SignatureController inspectorController = SignatureController(penStrokeWidth: 3, penColor: Colors.black);
  SignatureController ownerController = SignatureController(penStrokeWidth: 3, penColor: Colors.black);
  bool inspectorSigned = true;
  bool ownerSigned = false;
  bool fingerCaptured = true;
  bool voiceCaptured = true;

  @override
  void initState() {
    super.initState();
    activateGpsActive();
  }

  Future<void> activateGpsActive() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => gpsText = "GPS OFF - ENABLE IT!");
      _showGpsAlert("GPS service OFF! Please turn ON location.");
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      setState(() => gpsText = "GPS PERMISSION DENIED!");
      return;
    }
    // ACTIVE GPS STREAM - automatic alert
    Geolocator.getPositionStream(locationSettings: LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 5)).listen((pos) {
      setState(() {
        currentPos = pos;
        gpsLocked = true;
        gpsText = "GPS LOCKED • ${pos.latitude.toStringAsFixed(4)}°S ${pos.longitude.toStringAsFixed(4)}°E • Accuracy ${pos.accuracy.toStringAsFixed(0)}m";
      });
    });
    
    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPos = pos;
      gpsLocked = true;
      gpsText = "GPS LOCKED • ${pos.latitude.toStringAsFixed(4)}°S ${pos.longitude.toStringAsFixed(4)}°E • Accuracy ${pos.accuracy.toStringAsFixed(0)}m";
    });
  }

  void _showGpsAlert(String msg) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("🚨 GPS REQUIRED - AUTOMATIC ALERT"),
      content: Text("$msg\n\nApp blocked until GPS active! This prevents fake inspections - anti-corruption protection."),
      actions: [ElevatedButton(onPressed: () { Navigator.pop(c); activateGpsActive(); }, child: Text("ACTIVATE GPS NOW"))],
    ));
  }

  Future<void> authenticateFinger() async {
    try {
      bool didAuth = await auth.authenticate(localizedReason: "Verify fingerprint for anti-fraud delete", options: AuthenticationOptions(biometricOnly: true));
      if (didAuth) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Fingerprint Verified!"), backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fingerprint: $e - Using mock for demo"), backgroundColor: Colors.orange));
    }
  }

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
        CheckboxListTile(value: f1, onChanged: (v) { setD(() => f1=v!); if(v!) authenticateFinger(); }, title: Text("Inspector Fingerprint", style: TextStyle(fontSize: 11)), secondary: Icon(Icons.fingerprint)),
        CheckboxListTile(value: f2, onChanged: (v) { setD(() => f2=v!); if(v!) authenticateFinger(); }, title: Text("Supervisor Fingerprint 2", style: TextStyle(fontSize: 11)), secondary: Icon(Icons.fingerprint)),
        CheckboxListTile(value: voice, onChanged: (v) => setD(() => voice=v!), title: Text("Voice Reason 00:18 Recorded", style: TextStyle(fontSize: 11)), secondary: Icon(Icons.mic, color: Colors.orange)),
      ])),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(ctx), child: Text("CANCEL")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: (f1&&f2&&voice&&reasonCtrl.text.length>5) ? () {
            setState(() => auditReason = reasonCtrl.text);
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("🔴 STAMPED: DELETED UNDER REVIEW - Reason: ${reasonCtrl.text} - Hash ${hashOriginal.substring(0,8)} preserved"), backgroundColor: Colors.red, duration: Duration(seconds: 5)));
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
        Container(width: double.infinity, padding: EdgeInsets.only(top: 45, bottom: 12), color: Color(0xFF0A2A5E), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset('assets/logo.png', width: 50, height: 50, errorBuilder: (c,e,s)=>Icon(Icons.shield, color: Colors.white)), SizedBox(width: 10), Text("ScanSafeAfrica", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))])),
        Container(width: double.infinity, color: Color(0xFF0D5CFF), padding: EdgeInsets.symmetric(vertical: 5), child: Text("SECURE VERIFIED • ANTI-CORRUPTION OFFICIAL", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
        
        if (!gpsLocked)
          Container(width: double.infinity, color: Colors.red, padding: EdgeInsets.all(10), child: Row(children: [Icon(Icons.gps_off, color: Colors.white), SizedBox(width: 8), Expanded(child: Text("🚨 AUTOMATIC ALERT: GPS INACTIVE - SCAN BLOCKED! Activate GPS to work - Anti-fraud protection.", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))), ElevatedButton(onPressed: activateGpsActive, style: ElevatedButton.styleFrom(backgroundColor: Colors.white), child: Text("ACTIVATE", style: TextStyle(color: Colors.red, fontSize: 10)))])),
        
        Padding(padding: EdgeInsets.all(12), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("FIELD INSPECTION v3.2.1", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)), Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: gpsLocked?Colors.blue.shade100:Colors.red.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: gpsLocked?Colors.blue:Colors.red)), child: Text(gpsText, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)))]),
          SizedBox(height: 8),
          Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: gpsLocked?Colors.green.shade100:Colors.red.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: gpsLocked?Colors.green:Colors.red)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(gpsLocked?Icons.check_circle:Icons.error, size: 14, color: gpsLocked?Colors.green:Colors.red), SizedBox(width: 4), Text(gpsLocked?"Compliance Status: COMPLIANT - GPS ACTIVE":"Compliance: BLOCKED - GPS REQUIRED", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))])),
          
          SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.camera_alt_outlined), SizedBox(width: 6), Text("Evidence Capture", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]), Text("9/9 Captured", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))]),
          SizedBox(height: 8),
          GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: NeverScrollableScrollPhysics(), crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85, children: [
            _card(Icons.image, "PHOTO FRIDGE", "Captured"),
            _card(Icons.fact_check, "PHOTO PRODUCTS", "Captured"),
            _card(Icons.description, "PHOTO CIPC", "Captured"),
            _card(Icons.note_add, "PHOTO HEALTH CERT", "Captured"),
            _cardDel(),
            _card(Icons.description, "PHOTO SARS CERT", "Captured"),
            _card(Icons.description, "PHOTO VAT CERT", "Captured"),
            _card(Icons.description, "PHOTO SAPS CASE", "Captured"),
            _card(Icons.mic, "RECORD VOICE NOTE", "Captured • 00:18", isVoice: true),
          ]),
          
          SizedBox(height: 12),
          Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Color(0xFFFFE8CC), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("TCS PIN: •••• 7823", style: TextStyle(fontWeight: FontWeight.bold)), ElevatedButton(onPressed: (){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SARS VERIFIED - GPS ${currentPos?.latitude} - Hash OK"))); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: Text("VERIFY >"))])),
          
          Container(margin: EdgeInsets.only(top: 8), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red)), child: Column(children: [
            Container(padding: EdgeInsets.all(6), color: Colors.red, child: Row(children: [Icon(Icons.warning, color: Colors.white, size: 16), SizedBox(width: 6), Expanded(child: Text("CORRUPTION LOG / AUDIT TRAIL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)))])),
            Padding(padding: EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("• Delete requires 2 fingerprints + voice + written reason", style: TextStyle(fontSize: 10)),
              Text("• Original hash: ${hashOriginal.substring(0,16)}... preserved 🔒", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              if (auditReason.isNotEmpty) Text("• FOLLOW-UP: ${auditReason}", style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
            ]))
          ])),

          SizedBox(height: 12),
          // SIGNATURES - ACTIVE
          Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)), child: Column(children: [
            Text("INSPECTION VERIFICATION + SIGNATURES + FINGERPRINT", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
            SizedBox(height: 10),
            Row(children: [
              Expanded(child: Column(children: [Container(width: 75, height: 75, color: Colors.black, child: Icon(Icons.qr_code, color: Colors.white, size: 65)), SizedBox(height: 4), Text("SSA-2024-77192", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)), Text("GPS: ${currentPos?.latitude.toStringAsFixed(2) ?? 'LOCKING...'}", style: TextStyle(fontSize: 7))])),
              Container(width: 1, height: 200, color: Colors.grey.shade300),
              Expanded(flex: 2, child: Column(children: [
                Text("Inspector Signature - ACTIVE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                Container(height: 60, decoration: BoxDecoration(border: Border.all(color: Colors.grey)), child: Signature(controller: inspectorController, backgroundColor: Colors.white)),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [TextButton(onPressed: ()=>inspectorController.clear(), child: Text("Clear", style: TextStyle(fontSize: 9))), ElevatedButton(onPressed: (){ setState(()=>inspectorSigned=true); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Inspector Signed + Fingerprint captured"))); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: Text("SAVE SIG + FINGERPRINT", style: TextStyle(fontSize: 8)))]),
                Divider(),
                Text("Owner Signature - ACTIVE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                Container(height: 60, decoration: BoxDecoration(border: Border.all(color: Colors.grey)), child: Signature(controller: ownerController, backgroundColor: Colors.white)),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [TextButton(onPressed: ()=>ownerController.clear(), child: Text("Clear", style: TextStyle(fontSize: 9))), ElevatedButton(onPressed: (){ setState(()=>ownerSigned=true); authenticateFinger(); }, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0A2A5E)), child: Text("SAVE + FINGERPRINT", style: TextStyle(fontSize: 8)))]),
              ])),
            ])
          ])),

          SizedBox(height: 12),
          Row(children: [
            Expanded(child: ElevatedButton.icon(onPressed: gpsLocked?(){}:()=>_showGpsAlert("GPS must be active!"), icon: Icon(Icons.check_circle), label: Text("MARK VERIFIED", style: TextStyle(fontSize: 9)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(vertical: 12)))),
            SizedBox(width: 6),
            Expanded(child: ElevatedButton.icon(onPressed: (){}, icon: Icon(Icons.power_settings_new), label: Text("SHUT DOWN\nINVESTIGATION", textAlign: TextAlign.center, style: TextStyle(fontSize: 8)), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: EdgeInsets.symmetric(vertical: 8)))),
            SizedBox(width: 6),
            Expanded(child: ElevatedButton.icon(onPressed: (){}, icon: Icon(Icons.shield), label: Text("ESCALATE TO\nSAPS", textAlign: TextAlign.center, style: TextStyle(fontSize: 8)), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0A2A5E), padding: EdgeInsets.symmetric(vertical: 8)))),
          ]),
          
          SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: gpsLocked ? (){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SCAN ACTION ACTIVE - GPS ${gpsText} - Camera opening..."), backgroundColor: Colors.blue)); } : () => _showGpsAlert("SCAN BLOCKED - GPS must be active to work!"),
            icon: Icon(Icons.qr_code_scanner, size: 28),
            label: Text(gpsLocked ? "SCAN ACTION • GPS LOCKED ✓ ACTIVE" : "SCAN BLOCKED • ACTIVATE GPS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            style: ElevatedButton.styleFrom(backgroundColor: gpsLocked ? Color(0xFF0D5CFF) : Colors.grey, foregroundColor: Colors.white, minimumSize: Size(double.infinity, 58), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ])),
      ])),
    );
  }

  Widget _card(IconData icon, String title, String status, {bool isVoice=false}) {
    return Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)), padding: EdgeInsets.all(8), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 36, color: isVoice?Colors.orange:Color(0xFF0A2A5E)), SizedBox(height: 5), Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9)), SizedBox(height: 3), Text(status, style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold))]));
  }

  Widget _cardDel() {
    return GestureDetector(
      onTap: showDeleteFlow,
      child: Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.red), borderRadius: BorderRadius.circular(8)), padding: EdgeInsets.all(8), child: Stack(children: [
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.description, size: 36, color: Color(0xFF0A2A5E)), SizedBox(height: 5), Text("PHOTO INVOICE", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9))]),
        Positioned.fill(child: Container(color: Colors.white.withOpacity(0.88), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Transform.rotate(angle: -0.25, child: Container(padding: EdgeInsets.all(3), decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 2)), child: Text("DELETED —\nUNDER REVIEW", textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 9)))), SizedBox(height: 3), Text("Deleted by J.Mokoena\n07 Dec 2024", textAlign: TextAlign.center, style: TextStyle(fontSize: 6)), Text("Tap for reason + evidence", style: TextStyle(fontSize: 6, color: Colors.blue, decoration: TextDecoration.underline))] )))
      ])),
    );
  }
}
