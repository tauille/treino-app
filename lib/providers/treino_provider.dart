import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../models/treino_model.dart';
import '../models/api_response_model.dart';
import '../core/services/treino_service.dart';

class TreinoProvider with ChangeNotifier {
  // ESTADO DA LISTA DE TREINOS
  List<TreinoModel> _treinos = [];
  bool _isLoading = false;
  String? _error;

  // ESTADO DO TREINO INDIVIDUAL
  TreinoModel? _treinoAtual;
  bool _isLoadingTreino = false;

  // ESTADO DE CRIAÇÃO/EDIÇÃO
  bool _isSaving = false;

  // CONTROLE DE NOTIFICAÇÕES
  bool _isNotifying = false;

  // GETTERS
  List<TreinoModel> get treinos => _treinos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TreinoModel? get treinoAtual => _treinoAtual;
  bool get isLoadingTreino => _isLoadingTreino;
  bool get isSaving => _isSaving;

  // GETTERS ÚTEIS
  List<TreinoModel> get treinosAtivos => _treinos.where((t) => t.isAtivo).toList();
  int get totalTreinos => _treinos.length;
  int get totalTreinosAtivos => treinosAtivos.length;
  bool get hasError => _error != null;

  /// Listar treinos com filtros opcionais
  Future<ApiResponse<List<TreinoModel>>> listarTreinos({
    String? busca,
    String? dificuldade,
    String? tipoTreino,
    String? orderBy,
    String? orderDirection,
    int? perPage,
    bool forceRefresh = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await TreinoService.listarTreinos(
        busca: busca,
        dificuldade: dificuldade,
        tipoTreino: tipoTreino,
        orderBy: orderBy,
        orderDirection: orderDirection,
        perPage: perPage,
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        // Atualizar lista local
        _treinos = response.data!;
        _safeNotifyListeners();
        
        return ApiResponse.success(
          data: response.data!,
          message: response.message ?? 'Treinos carregados com sucesso',
        );
      } else {
        final errorMsg = response.message ?? 'Erro ao carregar treinos';
        _setError(errorMsg);
        
        return ApiResponse.error(
          message: errorMsg,
          errors: response.errors,
        );
      }
    } catch (e) {
      final errorMessage = 'Erro inesperado ao carregar treinos: $e';
      _setError(errorMessage);
      debugPrint('Erro em listarTreinos: $e');
      
      return ApiResponse.error(message: errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  /// Buscar treino por ID
  Future<ApiResponse<TreinoModel>> buscarTreino(int id) async {
    _setLoadingTreino(true);
    _clearError();

    try {
      final response = await TreinoService.buscarTreino(id);

      if (response.success && response.data != null) {
        _treinoAtual = response.data!;
        _safeNotifyListeners();
        
        return ApiResponse.success(
          data: response.data!,
          message: response.message ?? 'Treino carregado com sucesso',
        );
      } else {
        final errorMsg = response.message ?? 'Treino não encontrado';
        _setError(errorMsg);
        
        return ApiResponse.error(
          message: errorMsg,
          errors: response.errors,
        );
      }
    } catch (e) {
      final errorMessage = 'Erro inesperado ao buscar treino: $e';
      _setError(errorMessage);
      debugPrint('Erro em buscarTreino: $e');
      
      return ApiResponse.error(message: errorMessage);
    } finally {
      _setLoadingTreino(false);
    }
  }

  /// Criar novo treino
  Future<ApiResponse<TreinoModel>> criarTreino(TreinoModel treino) async {
    _setSaving(true);
    _clearError();

    try {
      final response = await TreinoService.criarTreino(treino);

      if (response.success && response.data != null) {
        // Adicionar à lista local
        _treinos.add(response.data!);
        _treinoAtual = response.data!;
        _safeNotifyListeners();
        
        return ApiResponse.success(
          data: response.data!,
          message: response.message ?? 'Treino criado com sucesso',
        );
      } else {
        final errorMsg = response.message ?? 'Erro ao criar treino';
        _setError(errorMsg);
        
        return ApiResponse.error(
          message: errorMsg,
          errors: response.errors,
        );
      }
    } catch (e) {
      final errorMessage = 'Erro inesperado ao criar treino: $e';
      _setError(errorMessage);
      debugPrint('Erro em criarTreino: $e');
      
      return ApiResponse.error(message: errorMessage);
    } finally {
      _setSaving(false);
    }
  }

  /// Atualizar treino existente
  Future<ApiResponse<TreinoModel>> atualizarTreino(TreinoModel treino) async {
    if (treino.id == null) {
      return ApiResponse.error(message: 'ID do treino é obrigatório para atualização');
    }

    _setSaving(true);
    _clearError();

    try {
      final response = await TreinoService.atualizarTreino(treino);

      if (response.success && response.data != null) {
        // Atualizar na lista local
        final index = _treinos.indexWhere((t) => t.id == treino.id);
        
        if (index != -1) {
          _treinos[index] = response.data!;
        } else {
          // Se não encontrar, adicionar (não deveria acontecer, mas é uma proteção)
          _treinos.add(response.data!);
        }
        
        // Atualizar treino atual se for o mesmo
        if (_treinoAtual?.id == treino.id) {
          _treinoAtual = response.data!;
        }
        
        _safeNotifyListeners();
        
        return ApiResponse.success(
          data: response.data!,
          message: response.message ?? 'Treino atualizado com sucesso',
        );
      } else {
        final errorMsg = response.message ?? 'Erro ao atualizar treino';
        _setError(errorMsg);
        
        return ApiResponse.error(
          message: errorMsg,
          errors: response.errors,
        );
      }
    } catch (e) {
      final errorMessage = 'Erro inesperado ao atualizar treino: $e';
      _setError(errorMessage);
      debugPrint('Erro em atualizarTreino: $e');
      
      return ApiResponse.error(message: errorMessage);
    } finally {
      _setSaving(false);
    }
  }

  /// Remover treino (soft delete)
  Future<ApiResponse<bool>> removerTreino(int id) async {
    _setSaving(true);
    _clearError();

    try {
      final response = await TreinoService.deletarTreino(id);

      if (response.success) {
        // Remover da lista local imediatamente
        _treinos.removeWhere((t) => t.id == id);
        
        // Se era o treino atual, limpar
        if (_treinoAtual?.id == id) {
          _treinoAtual = null;
        }
        
        _safeNotifyListeners();
        
        return ApiResponse.success(
          data: true,
          message: response.message ?? 'Treino removido com sucesso',
        );
      } else {
        final errorMsg = response.message ?? 'Erro ao remover treino';
        _setError(errorMsg);
        
        return ApiResponse.error(
          message: errorMsg,
          errors: response.errors,
        );
      }
    } catch (e) {
      final errorMessage = 'Erro inesperado ao remover treino: $e';
      _setError(errorMessage);
      debugPrint('Erro em removerTreino: $e');
      
      return ApiResponse.error(message: errorMessage);
    } finally {
      _setSaving(false);
    }
  }

  /// Listar treinos por dificuldade
  Future<ApiResponse<List<TreinoModel>>> listarTreinosPorDificuldade(String dificuldade) async {
    try {
      final response = await TreinoService.listarTreinosPorDificuldade(dificuldade);
      return response;
    } catch (e) {
      debugPrint('Erro em listarTreinosPorDificuldade: $e');
      return ApiResponse.error(message: 'Erro inesperado: $e');
    }
  }

  /// Buscar treinos (filtro local)
  List<TreinoModel> buscarTreinosLocal(String termo) {
    if (termo.isEmpty) return _treinos;
    
    final termoLower = termo.toLowerCase();
    return _treinos.where((treino) {
      return treino.nomeTreino.toLowerCase().contains(termoLower) ||
             treino.tipoTreino.toLowerCase().contains(termoLower) ||
             (treino.descricao?.toLowerCase().contains(termoLower) ?? false);
    }).toList();
  }

  /// Filtrar treinos por dificuldade (local)
  List<TreinoModel> filtrarPorDificuldade(String dificuldade) {
    return _treinos.where((treino) => treino.dificuldade == dificuldade).toList();
  }

  /// Filtrar treinos por tipo (local)
  List<TreinoModel> filtrarPorTipo(String tipo) {
    return _treinos.where((treino) => treino.tipoTreino == tipo).toList();
  }

  /// Recarregar lista de treinos
  Future<void> recarregar({bool forceRefresh = true}) async {
    await listarTreinos(forceRefresh: forceRefresh);
  }

  /// Limpar treino atual
  void limparTreinoAtual() {
    _treinoAtual = null;
    _safeNotifyListeners();
  }

  /// Limpar lista de treinos
  void limparTreinos() {
    _treinos.clear();
    _treinoAtual = null;
    _clearError();
    _safeNotifyListeners();
  }

  /// Inicializar provider (chamar no app startup)
  Future<void> inicializar() async {
    try {
      await listarTreinos();
    } catch (e) {
      debugPrint('Erro ao inicializar TreinoProvider: $e');
    }
  }

  /// Testar conexão com a API
  Future<bool> testarConexao() async {
    try {
      return await TreinoService.testarConexao();
    } catch (e) {
      return false;
    }
  }

  // MÉTODOS AUXILIARES PARA CONTROLE DE ESTADO

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _safeNotifyListeners();
    }
  }

  void _setLoadingTreino(bool loading) {
    if (_isLoadingTreino != loading) {
      _isLoadingTreino = loading;
      _safeNotifyListeners();
    }
  }

  void _setSaving(bool saving) {
    if (_isSaving != saving) {
      _isSaving = saving;
      _safeNotifyListeners();
    }
  }

  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      _safeNotifyListeners();
    }
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      _safeNotifyListeners();
    }
  }

  /// Método seguro para notificar listeners
  void _safeNotifyListeners() {
    if (_isNotifying) {
      return;
    }
    
    try {
      // Se estamos numa fase de build, agendar para depois
      if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
        _isNotifying = true;
        
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!_isNotifying) return;
          
          try {
            notifyListeners();
          } catch (e) {
            debugPrint('Erro ao notificar pós-build: $e');
          } finally {
            _isNotifying = false;
          }
        });
      } else {
        // Estamos em idle, pode notificar diretamente
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro em _safeNotifyListeners: $e');
      _isNotifying = false;
    }
  }

  // MÉTODOS UTILITÁRIOS

  /// Verificar se um treino existe na lista
  bool treinoExiste(int id) {
    return _treinos.any((treino) => treino.id == id);
  }

  /// Obter treino da lista por ID
  TreinoModel? obterTreinoPorId(int id) {
    try {
      return _treinos.firstWhere((treino) => treino.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obter estatísticas dos treinos
  Map<String, dynamic> obterEstatisticas() {
    final ativos = treinosAtivos;
    
    return {
      'total': _treinos.length,
      'ativos': ativos.length,
      'inativos': _treinos.length - ativos.length,
      'por_dificuldade': {
        'iniciante': ativos.where((t) => t.dificuldade == 'iniciante').length,
        'intermediario': ativos.where((t) => t.dificuldade == 'intermediario').length,
        'avancado': ativos.where((t) => t.dificuldade == 'avancado').length,
      },
      'tipos': ativos.map((t) => t.tipoTreino).toSet().toList(),
    };
  }

  /// Duplicar treino
  Future<ApiResponse<TreinoModel>> duplicarTreino(TreinoModel treino) async {
    try {
      final treinoDuplicado = TreinoModel.novo(
        nomeTreino: '${treino.nomeTreino} (Cópia)',
        tipoTreino: treino.tipoTreino,
        descricao: treino.descricao,
        dificuldade: treino.dificuldade,
        exercicios: treino.exercicios.map((e) => ExercicioModel.novo(
          nomeExercicio: e.nomeExercicio,
          descricao: e.descricao,
          grupoMuscular: e.grupoMuscular,
          tipoExecucao: e.tipoExecucao,
          repeticoes: e.repeticoes,
          series: e.series,
          tempoExecucao: e.tempoExecucao,
          tempoDescanso: e.tempoDescanso,
          peso: e.peso,
          unidadePeso: e.unidadePeso,
          observacoes: e.observacoes,
        )).toList(),
      );

      return await criarTreino(treinoDuplicado);
    } catch (e) {
      return ApiResponse.error(message: 'Erro ao duplicar treino: $e');
    }
  }

  /// Verificar se há dados carregados
  bool get temDados => _treinos.isNotEmpty;

  /// Verificar se está carregando algo
  bool get isCarregandoAlgo => _isLoading || _isLoadingTreino || _isSaving;

  /// Obter resumo do estado atual
  String get statusResumo {
    if (_isLoading) return 'Carregando treinos...';
    if (_isLoadingTreino) return 'Carregando detalhes...';
    if (_isSaving) return 'Salvando...';
    if (_error != null) return 'Erro: $_error';
    if (_treinos.isEmpty) return 'Nenhum treino encontrado';
    return '${_treinos.length} treinos carregados';
  }

  @override
  void dispose() {
    _treinos.clear();
    _treinoAtual = null;
    _error = null;
    _isNotifying = false;
    super.dispose();
  }

  // MÉTODOS PARA EXERCÍCIOS

  /// Listar exercícios de um treino
  Future<ApiResponse<List<ExercicioModel>>> listarExercicios(int treinoId) async {
    try {
      final response = await TreinoService.listarExercicios(treinoId);
      return response;
    } catch (e) {
      return ApiResponse.error(message: 'Erro inesperado: $e');
    }
  }

  /// Criar exercício
  Future<ApiResponse<ExercicioModel>> criarExercicio(int treinoId, ExercicioModel exercicio) async {
    _setSaving(true);
    _clearError();
    
    try {
      final response = await TreinoService.criarExercicio(treinoId, exercicio);
      
      if (response.success && response.data != null) {
        // Recarregar o treino atual se for o mesmo
        if (_treinoAtual?.id == treinoId) {
          final treinoAtualizado = await TreinoService.buscarTreino(treinoId);
          if (treinoAtualizado.success && treinoAtualizado.data != null) {
            _treinoAtual = treinoAtualizado.data!;
          }
        }
        
        // Também atualizar na lista geral se estiver carregada
        final index = _treinos.indexWhere((t) => t.id == treinoId);
        if (index != -1) {
          final treinoAtualizado = await TreinoService.buscarTreino(treinoId);
          if (treinoAtualizado.success && treinoAtualizado.data != null) {
            _treinos[index] = treinoAtualizado.data!;
          }
        }
        
        _safeNotifyListeners();
        
        return response;
      } else {
        final errorMsg = response.message ?? 'Erro ao criar exercício';
        _setError(errorMsg);
        return response;
      }
    } catch (e) {
      final errorMessage = 'Erro inesperado ao criar exercício: $e';
      _setError(errorMessage);
      return ApiResponse.error(message: errorMessage);
    } finally {
      _setSaving(false);
    }
  }

  /// Atualizar exercício
  Future<ApiResponse<ExercicioModel>> atualizarExercicio(
    int treinoId, 
    int exercicioId, 
    ExercicioModel exercicio
  ) async {
    _setSaving(true);
    _clearError();
    
    try {
      final response = await TreinoService.atualizarExercicio(treinoId, exercicioId, exercicio);
      
      if (response.success && response.data != null) {
        // Recarregar o treino atual
        if (_treinoAtual?.id == treinoId) {
          final treinoAtualizado = await TreinoService.buscarTreino(treinoId);
          if (treinoAtualizado.success && treinoAtualizado.data != null) {
            _treinoAtual = treinoAtualizado.data!;
          }
        }
        
        // Atualizar na lista geral
        final index = _treinos.indexWhere((t) => t.id == treinoId);
        if (index != -1) {
          final treinoAtualizado = await TreinoService.buscarTreino(treinoId);
          if (treinoAtualizado.success && treinoAtualizado.data != null) {
            _treinos[index] = treinoAtualizado.data!;
          }
        }
        
        _safeNotifyListeners();
        
        return response;
      } else {
        final errorMsg = response.message ?? 'Erro ao atualizar exercício';
        _setError(errorMsg);
        return response;
      }
    } catch (e) {
      final errorMessage = 'Erro inesperado ao atualizar exercício: $e';
      _setError(errorMessage);
      return ApiResponse.error(message: errorMessage);
    } finally {
      _setSaving(false);
    }
  }

  /// Deletar exercício
  Future<ApiResponse<bool>> deletarExercicio(int treinoId, int exercicioId) async {
    _setSaving(true);
    _clearError();
    
    try {
      final response = await TreinoService.deletarExercicio(treinoId, exercicioId);
      
      if (response.success) {
        // Recarregar o treino atual
        if (_treinoAtual?.id == treinoId) {
          final treinoAtualizado = await TreinoService.buscarTreino(treinoId);
          if (treinoAtualizado.success && treinoAtualizado.data != null) {
            _treinoAtual = treinoAtualizado.data!;
          }
        }
        
        // Também atualizar na lista geral
        final index = _treinos.indexWhere((t) => t.id == treinoId);
        if (index != -1) {
          final treinoAtualizado = await TreinoService.buscarTreino(treinoId);
          if (treinoAtualizado.success && treinoAtualizado.data != null) {
            _treinos[index] = treinoAtualizado.data!;
          }
        }
        
        _safeNotifyListeners();
        
        return response;
      } else {
        final errorMsg = response.message ?? 'Erro ao deletar exercício';
        _setError(errorMsg);
        return response;
      }
    } catch (e) {
      final errorMessage = 'Erro inesperado ao deletar exercício: $e';
      _setError(errorMessage);
      return ApiResponse.error(message: errorMessage);
    } finally {
      _setSaving(false);
    }
  }

  /// Reordenar exercícios
  Future<ApiResponse<bool>> reordenarExercicios(
    int treinoId,
    List<Map<String, dynamic>> exerciciosOrdenados,
  ) async {
    _setSaving(true);
    _clearError();
    
    try {
      final response = await TreinoService.reordenarExercicios(treinoId, exerciciosOrdenados);
      
      if (response.success) {
        // Recarregar o treino atual
        if (_treinoAtual?.id == treinoId) {
          final treinoAtualizado = await TreinoService.buscarTreino(treinoId);
          if (treinoAtualizado.success && treinoAtualizado.data != null) {
            _treinoAtual = treinoAtualizado.data!;
          }
        }
        
        // Atualizar na lista geral
        final index = _treinos.indexWhere((t) => t.id == treinoId);
        if (index != -1) {
          final treinoAtualizado = await TreinoService.buscarTreino(treinoId);
          if (treinoAtualizado.success && treinoAtualizado.data != null) {
            _treinos[index] = treinoAtualizado.data!;
          }
        }
        
        _safeNotifyListeners();
        
        return response;
      } else {
        final errorMsg = response.message ?? 'Erro ao reordenar exercícios';
        _setError(errorMsg);
        return response;
      }
    } catch (e) {
      final errorMessage = 'Erro inesperado ao reordenar exercícios: $e';
      _setError(errorMessage);
      return ApiResponse.error(message: errorMessage);
    } finally {
      _setSaving(false);
    }
  }
}