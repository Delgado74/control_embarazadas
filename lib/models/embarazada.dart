import 'dart:convert';

class Embarazada {
  final String id;
  final String nombre;
  final String edad;
  final String cedula;
  final String telefono;
  final String direccion;
  final DateTime fechaRegistro;
  final DateTime? fechaUltimaMenstruacion;
  final DateTime? fechaProbableParto;
  final DateTime? fechaUltrasonido;
  final int? tiempoGestacionalSemanasUltrasonido;
  final int? tiempoGestacionalDiasUltrasonido;
  final String? antecedentesFamiliares;
  final String? antecedentesPersonales;
  final String consultorio;
  final String? medico;
  final int? embarazos;
  final int? partos;
  final int? abortos;
  final String? escolaridad;
  final String? estadoConyugal;
  final String? ocupacion;
  final String? operaciones;
  final String? transfusiones;
  final String? citologia;
  final String? peso;
  final String? talla;
  final String? nombreEsposo;
  final String? cedulaEsposo;
  final String? ocupacionEsposo;
  final String? condicionesSocioeconomicas;
  final List<String>? factoresAro;
  final List<String>? factoresBro;
  final String? ingresada;

  static const List<String> factoresAroList = [
    'EPILEPSIA',
    'ENFERMEDAD DE TIROIDES',
    'CARDIOPATIA',
    'HTA',
    'DIABETES MELLITUS',
    'NEUMOPATIAS',
    'HEPATOPATIAS',
    'SICKLEMIA',
    'ENFERMEDADES NEUROPSIQUIATRICAS',
    'ENFERMEDAD RENAL',
    'TUMOR DE OVARIO',
    'MALFORMACION UTERINA',
    'PROCESOS MALIGNOS',
    'ENFERMEDAD TROMBOEMBOLICA',
    'EMBARAZO MULTIPLE',
    'EMBARAZO POSTERMINO',
    'ENFERMEDAD HEMOLITICA PERINATAL',
    'GASTRORRAGIA',
    'ALTERACION DEL VOLUMEN DEL LIQUIDO AMNIOTICO',
    'ROTURA PREMATURA DE MEMBRANAS OVULARES',
    'INFECCION OVULAR',
    'ENTIDADES QUIRURGICAS AGUDAS',
    'PROCEDIMIENTOS INVASIVOS',
    'ANEMIA MODERADA',
    'INFECCIONES MATERNAS (HIV, HEPATITIS B/C, TOXOPLASMOSIS, PIELONEFRITIS, SIFILIS, CMV, HERPES 2, HPV)',
    'DEFICIT NUTRICIONAL < 3P',
    'OBESIDAD MORBIDA',
    'EDAD (MAYOR DE 40 ANOS / MENOR DE 16 ANOS)',
    'VARIOS FACTORES DE BRO + CONDICIONES SOCIOECONOMICAS DESFAVORABLES',
  ];

  static const List<String> factoresBroList = [
    'DEFICIT NUTRICIONAL (3 - 10 P)',
    'ANTECEDENTES DE MUERTE PERINATAL',
    'ANTECEDENTES DE PARTO PRETERMINO',
    'ANTECEDENTES DE RECIEN NACIDO BAJO PESO',
    'ANTECEDENTES DE PREECLAMPSIA O ECLAMPSIA',
    'ANTECEDENTES DE DESPRENDIMIENTO PREMATURO DE PLACENTA NORMOINSERTA',
    'ANTECEDENTES DE CESAREA U OPERACION UTERINA',
    'ANTECEDENTES DE ISOINMUNIZACION RH',
    'INCOMPETENCIA ITSMICA-CERVICAL',
    'TABAQUISMO',
    'ALCOHOLISMO',
    'CONDICIONES SOCIOECONOMICAS DESFAVORABLES',
    'ATENCION PRENATAL DEFICIENTE (MENOS DE 3 CONSULTAS PRENATALES)',
    'MULTIPARIDAD',
  ];

