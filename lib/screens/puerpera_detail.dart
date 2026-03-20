import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/puerpera.dart';
import '../models/cita.dart';
import '../models/evolucion_puerpera.dart';
import 'puerpera_form.dart';
import 'package:intl/intl.dart';

class PuerperaDetailScreen extends StatefulWidget {
  final Puerpera puerpera;

  const PuerperaDetailScreen({super.key, required this.puerpera});

  @override
  State<PuerperaDetailScreen> createState() => _PuerperaDetailScreenState();
}

class _PuerperaDetailScreenState extends State<PuerperaDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Puerpera? _puerpera;
  List<Cita> _citas = [];
  List<EvolucionPuerpera> _evoluciones = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _puerpera = widget.puerpera;
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _puerpera = await DatabaseHelper.instance.getPuerpera(_puerpera!.id);
    _citas = await DatabaseHelper.instance.getCitasByPuerpera(_puerpera!.id);
    _evoluciones = await DatabaseHelper.instance.getEvolucionesByPuerpera(
      _puerpera!.id,
    );
    if (mounted) setState(() {});
  }

  Future<void> _deletePuerpera() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Está seguro de eliminar esta puérpera? Esta acción no se puede deshacer.',
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
      await DatabaseHelper.instance.deletePuerpera(_puerpera!.id);
      if (mounted) Navigator.pop(context);
    }
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
                  idEmbarazada: _puerpera!.id,
                  fechaHora: fechaHora,
                  motivo: motivoController.text.trim(),
                );
                await DatabaseHelper.instance.insertCitaPuerpera(cita);
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

  void _showAddEvolucionDialog({EvolucionPuerpera? evolucion}) {
    final pesoController = TextEditingController(text: evolucion?.peso ?? '');
    final presionController = TextEditingController(
      text: evolucion?.presionArterial ?? '',
    );
    final temperaturaController = TextEditingController(
      text: evolucion?.temperatura ?? '',
    );
    final fcController = TextEditingController(
      text: evolucion?.frecuenciaCardiaca ?? '',
    );
    final frController = TextEditingController(
      text: evolucion?.frecuenciaRespiratoria ?? '',
    );
    final auController = TextEditingController(
      text: evolucion?.alturaUterina ?? '',
    );
    final loquiosController = TextEditingController(
      text: evolucion?.loquios ?? '',
    );
    final mamasController = TextEditingController(text: evolucion?.mamas ?? '');
    final perineController = TextEditingController(
      text: evolucion?.perine ?? '',
    );
    final estadoPsiquicoController = TextEditingController(
      text: evolucion?.estadoPsiquico ?? '',
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: pesoController,
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: temperaturaController,
                      decoration: const InputDecoration(
                        labelText: 'Temp (°C)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: presionController,
                      decoration: const InputDecoration(
                        labelText: 'PA',
                        border: OutlineInputBorder(),
                        hintText: '120/80',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: fcController,
                      decoration: const InputDecoration(
                        labelText: 'FC',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: frController,
                      decoration: const InputDecoration(
                        labelText: 'FR',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: auController,
                      decoration: const InputDecoration(
                        labelText: 'AU (cm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: loquiosController,
                decoration: const InputDecoration(
                  labelText: 'Loquios',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: mamasController,
                decoration: const InputDecoration(
                  labelText: 'Mamas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: perineController,
                decoration: const InputDecoration(
                  labelText: 'Periné',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: estadoPsiquicoController,
                decoration: const InputDecoration(
                  labelText: 'Estado Psíquico',
                  border: OutlineInputBorder(),
                ),
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
              final evolucionData = EvolucionPuerpera(
                id: evolucion?.id ?? const Uuid().v4(),
                idPuerpera: _puerpera!.id,
                fecha: fechaSeleccionada,
                peso: pesoController.text.trim(),
                presionArterial: presionController.text.trim(),
                temperatura: temperaturaController.text.trim(),
                frecuenciaCardiaca: fcController.text.trim(),
                frecuenciaRespiratoria: frController.text.trim(),
                alturaUterina: auController.text.trim(),
                loquios: loquiosController.text.trim(),
                mamas: mamasController.text.trim(),
                perine: perineController.text.trim(),
                estadoPsiquico: estadoPsiquicoController.text.trim(),
                sintomas: sintomasController.text.trim(),
                observaciones: observacionesController.text.trim(),
                profesional: _puerpera!.medico,
              );
              if (evolucion == null) {
                await DatabaseHelper.instance.insertEvolucionPuerpera(
                  evolucionData,
                );
              } else {
                await DatabaseHelper.instance.updateEvolucionPuerpera(
                  evolucionData,
                );
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
      await DatabaseHelper.instance.deleteEvolucionPuerpera(id);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_puerpera?.nombre ?? 'Detalles'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PuerperaFormScreen(
                    puerpera: _puerpera,
                    consultorio: _puerpera!.consultorio,
                    medico: _puerpera!.medico ?? '',
                  ),
                ),
              ).then((_) => _loadData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deletePuerpera,
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
    final diasPostParto = _puerpera!.diasPostParto;
    final estadoColor = diasPostParto <= 7
        ? Colors.red
        : diasPostParto <= 28
        ? Colors.orange
        : Colors.green;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: estadoColor.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer, color: estadoColor, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '$diasPostParto días post-parto',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: estadoColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: estadoColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _puerpera!.estadoPuerperio,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_puerpera!.diasRestantes > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Faltan ${_puerpera!.diasRestantes} días para finalizar el puerperio',
                    style: TextStyle(color: Colors.grey[600]),
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
                  'Datos del Parto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Fecha de Parto',
                  DateFormat('dd/MM/yyyy').format(_puerpera!.fechaParto),
                ),
                _buildInfoRow(
                  Icons.child_care,
                  'Tipo de Parto',
                  _puerpera!.tipoParto,
                ),
                _buildInfoRow(
                  Icons.access_time,
                  'Fecha de Registro',
                  DateFormat('dd/MM/yyyy').format(_puerpera!.fechaRegistro),
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
                  'Datos Personales',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.person, 'Nombre', _puerpera!.nombre),
                _buildInfoRow(Icons.badge, 'DNI', _puerpera!.cedula),
                _buildInfoRow(Icons.cake, 'Edad', '${_puerpera!.edad} años'),
                _buildInfoRow(Icons.phone, 'Teléfono', _puerpera!.telefono),
                _buildInfoRow(Icons.home, 'Dirección', _puerpera!.direccion),
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
                _buildInfoRow(Icons.school, 'Escolaridad', _puerpera!.escuela),
                _buildInfoRow(
                  Icons.favorite,
                  'Estado Conyugal',
                  _puerpera!.estadoConyugal,
                ),
                _buildInfoRow(Icons.work, 'Ocupación', _puerpera!.ocupacion),
              ],
            ),
          ),
        ),
        if (_puerpera!.weighing != null || _puerpera!.height != null) ...[
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
                          _puerpera!.weighing != null
                              ? '${_puerpera!.weighing} kg'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoRow(
                          Icons.height,
                          'Talla',
                          _puerpera!.height != null
                              ? '${_puerpera!.height} m'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  if (_puerpera!.imc != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.analytics,
                      'IMC',
                      '${_puerpera!.imcString} (${_puerpera!.clasificacionImc})',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        if (_puerpera!.nombreEsposo != null) ...[
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
                    _puerpera!.nombreEsposo,
                  ),
                  _buildInfoRow(Icons.badge, 'DNI', _puerpera!.cedulaEsposo),
                  _buildInfoRow(
                    Icons.work,
                    'Ocupación',
                    _puerpera!.ocupacionEsposo,
                  ),
                ],
              ),
            ),
          ),
        ],
        if (_puerpera!.antecedentesFamiliares != null ||
            _puerpera!.antecedentesPersonales != null) ...[
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
                  if (_puerpera!.antecedentesFamiliares != null &&
                      _puerpera!.antecedentesFamiliares!.isNotEmpty) ...[
                    const Text(
                      'Familiares:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_puerpera!.antecedentesFamiliares!),
                    const SizedBox(height: 8),
                  ],
                  if (_puerpera!.antecedentesPersonales != null &&
                      _puerpera!.antecedentesPersonales!.isNotEmpty) ...[
                    const Text(
                      'Personales:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_puerpera!.antecedentesPersonales!),
                  ],
                ],
              ),
            ),
          ),
        ],
        if (_puerpera!.intervenciones != null ||
            _puerpera!.transfusiones != null ||
            _puerpera!.citologia != null) ...[
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
                  if (_puerpera!.intervenciones != null &&
                      _puerpera!.intervenciones!.isNotEmpty) ...[
                    const Text(
                      'Intervenciones:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_puerpera!.intervenciones!),
                    const SizedBox(height: 8),
                  ],
                  if (_puerpera!.transfusiones != null &&
                      _puerpera!.transfusiones!.isNotEmpty) ...[
                    const Text(
                      'Transfusiones:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_puerpera!.transfusiones!),
                    const SizedBox(height: 8),
                  ],
                  if (_puerpera!.citologia != null &&
                      _puerpera!.citologia!.isNotEmpty) ...[
                    const Text(
                      'Citología:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_puerpera!.citologia!),
                  ],
                ],
              ),
            ),
          ),
        ],
        if (_puerpera!.observaciones != null &&
            _puerpera!.observaciones!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.note, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'Observaciones del Parto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_puerpera!.observaciones!),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información del Centro',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.local_hospital,
                  'Consultorio',
                  _puerpera!.consultorio,
                ),
                _buildInfoRow(
                  Icons.medical_services,
                  'Médico',
                  _puerpera!.medico,
                ),
              ],
            ),
          ),
        ),
        if (!_puerpera!.activa) ...[
          const SizedBox(height: 16),
          Card(
            color: Colors.grey.shade200,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'PERIODO DE PUERPERIO FINALIZADO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
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
                            await DatabaseHelper.instance.insertCitaPuerpera(
                              updated,
                            );
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
                                if (evo.temperatura != null &&
                                    evo.temperatura!.isNotEmpty)
                                  _buildEvoRow('Temp', '${evo.temperatura}°C'),
                                if (evo.frecuenciaCardiaca != null &&
                                    evo.frecuenciaCardiaca!.isNotEmpty)
                                  _buildEvoRow(
                                    'FC',
                                    '${evo.frecuenciaCardiaca} lpm',
                                  ),
                                if (evo.frecuenciaRespiratoria != null &&
                                    evo.frecuenciaRespiratoria!.isNotEmpty)
                                  _buildEvoRow(
                                    'FR',
                                    '${evo.frecuenciaRespiratoria} rpm',
                                  ),
                                if (evo.alturaUterina != null &&
                                    evo.alturaUterina!.isNotEmpty)
                                  _buildEvoRow('AU', '${evo.alturaUterina} cm'),
                                if (evo.loquios != null &&
                                    evo.loquios!.isNotEmpty)
                                  _buildEvoRow('Loquios', evo.loquios!),
                                if (evo.mamas != null && evo.mamas!.isNotEmpty)
                                  _buildEvoRow('Mamas', evo.mamas!),
                                if (evo.perine != null &&
                                    evo.perine!.isNotEmpty)
                                  _buildEvoRow('Periné', evo.perine!),
                                if (evo.estadoPsiquico != null &&
                                    evo.estadoPsiquico!.isNotEmpty)
                                  _buildEvoRow(
                                    'Estado Psíquico',
                                    evo.estadoPsiquico!,
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
