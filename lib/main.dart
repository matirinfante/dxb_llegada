import 'package:dxb_llegada/Cronometro.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Llegadas',
      home: Crono(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Crono extends StatelessWidget {
  Crono({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Registro de Llegadas"),
      ),
      body: new Container(child: new Cronometro()),
    );
  }
}
