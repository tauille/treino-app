import 'dart:io';
import 'package:flutter/services.dart';
import '../services/image_cache_service.dart';

/// Helper para gerenciar assets e imagens de exercícios
class ExerciseAssetsHelper {
  static const String _assetsPath = 'assets/images/exercicios/';
  
  /// Mapeamento direto para exercícios conhecidos
  static final Map<String, String> _exerciseAssets = {
    // Exercícios básicos
    'prancha': '${_assetsPath}prancha.gif',
    'flexao': '${_assetsPath}flexao.gif',
    'flexão': '${_assetsPath}flexao.gif',
    'flexão de braço': '${_assetsPath}flexao.gif',
    'agachamento': '${_assetsPath}agachamento.gif',
    'abdominal': '${_assetsPath}abdominal.gif',
    
    // Musculação
    'supino reto': '${_assetsPath}supino_reto.gif',
    'supino inclinado': '${_assetsPath}supino_inclinado.gif',
    'leg press': '${_assetsPath}leg_press.gif',
    'rosca direta': '${_assetsPath}rosca_direta.gif',
    'triceps testa': '${_assetsPath}triceps_testa.gif',
    'tríceps testa': '${_assetsPath}triceps_testa.gif',
    'barra fixa': '${_assetsPath}barra_fixa.gif',
    'remada': '${_assetsPath}remada.gif',
    'desenvolvimento': '${_assetsPath}desenvolvimento.gif',
    'elevação lateral': '${_assetsPath}elevacao_lateral.gif',
    'elevacao lateral': '${_assetsPath}elevacao_lateral.gif',
    'cadeira extensora': '${_assetsPath}cadeira_extensora.gif',
    'mesa flexora': '${_assetsPath}mesa_flexora.gif',
    'panturrilha': '${_assetsPath}panturrilha.gif',
    'rosca martelo': '${_assetsPath}rosca_martelo.gif',
    'triceps pulley': '${_assetsPath}triceps_pulley.gif',
    'tríceps pulley': '${_assetsPath}triceps_pulley.gif',
    'crucifixo': '${_assetsPath}crucifixo.gif',
    
    // Exercícios de exemplo/teste
    'mais um': '${_assetsPath}mais_um.jpg',
  };

  /// Extensões de arquivo suportadas (prioridade JPG/PNG)
  static const List<String> _supportedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  /// Assets de fallback por grupo muscular
  static final Map<String, String> _groupFallbacks = {
    'peito': '${_assetsPath}supino_reto.gif',
    'peitoral': '${_assetsPath}supino_reto.gif',
    'costas': '${_assetsPath}remada.gif',
    'biceps': '${_assetsPath}rosca_direta.gif',
    'bíceps': '${_assetsPath}rosca_direta.gif',
    'triceps': '${_assetsPath}triceps_testa.gif',
    'tríceps': '${_assetsPath}triceps_testa.gif',
    'ombros': '${_assetsPath}desenvolvimento.gif',
    'ombro': '${_assetsPath}desenvolvimento.gif',
    'pernas': '${_assetsPath}agachamento.gif',
    'coxas': '${_assetsPath}leg_press.gif',
    'quadriceps': '${_assetsPath}cadeira_extensora.gif',
    'quadríceps': '${_assetsPath}cadeira_extensora.gif',
    'posterior': '${_assetsPath}mesa_flexora.gif',
    'panturrilhas': '${_assetsPath}panturrilha.gif',
    'abdomen': '${_assetsPath}abdominal.gif',
    'abdômen': '${_assetsPath}abdominal.gif',
    'core': '${_assetsPath}prancha.gif',
  };

  /// Ícone genérico de exercício
  static const String _genericIcon = '${_assetsPath}generic_exercise.png';

  /// Resolver asset de imagem para um exercício
  /// 
  /// Retorna o caminho do asset ou null se não encontrar
  static String? resolveExerciseAsset(String exerciseName, {String? muscleGroup}) {
    if (exerciseName.isEmpty) return null;

    // 1. Busca no mapeamento direto (exata)
    final exactAsset = _findExactMatch(exerciseName);
    if (exactAsset != null) {
      print('Asset encontrado (exato): $exactAsset para "$exerciseName"');
      return exactAsset;
    }

    // 2. Busca no mapeamento direto (parcial)
    final partialAsset = _findPartialMatch(exerciseName);
    if (partialAsset != null) {
      print('Asset encontrado (parcial): $partialAsset para "$exerciseName"');
      return partialAsset;
    }

    // 3. Gerar nome de arquivo baseado no exercício
    final generatedAsset = _generateAssetPath(exerciseName);
    if (generatedAsset != null) {
      print('Asset gerado: $generatedAsset para "$exerciseName"');
      return generatedAsset;
    }

    // 4. Fallback por grupo muscular
    if (muscleGroup != null && muscleGroup.isNotEmpty) {
      final groupAsset = _findGroupFallback(muscleGroup);
      if (groupAsset != null) {
        print('Asset fallback (grupo): $groupAsset para grupo "$muscleGroup"');
        return groupAsset;
      }
    }

    // 5. Nenhum asset encontrado
    print('Nenhum asset encontrado para "$exerciseName"');
    return null;
  }

