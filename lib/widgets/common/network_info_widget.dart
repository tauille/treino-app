import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';

/// Widget para mostrar informações da rede detectada (opcional para debug)
class NetworkInfoWidget extends StatefulWidget {
  final bool showDetails;
  final bool allowForceRefresh;
  
  const NetworkInfoWidget({
    super.key,
    this.showDetails = false,
    this.allowForceRefresh = true,
  });

  @override
  State<NetworkInfoWidget> createState() => _NetworkInfoWidgetState();
}

class _NetworkInfoWidgetState extends State<NetworkInfoWidget> {
  Map<String, dynamic>? _networkInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNetworkInfo();
  }

  void _loadNetworkInfo() {
    setState(() {
      _networkInfo = ApiConstants.getNetworkInfo();
    });
  }

  Future<void> _forceRefresh() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ApiConstants.forceNetworkDetection();
      _loadNetworkInfo();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rede detectada novamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na detecção: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_networkInfo == null) {
      return const SizedBox.shrink();
    }

    final currentIP = _networkInfo!['currentIP'] as String?;
    final isDetecting = _networkInfo!['isDetecting'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                isDetecting 
                    ? Icons.wifi_find
                    : currentIP != null 
                        ? Icons.wifi 
                        : Icons.wifi_off,
                color: isDetecting 
                    ? Colors.orange
                    : currentIP != null 
                        ? Colors.green 
                        : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                isDetecting 
                    ? 'Detectando rede...'
                    : currentIP != null 
                        ? 'Conectado: $currentIP'
                        : 'Sem conexão',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (widget.allowForceRefresh)
                InkWell(
                  onTap: _isLoading ? null : _forceRefresh,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: _isLoading
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.refresh,
                            size: 16,
                            color: Colors.blue,
                          ),
                  ),
                ),
            ],
          ),
          
          // Detalhes (opcional)
          if (widget.showDetails && currentIP != null) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            
            // URL base atual
            _buildDetailRow(
              'URL Base:',
              _networkInfo!['currentBaseUrl'] as String? ?? 'N/A',
            ),
            
            // IPs disponíveis
            if (_networkInfo!['possibleIPs'] != null) ...[
              const SizedBox(height: 4),
              _buildDetailRow(
                'IPs disponíveis:',
                (_networkInfo!['possibleIPs'] as List).join(', '),
              ),
            ],
            
            // Porta
            const SizedBox(height: 4),
            _buildDetailRow(
              'Porta:',
              _networkInfo!['port']?.toString() ?? 'N/A',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget compacto apenas com o status da conexão
class NetworkStatusIndicator extends StatefulWidget {
  const NetworkStatusIndicator({super.key});

  @override
  State<NetworkStatusIndicator> createState() => _NetworkStatusIndicatorState();
}

class _NetworkStatusIndicatorState extends State<NetworkStatusIndicator> {
  String? _currentIP;
  
  @override
  void initState() {
    super.initState();
    _loadCurrentIP();
  }

  void _loadCurrentIP() {
    setState(() {
      _currentIP = ApiConstants.getCurrentIP();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _currentIP != null 
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _currentIP != null ? Icons.wifi : Icons.wifi_off,
            size: 12,
            color: _currentIP != null ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            _currentIP ?? 'Offline',
            style: TextStyle(
              fontSize: 10,
              color: _currentIP != null ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}