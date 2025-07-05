// lib/providers/treino_provider.dart
import 'package:flutter/material.dart';
import '../models/treino_model.dart';
import '../models/exercicio_model.dart';
import '../models/api_response_model.dart';
import '../core/services/treino_service.dart';

class TreinoProvider with ChangeNotifier {
  // ========================================
  // ESTADO INTERNO
  // ========================================
  
  List<Treino> _treinos = [];
  Treino? _treinoAtual;
  List<Exercicio> _exercicios = [];
  
  bool _isLoading = false;
  bool _isLoadingTreinos = false;
  bool _isLoadingExercicios = false;
  String? _errorMessage;
  
  // Filtros
  String? _filtroTipo;
  String? _filtroDificuldade;
  String? _filtroBusca;
  
  // ========================================
  // GETTERS
  // ========================================
  
  List<Treino> get treinos => _treinos;
  Treino? get treinoAtual => _treinoAtual;
  List<Exercicio> get exercicios => _exercicios;
  
  bool get isLoading => _isLoading;
  bool get isLoadingTreinos => _isLoadingTreinos;
  bool get isLoadingExercicios => _isLoadingExercicios;
  String? get errorMessage => _errorMessage;
  
  // Filtros
  String? get filtroTipo => _filtroTipo;
  String? get filtroDificuldade => _filtroDificuldade;
  String? get filtroBusca => _filtroBusca;
  
  // Estatísticas
  int get totalTreinos => _treinos.length;
  int get treinosAtivos => _treinos.where((t) => t.isAtivo).length;
  
  List<Treino> get treinosFiltrados {
    var lista = _treinos.where((treino) => treino.isAtivo);
    
    if (_filtroTipo != null && _filtroTipo!.isNotEmpty) {
      lista = lista.where((t) => t.tipoTreino.toLowerCase().contains(_filtroTipo!.toLowerCase()));
    }
    
    if (_filtroDificuldade != null && _filtroDificuldade!.isNotEmpty) {
      lista = lista.where((t) => t.dificuldade == _filtroDificuldade);
    }
    
    if (_filtroBusca != null && _filtroBusca!.isNotEmpty) {
      lista = lista.where((t) => 
        t.nomeTreino.toLowerCase().contains(_filtroBusca!.toLowerCase()) ||
        t.tipoTreino.toLowerCase().contains(_filtroBusca!.toLowerCase()) ||
        (t.descricao?.toLowerCase().contains(_filtroBusca!.toLowerCase()) ?? false)
      );
    }
    
    return lista.toList();
  }
  
  // ========================================
  // MÉTODOS DE TREINOS
  // ========================================
  
  /// Carregar todos os treinos do usuário
  Future<void> carregarTreinos({bool forceRefresh = false}) async {
    if (_isLoadingTreinos && !forceRefresh) return;
    
    _isLoadingTreinos = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await TreinoService.getTreinos();
      
      if (response.success) {
        _treinos = response.data ?? [];
        _errorMessage = null;
        debugPrint('✅ ${_treinos.length} treinos carregados');
      } else {
        _errorMessage = response.message;
        debugPrint('❌ Erro ao carregar treinos: ${response.message}');
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão. Verifique sua internet.';
      debugPrint('❌ Exceção ao carregar treinos: $e');
    } finally {
      _isLoadingTreinos = false;
      notifyListeners();
    }
  }
  