  Embarazada({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.cedula,
    required this.telefono,
    required this.direccion,
    required this.fechaRegistro,
    this.fechaUltimaMenstruacion,
    this.fechaProbableParto,
    this.fechaUltrasonido,
    this.tiempoGestacionalSemanasUltrasonido,
    this.tiempoGestacionalDiasUltrasonido,
    this.antecedentesFamiliares,
    this.antecedentesPersonales,
    required this.consultorio,
    this.medico,
    this.embarazos,
    this.partos,
    this.abortos,
    this.escolaridad,
    this.estadoConyugal,
    this.ocupacion,
    this.operaciones,
    this.transfusiones,
    this.citologia,
    this.peso,
    this.talla,
    this.nombreEsposo,
    this.cedulaEsposo,
    this.ocupacionEsposo,
    this.condicionesSocioeconomicas,
    this.factoresAro,
    this.factoresBro,
    this.ingresada,
  });

  double? get indiceMasaCorporal {
    if (peso == null || talla == null) return null;
    final pesoNum = double.tryParse(peso!.replaceAll(',', '.'));
    final tallaNum = double.tryParse(talla!.replaceAll(',', '.'));
    if (pesoNum == null || tallaNum == null || tallaNum <= 0) return null;
    return pesoNum / (tallaNum * tallaNum);
  }

  String? get indiceMasaCorporalString {
    final imc = indiceMasaCorporal;
    if (imc == null) return null;
    return imc.toStringAsFixed(1);
  }

