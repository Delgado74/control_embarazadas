class Cita {
  final String id;
  final String idEmbarazada;
  final DateTime fechaHora;
  final String motivo;
  final String? observaciones;
  final bool cumplida;
  final DateTime? fechaProxima;

  Cita({
    required this.id,
    required this.idEmbarazada,
    required this.fechaHora,
    required this.motivo,
    this.observaciones,
    this.cumplida = false,
    this.fechaProxima,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idEmbarazada': idEmbarazada,
      'fechaHora': fechaHora.toIso8601String(),
      'motivo': motivo,
      'observaciones': observaciones,
      'cumplida': cumplida ? 1 : 0,
      'fechaProxima': fechaProxima?.toIso8601String(),
    };
  }

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'] as String,
      idEmbarazada: json['idEmbarazada'] as String,
      fechaHora: DateTime.parse(json['fechaHora'] as String),
      motivo: json['motivo'] as String,
      observaciones: json['observaciones'] as String?,
      cumplida: json['cumplida'] == 1 || json['cumplida'] == true,
      fechaProxima: json['fechaProxima'] != null
          ? DateTime.parse(json['fechaProxima'] as String)
          : null,
    );
  }

  Cita copyWith({
    String? id,
    String? idEmbarazada,
    DateTime? fechaHora,
    String? motivo,
    String? observaciones,
    bool? cumplida,
    DateTime? fechaProxima,
  }) {
    return Cita(
      id: id ?? this.id,
      idEmbarazada: idEmbarazada ?? this.idEmbarazada,
      fechaHora: fechaHora ?? this.fechaHora,
      motivo: motivo ?? this.motivo,
      observaciones: observaciones ?? this.observaciones,
      cumplida: cumplida ?? this.cumplida,
      fechaProxima: fechaProxima ?? this.fechaProxima,
    );
  }
}
