class LlegadaMaraton {
  int id, registrado;
  String idPunto, idUser, numCorredor, tiempoLlegada;

  LlegadaMaraton(
      {this.id,
      this.idPunto,
      this.idUser,
      this.numCorredor,
      this.tiempoLlegada,
      this.registrado});

  Map<String, dynamic> toMap() => {
        "id": id,
        "idPunto": idPunto,
        "idUser": idUser,
        "numCorredor": numCorredor,
        "tiempoLlegada": tiempoLlegada,
        "registrado": registrado
      };

  factory LlegadaMaraton.fromMap(Map<String, dynamic> json) =>
      new LlegadaMaraton(
          id: json["id"],
          idPunto: json["idPunto"],
          idUser: json["idUser"],
          numCorredor: json["numCorredor"],
          tiempoLlegada: json["tiempoLlegada"],
          registrado: json["registrado"]);

  Map<String, dynamic> toJson() => {
        "idPunto": idPunto,
        "idUser": idUser,
        "numCorredor": numCorredor,
        "tiempoLlegada": tiempoLlegada,
      };
}
