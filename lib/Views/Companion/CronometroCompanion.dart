import 'dart:async';
import 'dart:convert';

import 'package:dxb_llegada/Models/Llegada.dart';
import 'package:dxb_llegada/Views/Companion/LlegadaEdit.dart';
import 'package:dxb_llegada/Views/Companion/UpdateLlegada.dart';
import 'package:dxb_llegada/database/db.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//TODO DRAWER RESET
//TODO LIMPIAR CODIGO
class CronometroCompanion extends StatefulWidget {
  CronometroCompanion({Key key}) : super(key: key);

  CronometroCompanionState createState() => new CronometroCompanionState();
}

class CronometroCompanionState extends State<CronometroCompanion> {
  int _indexGeneral = 0;
  ScrollController _controller;

  void initState() {
    super.initState();
    _controller = new ScrollController();
    _obtenerIndex();
  }

  void _moverArriba() {
    _controller.animateTo(_controller.offset + 100,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  @override
  void didUpdateWidget(CronometroCompanion oldWidget) {
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
    //final file = await _localFile;
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
    Share.text('json', s, 'application/json');
  }

  //Funcion que borra toda la tabla
  void resetDB() async {
    await LlegadaDB.db.dropLlegada();
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt('horaLargada', 0);
    setState(() {
      _indexGeneral = 0;
    });
  }

  //Funcion que agrega una llegada a la base de datos e incrementa el indexGeneral
  void _addLlegada() async {
    String timestamp = DateTime.now().toIso8601String();
    var _llegadaARegistrar = new Llegada(
        id: _indexGeneral,
        tiempoLlegada: timestamp,
        numCorredor: null,
        respuestasCorrectas: null,
        registrado: 0);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Flexible(
            flex: 8,
            child: FutureBuilder<List<Llegada>>(
              future: LlegadaDB.db.getLlegadas(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Llegada>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.separated(
                    physics: BouncingScrollPhysics(),
                    reverse: true,
                    controller: _controller,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      Llegada item = snapshot.data[index];
                      final tiempoFormatted = item.tiempoLlegada;
                      String numEquipo = item.numCorredor == null
                          ? "Falta Número de Equipo"
                          : item.numCorredor;
                      return ListTile(
                        leading: Icon(Icons.access_alarms),
                        title: Text('$tiempoFormatted - ' + numEquipo),
                        trailing: Icon(item.registrado == 0
                            ? Icons.navigate_next
                            : Icons.check_circle),
                        onTap: () async {
                          if (item.registrado == 0) {
                            await Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => LlegadaEdit(
                                    tileIndex: index,
                                    formattedTime: tiempoFormatted)));
                          } else {
                            await Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    UpdateLlegada(
                                      tileIndex: index,
                                      formattedTime: tiempoFormatted,
                                      respuestas: item.respuestasCorrectas,
                                      numCorredor: item.numCorredor,
                                    )));
                          }
                        },
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
                          _addLlegada();
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
      ),
    );
  }
}
