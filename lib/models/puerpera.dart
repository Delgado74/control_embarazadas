class Puerpera {
  final String id;
  final String idEmbarazada;
  final String nombre;
  final String edad;
  final String cedula;
  final String telefono;
  final String direccion;
  final DateTime fechaRegistro;
  final DateTime fechaParto;
  final String tipoParto;
  final String? observaciones;
  final String consultorio;
  final String? medico;
  final String? escuela;
  final String? estadoConyugal;
  final String? ocupacion;
  final String? antecedentesFamiliares;
  final String? antecedentesPersonales;
  final String? intervenciones;
  final String? transfusiones;
  final String? citologia;
  final String? weighing;
  final String? height;
  final String? nombreEsposo;
  final String? cedulaEsposo;
  final String? ocupacionEsposo;
  final String? condicionesSocioeconomicas;
  final String? ingresoHospitalario;
  final bool activa;

  static const List<String> tipoPartoOptions = [
    'EUTOCICO',
    'DISTOCICO',
    'CESAREA',
    'ABORTO',
  ];

  Puerpera({
    required this.id,
    required this.idEmbarazada,
    required this.nombre,
    required this.edad,
    required this.cedula,
    required this.telefono,
    required this.direccion,
    required this.fechaRegistro,
    required this.fechaParto,
    required this.tipoParto,
    this.observaciones,
    required this.consultorio,
    this.medico,
    this.escuela,
    this.estadoConyugal,
    this.ocupacion,
    this.antecedentesFamiliares,
    this.antecedentesPersonales,
    this.intervenciones,
    this.transfusiones,
    this.citologia,
    this.weighing,
    this.height,
    this.nombreEsposo,
    this.cedulaEsposo,
    this.ocupacionEsposo,
    this.condicionesSocioeconomicas,
    this.ingresoHospitalario,
    this.activa = true,
  });

  int get diasPostParto => DateTime.now().difference(fechaParto).inDays;

  bool get periodoPuerperioCompletado => diasPostParto > 42;

  int get diasRestantes {
    final restantes = 42 - diasPostParto;
    return restantes > 0 ? restantes : 0;
  }

  String get estadoPuerperio {
    if (diasPostParto <= 7) return 'PUERPERIO INMEDIATO';
    if (diasPostParto <= 28) return 'PUERPERIO TARDIO';
    return 'PUERPERIO EXTENDIDO';
  }

  double? get imc {
    if (weighing == null || height == null) return null;
    final pesoNum = double.tryParse(weighing!.replaceAll(',', '.'));
    final tallaNum = double.tryParse(height!.replaceAll(',', '.'));
    if (pesoNum == null || tallaNum == null || tallaNum <= 0) return null;
    return pesoNum / (tallaNum * tallaNum);
  }

  String? get imcString {
    final imcVal = imc;
    if (imcVal == null) return null;
    return imcVal.toStringAsFixed(1);
  }

  String? get clasificacionImc {
    final imcVal = imc;
    if (imcVal == null) return null;
    if (imcVal < 18.5) return 'Bajo peso';
    if (imcVal < 25) return 'Normal';
    if (imcVal < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idEmbarazada': idEmbarazada,
      'nombre': nombre,
      'edad': edad,
      'cedula': cedula,
      'telefono': telefono,
      'direccion': direccion,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'fechaParto': fechaParto.toIso8601String(),
      'tipoParto': tipoParto,
      'observaciones': observaciones,
      'consultorio': consultorio,
      'medico': medico,
      'escuela': escuela,
      'estadoConyugal': estadoConyugal,
      'ocupacion': ocupacion,
      'antecedentesFamiliares': antecedentesFamiliares,
      'antecedentesPersonales': antecedentesPersonales,
      'intervenciones': intervenciones,
      'transfusiones': transfusiones,
      'citologia': citologia,
      'weighing': weighing,
      'height': height,
      'nombreEsposo': nombreEsposo,
      'cedulaEsposo': cedulaEsposo,
      'ocupacionEsposo': ocupacionEsposo,
      'condicionesSocioeconomicas': condicionesSocioeconomicas,
      'ingresoHospitalario': ingresoHospitalario,
      'activa': activa ? 1 : 0,
    };
  }

  factory Puerpera.fromJson(Map<String, dynamic> json) {
    return Puerpera(
      id: json['id'] as String,
      idEmbarazada: json['idEmbarazada'] as String,
      nombre: json['nombre'] as String,
      edad: json['edad'] as String,
      cedula: json['cedula'] as String,
      telefono: json['telefono'] as String,
      direccion: json['direccion'] as String,
      fechaRegistro: DateTime.parse(json['fechaRegistro'] as String),
      fechaParto: DateTime.parse(json['fechaParto'] as String),
      tipoParto: json['tipoParto'] as String,
      observaciones: json['observaciones'] as String?,
      consultorio: json['consultorio'] as String,
      medico: json['medico'] as String?,
      escuela: json['escuela'] as String?,
      estadoConyugal: json['estadoConyugal'] as String?,
      ocupacion: json['ocupacion'] as String?,
      antecedentesFamiliares: json['antecedentesFamiliares'] as String?,
      antecedentesPersonales: json['antecedentesPersonales'] as String?,
      intervenciones: json['intervenciones'] as String?,
      transfusiones: json['transfusiones'] as String?,
      citologia: json['citologia'] as String?,
      weighing: json['weighing'] as String?,
      height: json['height'] as String?,
      nombreEsposo: json['nombreEsposo'] as String?,
      cedulaEsposo: json['cedulaEsposo'] as String?,
      ocupacionEsposo: json['ocupacionEsposo'] as String?,
      condicionesSocioeconomicas: json['condicionesSocioeconomicas'] as String?,
      ingresoHospitalario: json['ingresoHospitalario'] as String?,
      activa: json['activa'] == 1 || json['activa'] == true,
    );
  }

  Puerpera copyWith({
    String? id,
    String? idEmbarazada,
    String? nombre,
    String? edad,
    String? cedula,
    String? telefono,
    String? direccion,
    DateTime? fechaRegistro,
    DateTime? fechaParto,
    String? tipoParto,
    String? observaciones,
    String? consultorio,
    String? medico,
    String? escuela,
    String? estadoConyugal,
    String? ocupacion,
    String? antecedentesFamiliares,
    String? antecedentesPersonales,
    String? intervenciones,
    String? transfusiones,
    String? citologia,
    String? weighing,
    String? height,
    String? nombreEsposo,
    String? cedulaEsposo,
    String? ocupacionEsposo,
    String? condicionesSocioeconomicas,
    String? ingresoHospitalario,
    bool? activa,
  }) {
    return Puerpera(
      id: id ?? this.id,
      idEmbarazada: idEmbarazada ?? this.idEmbarazada,
      nombre: nombre ?? this.nombre,
      edad: edad ?? this.edad,
      cedula: cedula ?? this.cedula,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      fechaParto: fechaParto ?? this.fechaParto,
      tipoParto: tipoParto ?? this.tipoParto,
      observaciones: observaciones ?? this.observaciones,
      consultorio: consultorio ?? this.consultorio,
      medico: medico ?? this.medico,
      escuela: escuela ?? this.escuela,
      estadoConyugal: estadoConyugal ?? this.estadoConyugal,
      ocupacion: ocupacion ?? this.ocupacion,
      antecedentesFamiliares:
          antecedentesFamiliares ?? this.antecedentesFamiliares,
      antecedentesPersonales:
          antecedentesPersonales ?? this.antecedentesPersonales,
      intervenciones: intervenciones ?? this.intervenciones,
      transfusiones: transfusiones ?? this.transfusiones,
      citologia: citologia ?? this.citologia,
      weighing: weighing ?? this.weighing,
      height: height ?? this.height,
      nombreEsposo: nombreEsposo ?? this.nombreEsposo,
      cedulaEsposo: cedulaEsposo ?? this.cedulaEsposo,
      ocupacionEsposo: ocupacionEsposo ?? this.ocupacionEsposo,
      condicionesSocioeconomicas:
          condicionesSocioeconomicas ?? this.condicionesSocioeconomicas,
      ingresoHospitalario: ingresoHospitalario ?? this.ingresoHospitalario,
      activa: activa ?? this.activa,
    );
  }
}
