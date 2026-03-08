import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/lactante.dart';
import 'lactante_form.dart';
import 'lactante_detail.dart';

class LactantesScreen extends StatefulWidget {
  final String consultorio;
  final String medico;

  const LactantesScreen({
    super.key,
    required this.consultorio,
    required this.medico,
  });

  @override
  State<LactantesScreen> createState() => _LactantesScreenState();
}

class _LactantesScreenState extends State<LactantesScreen> {
  List<Lactante> _lactantes = [];
  bool _isLoading = true;
  String _filtroConsultorio = '';

  @override
  void initState() {
    super.initState();
    _loadLactantes();
  }

  Future<void> _loadLactantes() async {
    setState(() => _isLoading = true);
    if (_filtroConsultorio == 'TODOS') {
      _lactantes = await DatabaseHelper.instance.getAllLactantes();
    } else if (_filtroConsultorio.isNotEmpty) {
      _lactantes = await DatabaseHelper.instance.getLactantesByConsultorio(
        _filtroConsultorio,
      );
    } else {
      _lactantes = await DatabaseHelper.instance.getLactantesByConsultorio(
        widget.consultorio,
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showFiltroDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por Consultorio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todos'),
              leading: const Icon(Icons.list),
              selected: _filtroConsultorio == 'TODOS',
              onTap: () {
                setState(() => _filtroConsultorio = 'TODOS');
                Navigator.pop(context);
                _loadLactantes();
              },
            ),
            ListTile(
              title: const Text('Consultorio específico'),
              leading: const Icon(Icons.search),
              onTap: () {
                Navigator.pop(context);
                _showConsultorioInputDialog();
              },
            ),
            if (_filtroConsultorio.isNotEmpty && _filtroConsultorio != 'TODOS')
              ListTile(
                title: Text('Actual: $_filtroConsultorio'),
                leading: const Icon(Icons.check, color: Colors.green),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showConsultorioInputDialog() {
    final controller = TextEditingController(
      text: _filtroConsultorio == 'TODOS' ? '' : _filtroConsultorio,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ingrese el Consultorio'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre del Consultorio',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _filtroConsultorio = controller.text.trim());
              Navigator.pop(context);
              _loadLactantes();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String titulo = 'Lactantes';
    if (_filtroConsultorio == 'TODOS') {
      titulo = 'Todos los Lactantes';
    } else if (_filtroConsultorio.isNotEmpty) {
      titulo = 'Lactantes: $_filtroConsultorio';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _filtroConsultorio.isEmpty
                  ? Icons.filter_alt_outlined
                  : Icons.filter_alt,
            ),
            tooltip: 'Filtrar',
            onPressed: _showFiltroDialog,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _showEstadisticasDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lactantes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.child_care, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay lactantes registrados',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LactanteFormScreen(
                            consultorio: widget.consultorio,
                            medico: widget.medico,
                          ),
                        ),
                      ).then((_) => _loadLactantes());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Lactante'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _lactantes.length,
              itemBuilder: (context, index) {
                final lactante = _lactantes[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LactanteDetailScreen(lactante: lactante),
                        ),
                      ).then((_) => _loadLactantes());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              lactante.nombre.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lactante.nombre,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  lactante.consultorio,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'FN: ${lactante.fechaNacimiento.toString().split(' ')[0]}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  lactante.edadMesesString,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LactanteFormScreen(
                consultorio: widget.consultorio,
                medico: widget.medico,
              ),
            ),
          ).then((_) => _loadLactantes());
        },
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showEstadisticasDialog() {
    final totalLactantes = _lactantes.length;
    final menores3Meses = _lactantes.where((l) => l.edadMeses < 3).length;
    final de3a6Meses = _lactantes
        .where((l) => l.edadMeses >= 3 && l.edadMeses < 7)
        .length;
    final mayores6Meses = _lactantes.where((l) => l.edadMeses >= 7).length;

    final totalLME = _lactantes.where((l) => l.alimentacion == 'LME').length;
    final totalMixta = _lactantes
        .where((l) => l.alimentacion == 'Lactancia Mixta')
        .length;
    final totalComplementaria = _lactantes
        .where((l) => l.alimentacion == 'Lactancia Complementaria')
        .length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.blue),
            SizedBox(width: 8),
            Text('Estadísticas'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEstadisticaCard(
                'Total Lactantes',
                totalLactantes.toString(),
                Colors.blue,
                Icons.child_care,
              ),
              const SizedBox(height: 12),
              _buildEstadisticaCard(
                'Menores de 3 meses',
                menores3Meses.toString(),
                Colors.orange,
                Icons.child_friendly,
              ),
              const SizedBox(height: 12),
              _buildEstadisticaCard(
                'De 3 a 6 meses',
                de3a6Meses.toString(),
                Colors.green,
                Icons.child_care,
              ),
              const SizedBox(height: 12),
              _buildEstadisticaCard(
                '7 meses o más',
                mayores6Meses.toString(),
                Colors.purple,
                Icons.person,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Tipo de Alimentación',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildEstadisticaCard(
                'LME (Lactancia Materna Exclusiva)',
                totalLME.toString(),
                Colors.teal,
                Icons.local_hospital,
              ),
              const SizedBox(height: 12),
              _buildEstadisticaCard(
                'Lactancia Mixta',
                totalMixta.toString(),
                Colors.amber,
                Icons.local_drink,
              ),
              const SizedBox(height: 12),
              _buildEstadisticaCard(
                'Lactancia Complementaria',
                totalComplementaria.toString(),
                Colors.brown,
                Icons.restaurant,
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
}
