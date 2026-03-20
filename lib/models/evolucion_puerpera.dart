class EvolucionPuerpera {
  final String id;
  final String idPuerpera;
  final DateTime fecha;
  final String? peso;
  final String? presionArterial;
  final String? temperatura;
  final String? frecuenciaCardiaca;
  final String? frecuenciaRespiratoria;
  final String? alturaUterina;
  final String? loquios;
  final String? mamas;
  final String? perine;
  final String? estadoPsiquico;
  final String? sintomas;
  final String? observaciones;
  final String? proximaCita;
  final String? profesional;

  EvolucionPuerpera({
    required this.id,
    required this.idPuerpera,
    required this.fecha,
    this.peso,
    this.presionArterial,
    this.temperatura,
    this.frecuenciaCardiaca,
    this.frecuenciaRespiratoria,
    this.alturaUterina,
    this.loquios,
    this.mamas,
    this.perine,
    this.estadoPsiquico,
    this.sintomas,
    this.observaciones,
    this.proximaCita,
    this.profesional,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPuerpera': idPuerpera,
      'fecha': fecha.toIso8601String(),
      'peso': peso,
      'presionArterial': presionArterial,
      'temperatura': temperatura,
      'frecuenciaCardiaca': frecuenciaCardiaca,
      'frecuenciaRespiratoria': frecuenciaRespiratoria,
      'alturaUterina': alturaUterina,
      'loquios': loquios,
      'mamas': mamas,
      'perine': perine,
      'estadoPsiquico': estadoPsiquico,
      'sintomas': sintomas,
      'observaciones': observaciones,
      'proximaCita': proximaCita,
      'profesional': profesional,
    };
  }

  factory EvolucionPuerpera.fromJson(Map<String, dynamic> json) {
    return EvolucionPuerpera(
      id: json['id'] as String,
      idPuerpera: json['idPuerpera'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      peso: json['peso'] as String?,
      presionArterial: json['presionArterial'] as String?,
      temperatura: json['temperatura'] as String?,
      frecuenciaCardiaca: json['frecuenciaCardiaca'] as String?,
      frecuenciaRespiratoria: json['frecuenciaRespiratoria'] as String?,
      alturaUterina: json['alturaUterina'] as String?,
      loquios: json['loquios'] as String?,
      mamas: json['mamas'] as String?,
      perine: json['perine'] as String?,
      estadoPsiquico: json['estadoPsiquico'] as String?,
      sintomas: json['sintomas'] as String?,
      observaciones: json['observaciones'] as String?,
      proximaCita: json['proximaCita'] as String?,
      profesional: json['profesional'] as String?,
    );
  }

  EvolucionPuerpera copyWith({
    String? id,
    String? idPuerpera,
    DateTime? fecha,
    String? peso,
    String? presionArterial,
    String? temperatura,
    String? frecuenciaCardiaca,
    String? frecuenciaRespiratoria,
    String? alturaUterina,
    String? loquios,
    String? mamas,
    String? perine,
    String? estadoPsiquico,
    String? sintomas,
    String? observaciones,
    String? proximaCita,
    String? profesional,
  }) {
    return EvolucionPuerpera(
      id: id ?? this.id,
      idPuerpera: idPuerpera ?? this.idPuerpera,
      fecha: fecha ?? this.fecha,
      peso: peso ?? this.peso,
      presionArterial: presionArterial ?? this.presionArterial,
      temperatura: temperatura ?? this.temperatura,
      frecuenciaCardiaca: frecuenciaCardiaca ?? this.frecuenciaCardiaca,
      frecuenciaRespiratoria:
          frecuenciaRespiratoria ?? this.frecuenciaRespiratoria,
      alturaUterina: alturaUterina ?? this.alturaUterina,
      loquios: loquios ?? this.loquios,
      mamas: mamas ?? this.mamas,
      perine: perine ?? this.perine,
      estadoPsiquico: estadoPsiquico ?? this.estadoPsiquico,
      sintomas: sintomas ?? this.sintomas,
      observaciones: observaciones ?? this.observaciones,
      proximaCita: proximaCita ?? this.proximaCita,
      profesional: profesional ?? this.profesional,
    );
  }
}