  /// Busca exata no mapeamento
  static String? _findExactMatch(String exerciseName) {
    final normalizedName = _normalizeString(exerciseName);
    return _exerciseAssets[normalizedName];
  }

  /// Busca parcial no mapeamento
  static String? _findPartialMatch(String exerciseName) {
    final normalizedName = _normalizeString(exerciseName);
    
    // Busca se alguma chave contém o nome ou vice-versa
    for (final entry in _exerciseAssets.entries) {
      if (normalizedName.contains(entry.key) || entry.key.contains(normalizedName)) {
        return entry.value;
      }
    }
    
    return null;
  }

  /// Gera caminho de asset baseado no nome do exercício
  static String? _generateAssetPath(String exerciseName) {
    final fileName = _normalizeToFileName(exerciseName);
    
    // Tenta cada extensão suportada
    for (final ext in _supportedExtensions) {
      final assetPath = '$_assetsPath$fileName.$ext';
      // Retorna o primeiro (em ordem de prioridade)
      return assetPath;
    }
    
    return null;
  }

  /// Busca fallback por grupo muscular
  static String? _findGroupFallback(String muscleGroup) {
    final normalizedGroup = _normalizeString(muscleGroup);
    return _groupFallbacks[normalizedGroup];
  }

  /// Normaliza string para busca (remove acentos, converte para minúsculo)
  static String _normalizeString(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll('ã', 'a')
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');
  }

  /// Normaliza string para nome de arquivo
  static String _normalizeToFileName(String text) {
    return _normalizeString(text)
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), ''); // Remove caracteres especiais
  }

  /// Verifica se um asset existe fisicamente
  static Future<bool> assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Listar todos os assets de exercícios disponíveis
  static List<String> getAllExerciseAssets() {
    return _exerciseAssets.values.toList();
  }

  /// Obter asset ou usar imagem em cache
  static Future<String?> getExerciseImagePath(
    String exerciseName, {
    String? muscleGroup,
    String? exerciseId,
  }) async {
    // 1. Tentar resolver asset local primeiro
    final assetPath = resolveExerciseAsset(exerciseName, muscleGroup: muscleGroup);
    if (assetPath != null) {
      // Verificar se asset existe
      final exists = await assetExists(assetPath);
      if (exists) {
        return assetPath;
      }
    }

    // 2. TODO: Verificar cache quando ImageCacheService estiver completo
    // if (exerciseId != null) {
    //   final cachedPath = await ImageCacheService.getCachedImagePath(exerciseId);
    //   if (cachedPath != null && await File(cachedPath).exists()) {
    //     return cachedPath;
    //   }
    // }

    // 3. Não encontrou nada
    return null;
  }

  /// Adicionar novo mapeamento de exercício
  static void addExerciseMapping(String exerciseName, String assetPath) {
    final normalizedName = _normalizeString(exerciseName);
    _exerciseAssets[normalizedName] = assetPath;
    print('Mapeamento adicionado: "$normalizedName" -> "$assetPath"');
  }

  /// Remover mapeamento de exercício
  static void removeExerciseMapping(String exerciseName) {
    final normalizedName = _normalizeString(exerciseName);
    _exerciseAssets.remove(normalizedName);
    print('Mapeamento removido: "$normalizedName"');
  }

  /// Debug: imprimir todos os mapeamentos
  static void debugPrintMappings() {
    print('=== MAPEAMENTOS DE EXERCÍCIOS ===');
    _exerciseAssets.forEach((key, value) {
      print('  "$key" -> "$value"');
    });
    print('=== FIM MAPEAMENTOS ===');
  }

  /// Debug: testar resolução de asset
  static Future<void> debugTestAsset(String exerciseName, {String? muscleGroup}) async {
    print('=== TESTE DE ASSET ===');
    print('Exercício: "$exerciseName"');
    print('Grupo muscular: ${muscleGroup ?? "não informado"}');
    
    final asset = resolveExerciseAsset(exerciseName, muscleGroup: muscleGroup);
    print('Asset resolvido: ${asset ?? "não encontrado"}');
    
    if (asset != null) {
      final exists = await assetExists(asset);
      print('Asset existe fisicamente: $exists');
    }
    
    print('=== FIM TESTE ===');
  }
}