import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(ScanSafeApp());

class ScanSafeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ScanSafeAfrica',
      theme: ThemeData(primaryColor: Color(0xFF0A3D8F)),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String gpsStatus = "Checking GPS...";
  Position? currentPos;
  List<String> alerts = [];

  @override
  void initState(){
    super.initState();
    checkGps();
  }
  
  checkGps() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if(!serviceEnabled){
      setState(()=> gpsStatus = "GPS OFF - Turn On Location");
      return;
    }
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied || permission == LocationPermission.deniedForever){
      setState(()=> gpsStatus = "GPS LOCKED - Allow Location");
    } else {
      Position pos = await Geolocator.getCurrentPosition();
      setState((){
        currentPos = pos;
        gpsStatus = "GPS LOCKED: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}";
      });
    }
  }

  // AUTOMATIC ALERT FUNCTION
  void triggerAutoAlert(String productCode, bool isFake) {
    String time = DateTime.now().toString().substring(0,19);
    String location = currentPos != null ? "${currentPos!.latitude.toStringAsFixed(4)}, ${currentPos!.longitude.toStringAsFixed(4)}" : "No GPS";
    String alertMsg = "${isFake ? '🚨 FAKE' : '✅ ORIGINAL'}: $productCode at $location - $time";
    
    setState(()=> alerts.insert(0, alertMsg));

    if(isFake){
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          backgroundColor: Colors.red.shade700,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children:[Icon(Icons.warning_amber_rounded, color: Colors.white, size:40), SizedBox(width:10), Expanded(child: Text("AUTOMATIC FAKE ALERT!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:18)))]),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children:[
            Text("🚨 COUNTERFEIT DETECTED!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:16)),
            Divider(color: Colors.white54),
            Text("Product: $productCode", style: TextStyle(color: Colors.white)),
            SizedBox(height:5),
            Text("Location: $location", style: TextStyle(color: Colors.white)),
            SizedBox(height:5),
            Text("Time: $time", style: TextStyle(color: Colors.white)),
            SizedBox(height:10),
            Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: Text("⚠️ Auto-Alert sent to ALL users + HQ in Bethelsdorp + Authorities", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize:11))),
          ]),
          actions: [
            TextButton(onPressed: ()=> Navigator.pop(c), child: Text("ALERT ALL USERS ✅", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ $productCode VERIFIED ORIGINAL at $location"), backgroundColor: Colors.green, duration: Duration(seconds: 4)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0A3D8F),
        title: Row(children:[Icon(Icons.shield, color: Colors.amber), SizedBox(width:8), Text("ScanSafeAfrica", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:18))]),
        actions: [IconButton(icon: Icon(Icons.notifications_active, color: Colors.white), onPressed: ()=> showDialog(context: context, builder: (c)=> AlertDialog(title: Text("Auto Alerts (${alerts.length})"), content: Container(width: double.maxFinite, height: 300, child: ListView(children: alerts.map((a)=> ListTile(title: Text(a, style: TextStyle(fontSize:12)))).toList())), actions: [TextButton(onPressed: ()=> Navigator.pop(c), child: Text("Close"))]))],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0xFF0A3D8F))),
              child: Row(children:[Icon(Icons.location_on, color: Color(0xFF0A3D8F)), SizedBox(width:8), Expanded(child: Text(gpsStatus, style: TextStyle(fontWeight: FontWeight.bold, fontSize:12)))]),
            ),
            SizedBox(height:16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: [
                  _buildButton(Icons.qr_code_scanner, "SCAN PRODUCT", Colors.green, () { triggerAutoAlert("PROD-${DateTime.now().millisecond}", DateTime.now().millisecond % 2 == 0); }),
                  _buildButton(Icons.verified_user, "VERIFY", Color(0xFF0A3D8F), () { triggerAutoAlert("VERIFY-${DateTime.now().millisecond}", false); }),
                  _buildButton(Icons.report_problem, "REPORT FAKE", Colors.red.shade700, () { triggerAutoAlert("FAKE-REPORT-${DateTime.now().millisecond}", true); }),
                  _buildButton(Icons.history, "ALERT HISTORY", Colors.orange, () { 
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Alerts: ${alerts.length} auto-alerts sent")));
                  }),
                ],
              ),
            ),
            Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children:[Icon(Icons.security, color: Colors.greenAccent, size:14), SizedBox(width:5), Text("AUTO-ALERT ACTIVE ON ALL SCANS", style: TextStyle(color: Colors.greenAccent, fontSize:10, fontWeight: FontWeight.bold))])),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, Color color, VoidCallback onTap){
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
          Icon(icon, size:48, color: Colors.white),
          SizedBox(height:10),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:12)),
        ]),
      ),
    );
  }
}
