import 'package:flutter/foundation.dart';
import '../models/treino_model.dart';
import '../core/services/treino_service.dart';

/// Provider para gerenciar estado dos treinos
class TreinoProvider extends ChangeNotifier {
  // ===== ESTADO =====
  List<TreinoModel> _treinos = [];
  TreinoModel? _treinoAtual;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filtros
  String? _filtroTipo;
  String? _filtroDificuldade;
  String? _filtroBusca;
  
  // ===== GETTERS =====
  List<TreinoModel> get treinos => _treinos;
  TreinoModel? get treinoAtual => _treinoAtual;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Filtros
  String? get filtroTipo => _filtroTipo;
  String? get filtroDificuldade => _filtroDificuldade;
  String? get filtroBusca => _filtroBusca;
  
  // Estatísticas
  int get totalTreinos => _treinos.length;
  int get treinosAtivos => _treinos.where((t) => t.status == 'ativo').length;
  int get totalExercicios => _treinos.fold(0, (sum, treino) => sum + treino.totalExercicios);
  
  /// Carregar lista de treinos
  Future<void> loadTreinos({
    String? busca,
    String? dificuldade,
    String? tipo,
    bool forceRefresh = false,
  }) async {
    // Se já temos dados e não é refresh, não recarregar
    if (_treinos.isNotEmpty && !forceRefresh) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final result = await TreinoService().getTreinos(
        busca: busca,
        dificuldade: dificuldade,
        tipoTreino: tipo,
      );
      
      if (result['success']) {
        _treinos = (result['data']['data'] as List)
            .map((json) => TreinoModel.fromJson(json))
            .toList();
        
        // Aplicar filtros se definidos
        _aplicarFiltros();
        
        if (kDebugMode) {
          print('✅ ${_treinos.length} treinos carregados');
        }
      } else {
        _setError(result['message'] ?? 'Erro ao carregar treinos');
      }
    } catch (e) {
      _setError('Erro de conexão');
      if (kDebugMode) print('❌ Erro loadTreinos: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Carregar treino específico
  Future<bool> loadTreino(int treinoId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await TreinoService().getTreino(treinoId);
      
      if (result['success']) {
        _treinoAtual = TreinoModel.fromJson(result['data']);
        
        if (kDebugMode) {
          print('✅ Treino ${_treinoAtual!.nomeTreino} carregado');
        }
        
        return true;
      } else {
        _setError(result['message'] ?? 'Treino não encontrado');
        return false;
      }
    } catch (e) {
      _setError('Erro ao carregar treino');
      if (kDebugMode) print('❌ Erro loadTreino: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Criar novo treino
  Future<bool> createTreino({
    required String nomeTreino,
    required String tipoTreino,
    String? descricao,
    String? dificuldade,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await TreinoService().createTreino(
        nomeTreino: nomeTreino,
        tipoTreino: tipoTreino,
        descricao: descricao,
        dificuldade: dificuldade,
      );
      
      if (result['success']) {
        final novoTreino = TreinoModel.fromJson(result['data']);
        _treinos.insert(0, novoTreino);
        
        if (kDebugMode) {
          print('✅ Treino "${novoTreino.nomeTreino}" criado');
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Erro ao criar treino');
        return false;
      }
    } catch (e) {
      _setError('Erro ao criar treino');
      if (kDebugMode) print('❌ Erro createTreino: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Atualizar treino
  Future<bool> updateTreino({
    required int treinoId,
    String? nomeTreino,
    String? tipoTreino,
    String? descricao,
    String? dificuldade,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await TreinoService().updateTreino(
        treinoId: treinoId,
        nomeTreino: nomeTreino,
        tipoTreino: tipoTreino,
        descricao: descricao,
        dificuldade: dificuldade,
      );
      
      if (result['success']) {
        final treinoAtualizado = TreinoModel.fromJson(result['data']);
        
        // Atualizar na lista
        final index = _treinos.indexWhere((t) => t.id == treinoId);
        if (index != -1) {
          _treinos[index] = treinoAtualizado;
        }
        
        // Atualizar treino atual se for o mesmo
        if (_treinoAtual?.id == treinoId) {
          _treinoAtual = treinoAtualizado;
        }
        
        if (kDebugMode) {
          print('✅ Treino atualizado');
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Erro ao atualizar treino');
        return false;
      }
    } catch (e) {
      _setError('Erro ao atualizar treino');
      if (kDebugMode) print('❌ Erro updateTreino: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Deletar treino
  Future<bool> deleteTreino(int treinoId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await TreinoService().deleteTreino(treinoId);
      
      if (result['success']) {
        // Remover da lista
        _treinos.removeWhere((t) => t.id == treinoId);
        
        // Limpar treino atual se for o mesmo
        if (_treinoAtual?.id == treinoId) {
          _treinoAtual = null;
        }
        
        if (kDebugMode) {
          print('✅ Treino removido');
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Erro ao remover treino');
        return false;
      }
    } catch (e) {
      _setError('Erro ao remover treino');
      if (kDebugMode) print('❌ Erro deleteTreino: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Carregar treinos por dificuldade
  Future<void> loadTreinosByDificuldade(String dificuldade) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await TreinoService().getTreinosByDificuldade(dificuldade);
      
      if (result['success']) {
        _treinos = (result['data'] as List)
            .map((json) => TreinoModel.fromJson(json))
            .toList();
        
        _filtroDificuldade = dificuldade;
        
        if (kDebugMode) {
          print('✅ ${_treinos.length} treinos de nível $dificuldade carregados');
        }
      } else {
        _setError(result['message'] ?? 'Erro ao carregar treinos');
      }
    } catch (e) {
      _setError('Erro ao carregar treinos por dificuldade');
      if (kDebugMode) print('❌ Erro loadTreinosByDificuldade: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // ===== FILTROS =====
  
  /// Aplicar filtro de busca
  void setFiltroBusca(String? busca) {
    _filtroBusca = busca;
    _aplicarFiltros();
    notifyListeners();
  }
  
  /// Aplicar filtro de tipo
  void setFiltroTipo(String? tipo) {
    _filtroTipo = tipo;
    _aplicarFiltros();
    notifyListeners();
  }
  
  /// Aplicar filtro de dificuldade
  void setFiltroDificuldade(String? dificuldade) {
    _filtroDificuldade = dificuldade;
    _aplicarFiltros();
    notifyListeners();
  }
  
  /// Limpar todos os filtros
  void clearFiltros() {
    _filtroBusca = null;
    _filtroTipo = null;
    _filtroDificuldade = null;
    _aplicarFiltros();
    notifyListeners();
  }
  
  /// Aplicar filtros à lista de treinos
  void _aplicarFiltros() {
    // Implementar lógica de filtros se necessário
    // Por enquanto, os filtros são aplicados no servidor
  }
  
  // ===== UTILITÁRIOS =====
  
  /// Obter treinos por tipo
  List<TreinoModel> getTreinosByTipo(String tipo) {
    return _treinos.where((treino) => treino.tipoTreino == tipo).toList();
  }
  
  /// Obter treinos por dificuldade
  List<TreinoModel> getTreinosByDificuldade(String dificuldade) {
    return _treinos.where((treino) => treino.dificuldade == dificuldade).toList();
  }
  
  /// Buscar treinos
  List<TreinoModel> searchTreinos(String query) {
    if (query.isEmpty) return _treinos;
    
    final queryLower = query.toLowerCase();
    return _treinos.where((treino) {
      return treino.nomeTreino.toLowerCase().contains(queryLower) ||
             treino.descricao?.toLowerCase().contains(queryLower) == true ||
             treino.tipoTreino.toLowerCase().contains(queryLower);
    }).toList();
  }
  
  /// Obter estatísticas dos treinos
  Map<String, dynamic> getEstatisticas() {
    if (_treinos.isEmpty) {
      return {
        'total': 0,
        'ativos': 0,
        'exercicios': 0,
        'dificuldades': <String, int>{},
        'tipos': <String, int>{},
      };
    }
    
    final dificuldades = <String, int>{};
    final tipos = <String, int>{};
    
    for (final treino in _treinos) {
      // Contar dificuldades
      if (treino.dificuldade != null) {
        dificuldades[treino.dificuldade!] = 
            (dificuldades[treino.dificuldade!] ?? 0) + 1;
      }
      
      // Contar tipos
      tipos[treino.tipoTreino] = (tipos[treino.tipoTreino] ?? 0) + 1;
    }
    
    return {
      'total': totalTreinos,
      'ativos': treinosAtivos,
      'exercicios': totalExercicios,
      'dificuldades': dificuldades,
      'tipos': tipos,
    };
  }
  
  // ===== MÉTODOS PRIVADOS =====
  
  /// Definir estado de loading
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  /// Definir erro
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  /// Limpar erro
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
  
  /// Limpar estado
  void clearState() {
    _treinos.clear();
    _treinoAtual = null;
    _isLoading = false;
    _errorMessage = null;
    _filtroBusca = null;
    _filtroTipo = null;
    _filtroDificuldade = null;
    notifyListeners();
    
    if (kDebugMode) print('🧹 TreinoProvider estado limpo');
  }
  
  @override
  void dispose() {
    if (kDebugMode) print('🗑️ TreinoProvider disposed');
    super.dispose();
  }
}