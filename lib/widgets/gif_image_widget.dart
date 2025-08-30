import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

/// Widget otimizado que resolve problemas específicos de animação de GIFs
class GifImageWidget extends StatefulWidget {
  final String imagePath;
  final double height;
  final double? width;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final List<BoxShadow>? boxShadow;
  final int gifLoopDurationSeconds;
  final bool showGifIndicator;

  const GifImageWidget({
    Key? key,
    required this.imagePath,
    required this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.boxShadow,
    this.gifLoopDurationSeconds = 8,
    this.showGifIndicator = true,
  }) : super(key: key);

  @override
  State<GifImageWidget> createState() => _GifImageWidgetState();
}

class _GifImageWidgetState extends State<GifImageWidget> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _isGif = false;
  File? _imageFile;
  Timer? _gifResetTimer;
  int _gifKey = 0;

  @override
  void initState() {
    super.initState();
    _loadAndValidateImage();
  }

  @override
  void didUpdateWidget(GifImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _resetState();
      _loadAndValidateImage();
    }
  }

  @override
  void dispose() {
    _gifResetTimer?.cancel();
    super.dispose();
  }

  void _resetState() {
    _gifResetTimer?.cancel();
    setState(() {
      _isLoading = true;
      _hasError = false;
      _imageFile = null;
      _gifKey = 0;
    });
  }

  Future<void> _loadAndValidateImage() async {
    print('=== GifImageWidget: Carregando ${widget.imagePath} ===');
    
    try {
      final file = File(widget.imagePath);
      
      // Verificações básicas apenas
      if (!await file.exists()) {
        print('ERRO: Arquivo não existe');
        _setErrorState('Arquivo não encontrado');
        return;
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        print('ERRO: Arquivo vazio');
        _setErrorState('Arquivo vazio');
        return;
      }

      // Detectar tipo apenas pela extensão
      final extension = widget.imagePath.toLowerCase();
      final isGifFile = extension.endsWith('.gif');
      
      print('Arquivo válido: ${fileSize} bytes, GIF: $isGifFile');

      setState(() {
        _imageFile = file;
        _isGif = isGifFile;
        _isLoading = false;
        _hasError = false;
      });

      // Se for GIF, configurar sistema de reset para manter animação
      if (_isGif) {
        print('Iniciando ciclo de reset para GIF a cada ${widget.gifLoopDurationSeconds}s');
        _startGifResetCycle();
      }

      print('✓ Carregamento concluído com sucesso');

    } catch (e) {
      print('ERRO ao carregar: $e');
      _setErrorState('Erro ao carregar: $e');
    }
  }

  void _setErrorState(String error) {
    print('Definindo erro: $error');
    setState(() {
      _hasError = true;
      _isLoading = false;
    });
  }

  void _startGifResetCycle() {
    _gifResetTimer?.cancel();
    
    _gifResetTimer = Timer.periodic(
      Duration(seconds: widget.gifLoopDurationSeconds),
      (timer) {
        if (mounted && _isGif) {
          setState(() {
            _gifKey++;
          });
          print('Reset GIF #$_gifKey');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        boxShadow: widget.boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError || _imageFile == null) {
      return _buildErrorState();
    }

    return Stack(
      children: [
        _buildOptimizedImage(),
        if (_isGif && widget.showGifIndicator) _buildGifIndicator(),
      ],
    );
  }

  Widget _buildOptimizedImage() {
    return Image.file(
      _imageFile!,
      key: ValueKey('${widget.imagePath}_$_gifKey'),
      width: widget.width ?? double.infinity,
      height: widget.height,
      fit: widget.fit,
      
      // CONFIGURAÇÕES CRÍTICAS PARA GIFS
      gaplessPlayback: false,  // Permite frames recarregarem
      filterQuality: FilterQuality.low,  // Reduz processamento
      
      // Cache otimizado - desabilitado para GIFs
      cacheWidth: _isGif ? null : 600,
      cacheHeight: _isGif ? null : 400,
      
      errorBuilder: (context, error, stackTrace) {
        print('ERRO Image.file: $error');
        return _buildErrorState();
      },
    );
  }

  Widget _buildGifIndicator() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 14,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Text(
              'GIF',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        color: Colors.grey[300],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF6BA6CD),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Carregando mídia...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6BA6CD), Color(0xFF5B9BD5)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isGif ? Icons.gif_box_outlined : Icons.image_not_supported,
            size: widget.height * 0.25,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(height: 16),
          Text(
            _isGif ? 'GIF Indisponível' : 'Imagem Indisponível',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Siga as instruções do exercício',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}