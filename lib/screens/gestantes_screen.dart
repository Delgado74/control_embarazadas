import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/embarazada.dart';
import 'embarazada_form.dart';
import 'embarazada_detail.dart';

class GestantesScreen extends StatefulWidget {
  final String consultorio;
  final String medico;

  const GestantesScreen({
    super.key,
    required this.consultorio,
    required this.medico,
  });

  @override
  State<GestantesScreen> createState() => _GestantesScreenState();
}

class _GestantesScreenState extends State<GestantesScreen> {
  List<Embarazada> _embarazadas = [];
  bool _isLoading = true;
  String _filtroConsultorio = '';

  @override
  void initState() {
    super.initState();
    _loadEmbarazadas();
  }

  Future<void> _loadEmbarazadas() async {
    setState(() => _isLoading = true);
    if (_filtroConsultorio == 'TODOS') {
      _embarazadas = await DatabaseHelper.instance.getAllEmbarazadas();
    } else if (_filtroConsultorio.isNotEmpty) {
      _embarazadas = await DatabaseHelper.instance.getEmbarazadasByConsultorio(
        _filtroConsultorio,
      );
    } else {
      _embarazadas = await DatabaseHelper.instance.getEmbarazadasByConsultorio(
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
                _loadEmbarazadas();
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
              _loadEmbarazadas();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _showEstadisticasDialog() {
    final totalEmbarazadas = _embarazadas.length;
    final totalAro = _embarazadas
        .where((e) => (e.factoresAro != null && e.factoresAro!.isNotEmpty))
        .length;
    final totalBro = _embarazadas
        .where(
          (e) =>
              (e.factoresBro != null && e.factoresBro!.isNotEmpty) &&
              (e.factoresAro == null || e.factoresAro!.isEmpty),
        )
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEstadisticaCard(
              'Total Gestantes',
              totalEmbarazadas.toString(),
              Colors.blue,
              Icons.pregnant_woman,
            ),
            const SizedBox(height: 12),
            _buildEstadisticaCard(
              'Alto Riesgo Obstétrico (ARO)',
              totalAro.toString(),
              Colors.red,
              Icons.warning,
            ),
            const SizedBox(height: 12),
            _buildEstadisticaCard(
              'Bajo Riesgo Obstétrico (BRO)',
              totalBro.toString(),
              Colors.green,
              Icons.check_circle,
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    String titulo = 'Gestantes';
    if (_filtroConsultorio == 'TODOS') {
      titulo = 'Todas las Gestantes';
    } else if (_filtroConsultorio.isNotEmpty) {
      titulo = 'Gestantes: $_filtroConsultorio';
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
          : _embarazadas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.pregnant_woman,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay embarazadas registradas',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmbarazadaFormScreen(
                            consultorio: widget.consultorio,
                            medico: widget.medico,
                          ),
                        ),
                      ).then((_) => _loadEmbarazadas());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Embarazada'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _embarazadas.length,
              itemBuilder: (context, index) {
                final emp = _embarazadas[index];
                final bool esAro =
                    emp.factoresAro != null && emp.factoresAro!.isNotEmpty;
                final bool esBro =
                    emp.factoresBro != null && emp.factoresBro!.isNotEmpty;
                final bool ingresada = emp.ingresada != null;

                Color tarjetaColor = Colors.white;
                if (esAro) {
                  tarjetaColor = Colors.red.shade50;
                } else if (esBro) {
                  tarjetaColor = Colors.green.shade50;
                }

                return Card(
                  color: tarjetaColor,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EmbarazadaDetailScreen(embarazada: emp),
                        ),
                      ).then((_) => _loadEmbarazadas());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: esAro
                                    ? Colors.red.shade100
                                    : esBro
                                    ? Colors.green.shade100
                                    : Colors.blue.shade100,
                                child: Text(
                                  emp.nombre.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    color: esAro
                                        ? Colors.red
                                        : esBro
                                        ? Colors.green
                                        : Colors.blue,
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
                                      emp.nombre,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      emp.consultorio,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (esAro)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'ARO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else if (esBro)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'BRO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.child_friendly,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'FPP: ${emp.fechaProbableParto?.toString().split(' ')[0] ?? "No definida"}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              if (ingresada) ...[
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.local_hospital,
                                  size: 16,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  emp.ingresada!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
              builder: (context) => EmbarazadaFormScreen(
                consultorio: widget.consultorio,
                medico: widget.medico,
              ),
            ),
          ).then((_) => _loadEmbarazadas());
        },
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
