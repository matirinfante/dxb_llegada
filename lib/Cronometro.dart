import 'dart:convert';
import 'dart:io';

import 'package:dxb_llegada/DatosLlegada.dart';
import 'package:dxb_llegada/LlegadaEdit.dart';
import 'package:dxb_llegada/UpdateLlegada.dart';
import 'package:dxb_llegada/database/db.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:quiver/async.dart';
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
  int _indexGeneral = 0, _horaLargadaMilli = 0, _currentTime = 0;
  DateTime _horaActual, _horaLargada;
  bool _largadaSetted = false;
  ScrollController _controller;

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

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    return directory.path;
  }

  Future<File> get _localFile async {
    //SimplePermissions.requestPermission(Permission.WriteExternalStorage);
    final path = await _localPath;
    return File('$path/json.txt');
  }

  Future<String> pasarBDaJSON() async {
    //final file = await _localFile;
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
    //bool _datos = await _verificarDatosCompletos();
    //if (_datos) {
    String s = await pasarBDaJSON();
    Share.text('json', s, 'application/json');
    /*} else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('No se pueden enviar datos incompletos'),
              actions: <Widget>[
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                )
              ],
            );
          });
    }*/
  }

  /*void startTimer() {
    _horaActual = DateTime.now();
    int _start = _horaLargada.difference(_horaActual).inSeconds + 1;
    print(_start);
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        _currentTime = _start - duration.elapsed.inSeconds;
        print(_currentTime);
      });
    });

    sub.onDone(() {
      dependencies.stopwatch.start();
      sub.cancel();
    });
  }*/

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
    DatePicker.showTimePicker(context, showTitleActions: true,
        onChanged: (date) {
      print('change $date in time zone ' +
          date.timeZoneOffset.inHours.toString());
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

class TimerText extends StatefulWidget {
  TimerText({this.dependencies, this.largada});

  final Dependencies dependencies;
  final int largada;

  TimerTextState createState() => new TimerTextState(
      dependencies: dependencies, milliseconds: this.largada);
}

class TimerTextState extends State<TimerText> {
  TimerTextState({this.dependencies, this.milliseconds});

  final Dependencies dependencies;

  //Timer timer;
  int milliseconds;

  @override
  Widget build(BuildContext context) {
    String minutesStr = (milliseconds % 60000).toString().padLeft(2, '0');
    String secondsStr = (milliseconds % 1000).toString().padLeft(2, '0');
    String hundredsStr = (milliseconds % 100).toString().padLeft(2, '0');
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new RepaintBoundary(
          child: new SizedBox(
              height: 100.0,
              child: Text(
                '$minutesStr:$secondsStr',
                style: TextStyle(fontSize: 90),
              )),
        ),
        new RepaintBoundary(
          child: new SizedBox(
            height: 100.0,
            child: Text('$hundredsStr', style: TextStyle(fontSize: 90)),
          ),
        ),
      ],
    );
  }
}
