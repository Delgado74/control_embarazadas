class EvolucionLactante {
  final String id;
  final String idLactante;
  final DateTime fecha;
  final String? interrogatorio;
  final String? peso;
  final String? talla;
  final String? cc;
  final String? pesoEdad;
  final String? tallaEdad;
  final String? ccEdad;
  final String? pesoTalla;
  final String? frecuenciaRespiratoria;
  final String? frecuenciaCardiaca;
  final String? dpm;
  final String? observaciones;
  final String? profesional;

  EvolucionLactante({
    required this.id,
    required this.idLactante,
    required this.fecha,
    this.interrogatorio,
    this.peso,
    this.talla,
    this.cc,
    this.pesoEdad,
    this.tallaEdad,
    this.ccEdad,
    this.pesoTalla,
    this.frecuenciaRespiratoria,
    this.frecuenciaCardiaca,
    this.dpm,
    this.observaciones,
    this.profesional,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idLactante': idLactante,
      'fecha': fecha.toIso8601String(),
      'interrogatorio': interrogatorio,
      'peso': peso,
      'talla': talla,
      'cc': cc,
      'pesoEdad': pesoEdad,
      'tallaEdad': tallaEdad,
      'ccEdad': ccEdad,
      'pesoTalla': pesoTalla,
      'frecuenciaRespiratoria': frecuenciaRespiratoria,
      'frecuenciaCardiaca': frecuenciaCardiaca,
      'dpm': dpm,
      'observaciones': observaciones,
      'profesional': profesional,
    };
  }

  factory EvolucionLactante.fromJson(Map<String, dynamic> json) {
    return EvolucionLactante(
      id: json['id'] as String,
      idLactante: json['idLactante'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      interrogatorio: json['interrogatorio'] as String?,
      peso: json['peso'] as String?,
      talla: json['talla'] as String?,
      cc: json['cc'] as String?,
      pesoEdad: json['pesoEdad'] as String?,
      tallaEdad: json['tallaEdad'] as String?,
      ccEdad: json['ccEdad'] as String?,
      pesoTalla: json['pesoTalla'] as String?,
      frecuenciaRespiratoria: json['frecuenciaRespiratoria'] as String?,
      frecuenciaCardiaca: json['frecuenciaCardiaca'] as String?,
      dpm: json['dpm'] as String?,
      observaciones: json['observaciones'] as String?,
      profesional: json['profesional'] as String?,
    );
  }

  EvolucionLactante copyWith({
    String? id,
    String? idLactante,
    DateTime? fecha,
    String? interrogatorio,
    String? peso,
    String? talla,
    String? cc,
    String? pesoEdad,
    String? tallaEdad,
    String? ccEdad,
    String? pesoTalla,
    String? frecuenciaRespiratoria,
    String? frecuenciaCardiaca,
    String? dpm,
    String? observaciones,
    String? profesional,
  }) {
    return EvolucionLactante(
      id: id ?? this.id,
      idLactante: idLactante ?? this.idLactante,
      fecha: fecha ?? this.fecha,
      interrogatorio: interrogatorio ?? this.interrogatorio,
      peso: peso ?? this.peso,
      talla: talla ?? this.talla,
      cc: cc ?? this.cc,
      pesoEdad: pesoEdad ?? this.pesoEdad,
      tallaEdad: tallaEdad ?? this.tallaEdad,
      ccEdad: ccEdad ?? this.ccEdad,
      pesoTalla: pesoTalla ?? this.pesoTalla,
      frecuenciaRespiratoria:
          frecuenciaRespiratoria ?? this.frecuenciaRespiratoria,
      frecuenciaCardiaca: frecuenciaCardiaca ?? this.frecuenciaCardiaca,
      dpm: dpm ?? this.dpm,
      observaciones: observaciones ?? this.observaciones,
      profesional: profesional ?? this.profesional,
    );
  }
}
