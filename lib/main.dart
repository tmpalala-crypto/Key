import 'package:flutter/material.dart';

void main() => runApp(ScanSafeAfricaApp());

class ScanSafeAfricaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ScanSafeAfrica',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: FieldInspectionPage(),
    );
  }
}

class FieldInspectionPage extends StatefulWidget {
  @override
  _FieldInspectionPageState createState() => _FieldInspectionPageState();
}

class _FieldInspectionPageState extends State<FieldInspectionPage> {
  Map<String, bool> captured = {
    'FRIDGE': true, 'PRODUCTS': true, 'CIPC': true,
    'HEALTH': true, 'INVOICE': false, 'SARS': true,
    'VAT': true, 'SAPS': true, 'VOICE': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A2F5A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInspectionTop(),
                    _buildEvidenceGrid(),
                    _buildSarsCheck(),
                    _buildAuditTrail(),
                    _buildVerification(),
                    _buildActionButtons(),
                    _buildFooter(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield, color: Colors.amber, size: 50),
              SizedBox(width: 10),
              Text('ScanSafeAfrica', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            color: Color(0xFF1565C0),
            child: Center(child: Text('SECURE VERIFIED • ANTI-CORRUPTION OFFICIAL', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionTop() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('FIELD INSPECTION v3.2.1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue)),
                child: Text('GPS LOCKED • 33.9249°S\n18.4241°E • Accuracy 3m', style: TextStyle(fontSize: 10, color: Colors.blue.shade900)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_circle, color: Colors.green, size: 18), SizedBox(width: 4), Text('Compliance Status: COMPLIANT', style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 12))]),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [Icon(Icons.camera_alt), SizedBox(width: 8), Text('Evidence Capture', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
              Text('9/9 Captured', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        children: [
          _evidenceCard('PHOTO FRIDGE', Icons.image, true, null),
          _evidenceCard('PHOTO PRODUCTS', Icons.fact_check, true, null),
          _evidenceCard('PHOTO CIPC', Icons.description, true, null),
          _evidenceCard('PHOTO HEALTH CERT', Icons.note_add, true, null),
          _evidenceCard('PHOTO INVOICE', Icons.receipt, false, 'DELETED - UNDER REVIEW\nDeleted by Officer J. Mokoena\n07 Dec 2024 - flagged for review'),
          _evidenceCard('PHOTO SARS CERTIFICATE', Icons.description, true, null),
          _evidenceCard('PHOTO VAT CERTIFICATE', Icons.description, true, null),
          _evidenceCard('PHOTO SAPS CASE\nCASE # SAPS-2024/4410', Icons.description, true, null),
          _evidenceCard('RECORD VOICE NOTE', Icons.mic, true, 'Captured • 00:18', isVoice: true),
        ],
      ),
    );
  }

  Widget _evidenceCard(String title, IconData icon, bool isCaptured, String? sub, {bool isVoice = false}) {
    bool isDeleted = title.contains('INVOICE');
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isDeleted ? Colors.red : Colors.grey.shade300)),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 35, color: isVoice ? Colors.orange : Color(0xFF0A2F5A)),
                SizedBox(height: 8),
                Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                if (isDeleted)
                  Text(sub ?? '', textAlign: TextAlign.center, style: TextStyle(fontSize: 8, color: Colors.red))
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 14),
                      SizedBox(width: 2),
                      Text(isVoice ? sub ?? 'Captured' : 'Captured', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
              ],
            ),
          ),
          if (isDeleted)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 3)),
                      child: Text('DELETED -\nUNDER REVIEW', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSarsCheck() {
    return Container(
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(children: [Icon(Icons.verified_user, color: Colors.orange), SizedBox(width: 8), Text('SARS COMPLIANCE CHECK', style: TextStyle(fontWeight: FontWeight.bold))]),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TCS PIN: •••• 7823', style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: Text('VERIFY >')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditTrail() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Color(0xFFFFCDD2), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.warning, color: Colors.white), Container(color: Colors.red, padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), child: Text('CORRUPTION LOG / AUDIT TRAIL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)))]),
          SizedBox(height: 6),
          Text('• Delete requires 2 fingerprints + voice reason  • Original hash preserved', style: TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildVerification() {
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text('INSPECTION VERIFICATION', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(children: [
                  Container(height: 80, width: 80, color: Colors.black, child: Icon(Icons.qr_code, color: Colors.white, size: 60)),
                  SizedBox(height: 6),
                  Text('Inspection ID: SSA-2024-77192', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  Text('Expires: 12 Dec 2024', style: TextStyle(fontSize: 9)),
                ]),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Icon(Icons.edit, color: Colors.green), SizedBox(width: 8), Text('Inspector Signature\nCaptured', style: TextStyle(fontSize: 11))]),
                    Divider(),
                    Row(children: [Icon(Icons.fingerprint, color: Colors.blue, size: 30), SizedBox(width: 8), Text('Subject Fingerprint\nCaptured', style: TextStyle(fontSize: 11))]),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(child: ElevatedButton.icon(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Marked Verified! Compliance logged.'))); }, icon: Icon(Icons.check_circle), label: Text('MARK VERIFIED', style: TextStyle(fontSize: 11)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))),
          SizedBox(width: 8),
          Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: Icon(Icons.power_settings_new), label: Text('SHUT DOWN\nINVESTIGATION', style: TextStyle(fontSize: 10)), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white))),
          SizedBox(width: 8),
          Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: Icon(Icons.shield), label: Text('ESCALATE TO\nSAPS', style: TextStyle(fontSize: 10)), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0A2F5A), foregroundColor: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      color: Color(0xFF0A2F5A),
      child: Text('SOFT DELETE ONLY • Evidence never erased • Court copy preserved • All actions logged to immutable audit trail • CIPC + SARS + SAPS Integrated', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 9)),
    );
  }
}
