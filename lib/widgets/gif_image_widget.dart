import 'package:flutter/material.dart';
import 'dart:io';

/// Widget otimizado para exibir imagens e GIFs sem reset automático
class GifImageWidget extends StatefulWidget {
  final String imagePath;
  final double height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final EdgeInsets? margin;

  const GifImageWidget({
    Key? key,
    required this.imagePath,
    required this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.boxShadow,
    this.margin,
  }) : super(key: key);

  @override
  State<GifImageWidget> createState() => _GifImageWidgetState();
}

class _GifImageWidgetState extends State<GifImageWidget> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _isGif = false;
  File? _imageFile;

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

  void _resetState() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _imageFile = null;
    });
  }

  Future<void> _loadAndValidateImage() async {
    try {
      final file = File(widget.imagePath);
      
      // Verificações básicas
      if (!await file.exists()) {
        _setErrorState();
        return;
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        _setErrorState();
        return;
      }

      // Detectar tipo apenas pela extensão
      final extension = widget.imagePath.toLowerCase();
      final isGifFile = extension.endsWith('.gif');

      if (mounted) {
        setState(() {
          _imageFile = file;
          _isGif = isGifFile;
          _isLoading = false;
          _hasError = false;
        });
      }

    } catch (e) {
      _setErrorState();
    }
  }

  void _setErrorState() {
    if (mounted) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        boxShadow: widget.boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
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

    return _buildOptimizedImage();
  }

  Widget _buildOptimizedImage() {
    return Image.file(
      _imageFile!,
      width: widget.width ?? double.infinity,
      height: widget.height,
      fit: widget.fit,
      gaplessPlayback: true,
      filterQuality: FilterQuality.low,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
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
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
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