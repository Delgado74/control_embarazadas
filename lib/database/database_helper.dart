import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/embarazada.dart';
import '../models/cita.dart';
import '../models/evolucion.dart';
import '../models/lactante.dart';
import '../models/evolucion_lactante.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('embarazadas.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE lactantes (
          id TEXT PRIMARY KEY,
          nombre TEXT NOT NULL,
          fechaNacimiento TEXT NOT NULL,
          nombreMadre TEXT NOT NULL,
          direccion TEXT,
          telefono TEXT,
          consultorio TEXT NOT NULL,
          medico TEXT,
          fechaRegistro TEXT NOT NULL,
          sexo TEXT,
          numeroConsultasPrenatales INTEGER,
          clasificacionRiesgoObstetrico TEXT,
          diagnosticosEmbarazo TEXT,
          egParto REAL,
          lugarParto TEXT,
          tipoParto TEXT,
          caracteristicasRn TEXT,
          pesoNacer REAL,
          tallaNacer REAL,
          ccNacer REAL,
          ctNacer REAL,
          apgar INTEGER,
          antecedentesFamiliares TEXT,
          clasificacion TEXT,
          valoracionNutricional TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE citas_lactantes (
          id TEXT PRIMARY KEY,
          idLactante TEXT NOT NULL,
          fechaHora TEXT NOT NULL,
          motivo TEXT NOT NULL,
          observaciones TEXT,
          cumplida INTEGER DEFAULT 0,
          FOREIGN KEY (idLactante) REFERENCES lactantes (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE evoluciones_lactantes (
          id TEXT PRIMARY KEY,
          idLactante TEXT NOT NULL,
          fecha TEXT NOT NULL,
          interrogatorio TEXT,
          peso TEXT,
          talla TEXT,
          cc TEXT,
          pesoEdad TEXT,
          tallaEdad TEXT,
          ccEdad TEXT,
          pesoTalla TEXT,
          frecuenciaRespiratoria TEXT,
          frecuenciaCardiaca TEXT,
          dpm TEXT,
          alimentacion TEXT,
          vacunacion TEXT,
          observaciones TEXT,
          profesional TEXT,
          FOREIGN KEY (idLactante) REFERENCES lactantes (id)
        )
      ''');
    }

    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE lactantes DROP COLUMN vaccinacion');
      } catch (_) {}
    }

    if (oldVersion < 4) {
      await db.execute('ALTER TABLE lactantes ADD COLUMN alimentacion TEXT');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE embarazadas (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        edad TEXT NOT NULL,
        cedula TEXT NOT NULL,
        telefono TEXT NOT NULL,
        direccion TEXT NOT NULL,
        fechaRegistro TEXT NOT NULL,
        fechaUltimaMenstruacion TEXT,
        fechaProbableParto TEXT,
        fechaUltrasonido TEXT,
        tiempoGestacionalSemanasUltrasonido INTEGER,
        tiempoGestacionalDiasUltrasonido INTEGER,
        antecedentesFamiliares TEXT,
        antecedentesPersonales TEXT,
        consultorio TEXT NOT NULL,
        medico TEXT,
        embarazos INTEGER,
        partos INTEGER,
        abortos INTEGER,
        escolaridad TEXT,
        estadoConyugal TEXT,
        ocupacion TEXT,
        operaciones TEXT,
        transfusiones TEXT,
        citologia TEXT,
        vacunacion TEXT,
        peso TEXT,
        talla TEXT,
        nombreEsposo TEXT,
        cedulaEsposo TEXT,
        ocupacionEsposo TEXT,
        condicionesSocioeconomicas TEXT,
        factoresAro TEXT,
        factoresBro TEXT,
        ingresada TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE citas (
        id TEXT PRIMARY KEY,
        idEmbarazada TEXT NOT NULL,
        fechaHora TEXT NOT NULL,
        motivo TEXT NOT NULL,
        observaciones TEXT,
        cumplida INTEGER DEFAULT 0,
        fechaProxima TEXT,
        FOREIGN KEY (idEmbarazada) REFERENCES embarazadas (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE evoluciones (
        id TEXT PRIMARY KEY,
        idEmbarazada TEXT NOT NULL,
        fecha TEXT NOT NULL,
        peso TEXT,
        presionArterial TEXT,
        alturaUterina TEXT,
        frecuenciaCardiacaFetal TEXT,
        movimientosFetales TEXT,
        sintomas TEXT,
        observaciones TEXT,
        proximaCita TEXT,
        profesional TEXT,
        FOREIGN KEY (idEmbarazada) REFERENCES embarazadas (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE lactantes (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        fechaNacimiento TEXT NOT NULL,
        nombreMadre TEXT NOT NULL,
        direccion TEXT,
        telefono TEXT,
        consultorio TEXT NOT NULL,
        medico TEXT,
        fechaRegistro TEXT NOT NULL,
        sexo TEXT,
        numeroConsultasPrenatales INTEGER,
        clasificacionRiesgoObstetrico TEXT,
        diagnosticosEmbarazo TEXT,
        egParto REAL,
        lugarParto TEXT,
        tipoParto TEXT,
        caracteristicasRn TEXT,
        pesoNacer REAL,
        tallaNacer REAL,
        ccNacer REAL,
        ctNacer REAL,
        apgar INTEGER,
        antecedentesFamiliares TEXT,
        clasificacion TEXT,
        valoracionNutricional TEXT,
        alimentacion TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE citas_lactantes (
        id TEXT PRIMARY KEY,
        idLactante TEXT NOT NULL,
        fechaHora TEXT NOT NULL,
        motivo TEXT NOT NULL,
        observaciones TEXT,
        cumplida INTEGER DEFAULT 0,
        FOREIGN KEY (idLactante) REFERENCES lactantes (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE evoluciones_lactantes (
        id TEXT PRIMARY KEY,
        idLactante TEXT NOT NULL,
        fecha TEXT NOT NULL,
        interrogatorio TEXT,
        peso TEXT,
        talla TEXT,
        cc TEXT,
        pesoEdad TEXT,
        tallaEdad TEXT,
        ccEdad TEXT,
        pesoTalla TEXT,
        frecuenciaRespiratoria TEXT,
        frecuenciaCardiaca TEXT,
        dpm TEXT,
        alimentacion TEXT,
        vacunacion TEXT,
        observaciones TEXT,
        profesional TEXT,
        FOREIGN KEY (idLactante) REFERENCES lactantes (id)
      )
    ''');
  }

  Future<void> _createDBJefe(Database db, int version) async {
    await db.execute('''
      CREATE TABLE consultorios (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        fechaImportacion TEXT NOT NULL,
        descripcion TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE embarazadas (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        edad TEXT NOT NULL,
        cedula TEXT NOT NULL,
        telefono TEXT NOT NULL,
        direccion TEXT NOT NULL,
        fechaRegistro TEXT NOT NULL,
        fechaUltimaMenstruacion TEXT,
        fechaProbableParto TEXT,
        fechaUltrasonido TEXT,
        tiempoGestacionalSemanasUltrasonido INTEGER,
        tiempoGestacionalDiasUltrasonido INTEGER,
        antecedentesFamiliares TEXT,
        antecedentesPersonales TEXT,
        consultorio TEXT NOT NULL,
        medico TEXT,
        idConsultorio TEXT,
        FOREIGN KEY (idConsultorio) REFERENCES consultorios (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE citas (
        id TEXT PRIMARY KEY,
        idEmbarazada TEXT NOT NULL,
        fechaHora TEXT NOT NULL,
        motivo TEXT NOT NULL,
        observaciones TEXT,
        cumplida INTEGER DEFAULT 0,
        fechaProxima TEXT,
        FOREIGN KEY (idEmbarazada) REFERENCES embarazadas (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE evoluciones (
        id TEXT PRIMARY KEY,
        idEmbarazada TEXT NOT NULL,
        fecha TEXT NOT NULL,
        peso TEXT,
        presionArterial TEXT,
        alturaUterina TEXT,
        frecuenciaCardiacaFetal TEXT,
        movimientosFetales TEXT,
        sintomas TEXT,
        observaciones TEXT,
        proximaCita TEXT,
        profesional TEXT,
        FOREIGN KEY (idEmbarazada) REFERENCES embarazadas (id)
      )
    ''');
  }

  Future<void> insertEmbarazada(Embarazada embarazada) async {
    final db = await instance.database;
    await db.insert('embarazadas', {
      'id': embarazada.id,
      'nombre': embarazada.nombre,
      'edad': embarazada.edad,
      'cedula': embarazada.cedula,
      'telefono': embarazada.telefono,
      'direccion': embarazada.direccion,
      'fechaRegistro': embarazada.fechaRegistro.toIso8601String(),
      'fechaUltimaMenstruacion': embarazada.fechaUltimaMenstruacion
          ?.toIso8601String(),
      'fechaProbableParto': embarazada.fechaProbableParto?.toIso8601String(),
      'fechaUltrasonido': embarazada.fechaUltrasonido?.toIso8601String(),
      'tiempoGestacionalSemanasUltrasonido':
          embarazada.tiempoGestacionalSemanasUltrasonido,
      'tiempoGestacionalDiasUltrasonido':
          embarazada.tiempoGestacionalDiasUltrasonido,
      'antecedentesFamiliares': embarazada.antecedentesFamiliares,
      'antecedentesPersonales': embarazada.antecedentesPersonales,
      'consultorio': embarazada.consultorio,
      'medico': embarazada.medico,
      'embarazos': embarazada.embarazos,
      'partos': embarazada.partos,
      'abortos': embarazada.abortos,
      'escolaridad': embarazada.escolaridad,
      'estadoConyugal': embarazada.estadoConyugal,
      'ocupacion': embarazada.ocupacion,
      'operaciones': embarazada.operaciones,
      'transfusiones': embarazada.transfusiones,
      'citologia': embarazada.citologia,
      'peso': embarazada.peso,
      'talla': embarazada.talla,
      'nombreEsposo': embarazada.nombreEsposo,
      'cedulaEsposo': embarazada.cedulaEsposo,
      'ocupacionEsposo': embarazada.ocupacionEsposo,
      'condicionesSocioeconomicas': embarazada.condicionesSocioeconomicas,
      'factoresAro': embarazada.factoresAro != null
          ? jsonEncode(embarazada.factoresAro)
          : null,
      'factoresBro': embarazada.factoresBro != null
          ? jsonEncode(embarazada.factoresBro)
          : null,
      'ingresada': embarazada.ingresada,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Embarazada>> getAllEmbarazadas() async {
    final db = await instance.database;
    final result = await db.query('embarazadas', orderBy: 'fechaRegistro DESC');
    return result.map((json) => Embarazada.fromJson(json)).toList();
  }

  Future<Embarazada?> getEmbarazada(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'embarazadas',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Embarazada.fromJson(result.first);
  }

  Future<List<Embarazada>> getEmbarazadasByConsultorio(
    String consultorio,
  ) async {
    final db = await instance.database;
    final result = await db.query(
      'embarazadas',
      where: 'consultorio = ?',
      whereArgs: [consultorio],
      orderBy: 'fechaRegistro DESC',
    );
    return result.map((json) => Embarazada.fromJson(json)).toList();
  }

  Future<int> updateEmbarazada(Embarazada embarazada) async {
    final db = await instance.database;
    return await db.update(
      'embarazadas',
      embarazada.toJson(),
      where: 'id = ?',
      whereArgs: [embarazada.id],
    );
  }

  Future<int> deleteEmbarazada(String id) async {
    final db = await instance.database;
    await db.delete('citas', where: 'idEmbarazada = ?', whereArgs: [id]);
    await db.delete('evoluciones', where: 'idEmbarazada = ?', whereArgs: [id]);
    return await db.delete('embarazadas', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertCita(Cita cita) async {
    final db = await instance.database;
    await db.insert(
      'citas',
      cita.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Cita>> getCitasByEmbarazada(String idEmbarazada) async {
    final db = await instance.database;
    final result = await db.query(
      'citas',
      where: 'idEmbarazada = ?',
      whereArgs: [idEmbarazada],
      orderBy: 'fechaHora DESC',
    );
    return result.map((json) => Cita.fromJson(json)).toList();
  }

  Future<List<Cita>> getAllCitas() async {
    final db = await instance.database;
    final result = await db.query('citas', orderBy: 'fechaHora DESC');
    return result.map((json) => Cita.fromJson(json)).toList();
  }

  Future<void> insertEvolucion(Evolucion evolucion) async {
    final db = await instance.database;
    await db.insert(
      'evoluciones',
      evolucion.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Evolucion>> getEvolucionesByEmbarazada(
    String idEmbarazada,
  ) async {
    final db = await instance.database;
    final result = await db.query(
      'evoluciones',
      where: 'idEmbarazada = ?',
      whereArgs: [idEmbarazada],
      orderBy: 'fecha DESC',
    );
    return result.map((json) => Evolucion.fromJson(json)).toList();
  }

  Future<List<Evolucion>> getAllEvoluciones() async {
    final db = await instance.database;
    final result = await db.query('evoluciones', orderBy: 'fecha DESC');
    return result.map((json) => Evolucion.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> exportDataToJson() async {
    final db = await instance.database;
    final embarazadas = await db.query('embarazadas');
    final citas = await db.query('citas');
    final evoluciones = await db.query('evoluciones');
    final lactantes = await db.query('lactantes');
    final citasLactantes = await db.query('citas_lactantes');
    final evolucionesLactantes = await db.query('evoluciones_lactantes');

    return {
      'version': '1.0',
      'fechaExportacion': DateTime.now().toIso8601String(),
      'embarazadas': embarazadas,
      'citas': citas,
      'evoluciones': evoluciones,
      'lactantes': lactantes,
      'citasLactantes': citasLactantes,
      'evolucionesLactantes': evolucionesLactantes,
    };
  }

  Future<String> exportDataToJsonString() async {
    final data = await exportDataToJson();
    return jsonEncode(data);
  }

  Future<File> exportDataToFile(String consultorio) async {
    final data = await exportDataToJsonString();
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    final fileName =
        'embarazadas_${consultorio.replaceAll(' ', '_')}_$timestamp.json';
    final file = File('${directory.path}/$fileName');
    return await file.writeAsString(data);
  }

  Future<int> importDataFromJson(
    Map<String, dynamic> data, {
    String? consultorioId,
  }) async {
    final db = await instance.database;
    int count = 0;

    if (data['embarazadas'] != null) {
      for (var emp in data['embarazadas']) {
        emp['consultorio'] = consultorioId ?? emp['consultorio'] ?? 'importado';
        await db.insert(
          'embarazadas',
          Map<String, dynamic>.from(emp),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        count++;
      }
    }

    if (data['citas'] != null) {
      for (var cita in data['citas']) {
        await db.insert(
          'citas',
          Map<String, dynamic>.from(cita),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    if (data['evoluciones'] != null) {
      for (var evo in data['evoluciones']) {
        await db.insert(
          'evoluciones',
          Map<String, dynamic>.from(evo),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    if (data['lactantes'] != null) {
      for (var lact in data['lactantes']) {
        lact['consultorio'] =
            consultorioId ?? lact['consultorio'] ?? 'importado';
        await db.insert(
          'lactantes',
          Map<String, dynamic>.from(lact),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        count++;
      }
    }

    if (data['citasLactantes'] != null) {
      for (var cita in data['citasLactantes']) {
        await db.insert(
          'citas_lactantes',
          Map<String, dynamic>.from(cita),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    if (data['evolucionesLactantes'] != null) {
      for (var evo in data['evolucionesLactantes']) {
        await db.insert(
          'evoluciones_lactantes',
          Map<String, dynamic>.from(evo),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    return count;
  }

  Future<int> importDataFromJsonString(
    String jsonString, {
    String? consultorioId,
  }) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return await importDataFromJson(data, consultorioId: consultorioId);
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('evoluciones');
    await db.delete('citas');
    await db.delete('embarazadas');
    await db.delete('evoluciones_lactantes');
    await db.delete('citas_lactantes');
    await db.delete('lactantes');
  }

  Future<int> getEmbarazadasCount() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM embarazadas',
    );
    return result.first['count'] as int;
  }

  Future<int> getCitasCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM citas');
    return result.first['count'] as int;
  }

  Future<int> getEvolucionesCount() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM evoluciones',
    );
    return result.first['count'] as int;
  }

  Future<void> insertLactante(Lactante lactante) async {
    final db = await instance.database;
    await db.insert(
      'lactantes',
      lactante.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Lactante>> getAllLactantes() async {
    final db = await instance.database;
    final result = await db.query('lactantes', orderBy: 'fechaRegistro DESC');
    return result.map((json) => Lactante.fromJson(json)).toList();
  }

  Future<Lactante?> getLactante(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'lactantes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Lactante.fromJson(result.first);
  }

  Future<List<Lactante>> getLactantesByConsultorio(String consultorio) async {
    final db = await instance.database;
    final result = await db.query(
      'lactantes',
      where: 'consultorio = ?',
      whereArgs: [consultorio],
      orderBy: 'fechaRegistro DESC',
    );
    return result.map((json) => Lactante.fromJson(json)).toList();
  }

  Future<int> updateLactante(Lactante lactante) async {
    final db = await instance.database;
    return await db.update(
      'lactantes',
      lactante.toJson(),
      where: 'id = ?',
      whereArgs: [lactante.id],
    );
  }

  Future<int> deleteLactante(String id) async {
    final db = await instance.database;
    await db.delete(
      'citas_lactantes',
      where: 'idLactante = ?',
      whereArgs: [id],
    );
    await db.delete(
      'evoluciones_lactantes',
      where: 'idLactante = ?',
      whereArgs: [id],
    );
    return await db.delete('lactantes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertCitaLactante(Cita cita) async {
    final db = await instance.database;
    await db.insert('citas_lactantes', {
      'id': cita.id,
      'idLactante': cita.idEmbarazada,
      'fechaHora': cita.fechaHora.toIso8601String(),
      'motivo': cita.motivo,
      'observaciones': cita.observaciones,
      'cumplida': cita.cumplida ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Cita>> getCitasByLactante(String idLactante) async {
    final db = await instance.database;
    final result = await db.query(
      'citas_lactantes',
      where: 'idLactante = ?',
      whereArgs: [idLactante],
      orderBy: 'fechaHora DESC',
    );
    return result
        .map(
          (json) => Cita(
            id: json['id'] as String,
            idEmbarazada: json['idLactante'] as String,
            fechaHora: DateTime.parse(json['fechaHora'] as String),
            motivo: json['motivo'] as String,
            observaciones: json['observaciones'] as String?,
            cumplida: (json['cumplida'] as int) == 1,
          ),
        )
        .toList();
  }

  Future<void> insertEvolucionLactante(EvolucionLactante evolucion) async {
    final db = await instance.database;
    await db.insert(
      'evoluciones_lactantes',
      evolucion.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<EvolucionLactante>> getEvolucionesByLactante(
    String idLactante,
  ) async {
    final db = await instance.database;
    final result = await db.query(
      'evoluciones_lactantes',
      where: 'idLactante = ?',
      whereArgs: [idLactante],
      orderBy: 'fecha DESC',
    );
    return result.map((json) => EvolucionLactante.fromJson(json)).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}

class DatabaseHelperJefe {
  static final DatabaseHelperJefe instance = DatabaseHelperJefe._init();
  static Database? _database;

  DatabaseHelperJefe._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('jefe_grupo.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE consultorios (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        fechaImportacion TEXT NOT NULL,
        descripcion TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE embarazadas (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        edad TEXT NOT NULL,
        cedula TEXT NOT NULL,
        telefono TEXT NOT NULL,
        direccion TEXT NOT NULL,
        fechaRegistro TEXT NOT NULL,
        fechaUltimaMenstruacion TEXT,
        fechaProbableParto TEXT,
        antecedentesFamiliares TEXT,
        antecedentesPersonales TEXT,
        consultorio TEXT NOT NULL,
        medico TEXT,
        idConsultorio TEXT,
        FOREIGN KEY (idConsultorio) REFERENCES consultorios (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE citas (
        id TEXT PRIMARY KEY,
        idEmbarazada TEXT NOT NULL,
        fechaHora TEXT NOT NULL,
        motivo TEXT NOT NULL,
        observaciones TEXT,
        cumplida INTEGER DEFAULT 0,
        fechaProxima TEXT,
        FOREIGN KEY (idEmbarazada) REFERENCES embarazadas (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE evoluciones (
        id TEXT PRIMARY KEY,
        idEmbarazada TEXT NOT NULL,
        fecha TEXT NOT NULL,
        peso TEXT,
        presionArterial TEXT,
        alturaUterina TEXT,
        frecuenciaCardiacaFetal TEXT,
        movimientosFetales TEXT,
        sintomas TEXT,
        observaciones TEXT,
        proximaCita TEXT,
        profesional TEXT,
        FOREIGN KEY (idEmbarazada) REFERENCES embarazadas (id)
      )
    ''');
  }

  Future<void> insertConsultorio(
    String id,
    String nombre,
    String? descripcion,
  ) async {
    final db = await instance.database;
    await db.insert('consultorios', {
      'id': id,
      'nombre': nombre,
      'fechaImportacion': DateTime.now().toIso8601String(),
      'descripcion': descripcion,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllConsultorios() async {
    final db = await instance.database;
    return await db.query('consultorios', orderBy: 'fechaImportacion DESC');
  }

  Future<int> importDataFromJson(
    Map<String, dynamic> data,
    String consultorioId,
    String nombreConsultorio,
  ) async {
    final db = await instance.database;
    int count = 0;

    await insertConsultorio(
      consultorioId,
      nombreConsultorio,
      'Importado el ${DateTime.now()}',
    );

    if (data['embarazadas'] != null) {
      for (var emp in data['embarazadas']) {
        emp['consultorio'] = nombreConsultorio;
        emp['idConsultorio'] = consultorioId;
        await db.insert(
          'embarazadas',
          Map<String, dynamic>.from(emp),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        count++;
      }
    }

    if (data['citas'] != null) {
      for (var cita in data['citas']) {
        await db.insert(
          'citas',
          Map<String, dynamic>.from(cita),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    if (data['evoluciones'] != null) {
      for (var evo in data['evoluciones']) {
        await db.insert(
          'evoluciones',
          Map<String, dynamic>.from(evo),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    return count;
  }

  Future<List<Embarazada>> getEmbarazadasByConsultorio(
    String consultorioId,
  ) async {
    final db = await instance.database;
    final result = await db.query(
      'embarazadas',
      where: 'idConsultorio = ?',
      whereArgs: [consultorioId],
      orderBy: 'fechaRegistro DESC',
    );
    return result.map((json) => Embarazada.fromJson(json)).toList();
  }

  Future<List<Embarazada>> getAllEmbarazadas() async {
    final db = await instance.database;
    final result = await db.query('embarazadas', orderBy: 'fechaRegistro DESC');
    return result.map((json) => Embarazada.fromJson(json)).toList();
  }

  Future<List<Cita>> getCitasByEmbarazada(String idEmbarazada) async {
    final db = await instance.database;
    final result = await db.query(
      'citas',
      where: 'idEmbarazada = ?',
      whereArgs: [idEmbarazada],
      orderBy: 'fechaHora DESC',
    );
    return result.map((json) => Cita.fromJson(json)).toList();
  }

  Future<List<Evolucion>> getEvolucionesByEmbarazada(
    String idEmbarazada,
  ) async {
    final db = await instance.database;
    final result = await db.query(
      'evoluciones',
      where: 'idEmbarazada = ?',
      whereArgs: [idEmbarazada],
      orderBy: 'fecha DESC',
    );
    return result.map((json) => Evolucion.fromJson(json)).toList();
  }

  Future<Map<String, int>> getConsultorioStats(String consultorioId) async {
    final db = await instance.database;
    final embarazadas = await db.rawQuery(
      'SELECT COUNT(*) as count FROM embarazadas WHERE idConsultorio = ?',
      [consultorioId],
    );
    final citas = await db.rawQuery(
      'SELECT COUNT(*) as count FROM citas WHERE idEmbarazada IN (SELECT id FROM embarazadas WHERE idConsultorio = ?)',
      [consultorioId],
    );
    final evoluciones = await db.rawQuery(
      'SELECT COUNT(*) as count FROM evoluciones WHERE idEmbarazada IN (SELECT id FROM embarazadas WHERE idConsultorio = ?)',
      [consultorioId],
    );

    return {
      'embarazadas': embarazadas.first['count'] as int,
      'citas': citas.first['count'] as int,
      'evoluciones': evoluciones.first['count'] as int,
    };
  }

  Future<int> getTotalEmbarazadas() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM embarazadas',
    );
    return result.first['count'] as int;
  }

  Future<int> getTotalConsultorios() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM consultorios',
    );
    return result.first['count'] as int;
  }

  Future<void> deleteConsultorio(String consultorioId) async {
    final db = await instance.database;
    final embarazadas = await db.query(
      'embarazadas',
      columns: ['id'],
      where: 'idConsultorio = ?',
      whereArgs: [consultorioId],
    );

    for (var emp in embarazadas) {
      await db.delete(
        'citas',
        where: 'idEmbarazada = ?',
        whereArgs: [emp['id']],
      );
      await db.delete(
        'evoluciones',
        where: 'idEmbarazada = ?',
        whereArgs: [emp['id']],
      );
    }

    await db.delete(
      'embarazadas',
      where: 'idConsultorio = ?',
      whereArgs: [consultorioId],
    );
    await db.delete(
      'consultorios',
      where: 'id = ?',
      whereArgs: [consultorioId],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
