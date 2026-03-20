import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/embarazada.dart';
import '../models/cita.dart';
import '../models/evolucion.dart';
import '../models/puerpera.dart';
import 'embarazada_form.dart';
import 'puerpera_form.dart';

class EmbarazadaDetailScreen extends StatefulWidget {
  final Embarazada embarazada;

  const EmbarazadaDetailScreen({super.key, required this.embarazada});

  @override
  State<EmbarazadaDetailScreen> createState() => _EmbarazadaDetailScreenState();
}

class _EmbarazadaDetailScreenState extends State<EmbarazadaDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Embarazada? _embarazada;
  List<Cita> _citas = [];
  List<Evolucion> _evoluciones = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _embarazada = widget.embarazada;
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _embarazada = await DatabaseHelper.instance.getEmbarazada(_embarazada!.id);
    _citas = await DatabaseHelper.instance.getCitasByEmbarazada(
      _embarazada!.id,
    );
    _evoluciones = await DatabaseHelper.instance.getEvolucionesByEmbarazada(
      _embarazada!.id,
    );
    if (mounted) setState(() {});
  }

  Future<void> _deleteEmbarazada() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Está seguro de eliminar esta embarazada? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await DatabaseHelper.instance.deleteEmbarazada(_embarazada!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  void _registrarParto() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PuerperaFormScreen(
          embarazada: _embarazada,
          consultorio: _embarazada!.consultorio,
          medico: _embarazada!.medico ?? '',
        ),
      ),
    ).then((result) {
      if (result == true) {
        Navigator.pop(context, true);
      }
    });
  }

  void _showAddCitaDialog() {
    final motivoController = TextEditingController();
    DateTime fechaHora = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nueva Cita'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: motivoController,
                decoration: const InputDecoration(
                  labelText: 'Motivo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha y Hora'),
                subtitle: Text(fechaHora.toString().substring(0, 16)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: fechaHora,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(fechaHora),
                      );
                      if (time != null) {
                        setDialogState(() {
                          fechaHora = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
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
              onPressed: () async {
                if (motivoController.text.trim().isEmpty) return;
                final cita = Cita(
                  id: const Uuid().v4(),
                  idEmbarazada: _embarazada!.id,
                  fechaHora: fechaHora,
                  motivo: motivoController.text.trim(),
                );
                await DatabaseHelper.instance.insertCita(cita);
                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEvolucionDialog({Evolucion? evolucion}) {
    final pesoController = TextEditingController(text: evolucion?.peso ?? '');
    final presionController = TextEditingController(
      text: evolucion?.presionArterial ?? '',
    );
    final alturaUterinaController = TextEditingController(
      text: evolucion?.alturaUterina ?? '',
    );
    final fcFetalController = TextEditingController(
      text: evolucion?.frecuenciaCardiacaFetal ?? '',
    );
    final sintomasController = TextEditingController(
      text: evolucion?.sintomas ?? '',
    );
    final observacionesController = TextEditingController(
      text: evolucion?.observaciones ?? '',
    );
    final fechaController = TextEditingController(
      text:
          evolucion?.fecha.toString().substring(0, 10) ??
          DateTime.now().toString().substring(0, 10),
    );
    DateTime fechaSeleccionada = evolucion?.fecha ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(evolucion == null ? 'Nueva Evolución' : 'Editar Evolución'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fechaController,
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: fechaSeleccionada,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (fecha != null) {
                    fechaSeleccionada = fecha;
                    fechaController.text = fecha.toString().substring(0, 10);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pesoController,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: presionController,
                decoration: const InputDecoration(
                  labelText: 'Presión Arterial',
                  border: OutlineInputBorder(),
                  hintText: 'ej: 120/80',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: alturaUterinaController,
                decoration: const InputDecoration(
                  labelText: 'Altura Uterina (cm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fcFetalController,
                decoration: const InputDecoration(
                  labelText: 'Frecuencia Cardíaca Fetal (lpm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sintomasController,
                decoration: const InputDecoration(
                  labelText: 'Síntomas',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: observacionesController,
                decoration: const InputDecoration(
                  labelText: 'Observaciones',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final evolucionData = Evolucion(
                id: evolucion?.id ?? const Uuid().v4(),
                idEmbarazada: _embarazada!.id,
                fecha: fechaSeleccionada,
                peso: pesoController.text.trim(),
                presionArterial: presionController.text.trim(),
                alturaUterina: alturaUterinaController.text.trim(),
                frecuenciaCardiacaFetal: fcFetalController.text.trim(),
                sintomas: sintomasController.text.trim(),
                observaciones: observacionesController.text.trim(),
                profesional: _embarazada!.medico,
              );
              if (evolucion == null) {
                await DatabaseHelper.instance.insertEvolucion(evolucionData);
              } else {
                await DatabaseHelper.instance.updateEvolucion(evolucionData);
              }
              if (mounted) {
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvolucion(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Está seguro de que desea eliminar esta evolución?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteEvolucion(id);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_embarazada?.nombre ?? 'Detalles'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.child_friendly),
            onPressed: _registrarParto,
            tooltip: 'Registrar Parto',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmbarazadaFormScreen(
                    embarazada: _embarazada,
                    consultorio: _embarazada!.consultorio,
                    medico: _embarazada!.medico ?? '',
                  ),
                ),
              ).then((_) => _loadData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteEmbarazada,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Datos'),
            Tab(text: 'Citas'),
            Tab(text: 'Evolución'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDatosTab(), _buildCitasTab(), _buildEvolucionesTab()],
      ),
    );
  }

  Widget _buildDatosTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Datos Personales',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.person, 'Nombre', _embarazada?.nombre),
                _buildInfoRow(Icons.badge, 'DNI', _embarazada?.cedula),
                _buildInfoRow(Icons.cake, 'Edad', '${_embarazada?.edad} años'),
                _buildInfoRow(Icons.phone, 'Teléfono', _embarazada?.telefono),
                _buildInfoRow(Icons.home, 'Dirección', _embarazada?.direccion),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Datos Sociodemográficos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.school,
                  'Escolaridad',
                  _embarazada?.escolaridad,
                ),
                _buildInfoRow(
                  Icons.favorite,
                  'Estado Conyugal',
                  _embarazada?.estadoConyugal,
                ),
                _buildInfoRow(Icons.work, 'Ocupación', _embarazada?.ocupacion),
                _buildInfoRow(
                  Icons.attach_money,
                  'Condiciones Socioeconómicas',
                  _embarazada?.condicionesSocioeconomicas,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Historia Obstétrica',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.pregnant_woman,
                                size: 16,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Embarazos',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Text(_embarazada?.embarazos?.toString() ?? 'N/A'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.child_friendly,
                                size: 16,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Partos',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Text(_embarazada?.partos?.toString() ?? 'N/A'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning, size: 16, color: Colors.blue),
                              SizedBox(width: 4),
                              Text(
                                'Abortos',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Text(_embarazada?.abortos?.toString() ?? 'N/A'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Datos Antropométricos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        Icons.monitor_weight,
                        'Peso',
                        _embarazada?.peso != null
                            ? '${_embarazada!.peso} kg'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoRow(
                        Icons.height,
                        'Talla',
                        _embarazada?.talla != null
                            ? '${_embarazada!.talla} m'
                            : null,
                      ),
                    ),
                  ],
                ),
                if (_embarazada?.indiceMasaCorporal != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.analytics,
                    'IMC',
                    '${_embarazada!.indiceMasaCorporalString} (${_embarazada!.clasificacionImc})',
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Datos del Esposo/Pareja',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.person,
                  'Nombre',
                  _embarazada?.nombreEsposo,
                ),
                _buildInfoRow(Icons.badge, 'DNI', _embarazada?.cedulaEsposo),
                _buildInfoRow(
                  Icons.work,
                  'Ocupación',
                  _embarazada?.ocupacionEsposo,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.pregnant_woman,
                      color: Colors.blue,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Tiempo Gestacional',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_embarazada?.fechaUltimaMenstruacion != null ||
                    _embarazada?.fechaUltrasonido != null) ...[
                  Center(
                    child: Text(
                      'TG ${_embarazada?.tiempoGestacionalSemanas}.${_embarazada?.tiempoGestacionalDias} semanas',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      '(Se actualiza automáticamente)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ] else ...[
                  const Center(
                    child: Text(
                      'No hay datos de embarazo',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Datos del Embarazo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.calendar_today,
                  'FUM',
                  _embarazada?.fechaUltimaMenstruacion?.toString().split(
                        ' ',
                      )[0] ??
                      'No definida',
                ),
                _buildInfoRow(
                  Icons.child_friendly,
                  'FPP',
                  _embarazada?.fechaProbableParto?.toString().split(' ')[0] ??
                      'No definida',
                ),
                if (_embarazada?.fechaUltrasonido != null) ...[
                  _buildInfoRow(
                    Icons.medical_services,
                    'Fecha Ultrasonido',
                    _embarazada!.fechaUltrasonido!.toString().split(' ')[0],
                  ),
                  _buildInfoRow(
                    Icons.timer,
                    'TG en Ultrasonido',
                    _embarazada?.tiempoGestacionalSemanasUltrasonido != null
                        ? '${_embarazada!.tiempoGestacionalSemanasUltrasonido}.${_embarazada!.tiempoGestacionalDiasUltrasonido ?? 0} semanas'
                        : 'No definido',
                  ),
                ],
                _buildInfoRow(
                  Icons.medical_services,
                  'Médico',
                  _embarazada?.medico,
                ),
                _buildInfoRow(
                  Icons.local_hospital,
                  'Consultorio',
                  _embarazada?.consultorio,
                ),
              ],
            ),
          ),
        ),
        if ((_embarazada?.factoresAro != null &&
                _embarazada!.factoresAro!.isNotEmpty) ||
            (_embarazada?.factoresBro != null &&
                _embarazada!.factoresBro!.isNotEmpty) ||
            _embarazada?.ingresada != null) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clasificación de Riesgo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_embarazada?.factoresAro != null &&
                      _embarazada!.factoresAro!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'ALTO RIESGO OBSTÉTRICO (ARO)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ..._embarazada!.factoresAro!.map(
                            (factor) => Padding(
                              padding: const EdgeInsets.only(
                                left: 28,
                                bottom: 4,
                              ),
                              child: Text(
                                '• $factor',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_embarazada?.factoresBro != null &&
                        _embarazada!.factoresBro!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ..._embarazada!.factoresBro!.map(
                              (factor) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '• $factor',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ] else if (_embarazada?.factoresBro != null &&
                      _embarazada!.factoresBro!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'BAJO RIESGO OBSTÉTRICO (BRO)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ..._embarazada!.factoresBro!.map(
                            (factor) => Padding(
                              padding: const EdgeInsets.only(
                                left: 28,
                                bottom: 4,
                              ),
                              child: Text(
                                '• $factor',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_embarazada?.ingresada != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_hospital,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'INGRESADA: ${_embarazada!.ingresada}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        if (_embarazada?.antecedentesFamiliares != null ||
            _embarazada?.antecedentesPersonales != null) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Antecedentes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_embarazada?.antecedentesFamiliares != null &&
                      _embarazada!.antecedentesFamiliares!.isNotEmpty) ...[
                    const Text(
                      'Familiares:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_embarazada!.antecedentesFamiliares!),
                    const SizedBox(height: 8),
                  ],
                  if (_embarazada?.antecedentesPersonales != null &&
                      _embarazada!.antecedentesPersonales!.isNotEmpty) ...[
                    const Text(
                      'Personales:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_embarazada!.antecedentesPersonales!),
                  ],
                ],
              ),
            ),
          ),
        ],
        if (_embarazada?.operaciones != null ||
            _embarazada?.transfusiones != null ||
            _embarazada?.citologia != null) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Otros Datos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_embarazada?.operaciones != null &&
                      _embarazada!.operaciones!.isNotEmpty) ...[
                    const Text(
                      'Operaciones:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_embarazada!.operaciones!),
                    const SizedBox(height: 8),
                  ],
                  if (_embarazada?.transfusiones != null &&
                      _embarazada!.transfusiones!.isNotEmpty) ...[
                    const Text(
                      'Transfusiones:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_embarazada!.transfusiones!),
                    const SizedBox(height: 8),
                  ],
                  if (_embarazada?.citologia != null &&
                      _embarazada!.citologia!.isNotEmpty) ...[
                    const Text(
                      'Citología:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_embarazada!.citologia!),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }

  Widget _buildCitasTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _showAddCitaDialog,
            icon: const Icon(Icons.add),
            label: const Text('Nueva Cita'),
          ),
        ),
        Expanded(
          child: _citas.isEmpty
              ? const Center(
                  child: Text(
                    'No hay citas programadas',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _citas.length,
                  itemBuilder: (context, index) {
                    final cita = _citas[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.event,
                          color: cita.cumplida ? Colors.green : Colors.orange,
                        ),
                        title: Text(cita.motivo),
                        subtitle: Text(
                          cita.fechaHora.toString().substring(0, 16),
                        ),
                        trailing: Checkbox(
                          value: cita.cumplida,
                          onChanged: (value) async {
                            final updated = cita.copyWith(cumplida: value);
                            await DatabaseHelper.instance.insertCita(updated);
                            _loadData();
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEvolucionesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _showAddEvolucionDialog,
            icon: const Icon(Icons.add),
            label: const Text('Nueva Evolución'),
          ),
        ),
        Expanded(
          child: _evoluciones.isEmpty
              ? const Center(
                  child: Text(
                    'No hay evoluciones registradas',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _evoluciones.length,
                  itemBuilder: (context, index) {
                    final evo = _evoluciones[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ExpansionTile(
                        title: Text(evo.fecha.toString().substring(0, 10)),
                        subtitle: Text('Dr. ${evo.profesional ?? 'N/A'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () =>
                                  _showAddEvolucionDialog(evolucion: evo),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                size: 20,
                                color: Colors.red,
                              ),
                              onPressed: () => _deleteEvolucion(evo.id),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (evo.peso != null && evo.peso!.isNotEmpty)
                                  _buildEvoRow('Peso', '${evo.peso} kg'),
                                if (evo.presionArterial != null &&
                                    evo.presionArterial!.isNotEmpty)
                                  _buildEvoRow('PA', evo.presionArterial!),
                                if (evo.alturaUterina != null &&
                                    evo.alturaUterina!.isNotEmpty)
                                  _buildEvoRow('AU', '${evo.alturaUterina} cm'),
                                if (evo.frecuenciaCardiacaFetal != null &&
                                    evo.frecuenciaCardiacaFetal!.isNotEmpty)
                                  _buildEvoRow(
                                    'FCF',
                                    '${evo.frecuenciaCardiacaFetal} lpm',
                                  ),
                                if (evo.sintomas != null &&
                                    evo.sintomas!.isNotEmpty)
                                  _buildEvoRow('Síntomas', evo.sintomas!),
                                if (evo.observaciones != null &&
                                    evo.observaciones!.isNotEmpty)
                                  _buildEvoRow(
                                    'Observaciones',
                                    evo.observaciones!,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEvoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
