import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../models/treino_model.dart';
import '../models/api_response_model.dart';
import '../core/services/treino_service.dart';

class TreinoProvider with ChangeNotifier {
  // ===== ESTADO DA LISTA DE TREINOS =====
  List<TreinoModel> _treinos = [];
  bool _isLoading = false;
  String? _error;

  // ===== ESTADO DO TREINO INDIVIDUAL =====
  TreinoModel? _treinoAtual;
  bool _isLoadingTreino = false;

  // ===== ESTADO DE CRIAÇÃO/EDIÇÃO =====
  bool _isSaving = false;

  // ===== CONTROLE DE NOTIFICAÇÕES =====
  bool _isNotifying = false;

  // ===== GETTERS =====
  List<TreinoModel> get treinos => _treinos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TreinoModel? get treinoAtual => _treinoAtual;
  bool get isLoadingTreino => _isLoadingTreino;
  bool get isSaving => _isSaving;

  // ===== GETTERS ÚTEIS =====
  List<TreinoModel> get treinosAtivos => _treinos.where((t) => t.isAtivo).toList();
  int get totalTreinos => _treinos.length;
  int get totalTreinosAtivos => treinosAtivos.length;
  bool get hasError => _error != null;

  // ===== MÉTODO PRINCIPAL CORRIGIDO COM FORCE REFRESH =====
  
  /// Listar treinos com filtros opcionais - CORRIGIDO COM forceRefresh
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
      print('🔍 PROVIDER: Carregando treinos...');
      print('📋 PROVIDER: Filtros: busca=$busca, dificuldade=$dificuldade, tipo=$tipoTreino');
      print('🔄 PROVIDER: ForceRefresh: $forceRefresh');

      // ===== CORREÇÃO: USAR MÉTODO ESTÁTICO COM FORCE REFRESH =====
      final response = await TreinoService.listarTreinos(
        busca: busca,
        dificuldade: dificuldade,
        tipoTreino: tipoTreino,
        orderBy: orderBy,
        orderDirection: orderDirection,
        perPage: perPage,
        forceRefresh: forceRefresh,
      );

      print('📊 PROVIDER: Resposta da API: success=${response.success}');
      print('📦 PROVIDER: Total de treinos: ${response.data?.length ?? 0}');

