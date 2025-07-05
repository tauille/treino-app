// lib/screens/test/api_test_screen.dart
import 'package:flutter/material.dart';
import '../../core/utils/api_test.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({Key? key}) : super(key: key);

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final ScrollController _scrollController = ScrollController();
  List<String> _logs = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _addLog('🧪 Tela de teste da API carregada');
    _addLog('📱 Dispositivo: ${Theme.of(context).platform}');
    _addLog('🌐 URL Base: ${ApiConstants.baseUrl}');
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
    
    // Auto-scroll para o final
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    
    // Também imprimir no console
    print(message);
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  Future<void> _runTest(String testName, Future<void> Function() testFunction) async {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
    });
    
    _addLog('\n🔄 Iniciando: $testName');
    
    try {
      await testFunction();
      _addLog('✅ Concluído: $testName');
    } catch (e) {
      _addLog('❌ Erro em $testName: $e');
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🧪 Teste da API'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: _clearLogs,
            tooltip: 'Limpar logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Informações da API
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🌐 URL da API:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${ApiConstants.baseUrl}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _isRunning ? Icons.sync : Icons.check_circle,
                      color: _isRunning ? Colors.orange : Colors.green,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _isRunning ? 'Executando teste...' : 'Pronto para testar',
                      style: TextStyle(
                        color: _isRunning ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Botões de teste
          Container(
            padding: EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TestButton(
                  label: '🔍 Conectividade',
                  onPressed: _isRunning ? null : () => _runTest(
                    'Teste de Conectividade',
                    () async {
                      await ApiTest.testConnection();
                    },
                  ),
                ),
                _TestButton(
                  label: '🔐 Registro',
                  onPressed: _isRunning ? null : () => _runTest(
                    'Teste de Registro',
                    () async {
                      await ApiTest.testRegister();
                    },
                  ),
                ),
                _TestButton(
                  label: '🔑 Login',
                  onPressed: _isRunning ? null : () => _runTest(
                    'Teste de Login',
                    () async {
                      await ApiTest.testLogin();
                    },
                  ),
                ),
                _TestButton(
                  label: '🏋️ Treinos',
                  onPressed: _isRunning ? null : () => _runTest(
                    'Teste de Treinos',
                    () async {
                      await ApiTest.testTreinos();
                    },
                  ),
                ),
                _TestButton(
                  label: '🆕 Criar Treino',
                  onPressed: _isRunning ? null : () => _runTest(
                    'Teste de Criação',
                    () async {
                      await ApiTest.testCreateTreino();
                    },
                  ),
                ),
                _TestButton(
                  label: '📊 Status',
                  onPressed: _isRunning ? null : () => _runTest(
                    'Status do Usuário',
                    () async {
                      await ApiTest.testUserStatus();
                    },
                  ),
                ),
                _TestButton(
                  label: '🧪 TODOS',
                  backgroundColor: Colors.green,
                  onPressed: _isRunning ? null : () => _runTest(
                    'Todos os Testes',
                    () async {
                      await ApiTest.runAllTests();
                    },
                  ),
                ),
              ],
            ),
          ),
          
          Divider(),
          
          // Área de logs
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.terminal, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Logs dos Testes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '${_logs.length} linhas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _logs.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhum log ainda.\nExecute algum teste!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: _logs.length,
                              itemBuilder: (context, index) {
                                final log = _logs[index];
                                Color textColor = Colors.white;
                                
                                // Colorir logs baseado no conteúdo
                                if (log.contains('✅')) {
                                  textColor = Colors.green.shade300;
                                } else if (log.contains('❌')) {
                                  textColor = Colors.red.shade300;
                                } else if (log.contains('⚠️')) {
                                  textColor = Colors.orange.shade300;
                                } else if (log.contains('🔍') || log.contains('📡')) {
                                  textColor = Colors.blue.shade300;
                                } else if (log.contains('💡')) {
                                  textColor = Colors.yellow.shade300;
                                }
                                
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 1),
                                  child: SelectableText(
                                    log,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: textColor,
                                      height: 1.2,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  const _TestButton({
    required this.label,
    this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.blue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}

// ========================================
// EXTENSÃO PARA ADICIONAR À SUA NAVEGAÇÃO
// ========================================

/*
Para usar essa tela, adicione em qualquer lugar do seu app:

// Botão temporário de teste (remover em produção)
if (!kReleaseMode) // Só mostrar em debug
  FloatingActionButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ApiTestScreen()),
      );
    },
    child: Icon(Icons.bug_report),
    backgroundColor: Colors.red,
  ),

OU adicionar como item de menu:

ListTile(
  leading: Icon(Icons.api),
  title: Text('Testar API'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ApiTestScreen()),
    );
  },
),
*/