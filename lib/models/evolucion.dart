class Evolucion {
  final String id;
  final String idEmbarazada;
  final DateTime fecha;
  final String? peso;
  final String? presionArterial;
  final String? alturaUterina;
  final String? frecuenciaCardiacaFetal;
  final String? movimientosFetales;
  final String? sintomas;
  final String? observaciones;
  final String? proximaCita;
  final String? profesional;

  Evolucion({
    required this.id,
    required this.idEmbarazada,
    required this.fecha,
    this.peso,
    this.presionArterial,
    this.alturaUterina,
    this.frecuenciaCardiacaFetal,
    this.movimientosFetales,
    this.sintomas,
    this.observaciones,
    this.proximaCita,
    this.profesional,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idEmbarazada': idEmbarazada,
      'fecha': fecha.toIso8601String(),
      'peso': peso,
      'presionArterial': presionArterial,
      'alturaUterina': alturaUterina,
      'frecuenciaCardiacaFetal': frecuenciaCardiacaFetal,
      'movimientosFetales': movimientosFetales,
      'sintomas': sintomas,
      'observaciones': observaciones,
      'proximaCita': proximaCita,
      'profesional': profesional,
    };
  }

  factory Evolucion.fromJson(Map<String, dynamic> json) {
    return Evolucion(
      id: json['id'] as String,
      idEmbarazada: json['idEmbarazada'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      peso: json['peso'] as String?,
      presionArterial: json['presionArterial'] as String?,
      alturaUterina: json['alturaUterina'] as String?,
      frecuenciaCardiacaFetal: json['frecuenciaCardiacaFetal'] as String?,
      movimientosFetales: json['movimientosFetales'] as String?,
      sintomas: json['sintomas'] as String?,
      observaciones: json['observaciones'] as String?,
      proximaCita: json['proximaCita'] as String?,
      profesional: json['profesional'] as String?,
    );
  }

  Evolucion copyWith({
    String? id,
    String? idEmbarazada,
    DateTime? fecha,
    String? peso,
    String? presionArterial,
    String? alturaUterina,
    String? frecuenciaCardiacaFetal,
    String? movimientosFetales,
    String? sintomas,
    String? observaciones,
    String? proximaCita,
    String? profesional,
  }) {
    return Evolucion(
      id: id ?? this.id,
      idEmbarazada: idEmbarazada ?? this.idEmbarazada,
      fecha: fecha ?? this.fecha,
      peso: peso ?? this.peso,
      presionArterial: presionArterial ?? this.presionArterial,
      alturaUterina: alturaUterina ?? this.alturaUterina,
      frecuenciaCardiacaFetal:
          frecuenciaCardiacaFetal ?? this.frecuenciaCardiacaFetal,
      movimientosFetales: movimientosFetales ?? this.movimientosFetales,
      sintomas: sintomas ?? this.sintomas,
      observaciones: observaciones ?? this.observaciones,
      proximaCita: proximaCita ?? this.proximaCita,
      profesional: profesional ?? this.profesional,
    );
  }
}