      if (response.success && response.data != null) {
        // Atualizar lista local
        _treinos = response.data!;
        _safeNotifyListeners();
        
        print('✅ PROVIDER: Lista atualizada com ${_treinos.length} treinos');
        
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
      debugPrint('❌ Erro em listarTreinos: $e');
      
      return ApiResponse.error(message: errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  /// Buscar treino por ID - CORRIGIDO COM SAFE NOTIFY
  Future<ApiResponse<TreinoModel>> buscarTreino(int id) async {
    _setLoadingTreino(true);
    _clearError();

    try {
      print('🔍 PROVIDER: Buscando treino ID: $id');

      // ===== CORREÇÃO: USAR MÉTODO ESTÁTICO =====
      final response = await TreinoService.buscarTreino(id);

      if (response.success && response.data != null) {
        _treinoAtual = response.data!;
        _safeNotifyListeners();
        
        print('✅ PROVIDER: Treino encontrado: ${response.data!.nomeTreino}');
        
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
      debugPrint('❌ Erro em buscarTreino: $e');
      
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
      print('🚀 PROVIDER: Criando treino: ${treino.nomeTreino}');

      // ===== CORREÇÃO: USAR MÉTODO ESTÁTICO =====
      final response = await TreinoService.criarTreino(treino);

      if (response.success && response.data != null) {
        // Adicionar à lista local
        _treinos.add(response.data!);
        _treinoAtual = response.data!;
        _safeNotifyListeners();
        
        print('✅ PROVIDER: Treino criado com sucesso: ${response.data!.nomeTreino}');
        
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
      debugPrint('❌ Erro em criarTreino: $e');
      
      return ApiResponse.error(message: errorMessage);
    } finally {
      _setSaving(false);
    }
  }

  /// ATUALIZAR TREINO - VERSÃO CORRIGIDA COM DEBUG COMPLETO
  Future<ApiResponse<TreinoModel>> atualizarTreino(TreinoModel treino) async {
    if (treino.id == null) {
      print('❌ PROVIDER: ID do treino é null');
      return ApiResponse.error(message: 'ID do treino é obrigatório para atualização');
    }

    print('🔄 PROVIDER: INICIANDO atualização do treino:');
    print('   • ID: ${treino.id}');
    print('   • Nome: ${treino.nomeTreino}');
    print('   • Tipo: ${treino.tipoTreino}');
    print('   • Dificuldade: ${treino.dificuldade}');

    _setSaving(true);
    _clearError();

    try {
      // ✅ CHAMAR O SERVICE
      final response = await TreinoService.atualizarTreino(treino);

      print('🔥 PROVIDER: RESPOSTA do service:');
      print('   • Success: ${response.success}');
      print('   • Data: ${response.data?.nomeTreino ?? 'null'}');
      print('   • Message: ${response.message}');

      if (response.success && response.data != null) {
        print('✅ PROVIDER: Atualizando lista local...');
        
        // ✅ ATUALIZAR NA LISTA LOCAL
        final index = _treinos.indexWhere((t) => t.id == treino.id);
        print('🔍 PROVIDER: Índice na lista: $index (de ${_treinos.length} treinos)');
        
        if (index != -1) {
          // ✅ SUBSTITUIR O TREINO NA LISTA
          final treinoAntigo = _treinos[index];
          _treinos[index] = response.data!;
          
          print('🔄 PROVIDER: Treino substituído:');
          print('   • Antigo: ${treinoAntigo.nomeTreino}');
          print('   • Novo: ${response.data!.nomeTreino}');
        } else {
          print('⚠️ PROVIDER: AVISO: Treino com ID ${treino.id} não encontrado na lista local');
          // ✅ SE NÃO ENCONTRAR, ADICIONAR (não deveria acontecer, mas é uma proteção)
          _treinos.add(response.data!);
        }
        
        // ✅ ATUALIZAR TREINO ATUAL SE FOR O MESMO
        if (_treinoAtual?.id == treino.id) {
          _treinoAtual = response.data!;
          print('🔄 PROVIDER: Treino atual também atualizado');
        }
        
        // ✅ NOTIFICAR LISTENERS COM PROTEÇÃO
        _safeNotifyListeners();
        print('📢 PROVIDER: Listeners notificados');
        
        return ApiResponse.success(
          data: response.data!,
          message: response.message ?? 'Treino atualizado com sucesso',
        );
      } else {
        final errorMsg = response.message ?? 'Erro ao atualizar treino';
        print('❌ PROVIDER: ERRO na resposta: $errorMsg');
        _setError(errorMsg);
        
        return ApiResponse.error(
          message: errorMsg,
          errors: response.errors,
        );
      }
    } catch (e) {
      final errorMessage = 'Erro inesperado ao atualizar treino: $e';
      print('❌ PROVIDER: EXCEÇÃO: $errorMessage');
      _setError(errorMessage);
      debugPrint('❌ Erro em atualizarTreino: $e');
      
      return ApiResponse.error(message: errorMessage);
    } finally {
      _setSaving(false);
      print('🏁 PROVIDER: Finalizado atualizarTreino');
    }
  }

  /// Remover treino (soft delete) - CORRIGIDO COM INVALIDAÇÃO DE CACHE
  Future<ApiResponse<bool>> removerTreino(int id) async {
    _setSaving(true);
    _clearError();

    try {
      print('🗑️ PROVIDER: Removendo treino ID: $id');

      // ===== CORREÇÃO: USAR deletarTreino (MÉTODO CORRETO NO SERVICE) =====
      final response = await TreinoService.deletarTreino(id);

      print('📱 PROVIDER: Resultado da exclusão: success=${response.success}, message=${response.message}');

      if (response.success) {
        // REMOVER DA LISTA LOCAL IMEDIATAMENTE
        final treinoRemovido = _treinos.firstWhere((t) => t.id == id, orElse: () => throw StateError('Treino não encontrado'));
        _treinos.removeWhere((t) => t.id == id);
        print('✅ PROVIDER: Treino "${treinoRemovido.nomeTreino}" removido da lista local');
        
        // Se era o treino atual, limpar
        if (_treinoAtual?.id == id) {
          _treinoAtual = null;
          print('🧹 PROVIDER: Treino atual limpo');
        }
        
        // NOTIFICAR COM PROTEÇÃO - CRÍTICO!
        _safeNotifyListeners();
        print('📢 PROVIDER: Listeners notificados - UI deve atualizar');
        
        print('✅ PROVIDER: Treino removido com sucesso');
        
        return ApiResponse.success(
          data: true,
          message: response.message ?? 'Treino removido com sucesso',
        );
      } else {
        final errorMsg = response.message ?? 'Erro ao remover treino';
        print('❌ PROVIDER: Erro na exclusão: $errorMsg');
        _setError(errorMsg);
        
        return ApiResponse.error(
          message: errorMsg,
          errors: response.errors,
        );
      }
    } catch (e) {
      final errorMessage = 'Erro inesperado ao remover treino: $e';
      print('❌ PROVIDER: Exceção na exclusão: $errorMessage');
      _setError(errorMessage);
      debugPrint('❌ Erro em removerTreino: $e');
      
      return ApiResponse.error(message: errorMessage);
    } finally {
      _setSaving(false);
    }
  }

  /// Listar treinos por dificuldade
  Future<ApiResponse<List<TreinoModel>>> listarTreinosPorDificuldade(String dificuldade) async {
    try {
      // ===== CORREÇÃO: USAR MÉTODO ESTÁTICO =====
      final response = await TreinoService.listarTreinosPorDificuldade(dificuldade);
      
      if (response.success && response.data != null) {
        // Opcionalmente atualizar lista local com filtro
        // _treinos = response.data!;
        // _safeNotifyListeners();
      }
      
      return response;
    } catch (e) {
      debugPrint('❌ Erro em listarTreinosPorDificuldade: $e');
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

  /// Recarregar lista de treinos - CORRIGIDO COM FORCE REFRESH
  Future<void> recarregar({bool forceRefresh = true}) async {
    print('🔄 PROVIDER: Recarregando lista...');
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
      print('✅ TreinoProvider inicializado com sucesso');
    } catch (e) {
      print('❌ Erro ao inicializar TreinoProvider: $e');
    }
  }

  /// Testar conexão com a API
  Future<bool> testarConexao() async {
    try {
      return await TreinoService.testarConexao();
    } catch (e) {
      print('❌ Erro no teste de conexão: $e');
      return false;
    }
  }

  // ===== MÉTODOS AUXILIARES PARA CONTROLE DE ESTADO - CORRIGIDOS =====

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

  /// ✅ MÉTODO SEGURO PARA NOTIFICAR LISTENERS - SOLUÇÃO DO ERRO BUILD
  void _safeNotifyListeners() {
    if (_isNotifying) {
      print('⚠️ PROVIDER: Já notificando, ignorando duplicata');
      return;
    }
    
    try {
      // Se estamos numa fase de build, agendar para depois
      if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
        print('🔄 PROVIDER: Agendando notificação para pós-build...');
        _isNotifying = true;
        
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!_isNotifying) return; // Evitar dupla notificação
          
          try {
            print('📢 PROVIDER: Notificando listeners pós-build');
            notifyListeners();
          } catch (e) {
            print('❌ PROVIDER: Erro ao notificar pós-build: $e');
          } finally {
            _isNotifying = false;
          }
        });
      } else {
        // Estamos em idle, pode notificar diretamente
        print('📢 PROVIDER: Notificando listeners diretamente');
        notifyListeners();
      }
    } catch (e) {
      print('❌ PROVIDER: Erro em _safeNotifyListeners: $e');
      _isNotifying = false;
    }
  }

  // ===== MÉTODOS UTILITÁRIOS =====

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
    print('🧹 Limpando TreinoProvider...');
    _treinos.clear();
    _treinoAtual = null;
    _error = null;
    _isNotifying = false;
    super.dispose();
  }

