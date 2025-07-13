import 'package:flutter/foundation.dart';
import '../models/treino_model.dart';
import '../core/services/treino_service.dart';

class TreinoProvider with ChangeNotifier {
  // Estado dos treinos
  List<TreinoModel> _treinos = [];
  TreinoModel? _treinoAtual;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  
  // Getters
  List<TreinoModel> get treinos => _treinos;
  TreinoModel? get treinoAtual => _treinoAtual;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isEmpty => _treinos.isEmpty && !_isLoading;
  
  // Estatísticas
  int get totalTreinos => _treinos.length;
  int get treinosAtivos => _treinos.where((treino) => treino.isAtivo).length;
  int get treinosInativos => _treinos.where((treino) => treino.isInativo).length;
  
  int get totalExercicios => _treinos.fold<int>(
    0, 
    (sum, treino) => sum + (treino.totalExercicios ?? 0),
  );
  
  List<TreinoModel> get treinosRecentes {
    final agora = DateTime.now();
    return _treinos.where((treino) => 
      treino.createdAt != null && 
      agora.difference(treino.createdAt!).inDays <= 30
    ).toList();
  }

  // ========================================================================
  // MÉTODOS CRUD
  // ========================================================================

  /// Criar novo treino
  Future<TreinoModel?> criarTreino(TreinoModel treino) async {
    try {
      _setLoading(true);
      _clearError();

      print('🚀 Criando treino: ${treino.nomeTreino}');
      
      // ✅ Chama o TreinoService e processa ApiResponse
      final response = await TreinoService.criarTreino(treino);
      
      if (response.success && response.data != null) {
        final treinoCriado = response.data!;
        
        // Adicionar treino à lista (no início)
        _treinos.insert(0, treinoCriado);
        _treinoAtual = treinoCriado;
        
        print('✅ Treino criado e adicionado à lista: ${treinoCriado.nomeTreino}');
        notifyListeners();
        
        return treinoCriado;
      } else {
        _setError(response.message ?? 'Erro ao criar treino');
        return null;
      }
    } catch (e) {
      print('❌ Erro ao criar treino: $e');
      _setError('Erro interno: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Listar treinos do usuário
  Future<void> carregarTreinos({
    String? busca,
    String? dificuldade,
    String? tipoTreino,
    bool forceRefresh = false,
  }) async {
    if (_isLoading && !forceRefresh) return;

    try {
      _setLoading(true);
      _clearError();

      print('📥 Carregando treinos...');
      
      // ✅ Chama o TreinoService e processa ApiResponse
      final response = await TreinoService.listarTreinos(
        busca: busca,
        dificuldade: dificuldade,
        tipoTreino: tipoTreino,
      );
      
      if (response.success && response.data != null) {
        _treinos = response.data!;
        print('✅ ${_treinos.length} treinos carregados');
      } else {
        _setError(response.message ?? 'Erro ao carregar treinos');
        _treinos = [];
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ Erro ao carregar treinos: $e');
      _setError('Erro interno: $e');
      _treinos = [];
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Buscar treino por ID
  Future<TreinoModel?> buscarTreino(int id) async {
    try {
      _clearError();

      print('🔍 Buscando treino ID: $id');
      
      // ✅ Chama o TreinoService e processa ApiResponse
      final response = await TreinoService.buscarTreino(id);
      
      if (response.success && response.data != null) {
        final treino = response.data!;
        _treinoAtual = treino;

        // Atualizar treino na lista se já existir
        final index = _treinos.indexWhere((t) => t.id == id);
        if (index != -1) {
          _treinos[index] = treino;
        } else {
          _treinos.insert(0, treino);
        }

        print('✅ Treino encontrado: ${treino.nomeTreino}');
        notifyListeners();
        
        return treino;
      } else {
        _setError(response.message ?? 'Treino não encontrado');
        return null;
      }
    } catch (e) {
      print('❌ Erro ao buscar treino: $e');
      _setError('Erro interno: $e');
      return null;
    }
  }

  /// Atualizar treino
  Future<TreinoModel?> atualizarTreino(TreinoModel treino) async {
    try {
      _setLoading(true);
      _clearError();

      print('✏️ Atualizando treino: ${treino.nomeTreino}');
      
      // ✅ Chama o TreinoService e processa ApiResponse
      final response = await TreinoService.atualizarTreino(treino);
      
      if (response.success && response.data != null) {
        final treinoAtualizado = response.data!;

        // Atualizar treino na lista
        final index = _treinos.indexWhere((t) => t.id == treino.id);
        if (index != -1) {
          _treinos[index] = treinoAtualizado;
        }
        
        // Atualizar treino atual se for o mesmo
        if (_treinoAtual?.id == treino.id) {
          _treinoAtual = treinoAtualizado;
        }

        print('✅ Treino atualizado: ${treinoAtualizado.nomeTreino}');
        notifyListeners();
        
        return treinoAtualizado;
      } else {
        _setError(response.message ?? 'Erro ao atualizar treino');
        return null;
      }
    } catch (e) {
      print('❌ Erro ao atualizar treino: $e');
      _setError('Erro interno: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletar treino
  Future<bool> deletarTreino(int id) async {
    try {
      _setLoading(true);
      _clearError();

      print('🗑️ Deletando treino ID: $id');
      
      // ✅ Chama o TreinoService e processa ApiResponse
      final response = await TreinoService.deletarTreino(id);
      
      if (response.success && response.data == true) {
        // Remover treino da lista
        _treinos.removeWhere((treino) => treino.id == id);
        
        // Limpar treino atual se for o mesmo
        if (_treinoAtual?.id == id) {
          _treinoAtual = null;
        }

        print('✅ Treino deletado com sucesso');
        notifyListeners();
        
        return true;
      } else {
        _setError(response.message ?? 'Erro ao deletar treino');
        return false;
      }
    } catch (e) {
      print('❌ Erro ao deletar treino: $e');
      _setError('Erro interno: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========================================================================
  // MÉTODOS DE FILTRO E BUSCA
  // ========================================================================

  /// Filtrar treinos por dificuldade
  List<TreinoModel> filtrarPorDificuldade(String dificuldade) {
    return _treinos.where((treino) => treino.dificuldade == dificuldade).toList();
  }

  /// Filtrar treinos por tipo
  List<TreinoModel> filtrarPorTipo(String tipo) {
    return _treinos.where((treino) => treino.tipoTreino == tipo).toList();
  }

  /// Buscar treinos por texto
  List<TreinoModel> buscarPorTexto(String texto) {
    final textoLower = texto.toLowerCase();
    return _treinos.where((treino) {
      return treino.nomeTreino.toLowerCase().contains(textoLower) ||
             (treino.descricao?.toLowerCase().contains(textoLower) ?? false) ||
             treino.tipoTreino.toLowerCase().contains(textoLower);
    }).toList();
  }

  /// Obter treinos por dificuldade (da API)
  Future<List<TreinoModel>> carregarTreinosPorDificuldade(String dificuldade) async {
    try {
      _clearError();
      
      print('📥 Carregando treinos de dificuldade: $dificuldade');
      
      // ✅ Chama o TreinoService e processa ApiResponse
      final response = await TreinoService.listarTreinosPorDificuldade(dificuldade);
      
      if (response.success && response.data != null) {
        print('✅ ${response.data!.length} treinos de dificuldade $dificuldade carregados');
        return response.data!;
      } else {
        _setError(response.message ?? 'Erro ao carregar treinos por dificuldade');
        return [];
      }
    } catch (e) {
      print('❌ Erro ao carregar treinos por dificuldade: $e');
      _setError('Erro interno: $e');
      return [];
    }
  }

  // ========================================================================
  // MÉTODOS DE ESTADO
  // ========================================================================

  /// Definir treino atual
  void setTreinoAtual(TreinoModel? treino) {
    _treinoAtual = treino;
    notifyListeners();
  }

  /// Limpar dados
  void limpar() {
    _treinos = [];
    _treinoAtual = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Definir estado de loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Definir erro
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Limpar erro
  void _clearError() {
    _errorMessage = null;
  }

  /// Testar conexão com API
  Future<bool> testarConexao() async {
    try {
      return await TreinoService.testarConexao();
    } catch (e) {
      print('❌ Erro no teste de conexão: $e');
      return false;
    }
  }

  // ========================================================================
  // MÉTODOS UTILITÁRIOS
  // ========================================================================

  /// Reordenar treinos
  void reordenarTreinos(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final treino = _treinos.removeAt(oldIndex);
    _treinos.insert(newIndex, treino);
    notifyListeners();
  }

  /// Obter treino por ID (da lista local)
  TreinoModel? obterTreinoPorId(int id) {
    try {
      return _treinos.firstWhere((treino) => treino.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Verificar se treino existe na lista
  bool treinoExiste(int id) {
    return _treinos.any((treino) => treino.id == id);
  }

  /// Obter índice do treino na lista
  int obterIndiceTreino(int id) {
    return _treinos.indexWhere((treino) => treino.id == id);
  }

  /// Adicionar treino à lista (sem API)
  void adicionarTreinoLocal(TreinoModel treino) {
    _treinos.insert(0, treino);
    notifyListeners();
  }

  /// Remover treino da lista (sem API)
  void removerTreinoLocal(int id) {
    _treinos.removeWhere((treino) => treino.id == id);
    if (_treinoAtual?.id == id) {
      _treinoAtual = null;
    }
    notifyListeners();
  }

  /// Atualizar treino na lista (sem API)
  void atualizarTreinoLocal(TreinoModel treino) {
    final index = _treinos.indexWhere((t) => t.id == treino.id);
    if (index != -1) {
      _treinos[index] = treino;
      if (_treinoAtual?.id == treino.id) {
        _treinoAtual = treino;
      }
      notifyListeners();
    }
  }
}