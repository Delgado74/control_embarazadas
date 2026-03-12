import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/lactante.dart';
import '../models/cita.dart';
import '../models/evolucion_lactante.dart';
import 'lactante_form.dart';

const List<String> percentilesOptions = [
  '<P3',
  'P3',
  'P3-P10',
  'P10',
  'P10-P25',
  'P25',
  'P25-P50',
  'P50',
  'P50-P75',
  'P75',
  'P75-P90',
  'P90',
  'P90-P95',
  'P95',
  '>P95',
  '-',
];

class LactanteDetailScreen extends StatefulWidget {
  final Lactante lactante;

  const LactanteDetailScreen({super.key, required this.lactante});

  @override
  State<LactanteDetailScreen> createState() => _LactanteDetailScreenState();
}

class _LactanteDetailScreenState extends State<LactanteDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Lactante? _lactante;
  List<Cita> _citas = [];
  List<EvolucionLactante> _evoluciones = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _lactante = widget.lactante;
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _lactante = await DatabaseHelper.instance.getLactante(_lactante!.id);
    _citas = await DatabaseHelper.instance.getCitasByLactante(_lactante!.id);
    _evoluciones = await DatabaseHelper.instance.getEvolucionesByLactante(
      _lactante!.id,
    );
    if (mounted) setState(() {});
  }

  Future<void> _deleteLactante() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Está seguro de eliminar este lactante? Esta acción no se puede deshacer.',
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
      await DatabaseHelper.instance.deleteLactante(_lactante!.id);
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
                  idEmbarazada: _lactante!.id,
                  fechaHora: fechaHora,
                  motivo: motivoController.text.trim(),
                );
                await DatabaseHelper.instance.insertCitaLactante(cita);
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

  void _showAddEvolucionDialog({EvolucionLactante? evolucion}) {
    final interrogatorioController = TextEditingController(
      text: evolucion?.interrogatorio ?? '',
    );
    final pesoController = TextEditingController(text: evolucion?.peso ?? '');
    final tallaController = TextEditingController(text: evolucion?.talla ?? '');
    final ccController = TextEditingController(text: evolucion?.cc ?? '');
    String? pesoEdad = evolucion?.pesoEdad;
    String? tallaEdad = evolucion?.tallaEdad;
    String? ccEdad = evolucion?.ccEdad;
    String? pesoTalla = evolucion?.pesoTalla;
    final frController = TextEditingController(
      text: evolucion?.frecuenciaRespiratoria ?? '',
    );
    final fcController = TextEditingController(
      text: evolucion?.frecuenciaCardiaca ?? '',
    );
    final dpmController = TextEditingController(text: evolucion?.dpm ?? '');
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
                controller: interrogatorioController,
                decoration: const InputDecoration(
                  labelText: 'Interrogatorio',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
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
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: tallaController,
                      decoration: const InputDecoration(
                        labelText: 'Talla (cm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: ccController,
                      decoration: const InputDecoration(
                        labelText: 'CC (cm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: pesoEdad,
                      decoration: const InputDecoration(
                        labelText: 'Peso/Edad',
                        border: OutlineInputBorder(),
                      ),
                      items: percentilesOptions
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (v) => pesoEdad = v,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: tallaEdad,
                      decoration: const InputDecoration(
                        labelText: 'Talla/Edad',
                        border: OutlineInputBorder(),
                      ),
                      items: percentilesOptions
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (v) => tallaEdad = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: ccEdad,
                      decoration: const InputDecoration(
                        labelText: 'CC/Edad',
                        border: OutlineInputBorder(),
                      ),
                      items: percentilesOptions
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (v) => ccEdad = v,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: pesoTalla,
                      decoration: const InputDecoration(
                        labelText: 'Peso/Talla',
                        border: OutlineInputBorder(),
                      ),
                      items: percentilesOptions
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (v) => pesoTalla = v,
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
                        labelText: 'FResp.',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: fcController,
                      decoration: const InputDecoration(
                        labelText: 'FCard.',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dpmController,
                decoration: const InputDecoration(
                  labelText: 'Desarrollo Psicomotor (DPM)',
                  border: OutlineInputBorder(),
                ),
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
              final evolucionData = EvolucionLactante(
                id: evolucion?.id ?? const Uuid().v4(),
                idLactante: _lactante!.id,
                fecha: fechaSeleccionada,
                interrogatorio: interrogatorioController.text.trim().isEmpty
                    ? null
                    : interrogatorioController.text.trim(),
                peso: pesoController.text.trim().isEmpty
                    ? null
                    : pesoController.text.trim(),
                talla: tallaController.text.trim().isEmpty
                    ? null
                    : tallaController.text.trim(),
                cc: ccController.text.trim().isEmpty
                    ? null
                    : ccController.text.trim(),
                pesoEdad: pesoEdad,
                tallaEdad: tallaEdad,
                ccEdad: ccEdad,
                pesoTalla: pesoTalla,
                frecuenciaRespiratoria: frController.text.trim().isEmpty
                    ? null
                    : frController.text.trim(),
                frecuenciaCardiaca: fcController.text.trim().isEmpty
                    ? null
                    : fcController.text.trim(),
                dpm: dpmController.text.trim().isEmpty
                    ? null
                    : dpmController.text.trim(),
                observaciones: observacionesController.text.trim().isEmpty
                    ? null
                    : observacionesController.text.trim(),
                profesional: _lactante!.medico,
              );
              if (evolucion == null) {
                await DatabaseHelper.instance.insertEvolucionLactante(
                  evolucionData,
                );
              } else {
                await DatabaseHelper.instance.updateEvolucionLactante(
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
      await DatabaseHelper.instance.deleteEvolucionLactante(id);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_lactante?.nombre ?? 'Detalles'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LactanteFormScreen(
                    lactante: _lactante,
                    consultorio: _lactante!.consultorio,
                    medico: _lactante!.medico ?? '',
                  ),
                ),
              ).then((_) => _loadData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteLactante,
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
                _buildInfoRow(Icons.person, 'Nombre', _lactante?.nombre),
                _buildInfoRow(
                  Icons.cake,
                  'Fecha de nacimiento',
                  _lactante?.fechaNacimiento.toString().split(' ')[0],
                ),
                _buildInfoRow(
                  Icons.access_time,
                  'Edad',
                  _lactante?.edadMesesString,
                ),
                _buildInfoRow(
                  Icons.wc,
                  'Sexo',
                  _lactante?.sexo == 'M'
                      ? 'Masculino'
                      : _lactante?.sexo == 'F'
                      ? 'Femenino'
                      : 'N/A',
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
                  'Datos de la Madre',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.person, 'Madre', _lactante?.nombreMadre),
                _buildInfoRow(Icons.home, 'Dirección', _lactante?.direccion),
                _buildInfoRow(Icons.phone, 'Teléfono', _lactante?.telefono),
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
                  'Antecedentes Prenatales',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.numbers,
                  'Consultas prenatales',
                  _lactante?.numeroConsultasPrenatales?.toString(),
                ),
                _buildInfoRow(
                  Icons.warning,
                  'Clasificación de riesgo',
                  _lactante?.clasificacionRiesgoObstetrico,
                ),
                _buildInfoRow(
                  Icons.medical_services,
                  'Diagnósticos del embarazo',
                  _lactante?.diagnosticosEmbarazo,
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
                  'Antecedentes Natales',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.timer,
                  'EG del parto',
                  _lactante?.egParto != null
                      ? '${_lactante!.egParto} semanas'
                      : null,
                ),
                _buildInfoRow(
                  Icons.location_on,
                  'Lugar del parto',
                  _lactante?.lugarParto,
                ),
                _buildInfoRow(
                  Icons.child_friendly,
                  'Tipo de parto',
                  _lactante?.tipoParto,
                ),
                _buildInfoRow(
                  Icons.baby_changing_station,
                  'Características del RN',
                  _lactante?.caracteristicasRn,
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
                  'Antecedentes Postnatales',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.monitor_weight,
                  'Peso al nacer',
                  _lactante?.pesoNacer != null
                      ? '${_lactante!.pesoNacer} g'
                      : null,
                ),
                _buildInfoRow(
                  Icons.height,
                  'Talla al nacer',
                  _lactante?.tallaNacer != null
                      ? '${_lactante!.tallaNacer} cm'
                      : null,
                ),
                _buildInfoRow(
                  Icons.circle,
                  'CC al nacer',
                  _lactante?.ccNacer != null
                      ? '${_lactante!.ccNacer} cm'
                      : null,
                ),
                _buildInfoRow(
                  Icons.circle_outlined,
                  'CT al nacer',
                  _lactante?.ctNacer != null
                      ? '${_lactante!.ctNacer} cm'
                      : null,
                ),
                _buildInfoRow(
                  Icons.favorite,
                  'Apgar',
                  _lactante?.apgar?.toString(),
                ),
              ],
            ),
          ),
        ),
        if (_lactante?.antecedentesFamiliares != null &&
            _lactante!.antecedentesFamiliares!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Antecedentes Familiares',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(_lactante!.antecedentesFamiliares!),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Clasificación y Estado Nutricional',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.health_and_safety,
                  'Clasificación',
                  _lactante?.clasificacion,
                ),
                _buildInfoRow(
                  Icons.restaurant,
                  'Valoración nutricional',
                  _lactante?.valoracionNutricional,
                ),
                _buildInfoRow(
                  Icons.local_hospital,
                  'Alimentación',
                  _lactante?.alimentacion,
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
                  'Datos del Consultorio',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.local_hospital,
                  'Consultorio',
                  _lactante?.consultorio,
                ),
                _buildInfoRow(Icons.person, 'Médico', _lactante?.medico),
              ],
            ),
          ),
        ),
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
                            await DatabaseHelper.instance.insertCitaLactante(
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
                                if (evo.interrogatorio != null &&
                                    evo.interrogatorio!.isNotEmpty)
                                  _buildEvoRow(
                                    'Interrogatorio',
                                    evo.interrogatorio!,
                                  ),
                                if (evo.peso != null && evo.peso!.isNotEmpty)
                                  _buildEvoRow('Peso', '${evo.peso} kg'),
                                if (evo.talla != null && evo.talla!.isNotEmpty)
                                  _buildEvoRow('Talla', '${evo.talla} cm'),
                                if (evo.cc != null && evo.cc!.isNotEmpty)
                                  _buildEvoRow('CC', '${evo.cc} cm'),
                                if (evo.pesoEdad != null &&
                                    evo.pesoEdad!.isNotEmpty)
                                  _buildEvoRow('Peso/Edad', evo.pesoEdad!),
                                if (evo.tallaEdad != null &&
                                    evo.tallaEdad!.isNotEmpty)
                                  _buildEvoRow('Talla/Edad', evo.tallaEdad!),
                                if (evo.ccEdad != null &&
                                    evo.ccEdad!.isNotEmpty)
                                  _buildEvoRow('CC/Edad', evo.ccEdad!),
                                if (evo.pesoTalla != null &&
                                    evo.pesoTalla!.isNotEmpty)
                                  _buildEvoRow('Peso/Talla', evo.pesoTalla!),
                                if (evo.frecuenciaRespiratoria != null &&
                                    evo.frecuenciaRespiratoria!.isNotEmpty)
                                  _buildEvoRow(
                                    'FR',
                                    '${evo.frecuenciaRespiratoria} rpm',
                                  ),
                                if (evo.frecuenciaCardiaca != null &&
                                    evo.frecuenciaCardiaca!.isNotEmpty)
                                  _buildEvoRow(
                                    'FC',
                                    '${evo.frecuenciaCardiaca} lpm',
                                  ),
                                if (evo.dpm != null && evo.dpm!.isNotEmpty)
                                  _buildEvoRow('DPM', evo.dpm!),
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
