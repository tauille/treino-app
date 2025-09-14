import 'package:flutter/material.dart';
import '../core/helpers/exercise_assets_helper.dart';

/// Widget para testar se os assets de exercícios estão funcionando
class ExerciseImageTestWidget extends StatelessWidget {
  const ExerciseImageTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste de Assets de Exercícios'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Testando Assets de Exercícios:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Teste 1: Asset direto
            _buildTestSection(
              'Teste 1: Asset Direto',
              'assets/images/exercicios/teste.jpg',
              Colors.blue,
            ),
            
            const SizedBox(height: 20),
            
            // Teste 2: Helper - Flexão
            _buildHelperTestSection('Teste 2: Helper - Flexão', 'flexão'),
            
            const SizedBox(height: 20),
            
            // Teste 3: Helper - Prancha
            _buildHelperTestSection('Teste 3: Helper - Prancha', 'prancha'),
            
            const SizedBox(height: 20),
            
            // Botão de Debug
            ElevatedButton(
              onPressed: _runDebugTests,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Executar Testes de Debug'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection(String title, String assetPath, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          'Caminho: $assetPath',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('ERRO AO CARREGAR ASSET: $assetPath');
                print('ERRO: $error');
                return Container(
                  color: Colors.red.shade100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 32),
                      const SizedBox(height: 4),
                      Text(
                        'Erro',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelperTestSection(String title, String exerciseName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          'Exercício: $exerciseName',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        FutureBuilder<String?>(
          future: _resolveAsset(exerciseName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final assetPath = snapshot.data;
            print('ASSET RESOLVIDO PARA "$exerciseName": $assetPath');

            if (assetPath == null) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  color: Colors.orange.shade100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported, color: Colors.orange, size: 32),
                      const SizedBox(height: 4),
                      Text(
                        'Sem Asset',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('ERRO AO CARREGAR ASSET RESOLVIDO: $assetPath');
                    print('ERRO: $error');
                    return Container(
                      color: Colors.red.shade100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, color: Colors.red, size: 32),
                          const SizedBox(height: 4),
                          Text(
                            'Erro Load',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
      print('ASSET "$asset" EXISTE: $exists');
      return exists ? asset : null;
    }
    return null;
  }

  void _runDebugTests() {
    print('\n===== TESTES DE DEBUG DE ASSETS =====');
    
    // Testar helper
    ExerciseAssetsHelper.debugPrintMappings();
    
    // Testar exercícios específicos
    final testExercises = ['flexão', 'prancha', 'agachamento', 'teste'];
    
    for (final exercise in testExercises) {
      ExerciseAssetsHelper.debugTestAsset(exercise);
    }
    
    print('===== FIM DOS TESTES =====\n');
  }
}
