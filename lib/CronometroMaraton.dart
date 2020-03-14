import 'dart:async';
import 'dart:convert';

import 'package:dxb_llegada/Models/Llegada.dart';
import 'package:dxb_llegada/database/db.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cronometro extends StatefulWidget {
  Cronometro({Key key}) : super(key: key);

  CronometroState createState() => new CronometroState();
}

class CronometroState extends State<Cronometro> {
  int _indexGeneral = 0, _horaLargadaMilli = 0, _idPunto = 0, _idUser = 0;
  bool _largadaSetted = false;
  ScrollController _controller;
  TextEditingController textEditingController;

  //verificarDatosCompletos
  //Funcion dedicada a verificar, desde un snap de la base de datos, si todos los registros estan debidamente completados.
  //La verificación se realiza como chequeo antes de convertir los datos en JSON.
  //Function dedicated to verify, from a database snap, if all the registers have been completed properly.
  //This is one is called as a pre JSON parse of the data.
  //return: Future<bool>
  Future<bool> _verificarDatosCompletos() async {
    bool _completo = true;
    List<Llegada> list = await LlegadaDB.db.getLlegadas();
    list.forEach((element) {
      if (element.registrado == 0) {
        _completo = false;
      }
    });
    return _completo;
  }

  void initState() {
    super.initState();
    _controller = new ScrollController(initialScrollOffset: 0.0);
    textEditingController = new TextEditingController();
    _obtenerIndex();
  }

  void _moverArriba() {
    _controller.animateTo(_controller.offset + 100,
        duration: Duration(milliseconds: 250), curve: Curves.easeIn);
  }

  @override
  void didUpdateWidget(Cronometro oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  //Funcion que obtiene el indice actual almacenado en la base de datos
  void _obtenerIndex() async {
    List<Llegada> llegadas = await LlegadaDB.db.getLlegadas();
    setState(() {
      _indexGeneral = llegadas.length;
    });
  }

  Future<String> pasarBDaJSON() async {
    String s = '[';
    List<Llegada> data = await LlegadaDB.db.getLlegadas();
    data.forEach((element) {
      if (element == data.last) {
        s += jsonEncode(element);
        s += '\n';
      } else {
        s += jsonEncode(element);
        s += ',\n';
      }
    });
    // Write the file.
    s += ']';
    return s;
  }

  void _enviarDatos() async {
    String s = await pasarBDaJSON();
    Share.text('JSON', s, 'application/json');
  }

  //Boton que controla Parar e Inicio
  //Funcion que borra toda la tabla
  void resetDB() async {
    await LlegadaDB.db.resetDB();
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt('horaLargada', 0);
    setState(() {
      _indexGeneral = 0;
      _horaLargadaMilli = 0;
    });
  }

//Funcion que agrega una llegada a la base de datos e incrementa el indexGeneral
  void _addLlegada(String numCorredor) async {
    DateTime dateTime = DateTime.now();
    var _llegadaARegistrar = new Llegada(
        id: _indexGeneral,
        idPunto: _idPunto,
        idUser: _idUser,
        tiempoLlegada: dateTime.toIso8601String(),
        numCorredor: numCorredor,
        registrado: 1);
    await LlegadaDB.db.addLlegada(_llegadaARegistrar);
    setState(() {
      _indexGeneral += 1;
    });
    _moverArriba();
  }

//Funcion que da formato HH:MM:SS:MS a un tiempo en milisegundos
  String timeFormatter(int time) {
    Duration duration = Duration(milliseconds: time);
    int milliseconds = (time % 1000);
    String formato = [
      duration.inHours,
      duration.inMinutes,
      duration.inSeconds,
    ].map((seg) => seg.remainder(60).toString().padLeft(2, '0')).join(':');
    return formato + ':$milliseconds';
  }

  Widget Lista() {
    return FutureBuilder<List<Llegada>>(
      future: LlegadaDB.db.getLlegadas(),
      builder: (BuildContext context, AsyncSnapshot<List<Llegada>> snapshot) {
        if (snapshot.hasData) {
          return ListView.separated(
            physics: BouncingScrollPhysics(),
            reverse: false,
            controller: _controller,
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              Llegada item = snapshot.data[index];
              String timestamp = item.tiempoLlegada;
              String numCorredor = item.numCorredor == null
                  ? "Falta Número de Equipo"
                  : item.numCorredor;
              return ListTile(
                leading: Icon(Icons.access_alarms),
                title: Text('$timestamp - ' + numCorredor),
                trailing: Icon(item.registrado == 0
                    ? Icons.navigate_next
                    : Icons.check_circle),
                onTap: () {},
              );
            },
            separatorBuilder: (BuildContext context, index) {
              return Divider();
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Flexible(flex: 8, child: Lista()),
        SizedBox(
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: TextField(
            controller: textEditingController,
            keyboardType: TextInputType.numberWithOptions(signed: false),
            onChanged: (text) async {
              setState(() {
                text = textEditingController.text;
              });
            },
          ),
        ),
        SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: new Padding(
              padding: const EdgeInsets.only(
                top: 5.0,
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width,
                      color: Colors.amber,
                      onPressed: () {
                        _addLlegada(textEditingController.text.toString());
                        setState(() {
                          textEditingController.text = null;
                        });
                      },
                      child: Text("REGISTRAR"),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width,
                      color: Colors.deepOrangeAccent,
                      onPressed: _enviarDatos,
                      child: Text("ENVIAR DATOS"),
                    ),
                  )
                ],
              )),
        ),
      ],
    );
  }
}
