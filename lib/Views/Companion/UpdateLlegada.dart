import 'package:dxb_llegada/Views/Companion/CronometroCompanion.dart';
import 'package:dxb_llegada/database/db.dart';
import 'package:flutter/material.dart';

//TODO AGREGAR CAMPO RESPUESTAS CORRECTAS
class UpdateLlegada extends StatefulWidget {
  int tileIndex, respuestas;
  String formattedTime, numCorredor;

  UpdateLlegada({
    this.tileIndex,
    this.formattedTime,
    this.respuestas,
    this.numCorredor,
  });

  @override
  _UpdateLlegadaState createState() => _UpdateLlegadaState();
}

class _UpdateLlegadaState extends State<UpdateLlegada> {
  String _numCorredor;

  @override
  Widget build(BuildContext context) {
    _numCorredor = widget.numCorredor;

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
                  Text('Número de Corredor:'),
                  SizedBox(
                    width: 70,
                    child: TextField(
                      decoration: new InputDecoration.collapsed(
                        hintText: '$_numCorredor',
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      onChanged: (value) async {
                        if (await LlegadaDB.db.getLlegadaByEquipo(value) ==
                            null) {
                          await LlegadaDB.db
                              .updateEquipo(widget.tileIndex, value);
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
                          builder: (BuildContext context) =>
                              CronometroCompanion()),
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
