import 'package:dxb_llegada/Cronometro.dart';
import 'package:dxb_llegada/database/db.dart';
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

  resetDB() async {
    await LlegadaDB.db.resetDB();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Reset DB'),
                  onTap: () {
                    resetDB();
                  }))
        ],
      )),
      appBar: new AppBar(
        title: new Text("Registro de Llegadas"),
      ),
      body: new Container(child: new Cronometro()),
    );
  }
}
