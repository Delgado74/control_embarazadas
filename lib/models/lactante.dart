class Lactante {
  final String id;
  final String nombre;
  final DateTime fechaNacimiento;
  final String nombreMadre;
  final String? direccion;
  final String? telefono;
  final String consultorio;
  final String? medico;
  final DateTime fechaRegistro;
  final String? sexo;
  final int? numeroConsultasPrenatales;
  final String? clasificacionRiesgoObstetrico;
  final String? diagnosticosEmbarazo;
  final double? egParto;
  final String? lugarParto;
  final String? tipoParto;
  final String? caracteristicasRn;
  final double? pesoNacer;
  final double? tallaNacer;
  final double? ccNacer;
  final double? ctNacer;
  final String? apgar;
  final String? antecedentesFamiliares;
  final String? clasificacion;
  final String? valoracionNutricional;
  final String? alimentacion;

  Lactante({
    required this.id,
    required this.nombre,
    required this.fechaNacimiento,
    required this.nombreMadre,
    this.direccion,
    this.telefono,
    required this.consultorio,
    this.medico,
    required this.fechaRegistro,
    this.sexo,
    this.numeroConsultasPrenatales,
    this.clasificacionRiesgoObstetrico,
    this.diagnosticosEmbarazo,
    this.egParto,
    this.lugarParto,
    this.tipoParto,
    this.caracteristicasRn,
    this.pesoNacer,
    this.tallaNacer,
    this.ccNacer,
    this.ctNacer,
    this.apgar,
    this.antecedentesFamiliares,
    this.clasificacion,
    this.valoracionNutricional,
    this.alimentacion,
  });

  int get edadMeses {
    final now = DateTime.now();
    int meses =
        (now.year - fechaNacimiento.year) * 12 +
        (now.month - fechaNacimiento.month);
    if (now.day < fechaNacimiento.day) {
      meses--;
    }
    return meses;
  }

  String get edadMesesString {
    final meses = edadMeses;
    if (meses < 1) {
      final dias = DateTime.now().difference(fechaNacimiento).inDays;
      return '$dias días';
    } else if (meses == 1) {
      return '1 mes';
    } else {
      return '$meses meses';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'nombreMadre': nombreMadre,
      'direccion': direccion,
      'telefono': telefono,
      'consultorio': consultorio,
      'medico': medico,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'sexo': sexo,
      'numeroConsultasPrenatales': numeroConsultasPrenatales,
      'clasificacionRiesgoObstetrico': clasificacionRiesgoObstetrico,
      'diagnosticosEmbarazo': diagnosticosEmbarazo,
      'egParto': egParto,
      'lugarParto': lugarParto,
      'tipoParto': tipoParto,
      'caracteristicasRn': caracteristicasRn,
      'pesoNacer': pesoNacer,
      'tallaNacer': tallaNacer,
      'ccNacer': ccNacer,
      'ctNacer': ctNacer,
      'apgar': apgar,
      'antecedentesFamiliares': antecedentesFamiliares,
      'clasificacion': clasificacion,
      'valoracionNutricional': valoracionNutricional,
      'alimentacion': alimentacion,
    };
  }

  factory Lactante.fromJson(Map<String, dynamic> json) {
    return Lactante(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      fechaNacimiento: DateTime.parse(json['fechaNacimiento'] as String),
      nombreMadre: json['nombreMadre'] as String,
      direccion: json['direccion'] as String?,
      telefono: json['telefono'] as String?,
      consultorio: json['consultorio'] as String,
      medico: json['medico'] as String?,
      fechaRegistro: DateTime.parse(json['fechaRegistro'] as String),
      sexo: json['sexo'] as String?,
      numeroConsultasPrenatales: json['numeroConsultasPrenatales'] as int?,
      clasificacionRiesgoObstetrico:
          json['clasificacionRiesgoObstetrico'] as String?,
      diagnosticosEmbarazo: json['diagnosticosEmbarazo'] as String?,
      egParto: (json['egParto'] as num?)?.toDouble(),
      lugarParto: json['lugarParto'] as String?,
      tipoParto: json['tipoParto'] as String?,
      caracteristicasRn: json['caracteristicasRn'] as String?,
      pesoNacer: (json['pesoNacer'] as num?)?.toDouble(),
      tallaNacer: (json['tallaNacer'] as num?)?.toDouble(),
      ccNacer: (json['ccNacer'] as num?)?.toDouble(),
      ctNacer: (json['ctNacer'] as num?)?.toDouble(),
      apgar: json['apgar'] as String?,
      antecedentesFamiliares: json['antecedentesFamiliares'] as String?,
      clasificacion: json['clasificacion'] as String?,
      valoracionNutricional: json['valoracionNutricional'] as String?,
      alimentacion: json['alimentacion'] as String?,
    );
  }

  Lactante copyWith({
    String? id,
    String? nombre,
    DateTime? fechaNacimiento,
    String? nombreMadre,
    String? direccion,
    String? telefono,
    String? consultorio,
    String? medico,
    DateTime? fechaRegistro,
    String? sexo,
    int? numeroConsultasPrenatales,
    String? clasificacionRiesgoObstetrico,
    String? diagnosticosEmbarazo,
    double? egParto,
    String? lugarParto,
    String? tipoParto,
    String? caracteristicasRn,
    double? pesoNacer,
    double? tallaNacer,
    double? ccNacer,
    double? ctNacer,
    String? apgar,
    String? antecedentesFamiliares,
    String? clasificacion,
    String? valoracionNutricional,
    String? alimentacion,
  }) {
    return Lactante(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      nombreMadre: nombreMadre ?? this.nombreMadre,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      consultorio: consultorio ?? this.consultorio,
      medico: medico ?? this.medico,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      sexo: sexo ?? this.sexo,
      numeroConsultasPrenatales:
          numeroConsultasPrenatales ?? this.numeroConsultasPrenatales,
      clasificacionRiesgoObstetrico:
          clasificacionRiesgoObstetrico ?? this.clasificacionRiesgoObstetrico,
      diagnosticosEmbarazo: diagnosticosEmbarazo ?? this.diagnosticosEmbarazo,
      egParto: egParto ?? this.egParto,
      lugarParto: lugarParto ?? this.lugarParto,
      tipoParto: tipoParto ?? this.tipoParto,
      caracteristicasRn: caracteristicasRn ?? this.caracteristicasRn,
      pesoNacer: pesoNacer ?? this.pesoNacer,
      tallaNacer: tallaNacer ?? this.tallaNacer,
      ccNacer: ccNacer ?? this.ccNacer,
      ctNacer: ctNacer ?? this.ctNacer,
      apgar: apgar ?? this.apgar,
      antecedentesFamiliares:
          antecedentesFamiliares ?? this.antecedentesFamiliares,
      clasificacion: clasificacion ?? this.clasificacion,
      valoracionNutricional:
          valoracionNutricional ?? this.valoracionNutricional,
      alimentacion: alimentacion ?? this.alimentacion,
    );
  }
}
