class Llegada {
  int id, registrado, respuestasCorrectas;
  String numCorredor, tiempoLlegada;

  Llegada(
      {this.id,
      this.numCorredor,
      this.tiempoLlegada,
      this.respuestasCorrectas,
      this.registrado});

  Map<String, dynamic> toMap() => {
        "id": id,
        "numCorredor": numCorredor,
        "tiempoLlegada": tiempoLlegada,
        "respuestasCorrectas": respuestasCorrectas,
        "registrado": registrado
      };

  factory Llegada.fromMap(Map<String, dynamic> json) => new Llegada(
      id: json["id"],
      numCorredor: json["numCorredor"],
      tiempoLlegada: json["tiempoLlegada"],
      respuestasCorrectas: json["respuestasCorrectas"],
      registrado: json["registrado"]);

  Map<String, dynamic> toJson() => {
        "numCorredor": numCorredor,
        "tiempoLlegada": tiempoLlegada,
        "respuestasCorrectas": respuestasCorrectas
      };
}
