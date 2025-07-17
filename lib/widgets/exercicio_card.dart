import 'package:flutter/material.dart';
import '../models/execucao_treino.dart';
import '../models/execucao_exercicio.dart';

class ExercicioCard extends StatefulWidget {
  final ExercicioAtual exercicio;
  final ExecucaoExercicio? execucaoExercicio;
  final String tempoExercicio;
  final Function({
    int? series,
    int? repeticoes,
    double? peso,
    String? observacoes,
  }) onAtualizarProgresso;

  const ExercicioCard({
    Key? key,
    required this.exercicio,
    this.execucaoExercicio,
    required this.tempoExercicio,
    required this.onAtualizarProgresso,
  }) : super(key: key);

  @override
  State<ExercicioCard> createState() => _ExercicioCardState();
}

class _ExercicioCardState extends State<ExercicioCard> {
  late TextEditingController _seriesController;
  late TextEditingController _repeticoesController;
  late TextEditingController _pesoController;
  late TextEditingController _observacoesController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(ExercicioCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercicio.id != widget.exercicio.id) {
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    final realizado = widget.execucaoExercicio?.realizado;
    
    _seriesController = TextEditingController(
      text: realizado?.series?.toString() ?? '',
    );
    _repeticoesController = TextEditingController(
      text: realizado?.repeticoes?.toString() ?? '',
    );
    _pesoController = TextEditingController(
      text: realizado?.peso?.toString() ?? '',
    );
    _observacoesController = TextEditingController(
      text: widget.execucaoExercicio?.observacoes ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.blue.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 16),
            _buildInfo(),
            SizedBox(height: 16),
            _buildTimer(),
            SizedBox(height: 20),
            if (widget.exercicio.isPorRepeticao) _buildRepeticaoInputs(),
            if (widget.exercicio.isPorTempo) _buildTempoDisplay(),
            SizedBox(height: 16),
            _buildObservacoes(),
            SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.fitness_center,
            color: Colors.blue,
            size: 24,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.exercicio.nome,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.exercicio.grupoMuscular != null)
                Text(
                  widget.exercicio.grupoMuscular!,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.exercicio.isPorTempo ? Colors.orange : Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.exercicio.isPorTempo ? 'TEMPO' : 'REPS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Planejado',
                  widget.exercicio.tipoExecucaoTexto,
                  Icons.schedule,
                  Colors.blue,
                ),
              ),
              if (widget.exercicio.peso != null) ...[
                SizedBox(width: 12),
                Expanded(
                  child: _buildInfoItem(
                    'Peso',
                    widget.exercicio.pesoTexto,
                    Icons.fitness_center,
                    Colors.orange,
                  ),
                ),
              ],
            ],
          ),
          
          if (widget.exercicio.tempoDescanso != null) ...[
            SizedBox(height: 8),
            _buildInfoItem(
              'Descanso',
              widget.exercicio.tempoDescansoTexto,
              Icons.timer,
              Colors.green,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimer() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Text(
            'Tempo do Exercício',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          SizedBox(width: 12),
          Text(
            widget.tempoExercicio,
            style: TextStyle(
              color: Colors.green,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepeticaoInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progresso Realizado',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        
        Row(
          children: [
            // Séries
            Expanded(
              child: _buildInputField(
                controller: _seriesController,
                label: 'Séries',
                planned: widget.exercicio.series?.toString(),
                keyboardType: TextInputType.number,
                onChanged: (_) => _atualizarProgresso(),
              ),
            ),
            
            SizedBox(width: 12),
            
            // Repetições
            Expanded(
              child: _buildInputField(
                controller: _repeticoesController,
                label: 'Repetições',
                planned: widget.exercicio.repeticoes?.toString(),
                keyboardType: TextInputType.number,
                onChanged: (_) => _atualizarProgresso(),
              ),
            ),
            
            SizedBox(width: 12),
            
            // Peso
            Expanded(
              child: _buildInputField(
                controller: _pesoController,
                label: 'Peso (${widget.exercicio.unidadePeso ?? 'kg'})',
                planned: widget.exercicio.peso?.toString(),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _atualizarProgresso(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? planned,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
            if (planned != null) ...[
              SizedBox(width: 4),
              Text(
                '($planned)',
                style: TextStyle(
                  color: Colors.blue[300],
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue),
            ),
            filled: true,
            fillColor: Colors.grey[700],
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildTempoDisplay() {
    final tempoMeta = widget.exercicio.tempoExecucao;
    if (tempoMeta == null) return SizedBox.shrink();

    final tempoMetaFormatado = _formatarTempo(tempoMeta);
    final progresso = tempoMeta > 0 ? 
        (widget.execucaoExercicio?.realizado.tempoExecutado ?? 0) / tempoMeta : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progresso por Tempo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meta',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        tempoMetaFormatado,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Atual',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        widget.tempoExercicio,
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Barra de progresso
              LinearProgressIndicator(
                value: progresso.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[600],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progresso >= 1.0 ? Colors.green : Colors.orange,
                ),
              ),
              
              SizedBox(height: 8),
              
              Text(
                '${(progresso * 100).toStringAsFixed(0)}% completado',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildObservacoes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observações',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _observacoesController,
          maxLines: 2,
          style: TextStyle(color: Colors.white),
          onChanged: (_) => _atualizarProgresso(),
          decoration: InputDecoration(
            hintText: 'Como está se sentindo? Dificuldades? (opcional)',
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue),
            ),
            filled: true,
            fillColor: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Botão de ajuda/info
        IconButton(
          onPressed: _mostrarDetalhes,
          icon: Icon(Icons.info_outline, color: Colors.blue),
          tooltip: 'Detalhes do exercício',
        ),
        
        Spacer(),
        
        // Botão salvar progresso
        ElevatedButton.icon(
          onPressed: _atualizarProgresso,
          icon: Icon(Icons.save, size: 16),
          label: Text('Salvar Progresso'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  void _atualizarProgresso() {
    final series = int.tryParse(_seriesController.text);
    final repeticoes = int.tryParse(_repeticoesController.text);
    final peso = double.tryParse(_pesoController.text);
    final observacoes = _observacoesController.text.trim();

    widget.onAtualizarProgresso(
      series: series,
      repeticoes: repeticoes,
      peso: peso,
      observacoes: observacoes.isEmpty ? null : observacoes,
    );
  }

  void _mostrarDetalhes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text(
          widget.exercicio.nome,
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.exercicio.grupoMuscular != null) ...[
                _buildDetailItem('Grupo Muscular', widget.exercicio.grupoMuscular!),
                SizedBox(height: 8),
              ],
              
              _buildDetailItem('Tipo', widget.exercicio.tipoExecucaoTexto),
              SizedBox(height: 8),
              
              if (widget.exercicio.peso != null) ...[
                _buildDetailItem('Peso', widget.exercicio.pesoTexto),
                SizedBox(height: 8),
              ],
              
              _buildDetailItem('Descanso', widget.exercicio.tempoDescansoTexto),
              
              if (widget.exercicio.descricao != null) ...[
                SizedBox(height: 16),
                Text(
                  'Descrição:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.exercicio.descricao!,
                  style: TextStyle(color: Colors.grey[300]),
                ),
              ],
              
              if (widget.exercicio.observacoes != null) ...[
                SizedBox(height: 16),
                Text(
                  'Observações:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.exercicio.observacoes!,
                  style: TextStyle(color: Colors.grey[300]),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  String _formatarTempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segs = segundos % 60;
    return '${minutos}:${segs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _seriesController.dispose();
    _repeticoesController.dispose();
    _pesoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }
}