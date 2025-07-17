import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/execucao_treino.dart';
import '../models/execucao_exercicio.dart';
import '../services/execucao_treino_service.dart';

class ExecucaoTreinoProvider extends ChangeNotifier {
  final ExecucaoTreinoService _service;

  ExecucaoTreino? _execucaoAtual;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Timers
  Timer? _timerPrincipal;
  Timer? _timerExercicio;
  Timer? _timerDescanso;
  
  // Estados dos timers
  int _tempoTotalSegundos = 0;
  int _tempoExercicioSegundos = 0;
  int _tempoDescansoSegundos = 0;
  bool _emDescanso = false;
  
  // Estado atual
  TimerState _timerState = TimerState.parado;

  ExecucaoTreinoProvider(this._service);

  // Getters
  ExecucaoTreino? get execucaoAtual => _execucaoAtual;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasExecucao => _execucaoAtual != null;
  bool get emAndamento => _execucaoAtual?.isEmAndamento ?? false;
  bool get isPausado => _execucaoAtual?.isPausado ?? false;
  bool get isFinalizado => _execucaoAtual?.isFinalizado ?? false;
  
  // Timer getters
  int get tempoTotalSegundos => _tempoTotalSegundos;
  int get tempoExercicioSegundos => _tempoExercicioSegundos;
  int get tempoDescansoSegundos => _tempoDescansoSegundos;
  bool get emDescanso => _emDescanso;
  TimerState get timerState => _timerState;
  
  String get tempoTotalFormatado => _formatarTempo(_tempoTotalSegundos);
  String get tempoExercicioFormatado => _formatarTempo(_tempoExercicioSegundos);
  String get tempoDescansoFormatado => _formatarTempo(_tempoDescansoSegundos);

  // Exercício atual
  ExercicioAtual? get exercicioAtual => _execucaoAtual?.exercicioAtual;
  ExecucaoExercicio? get exercicioAtualExecucao => _execucaoAtual?.exercicioAtualExecucao;

