import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/embarazada.dart';
import 'gestantes_screen.dart';
import 'lactantes_screen.dart';
import 'export_import_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _nombreConsultorio = '';
  String _nombreMedico = '';
  bool _configurado = false;
  List<Embarazada> _embarazadas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final prefs = await DatabaseHelper.instance.database;
    final result = await prefs.query(
      'sqlite_master',
      where: 'type=? AND name=?',
      whereArgs: ['table', 'config'],
    );

    if (result.isEmpty) {
      await prefs.execute('''
        CREATE TABLE config (
          id INTEGER PRIMARY KEY,
          consultorio TEXT,
          medico TEXT
        )
      ''');
      await prefs.insert('config', {'id': 1, 'consultorio': '', 'medico': ''});
    }

    final config = await prefs.query('config', where: 'id = ?', whereArgs: [1]);
    if (config.isNotEmpty) {
      _nombreConsultorio = config.first['consultorio'] as String? ?? '';
      _nombreMedico = config.first['medico'] as String? ?? '';
      _configurado = _nombreConsultorio.isNotEmpty;
    }

    await _loadEmbarazadas();
    setState(() => _isLoading = false);
  }

  Future<void> _loadEmbarazadas() async {
    _embarazadas = await DatabaseHelper.instance.getAllEmbarazadas();
    if (mounted) setState(() {});
  }

  Future<void> _saveConfig() async {
    final prefs = await DatabaseHelper.instance.database;
    await prefs.update(
      'config',
      {'consultorio': _nombreConsultorio, 'medico': _nombreMedico},
      where: 'id = ?',
      whereArgs: [1],
    );
    setState(() {
      _configurado = _nombreConsultorio.isNotEmpty;
    });
  }

  void _showConfigDialog() {
    final consultorioController = TextEditingController(
      text: _nombreConsultorio,
    );
    final medicoController = TextEditingController(text: _nombreMedico);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración del Área de Atención'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: consultorioController,
              decoration: const InputDecoration(
                labelText: 'Área de Atención',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: medicoController,
              decoration: const InputDecoration(
                labelText: 'Responsable',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _nombreConsultorio = consultorioController.text.trim();
              _nombreMedico = medicoController.text.trim();
              _saveConfig();
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticaCard(
    String titulo,
    String valor,
    Color color,
    IconData icono,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icono, color: color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  Text(
                    valor,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAcercaDeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF1565C0)),
            SizedBox(width: 8),
            Text('Acerca de'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'PAMI-MF',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Programa de Atención Materno Infantil\nen Medicina Familiar',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              const Center(child: Text('Versión 1.0')),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                '¿Para qué sirve PAMI-MF?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'PAMI-MF es una herramienta integral para el control y seguimiento de:',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 8),
              _buildCaracteristica(
                Icons.pregnant_woman,
                'Embarazadas',
                'Control prenatal, clasificación de riesgo obstétrico (ARO/BRO), evoluciones, citas y estadísticas.',
              ),
              const SizedBox(height: 8),
              _buildCaracteristica(
                Icons.child_care,
                'Lactantes',
                'Seguimiento del desarrollo, alimentación (LME, mixta, complementaria), crecimiento y evaluaciones periódicas.',
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Funcionalidad Destacada',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '📤📥 Exportar/Importar Base de Datos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Esta función permite transferir todo el trabajo de un médico a otro de forma sencilla. '
                'Es ideal para:',
                textAlign: TextAlign.justify,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Traslado de pacientes entre médicos'),
                    Text('• Respaldo de información'),
                    Text('• Continuidad de la atención'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '👨‍⚕️ Jefe de Grupo Básico de Trabajo o Responsable de PAMI:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'El jefe puede importar las bases de datos de todos los consultorios o GBT de su área, '
                'teniendo así una visión integral de todo el trabajo realizado y facilitando '
                'la organización y supervisión del programa.',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'DESARROLLADOR: Dr YURI DELGADO\nISLA DE LA JUVENTUD. 2026',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCaracteristica(
    IconData icono,
    String titulo,
    String descripcion,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 24, color: const Color(0xFF1565C0)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                descripcion,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1565C0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.pregnant_woman, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  _nombreConsultorio.isEmpty ? 'PAMI-MF' : _nombreConsultorio,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  _nombreMedico.isEmpty
                      ? 'Configuración'
                      : 'Dr. $_nombreMedico',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Exportar/Importar BD'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExportImportScreen(
                    consultorio: _nombreConsultorio,
                    medico: _nombreMedico,
                  ),
                ),
              ).then((_) => _loadEmbarazadas());
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de'),
            onTap: () {
              Navigator.pop(context);
              _showAcercaDeDialog();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_configurado) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('PAMI-MF'),
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showConfigDialog,
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icon/pregnancy_10217344.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 16),
                const Text(
                  'PROGRAMA DE ATENCIÓN MATERNO INFANTIL\nEN MEDICINA FAMILIAR (PAMI-MF)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Bienvenido',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Configure su Área de Atención para comenzar',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showConfigDialog,
                  icon: const Icon(Icons.settings),
                  label: const Text('Configurar Área de Atención'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'DESARROLLADOR: Dr. YURI DELGADO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ISLA DE LA JUVENTUD 2026',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_nombreConsultorio),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showConfigDialog,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon/pregnancy_10217344.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 16),
              const Text(
                'Programa de Atención Materno Infantil\nen Medicina Familiar (PAMI-MF)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOpcionCard(
                    context,
                    'GESTANTES',
                    Icons.pregnant_woman,
                    Colors.pink,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GestantesScreen(
                            consultorio: _nombreConsultorio,
                            medico: _nombreMedico,
                          ),
                        ),
                      ).then((_) => _loadEmbarazadas());
                    },
                  ),
                  _buildOpcionCard(
                    context,
                    'LACTANTES',
                    Icons.child_care,
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LactantesScreen(
                            consultorio: _nombreConsultorio,
                            medico: _nombreMedico,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Spacer(),
              const Text(
                'DESARROLLADOR: Dr YURI DELGADO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'ISLA DE LA JUVENTUD. 2026',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpcionCard(
    BuildContext context,
    String titulo,
    IconData icono,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 160,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 64, color: color),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
