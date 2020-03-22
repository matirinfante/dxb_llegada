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

//TODO SOLO BOTON LLEGADA Y SUBIR DATOS
//TODO DRAWER RESET
//TODO TIEMPO ES TIMESTAMP STRING NO SE GUARDA EL TIEMPO DE LARGADA
//TODO ACTUALIZAR NUEVO TIMEPICKER
//TODO LIMPIAR CODIGO
class CronometroCompanion extends StatefulWidget {
  CronometroCompanion({Key key}) : super(key: key);

  CronometroCompanionState createState() => new CronometroCompanionState();
}

class CronometroCompanionState extends State<CronometroCompanion> {
  int _indexGeneral = 0, _horaLargadaMilli = 0, _currentTime = 0;
  DateTime _horaActual, _horaLargada;
  bool _largadaSetted = false;
  ScrollController _controller;

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

  void _setearLargada() async {
    setState(() {
      _horaLargadaMilli = _horaLargada.millisecondsSinceEpoch;
      _largadaSetted = true;
    });
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt('horaLargada', _horaLargadaMilli);
    print(_horaLargadaMilli);
  }

  void initState() {
    super.initState();
    _controller = new ScrollController();
    _obtenerIndex();
    _verificarHoraLargada();
  }

  void _moverArriba() {
    _controller.animateTo(_controller.offset + 100,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void _verificarHoraLargada() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      int largada = prefs.getInt('horaLargada') ?? 0;
      if (largada != 0) {
        _horaLargadaMilli = largada;
        _largadaSetted = true;
        _horaLargada = DateTime.fromMillisecondsSinceEpoch(_horaLargadaMilli);
      } else {
        _horaLargada = DateTime.utc(2019);
      }
    });
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

  //Boton que controla Laps y Reinicio
  void leftButtonPressed() {
    setState(() {
      if (_largadaSetted) {
        int dif = DateTime.now().difference(_horaLargada).inMilliseconds;
        _addLlegada(dif);
        print("je");
        print(dif);
      } else {
        //dependencies.stopwatch.reset();
        resetDB();
      }
    });
  }

  //Boton que controla Parar e Inicio
  void rightButtonPressed() {
    setState(() {
      //dependencies.stopwatch.start();
      showDialog(
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Ingrese hora de inicio'),
              content: TimePickerSpinner(
                is24HourMode: true,
                isShowSeconds: false,
                onTimeChange: (time) {
                  setState(() {
                    _horaLargada = time;
                    _setearLargada();
                  });
                },
              ),
            );
          },
          context: context);
    });
  }

  //Funcion que borra toda la tabla
  void resetDB() async {
    await LlegadaDB.db.dropLlegada();
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt('horaLargada', 0);
    setState(() {
      _indexGeneral = 0;
      _horaLargadaMilli = 0;
    });
  }

  //Funcion que agrega una llegada a la base de datos e incrementa el indexGeneral
  void _addLlegada(int ellapsedMilliseconds) async {
    var _llegadaARegistrar = new Llegada(
        id: _indexGeneral,
        tiempoLlegada: ellapsedMilliseconds,
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

  //Se buildean los botones
  Widget buildFloatingButton(String text, VoidCallback callback) {
    return new FloatingActionButton.extended(
        heroTag: text,
        icon: Icon(Icons.label),
        label: new Text(
          text,
          textAlign: TextAlign.center,
        ),
        onPressed: callback);
  }

  @override
  Widget build(BuildContext context) {
    String _llegadaFormato = timeFormatter(_horaLargadaMilli - 10800000);
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Flexible(
          flex: 2,
          child: Center(
            child: Text(
              _llegadaFormato,
              style: TextStyle(fontSize: 50),
            ),
          ),
        ),
        Flexible(
          flex: 8,
          child: FutureBuilder<List<Llegada>>(
            future: LlegadaDB.db.getLlegadas(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Llegada>> snapshot) {
              if (snapshot.hasData) {
                return ListView.separated(
                  physics: BouncingScrollPhysics(),
                  reverse: true,
                  controller: _controller,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    Llegada item = snapshot.data[index];
                    final tiempoFormatted = timeFormatter(item.tiempoLlegada);
                    String numEquipo = item.numCorredor == null
                        ? "Falta Número de Equipo"
                        : item.numCorredor.toString();
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
                                  timeMilliseconds: item.tiempoLlegada,
                                  formattedTime: tiempoFormatted)));
                        } else {
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => UpdateLlegada(
                                    tileIndex: index,
                                    timeMilliseconds: item.tiempoLlegada,
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
        new Flexible(
          flex: 1,
          child: new Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
            ),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                buildFloatingButton(_largadaSetted ? "Llegada" : "Reiniciar",
                    leftButtonPressed),
                FloatingActionButton.extended(
                  icon: Icon(Icons.timer),
                  heroTag: 'set',
                  label: Text('Setear arranque'),
                  onPressed: () {
                    setState(() {
                      //dependencies.stopwatch.start();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Ingrese hora de inicio'),
                              content: TimePickerSpinner(
                                is24HourMode: true,
                                isShowSeconds: true,
                                onTimeChange: (time) {
                                  setState(() {
                                    _horaLargada = time;
                                    _setearLargada();
                                  });
                                },
                              ),
                              actions: <Widget>[
                                Padding(
                                  child: MaterialButton(
                                    child: Text('Aceptar'),
                                    onPressed: () {
                                      //startTimer();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                ),
                              ],
                            );
                          });
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildFloatingButton('Resetear todo', resetDB),
              buildFloatingButton('Enviar datos', _enviarDatos),
            ],
          ),
        )
      ],
    );
  }
}
