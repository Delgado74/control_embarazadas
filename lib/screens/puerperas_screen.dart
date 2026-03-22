import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/puerpera.dart';
import 'puerpera_detail.dart';
import 'puerpera_form.dart';
import 'package:intl/intl.dart';

class PuerperasScreen extends StatefulWidget {
  final String consultorio;
  final String medico;

  const PuerperasScreen({
    super.key,
    required this.consultorio,
    required this.medico,
  });

  @override
  State<PuerperasScreen> createState() => _PuerperasScreenState();
}

class _PuerperasScreenState extends State<PuerperasScreen> {
  List<Puerpera> _puerperas = [];
  bool _isLoading = true;
  bool _showInactivas = false;

  @override
  void initState() {
    super.initState();
    _loadPuerperas();
  }

  Future<void> _loadPuerperas() async {
    setState(() => _isLoading = true);
    _puerperas = await DatabaseHelper.instance.getAllPuerperas(
      soloActivas: !_showInactivas,
    );
    setState(() => _isLoading = false);
  }

  void _showPuerperaForm({Puerpera? puerpera}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PuerperaFormScreen(
          puerpera: puerpera,
          consultorio: widget.consultorio,
          medico: widget.medico,
        ),
      ),
    ).then((_) => _loadPuerperas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puérperas'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _showInactivas ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() => _showInactivas = !_showInactivas);
              _loadPuerperas();
            },
            tooltip: _showInactivas
                ? 'Ocultar finalizadas'
                : 'Mostrar finalizadas',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _puerperas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.post_add, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay puérperas registradas',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Las puérperas aparecen aquí cuando se registra\nel parto de una embarazada',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPuerperas,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _puerperas.length,
                itemBuilder: (context, index) {
                  final puerpera = _puerperas[index];
                  return _buildPuerperaCard(puerpera);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPuerperaForm(),
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPuerperaCard(Puerpera puerpera) {
    final diasPostParto = puerpera.diasPostParto;
    final estadoColor = diasPostParto <= 7
        ? Colors.red
        : diasPostParto <= 28
        ? Colors.orange
        : Colors.green;
    final estadoTexto = puerpera.estadoPuerperio;
    final fechaPartoFormatted = DateFormat(
      'dd/MM/yyyy',
    ).format(puerpera.fechaParto);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PuerperaDetailScreen(puerpera: puerpera),
            ),
          ).then((_) => _loadPuerperas());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: estadoColor.withValues(alpha: 0.2),
                    child: Icon(Icons.female, color: estadoColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      puerpera.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: estadoColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: estadoColor),
                    ),
                    child: Text(
                      '$diasPostParto días',
                      style: TextStyle(
                        color: estadoColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(Icons.calendar_today, fechaPartoFormatted),
                  _buildInfoChip(Icons.child_care, puerpera.tipoParto),
                  _buildInfoChip(Icons.timeline, estadoTexto),
                  _buildInfoChip(Icons.location_on, puerpera.consultorio),
                ],
              ),
              if (!puerpera.activa) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PERIODO DE PUERPERIO FINALIZADO',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ],
      ),
    );
  }
}
