import 'package:dxb_llegada/database/db.dart';
import 'package:dxb_llegada/main.dart';
import 'package:flutter/material.dart';

class UpdateLlegada extends StatefulWidget {
  int tileIndex, timeMilliseconds, numEquipo;
  String formattedTime;

  UpdateLlegada({
    this.tileIndex,
    this.timeMilliseconds,
    this.formattedTime,
    this.numEquipo,
  });

  @override
  _UpdateLlegadaState createState() => _UpdateLlegadaState();
}

class _UpdateLlegadaState extends State<UpdateLlegada> {
  int _numEquipo;

  @override
  Widget build(BuildContext context) {
    _numEquipo = widget.numEquipo;

    return Scaffold(
      appBar: AppBar(
        title: Text('Modificar datos de llegada'),
      ),
      body: Container(
        child: Center(
          child: Column(children: <Widget>[
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('Tiempo registrado:'),
                  Text(widget.formattedTime),
                ],
              ),
            ),
            Divider(),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text('Número de Equipo:'),
                  SizedBox(
                    width: 70,
                    child: TextField(
                      decoration: new InputDecoration.collapsed(
                        hintText: '$_numEquipo',
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      onChanged: (value) async {
                        if (await LlegadaDB.db.getLlegada(int.parse(value)) ==
                            null) {
                          await LlegadaDB.db
                              .updateEquipo(widget.tileIndex, int.parse(value));
                        } else {}
                      },
                    ),
                  )
                ],
              ),
            ),
            Expanded(
                child: Container(
              width: MediaQuery.of(context).size.width,
              child: MaterialButton(
                child: Text('Listo'),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => Crono()),
                      (Route<dynamic> route) => false);
                },
                color: Colors.amber,
              ),
            ))
          ]),
        ),
      ),
    );
  }
}
