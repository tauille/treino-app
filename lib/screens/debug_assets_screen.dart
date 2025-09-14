import 'package:flutter/material.dart';
import '../core/helpers/exercise_assets_helper.dart';

class DebugAssetsScreen extends StatefulWidget {
  const DebugAssetsScreen({super.key});

  @override
  State<DebugAssetsScreen> createState() => _DebugAssetsScreenState();
}

class _DebugAssetsScreenState extends State<DebugAssetsScreen> {
  String _logOutput = 'Pronto para testar assets...';
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Assets'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botões de teste
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : _runAssetTests,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Testar Assets'),
                ),
                ElevatedButton(
                  onPressed: _isRunning ? null : _runMappingTests,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Testar Mapeamentos'),
                ),
                ElevatedButton(
                  onPressed: _clearLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Limpar'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Seção de teste visual
            const Text(
              'Teste Visual de Assets:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            _buildVisualTests(),

            const SizedBox(height: 20),

            // Log de saída
            const Text(
              'Log de Testes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _logOutput,
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

            if (_isRunning)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualTests() {
    final testExercises = ['flexão', 'prancha', 'agachamento', 'teste'];
    
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: testExercises.length,
        itemBuilder: (context, index) {
          final exercise = testExercises[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildExerciseCard(exercise),
          );
        },
      ),
    );
  }

  Widget _buildExerciseCard(String exerciseName) {
    return Column(
      children: [
        Text(
          exerciseName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FutureBuilder<String?>(
            future: _resolveAsset(exerciseName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final assetPath = snapshot.data;
              if (assetPath == null) {
                return Container(
                  color: Colors.red.shade100,
                  child: const Icon(Icons.image_not_supported, color: Colors.red),
                );
              }

              return ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.red.shade100,
                      child: const Icon(Icons.broken_image, color: Colors.red),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        FutureBuilder<String?>(
          future: _resolveAsset(exerciseName),
          builder: (context, snapshot) {
            final assetPath = snapshot.data;
            return Text(
              assetPath != null ? 'OK' : 'Erro',
              style: TextStyle(
                fontSize: 10,
                color: assetPath != null ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ],
    );
  }

  Future<String?> _resolveAsset(String exerciseName) async {
    final asset = ExerciseAssetsHelper.resolveExerciseAsset(exerciseName);
    if (asset != null) {
      final exists = await ExerciseAssetsHelper.assetExists(asset);
      return exists ? asset : null;
    }
    return null;
  }

  void _runAssetTests() async {
    setState(() {
      _isRunning = true;
      _logOutput = 'Iniciando teste de assets...\n';
    });

    try {
      _appendLog('🏋️ === TESTE DE ASSETS DE EXERCÍCIOS ===');
      
      // Testar exercícios específicos
      final testExercises = [
        'flexão',
        'prancha', 
        'agachamento',
        'supino reto',
        'teste',
        'exercicio inexistente'
      ];
      
      int assetsEncontrados = 0;
      int assetsTestados = 0;
      
      for (final exercise in testExercises) {
        assetsTestados++;
        _appendLog('\n🔍 Testando exercício: "$exercise"');
        
        // Resolver asset
        final assetPath = ExerciseAssetsHelper.resolveExerciseAsset(exercise);
        
        if (assetPath != null) {
          _appendLog('   Asset resolvido: $assetPath');
          
          // Verificar se existe fisicamente
          final exists = await ExerciseAssetsHelper.assetExists(assetPath);
          _appendLog('   Asset existe: $exists');
          
          if (exists) {
            assetsEncontrados++;
            _appendLog('   ✅ Asset OK');
          } else {
            _appendLog('   ⚠️ Asset não encontrado fisicamente');
          }
        } else {
          _appendLog('   ❌ Nenhum asset mapeado');
        }
      }
      
      _appendLog('\n📊 Resumo dos testes:');
      _appendLog('   Assets testados: $assetsTestados');
      _appendLog('   Assets encontrados: $assetsEncontrados');
      _appendLog('   Taxa de sucesso: ${(assetsEncontrados / assetsTestados * 100).toStringAsFixed(1)}%');
      
      // Testar helper methods
      _appendLog('\n🛠️ Testando métodos do helper...');
      
      // Testar lista de assets
      final allAssets = ExerciseAssetsHelper.getAllExerciseAssets();
      _appendLog('   Total de assets mapeados: ${allAssets.length}');
      
      // Testar obtenção de imagem
      final flexaoImage = await ExerciseAssetsHelper.getExerciseImagePath(
        'flexão', 
        exerciseId: 'test_123'
      );
      _appendLog('   Imagem para flexão: ${flexaoImage ?? "não encontrada"}');
      
      if (assetsEncontrados > 0) {
        _appendLog('\n✅ Teste concluído! ($assetsEncontrados assets funcionando)');
      } else {
        _appendLog('\n⚠️ Sistema funcionando, mas nenhum asset físico encontrado');
        _appendLog('💡 Dica: Adicione arquivos .jpg na pasta assets/images/exercicios/');
      }
      
    } catch (e) {
      _appendLog('\n❌ Erro no teste de assets: $e');
    }

    setState(() {
      _isRunning = false;
    });
  }

  void _runMappingTests() async {
    setState(() {
      _isRunning = true;
      _logOutput = 'Testando mapeamentos...\n';
    });

    try {
      _appendLog('🗺️ === TESTE DE MAPEAMENTOS ===');
      
      // Imprimir todos os mapeamentos
      final allAssets = ExerciseAssetsHelper.getAllExerciseAssets();
      _appendLog('\nTotal de exercícios mapeados: ${allAssets.length}');
      
      _appendLog('\nMapeamentos disponíveis:');
      for (int i = 0; i < allAssets.length; i++) {
        _appendLog('${i + 1}. ${allAssets[i]}');
      }
      
      // Testar normalização de strings
      _appendLog('\n🔧 Testando normalização:');
      final testStrings = ['Flexão de Braço', 'AGACHAMENTO', 'Supino Reto'];
      for (final str in testStrings) {
        final asset = ExerciseAssetsHelper.resolveExerciseAsset(str);
        _appendLog('   "$str" -> ${asset ?? "não encontrado"}');
      }
      
      _appendLog('\n✅ Teste de mapeamentos concluído!');
      
    } catch (e) {
      _appendLog('\n❌ Erro no teste de mapeamentos: $e');
    }

    setState(() {
      _isRunning = false;
    });
  }

  void _appendLog(String message) {
    setState(() {
      _logOutput += '\n$message';
    });
  }

  void _clearLog() {
    setState(() {
      _logOutput = 'Log limpo. Pronto para novos testes...';
    });
  }
}