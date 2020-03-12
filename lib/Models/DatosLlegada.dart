class DatosLlegada {
  int id, numEquipo, tiempoLlegada, registrado;

  DatosLlegada({this.id, this.numEquipo, this.tiempoLlegada, this.registrado});

  Map<String, dynamic> toMap() => {
        "id": id,
        "numEquipo": numEquipo,
        "tiempoLlegada": tiempoLlegada,
        "registrado": registrado
      };

  factory DatosLlegada.fromMap(Map<String, dynamic> json) => new DatosLlegada(
      id: json["id"],
      numEquipo: json["numEquipo"],
      tiempoLlegada: json["tiempoLlegada"],
      registrado: json["registrado"]);

  Map<String, dynamic> toJson() => {
        "numEquipo": numEquipo,
        "tiempoLlegada": tiempoLlegada,
      };
}