  // ===== DEBUG E LOGS =====
  
  void _logEstado(String operacao) {
    if (kDebugMode) {
      print('📊 [$operacao] TreinoProvider State:');
      print('   • Treinos: ${_treinos.length}');
      print('   • Loading: $_isLoading');
      print('   • Error: $_error');
      print('   • Atual: ${_treinoAtual?.nomeTreino ?? 'null'}');
    }
  }

  // ========================================================================
  // MÉTODOS PARA EXERCÍCIOS - VERSÃO CORRIGIDA COM SAFE NOTIFY
  // ========================================================================

  /// LISTAR EXERCÍCIOS DE UM TREINO
  Future<ApiResponse<List<ExercicioModel>>> listarExercicios(int treinoId) async {
    try {
      print('📋 PROVIDER: Listando exercícios do treino $treinoId');
      
      final response = await TreinoService.listarExercicios(treinoId);
      
      if (response.success) {
        print('✅ PROVIDER: ${response.data?.length ?? 0} exercícios carregados');
      } else {
        print('❌ PROVIDER: Erro ao listar exercícios: ${response.message}');
      }
      
      return response;
    } catch (e) {
      print('❌ PROVIDER: Exceção em listarExercicios: $e');
      return ApiResponse.error(message: 'Erro inesperado: $e');
    }
  }

