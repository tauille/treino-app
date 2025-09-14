import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

class ImageCacheService {
  static ImageCacheService? _instance;
  static ImageCacheService get instance => _instance ??= ImageCacheService._();
  ImageCacheService._();

  // Pasta onde ficam as imagens dos exercícios
  static const String _exerciciosFolder = 'exercicios';
  
  // Cache em memória para evitar recarregar do disco
  final Map<String, String> _cacheMemoria = {};

  /// Inicializar o serviço (criar pastas necessárias)
  Future<void> inicializar() async {
    try {
      final directory = await _obterDiretorioExercicios();
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        print('📁 Pasta de exercícios criada: ${directory.path}');
      } else {
        print('📁 Pasta de exercícios já existe: ${directory.path}');
      }
    } catch (e) {
      print('❌ Erro ao inicializar ImageCacheService: $e');
    }
  }

  /// Obter diretório onde ficam as imagens dos exercícios
  Future<Directory> _obterDiretorioExercicios() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return Directory(path.join(appDocDir.path, _exerciciosFolder));
  }

  /// Salvar imagem do ImagePicker para storage local
  Future<String?> salvarImagemExercicio({
    required String nomeExercicio,
    required XFile imageFile,
  }) async {
    try {
      print('💾 Salvando imagem para exercício: $nomeExercicio');
      
      // Ler bytes da imagem
      final bytes = await imageFile.readAsBytes();
      
      // Gerar nome único para o arquivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path).toLowerCase();
      final nomeArquivo = '${_sanitizarNome(nomeExercicio)}_$timestamp$extension';
      
      // Caminho completo do arquivo
      final directory = await _obterDiretorioExercicios();
      final filePath = path.join(directory.path, nomeArquivo);
      
      // Salvar arquivo
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      // Adicionar ao cache em memória
      _cacheMemoria[nomeExercicio] = filePath;
      
      print('✅ Imagem salva: $filePath');
      print('📊 Tamanho: ${(bytes.length / 1024).toStringAsFixed(1)} KB');
      
      return filePath;
    } catch (e) {
      print('❌ Erro ao salvar imagem: $e');
      return null;
    }
  }

  /// Salvar imagem de bytes (para uso futuro com URLs)
  Future<String?> salvarImagemDeBytes({
    required String nomeExercicio,
    required Uint8List bytes,
    required String extensao,
  }) async {
    try {
      print('💾 Salvando bytes para exercício: $nomeExercicio');
      
      // Gerar nome único para o arquivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final nomeArquivo = '${_sanitizarNome(nomeExercicio)}_$timestamp.$extensao';
      
      // Caminho completo do arquivo
      final directory = await _obterDiretorioExercicios();
      final filePath = path.join(directory.path, nomeArquivo);
      
      // Salvar arquivo
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      // Adicionar ao cache em memória
      _cacheMemoria[nomeExercicio] = filePath;
      
      print('✅ Imagem salva de bytes: $filePath');
      return filePath;
    } catch (e) {
      print('❌ Erro ao salvar bytes: $e');
      return null;
    }
  }

  /// Obter caminho da imagem do exercício
  Future<String?> obterImagemExercicio(String nomeExercicio) async {
    try {
      // Verificar cache em memória primeiro
      if (_cacheMemoria.containsKey(nomeExercicio)) {
        final cachedPath = _cacheMemoria[nomeExercicio]!;
        if (await File(cachedPath).exists()) {
          return cachedPath;
        } else {
          // Arquivo não existe mais, remover do cache
          _cacheMemoria.remove(nomeExercicio);
        }
      }

      // Buscar no diretório
      final directory = await _obterDiretorioExercicios();
      if (!await directory.exists()) return null;

      final files = directory.listSync();
      final nomeNormalizado = _sanitizarNome(nomeExercicio);
      
      // Procurar arquivos que começam com o nome do exercício
      for (final file in files) {
        if (file is File) {
          final fileName = path.basenameWithoutExtension(file.path);
          if (fileName.toLowerCase().startsWith(nomeNormalizado.toLowerCase())) {
            // Adicionar ao cache
            _cacheMemoria[nomeExercicio] = file.path;
            return file.path;
          }
        }
      }

      print('🔍 Imagem não encontrada para exercício: $nomeExercicio');
      return null;
    } catch (e) {
      print('❌ Erro ao obter imagem: $e');
      return null;
    }
  }

  /// Remover imagem do exercício
  Future<bool> removerImagemExercicio(String nomeExercicio) async {
    try {
      final imagePath = await obterImagemExercicio(nomeExercicio);
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
          _cacheMemoria.remove(nomeExercicio);
          print('🗑️ Imagem removida: $imagePath');
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ Erro ao remover imagem: $e');
      return false;
    }
  }

  /// Listar todas as imagens salvas
  Future<Map<String, String>> listarTodasImagens() async {
    try {
      final directory = await _obterDiretorioExercicios();
      if (!await directory.exists()) return {};

      final files = directory.listSync();
      final resultado = <String, String>{};

      for (final file in files) {
        if (file is File && _isImageFile(file.path)) {
          final fileName = path.basenameWithoutExtension(file.path);
          // Extrair nome do exercício (remover timestamp)
          final parts = fileName.split('_');
          if (parts.length > 1) {
            final nomeExercicio = parts.sublist(0, parts.length - 1).join('_');
            resultado[nomeExercicio] = file.path;
          }
        }
      }

      print('📋 Total de imagens encontradas: ${resultado.length}');
      return resultado;
    } catch (e) {
      print('❌ Erro ao listar imagens: $e');
      return {};
    }
  }

  /// Obter estatísticas do cache
  Future<Map<String, dynamic>> obterEstatisticas() async {
    try {
      final directory = await _obterDiretorioExercicios();
      if (!await directory.exists()) {
        return {
          'total_arquivos': 0,
          'tamanho_total_kb': 0.0,
          'pasta_existe': false,
          'caminho_pasta': directory.path,
        };
      }

      final files = directory.listSync();
      var totalSize = 0;
      var totalImages = 0;

      for (final file in files) {
        if (file is File && _isImageFile(file.path)) {
          totalImages++;
          final stat = await file.stat();
          totalSize += stat.size;
        }
      }

      return {
        'total_arquivos': totalImages,
        'tamanho_total_kb': (totalSize / 1024).toStringAsFixed(1),
        'pasta_existe': true,
        'caminho_pasta': directory.path,
        'cache_memoria': _cacheMemoria.length,
      };
    } catch (e) {
      print('❌ Erro ao obter estatísticas: $e');
      return {'erro': e.toString()};
    }
  }

  /// Limpar todas as imagens (usar com cuidado)
  Future<bool> limparCache() async {
    try {
      final directory = await _obterDiretorioExercicios();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        _cacheMemoria.clear();
        print('🧹 Cache de imagens limpo');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Erro ao limpar cache: $e');
      return false;
    }
  }

  /// Verificar se arquivo é uma imagem
  bool _isImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    return imageExtensions.contains(extension);
  }

  /// Sanitizar nome para usar como nome de arquivo
  String _sanitizarNome(String nome) {
    return nome
        .toLowerCase()
        .replaceAll(' ', '_')
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
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9_]'), ''); // Remove caracteres especiais
  }

  /// Obter widget Image para exibir imagem do exercício
  Future<Widget?> obterImageWidget(String nomeExercicio, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) async {
    try {
      final imagePath = await obterImagemExercicio(nomeExercicio);
      
      if (imagePath != null && await File(imagePath).exists()) {
        return Image.file(
          File(imagePath),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Erro ao carregar imagem: $error');
            return errorWidget ?? Icon(Icons.broken_image, size: height ?? 50);
          },
        );
      }
      
      // Se não encontrou imagem, retornar placeholder ou null
      return placeholder;
    } catch (e) {
      print('❌ Erro ao obter widget de imagem: $e');
      return errorWidget ?? Icon(Icons.error, size: height ?? 50);
    }
  }
}