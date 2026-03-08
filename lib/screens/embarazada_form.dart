import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/embarazada.dart';

class EmbarazadaFormScreen extends StatefulWidget {
  final Embarazada? embarazada;
  final String consultorio;
  final String medico;

  const EmbarazadaFormScreen({
    super.key,
    this.embarazada,
    required this.consultorio,
    required this.medico,
  });

  @override
  State<EmbarazadaFormScreen> createState() => _EmbarazadaFormScreenState();
}

class _EmbarazadaFormScreenState extends State<EmbarazadaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _antecedentesFamiliaresController = TextEditingController();
  final _antecedentesPersonalesController = TextEditingController();
  final _tiempoGestacionalSemanasController = TextEditingController();
  final _tiempoGestacionalDiasController = TextEditingController();
  final _embarazosController = TextEditingController();
  final _partosController = TextEditingController();
  final _abortosController = TextEditingController();
  final _operacionesController = TextEditingController();
  final _transfusionesController = TextEditingController();
  final _citologiaController = TextEditingController();
  final _pesoController = TextEditingController();
  final _tallaController = TextEditingController();
  final _nombreEsposoController = TextEditingController();
  final _cedulaEsposoController = TextEditingController();
  final _ocupacionEsposoController = TextEditingController();

  DateTime? _fechaUltimaMenstruacion;
  DateTime? _fechaProbableParto;
  DateTime? _fechaUltrasonido;
  bool _isLoading = false;
  String? _escolaridad;
  String? _estadoConyugal;
  String? _ocupacion;
  String? _condicionesSocioeconomicas;
  List<String> _factoresAro = [];
  List<String> _factoresBro = [];
  String? _ingresada;

  @override
  void initState() {
    super.initState();
    if (widget.embarazada != null) {
      _nombreController.text = widget.embarazada!.nombre;
      _edadController.text = widget.embarazada!.edad;
      _cedulaController.text = widget.embarazada!.cedula;
      _telefonoController.text = widget.embarazada!.telefono;
      _direccionController.text = widget.embarazada!.direccion;
      _antecedentesFamiliaresController.text =
          widget.embarazada!.antecedentesFamiliares ?? '';
      _antecedentesPersonalesController.text =
          widget.embarazada!.antecedentesPersonales ?? '';
      _fechaUltimaMenstruacion = widget.embarazada!.fechaUltimaMenstruacion;
      _fechaProbableParto = widget.embarazada!.fechaProbableParto;
      _fechaUltrasonido = widget.embarazada!.fechaUltrasonido;
      if (widget.embarazada!.tiempoGestacionalSemanasUltrasonido != null) {
        _tiempoGestacionalSemanasController.text = widget
            .embarazada!
            .tiempoGestacionalSemanasUltrasonido
            .toString();
      }
      if (widget.embarazada!.tiempoGestacionalDiasUltrasonido != null) {
        _tiempoGestacionalDiasController.text = widget
            .embarazada!
            .tiempoGestacionalDiasUltrasonido
            .toString();
      }
      if (widget.embarazada!.embarazos != null) {
        _embarazosController.text = widget.embarazada!.embarazos.toString();
      }
      if (widget.embarazada!.partos != null) {
        _partosController.text = widget.embarazada!.partos.toString();
      }
      if (widget.embarazada!.abortos != null) {
        _abortosController.text = widget.embarazada!.abortos.toString();
      }
      _escolaridad = widget.embarazada!.escolaridad;
      _estadoConyugal = widget.embarazada!.estadoConyugal;
      _ocupacion = widget.embarazada!.ocupacion;
      _operacionesController.text = widget.embarazada!.operaciones ?? '';
      _transfusionesController.text = widget.embarazada!.transfusiones ?? '';
      _citologiaController.text = widget.embarazada!.citologia ?? '';
      _pesoController.text = widget.embarazada!.peso ?? '';
      _tallaController.text = widget.embarazada!.talla ?? '';
      _nombreEsposoController.text = widget.embarazada!.nombreEsposo ?? '';
      _cedulaEsposoController.text = widget.embarazada!.cedulaEsposo ?? '';
      _ocupacionEsposoController.text =
          widget.embarazada!.ocupacionEsposo ?? '';
      _condicionesSocioeconomicas =
          widget.embarazada!.condicionesSocioeconomicas;
      _factoresAro = List<String>.from(widget.embarazada!.factoresAro ?? []);
      _factoresBro = List<String>.from(widget.embarazada!.factoresBro ?? []);
      _ingresada = widget.embarazada!.ingresada;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _antecedentesFamiliaresController.dispose();
    _antecedentesPersonalesController.dispose();
    _tiempoGestacionalSemanasController.dispose();
    _tiempoGestacionalDiasController.dispose();
    _embarazosController.dispose();
    _partosController.dispose();
    _abortosController.dispose();
    _operacionesController.dispose();
    _transfusionesController.dispose();
    _citologiaController.dispose();
    _pesoController.dispose();
    _tallaController.dispose();
    _nombreEsposoController.dispose();
    _cedulaEsposoController.dispose();
    _ocupacionEsposoController.dispose();
    super.dispose();
  }

  void _calcularFPPDesdeFUM() {
    if (_fechaUltimaMenstruacion != null) {
      setState(() {
        _fechaProbableParto = _fechaUltimaMenstruacion!.add(
          const Duration(days: 280),
        );
      });
    }
  }

  void _calcularFPPDesdeUltrasonido() {
    if (_fechaUltrasonido != null &&
        _tiempoGestacionalSemanasController.text.isNotEmpty) {
      final semanasGestacion = int.tryParse(
        _tiempoGestacionalSemanasController.text,
      );
      final diasGestacionUltrasonido =
          int.tryParse(_tiempoGestacionalDiasController.text) ?? 0;
      if (semanasGestacion != null) {
        final diasGestacion = (semanasGestacion * 7) + diasGestacionUltrasonido;
        final diasRestantes = 280 - diasGestacion;
        final fechaParto = _fechaUltrasonido!.add(
          Duration(days: diasRestantes),
        );
        setState(() {
          _fechaProbableParto = fechaParto;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFUM) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFUM) {
          _fechaUltimaMenstruacion = picked;
          _calcularFPPDesdeFUM();
        } else {
          _fechaProbableParto = picked;
        }
      });
    }
  }

  Future<void> _selectDateUltrasonido(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _fechaUltrasonido = picked;
        _calcularFPPDesdeUltrasonido();
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final embarazada = Embarazada(
      id: widget.embarazada?.id ?? const Uuid().v4(),
      nombre: _nombreController.text.trim(),
      edad: _edadController.text.trim(),
      cedula: _cedulaController.text.trim(),
      telefono: _telefonoController.text.trim(),
      direccion: _direccionController.text.trim(),
      fechaRegistro: widget.embarazada?.fechaRegistro ?? DateTime.now(),
      fechaUltimaMenstruacion: _fechaUltimaMenstruacion,
      fechaProbableParto: _fechaProbableParto,
      fechaUltrasonido: _fechaUltrasonido,
      tiempoGestacionalSemanasUltrasonido:
          _tiempoGestacionalSemanasController.text.isNotEmpty
          ? int.tryParse(_tiempoGestacionalSemanasController.text)
          : null,
      tiempoGestacionalDiasUltrasonido:
          _tiempoGestacionalDiasController.text.isNotEmpty
          ? int.tryParse(_tiempoGestacionalDiasController.text)
          : null,
      antecedentesFamiliares: _antecedentesFamiliaresController.text.trim(),
      antecedentesPersonales: _antecedentesPersonalesController.text.trim(),
      consultorio: widget.consultorio,
      medico: widget.medico,
      embarazos: _embarazosController.text.isNotEmpty
          ? int.tryParse(_embarazosController.text)
          : null,
      partos: _partosController.text.isNotEmpty
          ? int.tryParse(_partosController.text)
          : null,
      abortos: _abortosController.text.isNotEmpty
          ? int.tryParse(_abortosController.text)
          : null,
      escolaridad: _escolaridad,
      estadoConyugal: _estadoConyugal,
      ocupacion: _ocupacion,
      operaciones: _operacionesController.text.trim(),
      transfusiones: _transfusionesController.text.trim(),
      citologia: _citologiaController.text.trim(),
      peso: _pesoController.text.trim(),
      talla: _tallaController.text.trim(),
      nombreEsposo: _nombreEsposoController.text.trim(),
      cedulaEsposo: _cedulaEsposoController.text.trim(),
      ocupacionEsposo: _ocupacionEsposoController.text.trim(),
      condicionesSocioeconomicas: _condicionesSocioeconomicas,
      factoresAro: _factoresAro.isNotEmpty ? _factoresAro : null,
      factoresBro: _factoresBro.isNotEmpty ? _factoresBro : null,
      ingresada: _ingresada,
    );

    try {
      if (widget.embarazada != null) {
        await DatabaseHelper.instance.updateEmbarazada(embarazada);
      } else {
        await DatabaseHelper.instance.insertEmbarazada(embarazada);
      }

      setState(() => _isLoading = false);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.embarazada == null ? 'Nueva Embarazada' : 'Editar Embarazada',
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre Completo *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese el nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _edadController,
                    decoration: const InputDecoration(
                      labelText: 'Edad *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cake),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cedulaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'DNI *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese el teléfono';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese la dirección';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Datos Sociodemográficos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _escolaridad,
              decoration: const InputDecoration(
                labelText: 'Escolaridad',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Primaria', child: Text('Primaria')),
                DropdownMenuItem(
                  value: 'Secundaria',
                  child: Text('Secundaria'),
                ),
                DropdownMenuItem(value: 'TM/PU', child: Text('TM/PU')),
                DropdownMenuItem(
                  value: 'Universitaria',
                  child: Text('Universitaria'),
                ),
              ],
              onChanged: (value) => setState(() => _escolaridad = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _estadoConyugal,
              decoration: const InputDecoration(
                labelText: 'Estado Conyugal',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Casada', child: Text('Casada')),
                DropdownMenuItem(value: 'Soltera', child: Text('Soltera')),
                DropdownMenuItem(value: 'Unión', child: Text('Unión')),
              ],
              onChanged: (value) => setState(() => _estadoConyugal = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _ocupacion,
              decoration: const InputDecoration(
                labelText: 'Ocupación',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Estudia', child: Text('Estudia')),
                DropdownMenuItem(value: 'Trabaja', child: Text('Trabaja')),
                DropdownMenuItem(
                  value: 'Ama de casa',
                  child: Text('Ama de casa'),
                ),
              ],
              onChanged: (value) => setState(() => _ocupacion = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _condicionesSocioeconomicas,
              decoration: const InputDecoration(
                labelText: 'Condiciones Socioeconómicas',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Buenas', child: Text('Buenas')),
                DropdownMenuItem(value: 'Regular', child: Text('Regular')),
                DropdownMenuItem(value: 'Mala', child: Text('Mala')),
              ],
              onChanged: (value) =>
                  setState(() => _condicionesSocioeconomicas = value),
            ),
            const SizedBox(height: 24),
            const Text(
              'Historia Obstétrica',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _embarazosController,
                    decoration: const InputDecoration(
                      labelText: 'Embarazos',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _partosController,
                    decoration: const InputDecoration(
                      labelText: 'Partos',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _abortosController,
                    decoration: const InputDecoration(
                      labelText: 'Abortos',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Datos Antropométricos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      hintText: 'Ej: 60',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _tallaController,
                    decoration: const InputDecoration(
                      labelText: 'Talla (m)',
                      border: OutlineInputBorder(),
                      hintText: 'Ej: 1.60',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Datos del Esposo/Pareja',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreEsposoController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Esposo/Pareja',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cedulaEsposoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'DNI',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ocupacionEsposoController,
              decoration: const InputDecoration(
                labelText: 'Ocupación',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Datos del Embarazo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cálculo desde FUM (Fecha Última Menstruación)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Fecha Última Menstruación'),
                      subtitle: Text(
                        _fechaUltimaMenstruacion != null
                            ? _fechaUltimaMenstruacion!.toString().split(' ')[0]
                            : 'No seleccionada',
                      ),
                      trailing: TextButton(
                        onPressed: () => _selectDate(context, true),
                        child: const Text('Seleccionar'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'O cálculo desde Ultrasonido',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.medical_services),
                      title: const Text('Fecha del Ultrasonido'),
                      subtitle: Text(
                        _fechaUltrasonido != null
                            ? _fechaUltrasonido!.toString().split(' ')[0]
                            : 'No seleccionada',
                      ),
                      trailing: TextButton(
                        onPressed: () => _selectDateUltrasonido(context),
                        child: const Text('Seleccionar'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tiempoGestacionalSemanasController,
                            decoration: const InputDecoration(
                              labelText: 'Semanas',
                              border: OutlineInputBorder(),
                              hintText: 'Ej: 12',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _calcularFPPDesdeUltrasonido(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _tiempoGestacionalDiasController,
                            decoration: const InputDecoration(
                              labelText: 'Días',
                              border: OutlineInputBorder(),
                              hintText: 'Ej: 3',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _calcularFPPDesdeUltrasonido(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.child_friendly),
              title: const Text('Fecha Probable de Parto'),
              subtitle: Text(
                _fechaProbableParto != null
                    ? _fechaProbableParto!.toString().split(' ')[0]
                    : 'No calculada',
              ),
              trailing: TextButton(
                onPressed: () => _selectDate(context, false),
                child: const Text('Manual'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Antecedentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _antecedentesFamiliaresController,
              decoration: const InputDecoration(
                labelText: 'Antecedentes Familiares',
                border: OutlineInputBorder(),
                hintText: 'Enfermedades familiares importantes',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _antecedentesPersonalesController,
              decoration: const InputDecoration(
                labelText: 'Antecedentes Personales',
                border: OutlineInputBorder(),
                hintText: 'Enfermedades, cirugías, alergias, etc.',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              'Otros Datos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _operacionesController,
              decoration: const InputDecoration(
                labelText: 'Operaciones',
                border: OutlineInputBorder(),
                hintText: 'Tipo de operación y fecha',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _transfusionesController,
              decoration: const InputDecoration(
                labelText: 'Transfusiones',
                border: OutlineInputBorder(),
                hintText: 'Fecha y reacción si hubo',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _citologiaController,
              decoration: const InputDecoration(
                labelText: 'Citología y Vacunación',
                border: OutlineInputBorder(),
                hintText:
                    'Fecha y resultado de citología. Vacunas recibidas o pendientes',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
            const Text(
              'Clasificación de Riesgo Obstétrico',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'ALTO RIESGO OBSTÉTRICO (ARO)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...Embarazada.factoresAroList.map((factor) {
                      return CheckboxListTile(
                        title: Text(
                          factor,
                          style: const TextStyle(fontSize: 13),
                        ),
                        value: _factoresAro.contains(factor),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _factoresAro.add(factor);
                            } else {
                              _factoresAro.remove(factor);
                            }
                          });
                        },
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'BAJO RIESGO OBSTÉTRICO (BRO)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...Embarazada.factoresBroList.map((factor) {
                      return CheckboxListTile(
                        title: Text(
                          factor,
                          style: const TextStyle(fontSize: 13),
                        ),
                        value: _factoresBro.contains(factor),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _factoresBro.add(factor);
                            } else {
                              _factoresBro.remove(factor);
                            }
                          });
                        },
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.local_hospital, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'INGRESADA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('HOMA'),
                            value: 'HOMA',
                            groupValue: _ingresada,
                            onChanged: (value) {
                              setState(() {
                                _ingresada = value;
                              });
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('HHB'),
                            value: 'HHB',
                            groupValue: _ingresada,
                            onChanged: (value) {
                              setState(() {
                                _ingresada = value;
                              });
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.embarazada == null ? 'REGISTRAR' : 'ACTUALIZAR',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
