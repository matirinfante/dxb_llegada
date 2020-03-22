import 'dart:convert';

import 'package:dxb_llegada/Models/Llegada.dart';
import 'package:dxb_llegada/Models/LlegadaMaraton.dart';
import 'package:dxb_llegada/database/db.dart';
import 'package:dxb_llegada/main.dart';
import 'package:flutter/material.dart';

class LlegadaEdit extends StatefulWidget {
  int tileIndex, timeMilliseconds;
  String formattedTime;

  LlegadaEdit({this.tileIndex, this.timeMilliseconds, this.formattedTime});

  @override
  _LlegadaEditState createState() => _LlegadaEditState();
}

class _LlegadaEditState extends State<LlegadaEdit> {
  Llegada _datosLlegada;
  String _numCorredor;
  bool _datosCargados = false;
  int _respuestas;

  void initState() {
    _checkIfRegistered();
  }

  _checkIfRegistered() async {
    var object = await LlegadaDB.db.getLlegada(widget.tileIndex);
    print(object);
    if (object.registrado != 0) {
      setState(() {
        _datosCargados = true;
      });
    }
  }

  _subirDatos() async {
    if (_numCorredor != null) {
      if (await LlegadaDB.db.getLlegadaByEquipo(_numCorredor) != null) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: AlertDialog(
                  content: Text('EQUIPO YA AGREGADO!'),
                  actions: <Widget>[
                    MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    )
                  ],
                ),
              );
            });
      } else {
        _datosLlegada = new Llegada(
            numCorredor: _numCorredor,
            tiempoLlegada: widget.timeMilliseconds,
            respuestasCorrectas: _respuestas,
            registrado: 1);
        String _json = jsonEncode(_datosLlegada);
        print(_json);
        await LlegadaDB.db.updateLlegada(widget.tileIndex, _numCorredor, 1);
        setState(() {
          _datosCargados = true;
        });
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => Crono()),
            (Route<dynamic> route) => false);
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Imposible subir datos de llegada'),
              content: Text('Verifique que los campos no esten vacios.'),
              actions: <Widget>[
                MaterialButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar datos de llegada'),
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
                      keyboardType: TextInputType.numberWithOptions(),
                      onChanged: (value) async {
                        _numCorredor = value;
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
                child: Text('Subir datos'),
                onPressed: _datosCargados ? null : _subirDatos,
                color: Colors.amber,
              ),
            ))
          ]),
        ),
      ),
    );
  }
}
