import 'dart:convert';
import 'dart:io';

import 'package:dxb_llegada/DatosLlegada.dart';
import 'package:dxb_llegada/LlegadaEdit.dart';
import 'package:dxb_llegada/UpdateLlegada.dart';
import 'package:dxb_llegada/database/db.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TiempoTranscurrido {
  final int hundreds;
  final int seconds;
  final int minutes;

  TiempoTranscurrido({
    this.hundreds,
    this.seconds,
    this.minutes,
  });
}

class Dependencies {
  //final List<ValueChanged<TiempoTranscurrido>> timerListeners =
  //<ValueChanged<TiempoTranscurrido>>[];
  final TextStyle textStyle = const TextStyle(fontSize: 90.0);
//final Stopwatch stopwatch = new Stopwatch();
//final int timerMillisecondsRefreshRate = 30;
}

class Cronometro extends StatefulWidget {
  Cronometro({Key key}) : super(key: key);

  CronometroState createState() => new CronometroState();
}

class CronometroState extends State<Cronometro> {
  final Dependencies dependencies = new Dependencies();
  int _indexGeneral = 0, _horaLargadaMilli = 0;
  DateTime _horaLargada;
  bool _largadaSetted = false;
  ScrollController _controller;

  //verificarDatosCompletos
  //Funcion dedicada a verificar, desde un snap de la base de datos, si todos los registros estan debidamente completados.
  //La verificación se realiza como chequeo antes de convertir los datos en JSON.
  //Function dedicated to verify, from a database snap, if all the registers have been completed properly.
  //This is one is called as a pre JSON parse of the data.
  //return: Future<bool>
  Future<bool> _verificarDatosCompletos() async {
    bool _completo = true;
    List<DatosLlegada> list = await LlegadaDB.db.getLlegadas();
    list.forEach((element) {
      if (element.registrado == 0) {
        _completo = false;
      }
    });
    return _completo;
  }

  //
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
        duration: Duration(milliseconds: 250), curve: Curves.easeIn);
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
  void didUpdateWidget(Cronometro oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  //Funcion que obtiene el indice actual almacenado en la base de datos
  void _obtenerIndex() async {
    List<DatosLlegada> llegadas = await LlegadaDB.db.getLlegadas();
    setState(() {
      _indexGeneral = llegadas.length;
    });
  }

  Future<String> pasarBDaJSON() async {
    String s = '[';
    List<DatosLlegada> data = await LlegadaDB.db.getLlegadas();
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
        print("Largada registrada con millis: $dif");
      } else {
        resetDB();
      }
    });
  }

  //Boton que controla Parar e Inicio
  void rightButtonPressed() {
    DatePicker.showTimePicker(context, showTitleActions: true,
        onChanged: (date) {
      print('HORA ' + date.millisecondsSinceEpoch.toString());
      //print('EPOCH '+ date.millisecondsSinceEpoch)
    }, onConfirm: (date) {
      setState(() {
        _horaLargada = date;
        _setearLargada();
      });
    }, currentTime: DateTime.now());
  }

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
  void _addLlegada(int ellapsedMilliseconds) async {
    var _llegadaARegistrar = new DatosLlegada(
        id: _indexGeneral,
        tiempoLlegada: ellapsedMilliseconds,
        numEquipo: null,
        registrado: 0);
    await LlegadaDB.db.addLlegada(_llegadaARegistrar);
    setState(() {
      _indexGeneral += 1;
    });
    print(MediaQuery.of(context).size.height);
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
    DateTime _fechaActual = DateTime.now();
    int year = _fechaActual.year,
        month = _fechaActual.month,
        day = _fechaActual.day,
        _fechaBase = DateTime.utc(year, month, day).millisecondsSinceEpoch;
    String _llegadaFormato =
        timeFormatter(_horaLargadaMilli - _fechaBase - 10800000);
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
          child: FutureBuilder<List<DatosLlegada>>(
            future: LlegadaDB.db.getLlegadas(),
            builder: (BuildContext context,
                AsyncSnapshot<List<DatosLlegada>> snapshot) {
              if (snapshot.hasData) {
                return ListView.separated(
                  physics: BouncingScrollPhysics(),
                  reverse: true,
                  controller: _controller,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    DatosLlegada item = snapshot.data[index];
                    final tiempoFormatted = timeFormatter(item.tiempoLlegada);
                    String numEquipo = item.numEquipo == null
                        ? "Falta Número de Equipo"
                        : item.numEquipo.toString();
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
                                    numEquipo: item.numEquipo,
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
                    rightButtonPressed();
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
              //buildFloatingButton('Resetear todo', resetDB),
              buildFloatingButton('Enviar datos', _enviarDatos),
            ],
          ),
        )
      ],
    );
  }
}