  String? get clasificacionImc {
    final imc = indiceMasaCorporal;
    if (imc == null) return null;
    if (imc < 18.5) return 'Bajo peso';
    if (imc < 25) return 'Normal';
    if (imc < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  int get tiempoGestacionalSemanas {
    if (fechaUltrasonido != null &&
        tiempoGestacionalSemanasUltrasonido != null) {
      final diasTranscurridos = DateTime.now()
          .difference(fechaUltrasonido!)
          .inDays;
      final diasTotales =
          ((tiempoGestacionalSemanasUltrasonido! * 7) +
              (tiempoGestacionalDiasUltrasonido ?? 0)) +
          diasTranscurridos;
      return diasTotales ~/ 7;
    }

    final fechaBase = fechaUltimaMenstruacion;
    if (fechaBase == null) return 0;

    final diasTranscurridos = DateTime.now().difference(fechaBase).inDays;
    return diasTranscurridos ~/ 7;
  }

  double get tiempoGestacionalSemanasDecimal {
    if (fechaUltrasonido != null &&
        tiempoGestacionalSemanasUltrasonido != null) {
      final diasTranscurridos = DateTime.now()
          .difference(fechaUltrasonido!)
          .inDays;
      final diasTotales =
          ((tiempoGestacionalSemanasUltrasonido! * 7) +
              (tiempoGestacionalDiasUltrasonido ?? 0)) +
          diasTranscurridos;
      return diasTotales / 7;
    }

    final fechaBase = fechaUltimaMenstruacion;
    if (fechaBase == null) return 0;

    final diasTranscurridos = DateTime.now().difference(fechaBase).inDays;
    return diasTranscurridos / 7;
  }

  int get tiempoGestacionalDias {
    if (fechaUltrasonido != null &&
        tiempoGestacionalSemanasUltrasonido != null) {
      final diasTranscurridos = DateTime.now()
          .difference(fechaUltrasonido!)
          .inDays;
      final diasTotales =
          ((tiempoGestacionalSemanasUltrasonido! * 7) +
              (tiempoGestacionalDiasUltrasonido ?? 0)) +
          diasTranscurridos;
      final int dias = (diasTotales % 7).toInt();
      return dias;
    }

    final fechaBase = fechaUltimaMenstruacion;
    if (fechaBase == null) return 0;

    final diasTranscurridos = DateTime.now().difference(fechaBase).inDays;
    final dias = diasTranscurridos % 7;
    return dias;
  }

  DateTime? get fechaConcepcion {
    if (fechaUltimaMenstruacion != null) {
      return fechaUltimaMenstruacion!.add(const Duration(days: 14));
    }
    if (fechaUltrasonido != null &&
        tiempoGestacionalSemanasUltrasonido != null) {
      final diasGestacion =
          (tiempoGestacionalSemanasUltrasonido! * 7) +
          (tiempoGestacionalDiasUltrasonido ?? 0);
      return fechaUltrasonido!.subtract(Duration(days: diasGestacion - 14));
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'edad': edad,
      'cedula': cedula,
      'telefono': telefono,
      'direccion': direccion,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'fechaUltimaMenstruacion': fechaUltimaMenstruacion?.toIso8601String(),
      'fechaProbableParto': fechaProbableParto?.toIso8601String(),
      'fechaUltrasonido': fechaUltrasonido?.toIso8601String(),
      'tiempoGestacionalSemanasUltrasonido':
          tiempoGestacionalSemanasUltrasonido,
      'tiempoGestacionalDiasUltrasonido': tiempoGestacionalDiasUltrasonido,
      'antecedentesFamiliares': antecedentesFamiliares,
      'antecedentesPersonales': antecedentesPersonales,
      'consultorio': consultorio,
      'medico': medico,
      'embarazos': embarazos,
      'partos': partos,
      'abortos': abortos,
      'escolaridad': escolaridad,
      'estadoConyugal': estadoConyugal,
      'ocupacion': ocupacion,
      'operaciones': operaciones,
      'transfusiones': transfusiones,
      'citologia': citologia,
      'peso': peso,
      'talla': talla,
      'nombreEsposo': nombreEsposo,
      'cedulaEsposo': cedulaEsposo,
      'ocupacionEsposo': ocupacionEsposo,
      'condicionesSocioeconomicas': condicionesSocioeconomicas,
      'factoresAro': factoresAro != null ? jsonEncode(factoresAro) : null,
      'factoresBro': factoresBro != null ? jsonEncode(factoresBro) : null,
      'ingresada': ingresada,
    };
  }

  factory Embarazada.fromJson(Map<String, dynamic> json) {
    return Embarazada(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      edad: json['edad'] as String,
      cedula: json['cedula'] as String,
      telefono: json['telefono'] as String,
      direccion: json['direccion'] as String,
      fechaRegistro: DateTime.parse(json['fechaRegistro'] as String),
      fechaUltimaMenstruacion: json['fechaUltimaMenstruacion'] != null
          ? DateTime.parse(json['fechaUltimaMenstruacion'] as String)
          : null,
      fechaProbableParto: json['fechaProbableParto'] != null
          ? DateTime.parse(json['fechaProbableParto'] as String)
          : null,
      fechaUltrasonido: json['fechaUltrasonido'] != null
          ? DateTime.parse(json['fechaUltrasonido'] as String)
          : null,
      tiempoGestacionalSemanasUltrasonido:
          json['tiempoGestacionalSemanasUltrasonido'] as int?,
      tiempoGestacionalDiasUltrasonido:
          json['tiempoGestacionalDiasUltrasonido'] as int?,
      antecedentesFamiliares: json['antecedentesFamiliares'] as String?,
      antecedentesPersonales: json['antecedentesPersonales'] as String?,
      consultorio: json['consultorio'] as String,
      medico: json['medico'] as String?,
      embarazos: json['embarazos'] as int?,
      partos: json['partos'] as int?,
      abortos: json['abortos'] as int?,
      escolaridad: json['escolaridad'] as String?,
      estadoConyugal: json['estadoConyugal'] as String?,
      ocupacion: json['ocupacion'] as String?,
      operaciones: json['operaciones'] as String?,
      transfusiones: json['transfusiones'] as String?,
      citologia: json['citologia'] as String?,
      peso: json['peso'] as String?,
      talla: json['talla'] as String?,
      nombreEsposo: json['nombreEsposo'] as String?,
      cedulaEsposo: json['cedulaEsposo'] as String?,
      ocupacionEsposo: json['ocupacionEsposo'] as String?,
      condicionesSocioeconomicas: json['condicionesSocioeconomicas'] as String?,
      factoresAro: json['factoresAro'] != null
          ? List<String>.from(jsonDecode(json['factoresAro'] as String))
          : null,
      factoresBro: json['factoresBro'] != null
          ? List<String>.from(jsonDecode(json['factoresBro'] as String))
          : null,
      ingresada: json['ingresada'] as String?,
    );
  }

  Embarazada copyWith({
    String? id,
    String? nombre,
    String? edad,
    String? cedula,
    String? telefono,
    String? direccion,
    DateTime? fechaRegistro,
    DateTime? fechaUltimaMenstruacion,
    DateTime? fechaProbableParto,
    DateTime? fechaUltrasonido,
    int? tiempoGestacionalSemanasUltrasonido,
    int? tiempoGestacionalDiasUltrasonido,
    String? antecedentesFamiliares,
    String? antecedentesPersonales,
    String? consultorio,
    String? medico,
    int? embarazos,
    int? partos,
    int? abortos,
    String? escolaridad,
    String? estadoConyugal,
    String? ocupacion,
    String? operaciones,
    String? transfusiones,
    String? citologia,
    String? peso,
    String? talla,
    String? nombreEsposo,
    String? cedulaEsposo,
    String? ocupacionEsposo,
    String? condicionesSocioeconomicas,
    List<String>? factoresAro,
    List<String>? factoresBro,
    String? ingresada,
  }) {
    return Embarazada(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      edad: edad ?? this.edad,
      cedula: cedula ?? this.cedula,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      fechaUltimaMenstruacion:
          fechaUltimaMenstruacion ?? this.fechaUltimaMenstruacion,
      fechaProbableParto: fechaProbableParto ?? this.fechaProbableParto,
      fechaUltrasonido: fechaUltrasonido ?? this.fechaUltrasonido,
      tiempoGestacionalSemanasUltrasonido:
          tiempoGestacionalSemanasUltrasonido ??
          this.tiempoGestacionalSemanasUltrasonido,
      tiempoGestacionalDiasUltrasonido:
          tiempoGestacionalDiasUltrasonido ??
          this.tiempoGestacionalDiasUltrasonido,
      antecedentesFamiliares:
          antecedentesFamiliares ?? this.antecedentesFamiliares,
      antecedentesPersonales:
          antecedentesPersonales ?? this.antecedentesPersonales,
      consultorio: consultorio ?? this.consultorio,
      medico: medico ?? this.medico,
      embarazos: embarazos ?? this.embarazos,
      partos: partos ?? this.partos,
      abortos: abortos ?? this.abortos,
      escolaridad: escolaridad ?? this.escolaridad,
      estadoConyugal: estadoConyugal ?? this.estadoConyugal,
      ocupacion: ocupacion ?? this.ocupacion,
      operaciones: operaciones ?? this.operaciones,
      transfusiones: transfusiones ?? this.transfusiones,
      citologia: citologia ?? this.citologia,
      peso: peso ?? this.peso,
      talla: talla ?? this.talla,
      nombreEsposo: nombreEsposo ?? this.nombreEsposo,
      cedulaEsposo: cedulaEsposo ?? this.cedulaEsposo,
      ocupacionEsposo: ocupacionEsposo ?? this.ocupacionEsposo,
      condicionesSocioeconomicas:
          condicionesSocioeconomicas ?? this.condicionesSocioeconomicas,
      factoresAro: factoresAro ?? this.factoresAro,
      factoresBro: factoresBro ?? this.factoresBro,
      ingresada: ingresada ?? this.ingresada,
    );
  }
}
