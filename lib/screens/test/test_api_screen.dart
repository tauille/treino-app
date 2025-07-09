import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/utils/api_test.dart';
import '../../providers/auth_provider_google.dart';
import '../../widgets/common/loading_button.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/empty_state.dart';

/// Tela para testar conectividade e funcionalidades da API
/// Útil durante o desenvolvimento para debug
class TestApiScreen extends StatefulWidget {
  const TestApiScreen({super.key});

  @override
  State<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  bool _isTestingBasic = false;
  bool _isTestingAuth = false;
  bool _isTestingFull = false;
  
  Map<String, dynamic>? _basicTestResults;
  Map<String, dynamic>? _authTestResults;
  Map<String, dynamic>? _fullTestResults;
  
  String? _selectedTest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Teste de API',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _clearAllResults,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Limpar resultados',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            InfoCard.info(
              title: 'Testes de API',
              message: 'Use esta tela para testar a conectividade e funcionalidades da API durante o desenvolvimento.',
            ),
            
            const SizedBox(height: 24),
            
            // Botões de Teste
            _buildTestButtons(),
            
            const SizedBox(height: 24),
            
            // Resultados
            if (_basicTestResults != null || 
                _authTestResults != null || 
                _fullTestResults != null)
              _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Testes Disponíveis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Teste Básico
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.network_check,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Teste de Conectividade',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Testa conectividade básica, status da API e latência',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 16),
              
              LoadingButton(
                text: 'Executar Teste Básico',
                onPressed: _runBasicTest,
                isLoading: _isTestingBasic,
                icon: Icons.play_arrow,
                width: double.infinity,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Teste de Autenticação
        Consumer<AuthProviderGoogle>(
          builder: (context, authProvider, child) {
            return CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: Colors.green[600],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Teste de Autenticação',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    authProvider.isAuthenticated
                        ? 'Testa funcionalidades que requerem autenticação'
                        : 'Faça login para testar funcionalidades autenticadas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  LoadingButton(
                    text: 'Executar Teste de Auth',
                    onPressed: authProvider.isAuthenticated 
                        ? _runAuthTest 
                        : null,
                    isLoading: _isTestingAuth,
                    icon: Icons.play_arrow,
                    width: double.infinity,
                  ),
                ],
              ),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Teste Completo
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.rocket_launch,
                    color: Colors.purple[600],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Teste Completo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Executa todos os testes disponíveis e gera relatório completo',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 16),
              
              LoadingButton(
                text: 'Executar Teste Completo',
                onPressed: _runFullTest,
                isLoading: _isTestingFull,
                icon: Icons.play_arrow,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Resultados dos Testes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _copyResultsToClipboard,
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copiar'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Tabs para diferentes resultados
        if (_basicTestResults != null || 
            _authTestResults != null || 
            _fullTestResults != null)
          _buildResultTabs(),
        
        const SizedBox(height: 16),
        
        // Resultado selecionado
        _buildSelectedResult(),
      ],
    );
  }

  Widget _buildResultTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (_basicTestResults != null)
            _buildResultTab('Básico', 'basic'),
          
          if (_authTestResults != null)
            _buildResultTab('Autenticação', 'auth'),
          
          if (_fullTestResults != null)
            _buildResultTab('Completo', 'full'),
        ],
      ),
    );
  }

  Widget _buildResultTab(String title, String key) {
    final isSelected = _selectedTest == key;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedTest = key),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedResult() {
    Map<String, dynamic>? result;
    
    switch (_selectedTest) {
      case 'basic':
        result = _basicTestResults;
        break;
      case 'auth':
        result = _authTestResults;
        break;
      case 'full':
        result = _fullTestResults;
        break;
      default:
        // Mostrar o primeiro resultado disponível
        result = _fullTestResults ?? _authTestResults ?? _basicTestResults;
    }
    
    if (result == null) {
      return const EmptyState(
        icon: Icons.science,
        title: 'Nenhum resultado ainda',
        message: 'Execute um teste para ver os resultados aqui',
      );
    }
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do resultado
          Row(
            children: [
              Icon(
                _getResultIcon(result),
                color: _getResultColor(result),
              ),
              const SizedBox(width: 8),
              Text(
                _getResultTitle(result),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                _formatTimestamp(result['timestamp']),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Resumo
          if (result['summary'] != null)
            _buildSummary(result['summary']),
          
          const SizedBox(height: 16),
          
          // Detalhes dos testes
          if (result['tests'] != null)
            _buildTestDetails(result['tests']),
          
          // Duração total
          if (result['total_duration_ms'] != null) ...[
            const SizedBox(height: 16),
            Text(
              'Duração total: ${result['total_duration_ms']}ms',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummary(Map<String, dynamic> summary) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryStat(
              'Passou',
              '${summary['passed'] ?? 0}',
              Colors.green,
            ),
          ),
          Expanded(
            child: _buildSummaryStat(
              'Total',
              '${summary['total'] ?? 0}',
              Colors.blue,
            ),
          ),
          if (summary['success_rate'] != null)
            Expanded(
              child: _buildSummaryStat(
                'Taxa',
                '${summary['success_rate']}%',
                summary['success_rate'] >= 80 ? Colors.green : Colors.orange,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTestDetails(Map<String, dynamic> tests) {
    return Column(
      children: tests.entries.map((entry) {
        final testName = entry.key;
        final testResult = entry.value as Map<String, dynamic>;
        final success = testResult['success'] == true;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: success 
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: success 
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  testName.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (testResult['response_time_ms'] != null)
                Text(
                  '${testResult['response_time_ms']}ms',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ===== MÉTODOS =====

  Future<void> _runBasicTest() async {
    setState(() {
      _isTestingBasic = true;
      _selectedTest = 'basic';
    });

    try {
      final result = await ApiTestUtils.testBasicConnectivity();
      setState(() {
        _basicTestResults = result;
      });
    } catch (e) {
      _showError('Erro no teste básico: $e');
    } finally {
      setState(() {
        _isTestingBasic = false;
      });
    }
  }

  Future<void> _runAuthTest() async {
    final authProvider = Provider.of<AuthProviderGoogle>(context, listen: false);
    final token = authProvider.user != null 
        ? context.read<AuthProviderGoogle>().user?.toString() 
        : null;

    setState(() {
      _isTestingAuth = true;
      _selectedTest = 'auth';
    });

    try {
      final result = await ApiTestUtils.testAuthentication(token);
      setState(() {
        _authTestResults = result;
      });
    } catch (e) {
      _showError('Erro no teste de autenticação: $e');
    } finally {
      setState(() {
        _isTestingAuth = false;
      });
    }
  }

  Future<void> _runFullTest() async {
    final authProvider = Provider.of<AuthProviderGoogle>(context, listen: false);
    final token = authProvider.user != null 
        ? 'valid_token_here' // Simulado para o teste
        : null;

    setState(() {
      _isTestingFull = true;
      _selectedTest = 'full';
    });

    try {
      final result = await ApiTestUtils.runFullApiTest(authToken: token);
      setState(() {
        _fullTestResults = result;
      });
    } catch (e) {
      _showError('Erro no teste completo: $e');
    } finally {
      setState(() {
        _isTestingFull = false;
      });
    }
  }

  void _clearAllResults() {
    setState(() {
      _basicTestResults = null;
      _authTestResults = null;
      _fullTestResults = null;
      _selectedTest = null;
    });
  }

  void _copyResultsToClipboard() {
    Map<String, dynamic>? result;
    
    switch (_selectedTest) {
      case 'basic':
        result = _basicTestResults;
        break;
      case 'auth':
        result = _authTestResults;
        break;
      case 'full':
        result = _fullTestResults;
        break;
      default:
        result = _fullTestResults ?? _authTestResults ?? _basicTestResults;
    }
    
    if (result != null) {
      final textReport = ApiTestUtils.generateTextReport(result);
      Clipboard.setData(ClipboardData(text: textReport));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resultados copiados para a área de transferência'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ===== UTILITÁRIOS =====

  IconData _getResultIcon(Map<String, dynamic> result) {
    final summary = result['summary'];
    if (summary != null) {
      final passed = summary['passed'] ?? 0;
      final total = summary['total'] ?? 1;
      return passed == total ? Icons.check_circle : Icons.warning;
    }
    return Icons.info;
  }

  Color _getResultColor(Map<String, dynamic> result) {
    final summary = result['summary'];
    if (summary != null) {
      final passed = summary['passed'] ?? 0;
      final total = summary['total'] ?? 1;
      return passed == total ? Colors.green : Colors.orange;
    }
    return Colors.blue;
  }

  String _getResultTitle(Map<String, dynamic> result) {
    final summary = result['summary'];
    if (summary != null) {
      final passed = summary['passed'] ?? 0;
      final total = summary['total'] ?? 1;
      return passed == total ? 'Todos os testes passaram' : 'Alguns testes falharam';
    }
    return 'Resultado do teste';
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    
    try {
      final dateTime = DateTime.parse(timestamp.toString());
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}