  /// CRIAR EXERCÍCIO - VERSÃO CORRIGIDA COM ATUALIZAÇÃO DE ESTADO
  Future<ApiResponse<ExercicioModel>> criarExercicio(int treinoId, ExercicioModel exercicio) async {
    _setSaving(true);
    _clearError();
    
    try {
      print('➕ PROVIDER: Criando exercício "${exercicio.nomeExercicio}" no treino $treinoId');
      
      // 1️⃣ CHAMAR O SERVICE
      final response = await TreinoService.criarExercicio(treinoId, exercicio);
      
      print('📡 PROVIDER: Resposta da criação: success=${response.success}');
      
      if (response.success && response.data != null) {
        print('✅ PROVIDER: Exercício criado com sucesso');
        
        // 2️⃣ CRÍTICO: RECARREGAR O TREINO ATUAL SE FOR O MESMO
        if (_treinoAtual?.id == treinoId) {
          print('🔄 PROVIDER: Recarregando treino atual para incluir novo exercício...');
          
          final treinoAtualizado = await TreinoService.buscarTreino(treinoId);
          if (treinoAtualizado.success && treinoAtualizado.data != null) {
            _treinoAtual = treinoAtualizado.data!;
            print('✅ PROVIDER: Treino atual atualizado com ${_treinoAtual!.exercicios.length} exercícios');
          }
        }
        
        // 3️⃣ TAMBÉM ATUALIZAR NA LISTA GERAL SE ESTIVER CARREGADA
        final index = _treinos.indexWhere((t) => t.id == treinoId);
        if (index != -1) {
          print('🔄 PROVIDER: Atualizando treino na lista geral...');
          final treinoAtualizado = await TreinoService.buscarTreino(treinoId);
          if (treinoAtualizado.success && treinoAtualizado.data != null) {
            _treinos[index] = treinoAtualizado.data!;
            print('✅ PROVIDER: Treino na lista geral atualizado');
          }
        }
        
        // 4️⃣ NOTIFICAR COM PROTEÇÃO - CRÍTICO!
        _safeNotifyListeners();
        print('📢 PROVIDER: Listeners notificados - UI deve atualizar');
        
        return response;
      } else {
        final errorMsg = response.message ?? 'Erro ao criar exercício';
        print('❌ PROVIDER: Erro na criação: $errorMsg');
        _setError(errorMsg);
        return response;
      }
    } catch (e) {
      final errorMessage = 'Erro inesperado ao criar exercício: $e';
      print('❌ PROVIDER: Exceção: $errorMessage');
      _setError(errorMessage);
      return ApiResponse.error(message: errorMessage);
    } finally {
      _setSaving(false);
    }
  }

