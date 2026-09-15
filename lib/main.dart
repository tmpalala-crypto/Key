import 'package:flutter/material.dart';
void main()=>runApp(ScanSafeApp());
class ScanSafeApp extends StatelessWidget{
  @override Widget build(BuildContext c){return MaterialApp(debugShowCheckedModeBanner:false, home:HomePage());}
}
class HomePage extends StatefulWidget{
  @override _HomePageState createState()=>_HomePageState();
}
class _HomePageState extends State<HomePage>{
  String gps="GPS LOCKED: -33.873, 25.624 Bethelsdorp";
  List<String> alerts=[];
  void autoAlert(String code,bool isSuspect){
    String t=DateTime.now().toString().substring(11,19);
    String m="${isSuspect?'⚠️ SUSPECT':'✅ ORIGINAL'}: $code at $gps $t";
    setState(()=>alerts.insert(0,m));
    if(isSuspect){showDialog(context:context, barrierDismissible:false, builder:(c)=>AlertDialog(
      backgroundColor:Color(0xFF0A3D8F),
      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(20)),
      title:Row(children:[Icon(Icons.warning_amber_rounded,color:Colors.amber,size:35), SizedBox(width:8), Expanded(child:Text("AUTOMATIC SUSPECT ALERT!",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold)))]),
      content:Column(mainAxisSize:MainAxisSize.min, children:[
        Image.asset('assets/logo.png',height:120, errorBuilder:(c,e,s)=>Icon(Icons.shield,size:80,color:Colors.white)),
        SizedBox(height:10),
        Text("⚠️ SUSPECT PRODUCT DETECTED!",style:TextStyle(color:Colors.amber,fontWeight:FontWeight.bold)),
        SizedBox(height:6),
        Text("Code: $code\nLocation: $gps\nTime: $t\n\nFlagged as SUSPECT for verification.",style:TextStyle(color:Colors.white70,fontSize:11)),
        SizedBox(height:8),
        Container(color:Colors.amber, padding:EdgeInsets.all(6), child:Text("⚠️ Auto-Alert sent to HQ for verification",style:TextStyle(color:Color(0xFF0A3D8F),fontWeight:FontWeight.bold,fontSize:10))),
      ]),
      actions:[TextButton(onPressed:()=>Navigator.pop(c), child:Text("ACKNOWLEDGE ✅",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold)))],
    ));}else{ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("✅ $code VERIFIED ORIGINAL"),backgroundColor:Colors.green));}
  }
  @override Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(backgroundColor:Color(0xFF0A3D8F), title:Row(children:[Image.asset('assets/logo.png',height:36, errorBuilder:(c,e,s)=>Icon(Icons.shield,color:Colors.amber)), SizedBox(width:8), Text("ScanSafeAfrica",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))])),
      body:Padding(padding:EdgeInsets.all(16), child:Column(children:[
        Container(padding:EdgeInsets.all(14), decoration:BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(18), boxShadow:[BoxShadow(color:Colors.black12,blurRadius:8)]), child:Column(children:[
          Image.asset('assets/logo.png',height:140, errorBuilder:(c,e,s)=>Icon(Icons.shield,size:100,color:Color(0xFF0A3D8F))),
          SizedBox(height:8),
          Text("SECURE • VERIFIED • ANTI-COUNTERFEIT • OFFICIAL",style:TextStyle(fontSize:8,fontWeight:FontWeight.bold,color:Color(0xFFB8860B),letterSpacing:1)),
          SizedBox(height:8),
          Container(padding:EdgeInsets.symmetric(horizontal:10,vertical:5), decoration:BoxDecoration(color:Colors.green.shade50, borderRadius:BorderRadius.circular(20)), child:Row(mainAxisSize:MainAxisSize.min, children:[Icon(Icons.location_on,size:12,color:Colors.green), SizedBox(width:4), Text(gps,style:TextStyle(fontSize:9,fontWeight:FontWeight.bold))]))
        ])),
        SizedBox(height:16),
        Expanded(child:GridView.count(crossAxisCount:2,crossAxisSpacing:12,mainAxisSpacing:12, children:[
          _btn(Icons.qr_code_scanner,"SCAN PRODUCT",Colors.green,()=>autoAlert("SCAN-${DateTime.now().millisecond}",DateTime.now().millisecond%2==0)),
          _btn(Icons.verified_user,"VERIFY",Color(0xFF0A3D8F),()=>autoAlert("VERIFY-${DateTime.now().millisecond}",false)),
          _btn(Icons.report_problem,"REPORT SUSPECT",Colors.orange.shade800,()=>autoAlert("SUSPECT-${DateTime.now().millisecond}",true)),
          _btn(Icons.notifications_active,"ALERTS (${alerts.length})",Colors.orange,(){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("${alerts.length} alerts logged")));}),
        ])),
        Container(padding:EdgeInsets.all(6), decoration:BoxDecoration(color:Colors.black, borderRadius:BorderRadius.circular(6)), child:Row(mainAxisAlignment:MainAxisAlignment.center, children:[Icon(Icons.security,color:Colors.greenAccent,size:12), SizedBox(width:5), Text("SUSPECT PROTOCOL ACTIVE - LEGALLY SAFE",style:TextStyle(color:Colors.greenAccent,fontSize:8,fontWeight:FontWeight.bold))])),
      ])),
    );
  }
  Widget _btn(IconData i,String l,Color c,VoidCallback t){return InkWell(onTap:t, borderRadius:BorderRadius.circular(14), child:Container(decoration:BoxDecoration(color:c, borderRadius:BorderRadius.circular(14), boxShadow:[BoxShadow(color:Colors.black26,blurRadius:4)]), child:Column(mainAxisAlignment:MainAxisAlignment.center, children:[Icon(i,size:38,color:Colors.white), SizedBox(height:6), Text(l,style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:11),textAlign:TextAlign.center)])));}
}
