import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/puerpera.dart';
import '../models/embarazada.dart';

class PuerperaFormScreen extends StatefulWidget {
  final Puerpera? puerpera;
  final Embarazada? embarazada;
  final String consultorio;
  final String medico;

  const PuerperaFormScreen({
    super.key,
    this.puerpera,
    this.embarazada,
    required this.consultorio,
    required this.medico,
  });

  @override
  State<PuerperaFormScreen> createState() => _PuerperaFormScreenState();
}

class _PuerperaFormScreenState extends State<PuerperaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _edadController;
  late TextEditingController _cedulaController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _escuelaController;
  late TextEditingController _estadoConyugalController;
  late TextEditingController _ocupacionController;
  late TextEditingController _antecedentesFamiliaresController;
  late TextEditingController _antecedentesPersonalesController;
  late TextEditingController _intervencionesController;
  late TextEditingController _transfusionesController;
  late TextEditingController _citologiaController;
  late TextEditingController _pesoController;
  late TextEditingController _tallaController;
  late TextEditingController _nombreEsposoController;
  late TextEditingController _cedulaEsposoController;
  late TextEditingController _ocupacionEsposoController;
  late TextEditingController _condicionesSocioeconomicasController;
  late TextEditingController _observacionesController;
  late TextEditingController _ingresoHospitalarioController;

  DateTime _fechaParto = DateTime.now();
  String _tipoParto = 'EUTOCICO';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.puerpera;
    final e = widget.embarazada;

    _nombreController = TextEditingController(
      text: p?.nombre ?? e?.nombre ?? '',
    );
    _edadController = TextEditingController(text: p?.edad ?? e?.edad ?? '');
    _cedulaController = TextEditingController(
      text: p?.cedula ?? e?.cedula ?? '',
    );
    _telefonoController = TextEditingController(
      text: p?.telefono ?? e?.telefono ?? '',
    );
    _direccionController = TextEditingController(
      text: p?.direccion ?? e?.direccion ?? '',
    );
    _escuelaController = TextEditingController(
      text: p?.escuela ?? e?.escolaridad ?? '',
    );
    _estadoConyugalController = TextEditingController(
      text: p?.estadoConyugal ?? e?.estadoConyugal ?? '',
    );
    _ocupacionController = TextEditingController(
      text: p?.ocupacion ?? e?.ocupacion ?? '',
    );
    _antecedentesFamiliaresController = TextEditingController(
      text: p?.antecedentesFamiliares ?? e?.antecedentesFamiliares ?? '',
    );
    _antecedentesPersonalesController = TextEditingController(
      text: p?.antecedentesPersonales ?? e?.antecedentesPersonales ?? '',
    );
    _intervencionesController = TextEditingController(
      text: p?.intervenciones ?? e?.operaciones ?? '',
    );
    _transfusionesController = TextEditingController(
      text: p?.transfusiones ?? e?.transfusiones ?? '',
    );
    _citologiaController = TextEditingController(
      text: p?.citologia ?? e?.citologia ?? '',
    );
    _pesoController = TextEditingController(text: p?.weighing ?? e?.peso ?? '');
    _tallaController = TextEditingController(text: p?.height ?? e?.talla ?? '');
    _nombreEsposoController = TextEditingController(
      text: p?.nombreEsposo ?? e?.nombreEsposo ?? '',
    );
    _cedulaEsposoController = TextEditingController(
      text: p?.cedulaEsposo ?? e?.cedulaEsposo ?? '',
    );
    _ocupacionEsposoController = TextEditingController(
      text: p?.ocupacionEsposo ?? e?.ocupacionEsposo ?? '',
    );
    _condicionesSocioeconomicasController = TextEditingController(
      text:
          p?.condicionesSocioeconomicas ?? e?.condicionesSocioeconomicas ?? '',
    );
    _observacionesController = TextEditingController(
      text: p?.observaciones ?? '',
    );
    _ingresoHospitalarioController = TextEditingController(
      text: p?.ingresoHospitalario ?? e?.ingresada ?? '',
    );

    if (p != null) {
      _fechaParto = p.fechaParto;
      _tipoParto = p.tipoParto;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _escuelaController.dispose();
    _estadoConyugalController.dispose();
    _ocupacionController.dispose();
    _antecedentesFamiliaresController.dispose();
    _antecedentesPersonalesController.dispose();
    _intervencionesController.dispose();
    _transfusionesController.dispose();
    _citologiaController.dispose();
    _pesoController.dispose();
    _tallaController.dispose();
    _nombreEsposoController.dispose();
    _cedulaEsposoController.dispose();
    _ocupacionEsposoController.dispose();
    _condicionesSocioeconomicasController.dispose();
    _observacionesController.dispose();
    _ingresoHospitalarioController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaParto,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _fechaParto = date);
    }
  }

  Future<void> _savePuerpera() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final puerpera = Puerpera(
        id: widget.puerpera?.id ?? const Uuid().v4(),
        idEmbarazada:
            widget.puerpera?.idEmbarazada ?? widget.embarazada?.id ?? '',
        nombre: _nombreController.text.trim(),
        edad: _edadController.text.trim(),
        cedula: _cedulaController.text.trim(),
        telefono: _telefonoController.text.trim(),
        direccion: _direccionController.text.trim(),
        fechaRegistro: widget.puerpera?.fechaRegistro ?? DateTime.now(),
        fechaParto: _fechaParto,
        tipoParto: _tipoParto,
        observaciones: _observacionesController.text.trim().isEmpty
            ? null
            : _observacionesController.text.trim(),
        consultorio: widget.consultorio,
        medico: widget.medico.isEmpty ? null : widget.medico,
        escuela: _escuelaController.text.trim().isEmpty
            ? null
            : _escuelaController.text.trim(),
        estadoConyugal: _estadoConyugalController.text.trim().isEmpty
            ? null
            : _estadoConyugalController.text.trim(),
        ocupacion: _ocupacionController.text.trim().isEmpty
            ? null
            : _ocupacionController.text.trim(),
        antecedentesFamiliares:
            _antecedentesFamiliaresController.text.trim().isEmpty
            ? null
            : _antecedentesFamiliaresController.text.trim(),
        antecedentesPersonales:
            _antecedentesPersonalesController.text.trim().isEmpty
            ? null
            : _antecedentesPersonalesController.text.trim(),
        intervenciones: _intervencionesController.text.trim().isEmpty
            ? null
            : _intervencionesController.text.trim(),
        transfusiones: _transfusionesController.text.trim().isEmpty
            ? null
            : _transfusionesController.text.trim(),
        citologia: _citologiaController.text.trim().isEmpty
            ? null
            : _citologiaController.text.trim(),
        weighing: _pesoController.text.trim().isEmpty
            ? null
            : _pesoController.text.trim(),
        height: _tallaController.text.trim().isEmpty
            ? null
            : _tallaController.text.trim(),
        nombreEsposo: _nombreEsposoController.text.trim().isEmpty
            ? null
            : _nombreEsposoController.text.trim(),
        cedulaEsposo: _cedulaEsposoController.text.trim().isEmpty
            ? null
            : _cedulaEsposoController.text.trim(),
        ocupacionEsposo: _ocupacionEsposoController.text.trim().isEmpty
            ? null
            : _ocupacionEsposoController.text.trim(),
        condicionesSocioeconomicas:
            _condicionesSocioeconomicasController.text.trim().isEmpty
            ? null
            : _condicionesSocioeconomicasController.text.trim(),
        ingresoHospitalario: _ingresoHospitalarioController.text.trim().isEmpty
            ? null
            : _ingresoHospitalarioController.text.trim(),
        activa: true,
      );

      await DatabaseHelper.instance.insertPuerpera(puerpera);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Puérpera guardada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.puerpera != null ? 'Editar Puérpera' : 'Nueva Puérpera',
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Datos del Parto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha de Parto *',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                '${_fechaParto.day}/${_fechaParto.month}/${_fechaParto.year}',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _tipoParto,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de Parto *',
                              border: OutlineInputBorder(),
                            ),
                            items: Puerpera.tipoPartoOptions.map((tipo) {
                              return DropdownMenuItem(
                                value: tipo,
                                child: Text(tipo),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _tipoParto = value!);
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _observacionesController,
                            decoration: const InputDecoration(
                              labelText: 'Observaciones del Parto',
                              border: OutlineInputBorder(),
                              hintText: 'Detalles relevantes del parto',
                            ),
                            maxLines: 3,
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v!.trim().isEmpty ? 'Requerido' : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _cedulaController,
                                  decoration: const InputDecoration(
                                    labelText: 'DNI *',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) =>
                                      v!.trim().isEmpty ? 'Requerido' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _edadController,
                                  decoration: const InputDecoration(
                                    labelText: 'Edad *',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (v) =>
                                      v!.trim().isEmpty ? 'Requerido' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _telefonoController,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                v!.trim().isEmpty ? 'Requerido' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _direccionController,
                            decoration: const InputDecoration(
                              labelText: 'Dirección *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v!.trim().isEmpty ? 'Requerido' : null,
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
                            'Datos Sociodemográficos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _escuelaController,
                            decoration: const InputDecoration(
                              labelText: 'Escolaridad',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _estadoConyugalController,
                            decoration: const InputDecoration(
                              labelText: 'Estado Conyugal',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _ocupacionController,
                            decoration: const InputDecoration(
                              labelText: 'Ocupación',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _condicionesSocioeconomicasController,
                            decoration: const InputDecoration(
                              labelText: 'Condiciones Socioeconómicas',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _pesoController,
                                  decoration: const InputDecoration(
                                    labelText: 'Peso (kg)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _tallaController,
                                  decoration: const InputDecoration(
                                    labelText: 'Talla (m)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
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
                            'Datos del Esposo/Pareja',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nombreEsposoController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _cedulaEsposoController,
                                  decoration: const InputDecoration(
                                    labelText: 'DNI',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _ocupacionEsposoController,
                                  decoration: const InputDecoration(
                                    labelText: 'Ocupación',
                                    border: OutlineInputBorder(),
                                  ),
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
                            'Antecedentes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _antecedentesFamiliaresController,
                            decoration: const InputDecoration(
                              labelText: 'Antecedentes Familiares',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _antecedentesPersonalesController,
                            decoration: const InputDecoration(
                              labelText: 'Antecedentes Personales',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
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
                            'Otros Datos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _intervencionesController,
                            decoration: const InputDecoration(
                              labelText: 'Intervenciones Quirúrgicas',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _transfusionesController,
                            decoration: const InputDecoration(
                              labelText: 'Transfusiones',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _citologiaController,
                            decoration: const InputDecoration(
                              labelText: 'Citología',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _ingresoHospitalarioController,
                            decoration: const InputDecoration(
                              labelText: 'Ingreso Hospitalario',
                              border: OutlineInputBorder(),
                              hintText: 'HOMA / HHB / Otro',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _savePuerpera,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.puerpera != null ? 'Actualizar' : 'Guardar',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