  /// ATUALIZAR EXERCÍCIO - VERSÃO CORRIGIDA
  Future<ApiResponse<ExercicioModel>> atualizarExercicio(
    int treinoId, 
    int exercicioId, 
    ExercicioModel exercicio
  ) async {
    _setSaving(true);
    _clearError();
    
    try {
      print('📝 PROVIDER: Atualizando exercício $exercicioId do treino $treinoId');
      
      // 1️⃣ CHAMAR O SERVICE
      final response = await TreinoService.atualizarExercicio(treinoId, exercicioId, exercicio);
      
      if (response.success && response.data != null) {
        print('✅ PROVIDER: Exercício atualizado com sucesso');
        
        // 2️⃣ RECARREGAR O TREINO ATUAL
        if (_treinoAtual?.id == treinoId) {
          print('🔄 PROVIDER: Recarregando treino atual...');
          final treinoAtualizado = await TreinoService.buscarTreino(treinoId);
          if (treinoAtualizado.success && treinoAtualizado.data != null) {
            _treinoAtual = treinoAtualizado.data!;
          }
        }
        
        // 3️⃣ ATUALIZAR NA LISTA GERAL
        final index = _treinos.indexWhere((t) => t.id == treinoId);
        if (index != -1) {
          final treinoAtualizado = await TreinoService.buscarTreino(treinoId);
          if (treinoAtualizado.success && treinoAtualizado.data != null) {
            _treinos[index] = treinoAtualizado.data!;
          }
        }
        
        // 4️⃣ NOTIFICAR COM PROTEÇÃO
        _safeNotifyListeners();
        print('📢 PROVIDER: Listeners notificados após atualização');
        
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

  /// DELETAR EXERCÍCIO - VERSÃO CORRIGIDA COM ATUALIZAÇÃO DE ESTADO
  Future<ApiResponse<bool>> deletarExercicio(int treinoId, int exercicioId) async {
    _setSaving(true);
    _clearError();
    
    try {
      print('🗑️ PROVIDER: Deletando exercício $exercicioId do treino $treinoId');
      
      // 1️⃣ CHAMAR O SERVICE
      final response = await TreinoService.deletarExercicio(treinoId, exercicioId);
      
      print('📡 PROVIDER: Resposta da exclusão: success=${response.success}');
      
      if (response.success) {
        print('✅ PROVIDER: Exercício deletado com sucesso');
        
        // 2️⃣ CRÍTICO: RECARREGAR O TREINO ATUAL
        if (_treinoAtual?.id == treinoId) {
          print('🔄 PROVIDER: Recarregando treino atual após exclusão...');
          
          final treinoAtualizado = await TreinoService.buscarTreino(treinoId);
          if (treinoAtualizado.success && treinoAtualizado.data != null) {
            _treinoAtual = treinoAtualizado.data!;
            print('✅ PROVIDER: Treino atual atualizado - ${_treinoAtual!.exercicios.length} exercícios restantes');
          }
        }
        
        // 3️⃣ TAMBÉM ATUALIZAR NA LISTA GERAL
        final index = _treinos.indexWhere((t) => t.id == treinoId);
        if (index != -1) {
          print('🔄 PROVIDER: Atualizando treino na lista geral...');
          final treinoAtualizado = await TreinoService.buscarTreino(treinoId);
          if (treinoAtualizado.success && treinoAtualizado.data != null) {
            _treinos[index] = treinoAtualizado.data!;
            print('✅ PROVIDER: Treino na lista geral atualizado');
          }
        }
        
        // 4️⃣ NOTIFICAR COM PROTEÇÃO - CRÍTICO!
        _safeNotifyListeners();
        print('📢 PROVIDER: Listeners notificados - exercício deve sumir da UI');
        
        return response;
      } else {
        final errorMsg = response.message ?? 'Erro ao deletar exercício';
        print('❌ PROVIDER: Erro na exclusão: $errorMsg');
        _setError(errorMsg);
        return response;
      }
    } catch (e) {
      final errorMessage = 'Erro inesperado ao deletar exercício: $e';
      print('❌ PROVIDER: Exceção: $errorMessage');
      _setError(errorMessage);
      return ApiResponse.error(message: errorMessage);
    } finally {
      _setSaving(false);
    }
  }

  /// REORDENAR EXERCÍCIOS - VERSÃO CORRIGIDA
  Future<ApiResponse<bool>> reordenarExercicios(
    int treinoId,
    List<Map<String, dynamic>> exerciciosOrdenados,
  ) async {
    _setSaving(true);
    _clearError();
    
    try {
      print('🔄 PROVIDER: Reordenando exercícios do treino $treinoId');
      
      // 1️⃣ CHAMAR O SERVICE
      final response = await TreinoService.reordenarExercicios(treinoId, exerciciosOrdenados);
      
      if (response.success) {
        print('✅ PROVIDER: Exercícios reordenados com sucesso');
        
        // 2️⃣ RECARREGAR O TREINO ATUAL
        if (_treinoAtual?.id == treinoId) {
          final treinoAtualizado = await TreinoService.buscarTreino(treinoId);
          if (treinoAtualizado.success && treinoAtualizado.data != null) {
            _treinoAtual = treinoAtualizado.data!;
          }
        }
        
        // 3️⃣ ATUALIZAR NA LISTA GERAL
        final index = _treinos.indexWhere((t) => t.id == treinoId);
        if (index != -1) {
          final treinoAtualizado = await TreinoService.buscarTreino(treinoId);
          if (treinoAtualizado.success && treinoAtualizado.data != null) {
            _treinos[index] = treinoAtualizado.data!;
          }
        }
        
        // 4️⃣ NOTIFICAR COM PROTEÇÃO
        _safeNotifyListeners();
        print('📢 PROVIDER: Listeners notificados após reordenação');
        
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