  /// Iniciar novo treino
  Future<bool> iniciarTreino(int treinoId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _service.iniciarTreino(treinoId);
      
      if (response.isSuccess && response.data != null) {
        _execucaoAtual = response.data;
        _iniciarTimers();
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Erro ao iniciar treino: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Buscar execução atual
  Future<void> buscarExecucaoAtual() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _service.buscarExecucaoAtual();
      
      if (response.isSuccess && response.data != null) {
        _execucaoAtual = response.data;
        _sincronizarTimers();
        
        if (_execucaoAtual!.isEmAndamento) {
          _iniciarTimers();
        }
      } else if (response.isNotFound) {
        _execucaoAtual = null;
        _pararTimers();
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Erro ao buscar execução: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Pausar treino
  Future<bool> pausarTreino() async {
    if (_execucaoAtual == null) return false;

    _setLoading(true);
    
    try {
      final response = await _service.pausarTreino(_execucaoAtual!.id);
      
      if (response.isSuccess) {
        _execucaoAtual = _execucaoAtual!.copyWith(status: 'pausado');
        _pausarTimers();
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Erro ao pausar treino: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Retomar treino
  Future<bool> retomarTreino() async {
    if (_execucaoAtual == null) return false;

    _setLoading(true);
    
    try {
      final response = await _service.retomarTreino(_execucaoAtual!.id);
      
      if (response.isSuccess) {
        _execucaoAtual = _execucaoAtual!.copyWith(status: 'iniciado');
        _retomarTimers();
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Erro ao retomar treino: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Avançar para próximo exercício
  Future<bool> proximoExercicio() async {
    if (_execucaoAtual == null) return false;

    _setLoading(true);
    
    try {
      final response = await _service.proximoExercicio(_execucaoAtual!.id);
      
      if (response.isSuccess && response.data != null) {
        _execucaoAtual = response.data;
        _resetarTimerExercicio();
        _pararDescanso();
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Erro ao avançar exercício: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Voltar para exercício anterior
  Future<bool> exercicioAnterior() async {
    if (_execucaoAtual == null) return false;

    _setLoading(true);
    
    try {
      final response = await _service.exercicioAnterior(_execucaoAtual!.id);
      
      if (response.isSuccess && response.data != null) {
        _execucaoAtual = response.data;
        _resetarTimerExercicio();
        _pararDescanso();
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Erro ao voltar exercício: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Atualizar progresso do exercício
  Future<bool> atualizarExercicio({
    int? seriesRealizadas,
    int? repeticoesRealizadas,
    double? pesoUtilizado,
    String? observacoes,
  }) async {
    if (_execucaoAtual == null) return false;

    try {
      final atualizacao = AtualizacaoExercicio(
        seriesRealizadas: seriesRealizadas,
        repeticoesRealizadas: repeticoesRealizadas,
        pesoUtilizado: pesoUtilizado,
        tempoExecutadoSegundos: _tempoExercicioSegundos,
        observacoes: observacoes,
      );

      final response = await _service.atualizarExercicio(
        _execucaoAtual!.id,
        atualizacao,
      );

      if (response.isSuccess) {
        // Atualizar localmente (opcional, ou fazer nova busca)
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Erro ao atualizar exercício: $e');
      return false;
    }
  }

  /// Finalizar treino
  Future<bool> finalizarTreino({String? observacoes}) async {
    if (_execucaoAtual == null) return false;

    _setLoading(true);
    
    try {
      final response = await _service.finalizarTreino(
        _execucaoAtual!.id,
        observacoes: observacoes,
        tempoTotalSegundos: _tempoTotalSegundos,
      );
      
      if (response.isSuccess && response.data != null) {
        _execucaoAtual = response.data;
        _pararTimers();
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Erro ao finalizar treino: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cancelar treino
  Future<bool> cancelarTreino() async {
    if (_execucaoAtual == null) return false;

    _setLoading(true);
    
    try {
      final response = await _service.cancelarTreino(_execucaoAtual!.id);
      
      if (response.isSuccess) {
        _execucaoAtual = null;
        _pararTimers();
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Erro ao cancelar treino: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Iniciar período de descanso
  void iniciarDescanso() {
    if (exercicioAtual?.tempoDescanso == null) return;

    _emDescanso = true;
    _tempoDescansoSegundos = exercicioAtual!.tempoDescanso!;
    
    _timerDescanso = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_tempoDescansoSegundos > 0) {
        _tempoDescansoSegundos--;
        notifyListeners();
      } else {
        _pararDescanso();
      }
    });
    
    notifyListeners();
  }

  /// Pular descanso
  void pularDescanso() {
    _pararDescanso();
  }

  /// Limpar estado (logout, etc)
  void limpar() {
    _execucaoAtual = null;
    _pararTimers();
    _clearError();
    notifyListeners();
  }

  // Métodos privados

  void _iniciarTimers() {
    _pararTimers();
    _timerState = TimerState.rodando;

    // Timer principal (tempo total do treino)
    _timerPrincipal = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timerState == TimerState.rodando) {
        _tempoTotalSegundos++;
        notifyListeners();
      }
    });

    // Timer do exercício atual
    _timerExercicio = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timerState == TimerState.rodando && !_emDescanso) {
        _tempoExercicioSegundos++;
        notifyListeners();
      }
    });
  }

  void _pausarTimers() {
    _timerState = TimerState.pausado;
  }

  void _retomarTimers() {
    _timerState = TimerState.rodando;
  }

  void _pararTimers() {
    _timerState = TimerState.parado;
    _timerPrincipal?.cancel();
    _timerExercicio?.cancel();
    _pararDescanso();
    _timerPrincipal = null;
    _timerExercicio = null;
  }

  void _pararDescanso() {
    _timerDescanso?.cancel();
    _timerDescanso = null;
    _emDescanso = false;
    _tempoDescansoSegundos = 0;
  }

  void _resetarTimerExercicio() {
    _tempoExercicioSegundos = 0;
  }

  void _sincronizarTimers() {
    if (_execucaoAtual != null) {
      _tempoTotalSegundos = _execucaoAtual!.tempos.tempoTotalSegundos;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _formatarTempo(int segundos) {
    final horas = segundos ~/ 3600;
    final minutos = (segundos % 3600) ~/ 60;
    final segs = segundos % 60;

    if (horas > 0) {
      return '${horas.toString().padLeft(2, '0')}:'
             '${minutos.toString().padLeft(2, '0')}:'
             '${segs.toString().padLeft(2, '0')}';
    }

    return '${minutos.toString().padLeft(2, '0')}:'
           '${segs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _pararTimers();
    super.dispose();
  }
}

enum TimerState {
  parado,
  rodando,
  pausado,
}

// Extension para facilitar o copy do ExecucaoTreino (caso não tenha)
extension ExecucaoTreinoCopy on ExecucaoTreino {
  ExecucaoTreino copyWith({
    String? status,
  }) {
    return ExecucaoTreino(
      id: id,
      status: status ?? this.status,
      treino: treino,
      progresso: progresso,
      tempos: tempos,
      exercicioAtual: exercicioAtual,
      exercicios: exercicios,
    );
  }
}