  /// Carregar treino específico com exercícios
  Future<bool> carregarTreino(int treinoId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await TreinoService.getTreino(treinoId);
      
      if (response.success) {
        _treinoAtual = response.data;
        _exercicios = _treinoAtual?.exercicios ?? [];
        _errorMessage = null;
        debugPrint('✅ Treino carregado: ${_treinoAtual?.nomeTreino}');
        return true;
      } else {
        _errorMessage = response.message;
        debugPrint('❌ Erro ao carregar treino: ${response.message}');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão. Verifique sua internet.';
      debugPrint('❌ Exceção ao carregar treino: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Criar novo treino
  Future<bool> criarTreino({
    required String nomeTreino,
    required String tipoTreino,
    String? descricao,
    String? dificuldade,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await TreinoService.createTreino(
        nomeTreino: nomeTreino,
        tipoTreino: tipoTreino,
        descricao: descricao,
        dificuldade: dificuldade,
      );
      
      if (response.success) {
        // Adicionar à lista local
        _treinos.insert(0, response.data!);
        _errorMessage = null;
        debugPrint('✅ Treino criado: ${response.data?.nomeTreino}');
        return true;
      } else {
        _errorMessage = response.message;
        debugPrint('❌ Erro ao criar treino: ${response.message}');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão. Verifique sua internet.';
      debugPrint('❌ Exceção ao criar treino: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Atualizar treino
  Future<bool> atualizarTreino({
    required int treinoId,
    String? nomeTreino,
    String? tipoTreino,
    String? descricao,
    String? dificuldade,
    String? status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await TreinoService.updateTreino(
        treinoId: treinoId,
        nomeTreino: nomeTreino,
        tipoTreino: tipoTreino,
        descricao: descricao,
        dificuldade: dificuldade,
        status: status,
      );
      
      if (response.success) {
        // Atualizar na lista local
        final index = _treinos.indexWhere((t) => t.id == treinoId);
        if (index != -1) {
          _treinos[index] = response.data!;
        }
        
        // Atualizar treino atual se for o mesmo
        if (_treinoAtual?.id == treinoId) {
          _treinoAtual = response.data;
        }
        
        _errorMessage = null;
        debugPrint('✅ Treino atualizado: ${response.data?.nomeTreino}');
        return true;
      } else {
        _errorMessage = response.message;
        debugPrint('❌ Erro ao atualizar treino: ${response.message}');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão. Verifique sua internet.';
      debugPrint('❌ Exceção ao atualizar treino: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Deletar treino
  Future<bool> deletarTreino(int treinoId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await TreinoService.deleteTreino(treinoId);
      
      if (response.success) {
        // Remover da lista local
        _treinos.removeWhere((t) => t.id == treinoId);
        
        // Limpar treino atual se for o mesmo
        if (_treinoAtual?.id == treinoId) {
          _treinoAtual = null;
          _exercicios.clear();
        }
        
        _errorMessage = null;
        debugPrint('✅ Treino deletado');
        return true;
      } else {
        _errorMessage = response.message;
        debugPrint('❌ Erro ao deletar treino: ${response.message}');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão. Verifique sua internet.';
      debugPrint('❌ Exceção ao deletar treino: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ========================================
  // MÉTODOS DE EXERCÍCIOS
  // ========================================
  
  /// Carregar exercícios de um treino
  Future<void> carregarExercicios(int treinoId) async {
    _isLoadingExercicios = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await TreinoService.getExercicios(treinoId);
      
      if (response.success) {
        _exercicios = response.data ?? [];
        _errorMessage = null;
        debugPrint('✅ ${_exercicios.length} exercícios carregados');
      } else {
        _errorMessage = response.message;
        debugPrint('❌ Erro ao carregar exercícios: ${response.message}');
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão. Verifique sua internet.';
      debugPrint('❌ Exceção ao carregar exercícios: $e');
    } finally {
      _isLoadingExercicios = false;
      notifyListeners();
    }
  }
  
  /// Criar exercício
  Future<bool> criarExercicio({
    required int treinoId,
    required String nomeExercicio,
    String? descricao,
    String? grupoMuscular,
    required String tipoExecucao,
    int? repeticoes,
    int? series,
    int? tempoExecucao,
    int? tempoDescanso,
    double? peso,
    String? unidadePeso,
    int? ordem,
    String? observacoes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await TreinoService.createExercicio(
        treinoId: treinoId,
        nomeExercicio: nomeExercicio,
        descricao: descricao,
        grupoMuscular: grupoMuscular,
        tipoExecucao: tipoExecucao,
        repeticoes: repeticoes,
        series: series,
        tempoExecucao: tempoExecucao,
        tempoDescanso: tempoDescanso,
        peso: peso,
        unidadePeso: unidadePeso,
        ordem: ordem,
        observacoes: observacoes,
      );
      
      if (response.success) {
        // Adicionar à lista local se estamos vendo este treino
        if (_treinoAtual?.id == treinoId) {
          _exercicios.add(response.data!);
          _exercicios.sort((a, b) => a.ordem.compareTo(b.ordem));
        }
        
        _errorMessage = null;
        debugPrint('✅ Exercício criado: ${response.data?.nomeExercicio}');
        return true;
      } else {
        _errorMessage = response.message;
        debugPrint('❌ Erro ao criar exercício: ${response.message}');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão. Verifique sua internet.';
      debugPrint('❌ Exceção ao criar exercício: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ========================================
  // MÉTODOS DE FILTRO
  // ========================================
  
  void setFiltroTipo(String? tipo) {
    _filtroTipo = tipo;
    notifyListeners();
  }
  
  void setFiltroDificuldade(String? dificuldade) {
    _filtroDificuldade = dificuldade;
    notifyListeners();
  }
  
  void setFiltroBusca(String? busca) {
    _filtroBusca = busca;
    notifyListeners();
  }
  
  void limparFiltros() {
    _filtroTipo = null;
    _filtroDificuldade = null;
    _filtroBusca = null;
    notifyListeners();
  }
  
  // ========================================
  // MÉTODOS UTILITÁRIOS
  // ========================================
  
  void limparErro() {
    _errorMessage = null;
    notifyListeners();
  }
  
  void limparTreinoAtual() {
    _treinoAtual = null;
    _exercicios.clear();
    notifyListeners();
  }
  
  void limparTudo() {
    _treinos.clear();
    _treinoAtual = null;
    _exercicios.clear();
    _errorMessage = null;
    _isLoading = false;
    _isLoadingTreinos = false;
    _isLoadingExercicios = false;
    limparFiltros();
    notifyListeners();
  }
  
  // Para debug
  void debugPrint(String message) {
    if (!ApiConstants.isProduction) {
      print('🏋️ TreinoProvider: $message');
    }
  }
}