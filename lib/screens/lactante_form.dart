import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/lactante.dart';

class LactanteFormScreen extends StatefulWidget {
  final Lactante? lactante;
  final String consultorio;
  final String medico;

  const LactanteFormScreen({
    super.key,
    this.lactante,
    required this.consultorio,
    required this.medico,
  });

  @override
  State<LactanteFormScreen> createState() => _LactanteFormScreenState();
}

class _LactanteFormScreenState extends State<LactanteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _nombreMadreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _consultasPrenatalesController = TextEditingController();
  final _clasificacionRiesgoController = TextEditingController();
  final _diagnosticosEmbarazoController = TextEditingController();
  final _egPartoController = TextEditingController();
  final _pesoNacerController = TextEditingController();
  final _tallaNacerController = TextEditingController();
  final _ccNacerController = TextEditingController();
  final _ctNacerController = TextEditingController();
  final _apgarController = TextEditingController();
  final _antecedentesFamiliaresController = TextEditingController();

  DateTime? _fechaNacimiento;
  DateTime _fechaRegistro = DateTime.now();
  String? _sexo;
  String? _lugarParto;
  String? _tipoParto;
  String? _caracteristicasRn;
  String? _clasificacion;
  String? _valoracionNutricional;
  String? _alimentacion;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.lactante != null) {
      _nombreController.text = widget.lactante!.nombre;
      _nombreMadreController.text = widget.lactante!.nombreMadre;
      _direccionController.text = widget.lactante!.direccion ?? '';
      _telefonoController.text = widget.lactante!.telefono ?? '';
      _fechaNacimiento = widget.lactante!.fechaNacimiento;
      _fechaRegistro = widget.lactante!.fechaRegistro;
      _sexo = widget.lactante!.sexo;
      if (widget.lactante!.numeroConsultasPrenatales != null) {
        _consultasPrenatalesController.text = widget
            .lactante!
            .numeroConsultasPrenatales
            .toString();
      }
      _clasificacionRiesgoController.text =
          widget.lactante!.clasificacionRiesgoObstetrico ?? '';
      _diagnosticosEmbarazoController.text =
          widget.lactante!.diagnosticosEmbarazo ?? '';
      if (widget.lactante!.egParto != null) {
        _egPartoController.text = widget.lactante!.egParto.toString();
      }
      _lugarParto = widget.lactante!.lugarParto;
      _tipoParto = widget.lactante!.tipoParto;
      _caracteristicasRn = widget.lactante!.caracteristicasRn;
      if (widget.lactante!.pesoNacer != null) {
        _pesoNacerController.text = widget.lactante!.pesoNacer.toString();
      }
      if (widget.lactante!.tallaNacer != null) {
        _tallaNacerController.text = widget.lactante!.tallaNacer.toString();
      }
      if (widget.lactante!.ccNacer != null) {
        _ccNacerController.text = widget.lactante!.ccNacer.toString();
      }
      if (widget.lactante!.ctNacer != null) {
        _ctNacerController.text = widget.lactante!.ctNacer.toString();
      }
      if (widget.lactante!.apgar != null) {
        _apgarController.text = widget.lactante!.apgar!;
      }
      _antecedentesFamiliaresController.text =
          widget.lactante!.antecedentesFamiliares ?? '';
      _clasificacion = widget.lactante!.clasificacion;
      _valoracionNutricional = widget.lactante!.valoracionNutricional;
      _alimentacion = widget.lactante!.alimentacion;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isNacimiento) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isNacimiento
          ? (_fechaNacimiento ?? DateTime.now())
          : _fechaRegistro,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isNacimiento) {
          _fechaNacimiento = picked;
        } else {
          _fechaRegistro = picked;
        }
      });
    }
  }

  Future<void> _saveLactante() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar la fecha de nacimiento'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final lactante = Lactante(
      id: widget.lactante?.id ?? const Uuid().v4(),
      nombre: _nombreController.text.trim(),
      fechaNacimiento: _fechaNacimiento!,
      nombreMadre: _nombreMadreController.text.trim(),
      direccion: _direccionController.text.trim().isEmpty
          ? null
          : _direccionController.text.trim(),
      telefono: _telefonoController.text.trim().isEmpty
          ? null
          : _telefonoController.text.trim(),
      consultorio: widget.consultorio,
      medico: widget.medico,
      fechaRegistro: widget.lactante?.fechaRegistro ?? _fechaRegistro,
      sexo: _sexo,
      numeroConsultasPrenatales: int.tryParse(
        _consultasPrenatalesController.text,
      ),
      clasificacionRiesgoObstetrico:
          _clasificacionRiesgoController.text.trim().isEmpty
          ? null
          : _clasificacionRiesgoController.text.trim(),
      diagnosticosEmbarazo: _diagnosticosEmbarazoController.text.trim().isEmpty
          ? null
          : _diagnosticosEmbarazoController.text.trim(),
      egParto: double.tryParse(_egPartoController.text.replaceAll(',', '.')),
      lugarParto: _lugarParto,
      tipoParto: _tipoParto,
      caracteristicasRn: _caracteristicasRn,
      pesoNacer: double.tryParse(_pesoNacerController.text),
      tallaNacer: double.tryParse(_tallaNacerController.text),
      ccNacer: double.tryParse(_ccNacerController.text),
      ctNacer: double.tryParse(_ctNacerController.text),
      apgar: _apgarController.text.trim().isEmpty
          ? null
          : _apgarController.text.trim(),
      antecedentesFamiliares:
          _antecedentesFamiliaresController.text.trim().isEmpty
          ? null
          : _antecedentesFamiliaresController.text.trim(),
      clasificacion: _clasificacion,
      valoracionNutricional: _valoracionNutricional,
      alimentacion: _alimentacion,
    );

    if (widget.lactante != null) {
      await DatabaseHelper.instance.updateLactante(lactante);
    } else {
      await DatabaseHelper.instance.insertLactante(lactante);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lactante != null ? 'Editar Lactante' : 'Nuevo Lactante',
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
                  _buildSectionTitle('Datos del Lactante'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo del lactante *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.trim().isEmpty == true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _sexo,
                          decoration: const InputDecoration(
                            labelText: 'Sexo',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'M',
                              child: Text('Masculino'),
                            ),
                            DropdownMenuItem(
                              value: 'F',
                              child: Text('Femenino'),
                            ),
                          ],
                          onChanged: (value) => setState(() => _sexo = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fecha de nacimiento *',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _fechaNacimiento != null
                                  ? _fechaNacimiento!.toString().split(' ')[0]
                                  : 'Seleccionar',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Datos de la Madre'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nombreMadreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la madre *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.trim().isEmpty == true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _direccionController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono de familia',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Antecedentes Prenatales'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _consultasPrenatalesController,
                    decoration: const InputDecoration(
                      labelText: 'Número de consultas prenatales',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _clasificacionRiesgoController,
                    decoration: const InputDecoration(
                      labelText: 'Clasificación de riesgo obstétrico',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _diagnosticosEmbarazoController,
                    decoration: const InputDecoration(
                      labelText:
                          'Diagnósticos más importantes durante el embarazo',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Antecedentes Natales'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _egPartoController,
                          decoration: const InputDecoration(
                            labelText: 'EG del parto (semanas)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _lugarParto,
                          decoration: const InputDecoration(
                            labelText: 'Lugar del parto',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Institucional',
                              child: Text('Institucional'),
                            ),
                            DropdownMenuItem(
                              value: 'Extrahospitalario',
                              child: Text('Extrahospitalario'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _lugarParto = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _tipoParto,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de parto',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Eutocico',
                              child: Text('Eutócico'),
                            ),
                            DropdownMenuItem(
                              value: 'Cesarea',
                              child: Text('Cesárea'),
                            ),
                            DropdownMenuItem(
                              value: 'Instrumentado',
                              child: Text('Instrumentado'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _tipoParto = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _caracteristicasRn,
                          decoration: const InputDecoration(
                            labelText: 'Características del RN',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Normal',
                              child: Text('Normal'),
                            ),
                            DropdownMenuItem(
                              value: 'Deprimido',
                              child: Text('Deprimido'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _caracteristicasRn = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Antecedentes Postnatales'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _pesoNacerController,
                          decoration: const InputDecoration(
                            labelText: 'Peso al nacer (g)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _tallaNacerController,
                          decoration: const InputDecoration(
                            labelText: 'Talla al nacer (cm)',
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
                        child: TextFormField(
                          controller: _ccNacerController,
                          decoration: const InputDecoration(
                            labelText: 'CC al nacer (cm)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _ctNacerController,
                          decoration: const InputDecoration(
                            labelText: 'CT al nacer (cm)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _apgarController,
                    decoration: const InputDecoration(
                      labelText: 'Apgar (ej: 9/9)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Antecedentes Familiares'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _antecedentesFamiliaresController,
                    decoration: const InputDecoration(
                      labelText: 'Antecedentes familiares',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Clasificación y Estado Nutricional'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _clasificacion,
                    decoration: const InputDecoration(
                      labelText: 'Clasificación',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Sano', child: Text('Sano')),
                      DropdownMenuItem(
                        value: 'Con riesgo',
                        child: Text('Con riesgo'),
                      ),
                      DropdownMenuItem(
                        value: 'Enfermo',
                        child: Text('Enfermo'),
                      ),
                      DropdownMenuItem(
                        value: 'Con discapacidad',
                        child: Text('Con discapacidad'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _clasificacion = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _valoracionNutricional,
                    decoration: const InputDecoration(
                      labelText: 'Valoración nutricional',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Desnutrido',
                        child: Text('Desnutrido'),
                      ),
                      DropdownMenuItem(
                        value: 'Delgado',
                        child: Text('Delgado'),
                      ),
                      DropdownMenuItem(
                        value: 'Normopeso',
                        child: Text('Normopeso'),
                      ),
                      DropdownMenuItem(
                        value: 'Sobrepeso',
                        child: Text('Sobrepeso'),
                      ),
                      DropdownMenuItem(value: 'Obeso', child: Text('Obeso')),
                    ],
                    onChanged: (value) =>
                        setState(() => _valoracionNutricional = value),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _alimentacion,
                    decoration: const InputDecoration(
                      labelText: 'Alimentación',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'LME',
                        child: Text('LME (Lactancia Materna Exclusiva)'),
                      ),
                      DropdownMenuItem(
                        value: 'Lactancia Mixta',
                        child: Text('Lactancia Mixta'),
                      ),
                      DropdownMenuItem(
                        value: 'Lactancia Complementaria',
                        child: Text('Lactancia Complementaria'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _alimentacion = value),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveLactante,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.lactante != null ? 'Actualizar' : 'Guardar',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1565C0),
      ),
    );
  }
}
