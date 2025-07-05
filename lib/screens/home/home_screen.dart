// lib/screens/home/home_screen.dart - ARQUIVO COMPLETO CORRIGIDO

import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/trial_service.dart';
import '../../core/constants/api_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final TrialService _trialService = TrialService();
  
  List<String> _testResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    try {
      // Teste 1: Storage Service
      _addResult('🧪 Testando Storage Service...');
      await _storageService.initialize();
      final storageTest = await _storageService.testStorage();
      _addResult(storageTest ? '✅ Storage: OK' : '❌ Storage: FALHOU');

      // Teste 2: Trial Service  
      _addResult('🧪 Testando Trial Service...');
      await _trialService.initialize();
      final isFirstOpen = await _trialService.isFirstAppOpen();
      _addResult('📱 Primeira abertura: ${isFirstOpen ? "SIM" : "NÃO"}');

      // Teste 3: Configurações
      _addResult('🧪 Verificando configurações...');
      _addResult('🔗 API URL: ${ApiConstants.baseUrl}');
      
      // Teste 4: Trial Info
      _addResult('🧪 Informações do Trial...');
      final trialInfo = await _trialService.getTrialInfo();
      _addResult('⏰ Status: ${trialInfo['status_display']}');
      _addResult('🎁 Deve mostrar oferta: ${trialInfo['should_show_offer']}');

      _addResult('🎉 Todos os testes concluídos!');

    } catch (e) {
      _addResult('❌ Erro nos testes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }

  Future<void> _resetTrialSystem() async {
    try {
      _addResult('🔄 Resetando sistema de trial...');
      await _trialService.resetTrialSystem();
      await _storageService.clearAll();
      _addResult('✅ Sistema resetado! Reinicie o app.');
    } catch (e) {
      _addResult('❌ Erro ao resetar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treino App - Testes'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _runTests,
            icon: const Icon(Icons.refresh),
            tooltip: 'Executar testes novamente',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Card(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.science,
                      color: const Color(0xFF4CAF50),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Testes de Sistema',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Verificando se tudo está funcionando',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Loading indicator
            if (_isLoading)
              const LinearProgressIndicator(
                backgroundColor: Color(0xFFE0E0E0),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),

            const SizedBox(height: 16),

            // Resultados dos testes
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.list_alt),
                          const SizedBox(width: 8),
                          const Text(
                            'Resultados dos Testes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_testResults.length} linhas',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: _testResults.isEmpty
                            ? const Center(
                                child: Text(
                                  'Executando testes...',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _testResults.length,
                                itemBuilder: (context, index) {
                                  final result = _testResults[index];
                                  Color? textColor;
                                  
                                  if (result.startsWith('✅')) {
                                    textColor = Colors.green;
                                  } else if (result.startsWith('❌')) {
                                    textColor = Colors.red;
                                  } else if (result.startsWith('🧪')) {
                                    textColor = Colors.blue;
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Text(
                                      result,
                                      style: TextStyle(
                                        fontFamily: 'Courier',
                                        fontSize: 13,
                                        color: textColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _runTests,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Executar Testes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resetTrialSystem,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset Trial'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Informações de debug
            Card(
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Informações de Debug',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'API: ${ApiConstants.baseUrl}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Courier',
                      ),
                    ),
                    Text(
                      'Versão: 1.0.0+1 (teste)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Mostrar logs no console
          _storageService.printDebugInfo();
          _trialService.printTrialDebugInfo();
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.bug_report, color: Colors.white),
        tooltip: 'Imprimir logs no console',
      ),
    );
  }
}