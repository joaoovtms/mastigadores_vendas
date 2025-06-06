import 'package:flutter/material.dart';
import '../models/configuracao.dart';
import '../controllers/configuracao_controllers.dart';
import '../components/drawer_menu.dart';

class ConfiguracaoScreen extends StatefulWidget {
  const ConfiguracaoScreen({super.key});

  @override
  State<ConfiguracaoScreen> createState() => _ConfiguracaoScreenState();
}

class _ConfiguracaoScreenState extends State<ConfiguracaoScreen> {
  final ConfiguracaoDao dao = ConfiguracaoDao();
  final TextEditingController servidorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarConfiguracao();
  }

  void carregarConfiguracao() async {
    final config = await dao.obterConfiguracao();
    if (config != null) {
      servidorController.text = config.servidor;
    }
  }

  void salvarConfiguracao() async {
    final config = Configuracao(
      id: 1,
      servidor: servidorController.text.trim(),
    );

    await dao.salvarConfiguracao(config);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuração salva com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuração')),
      drawer: DrawerCustom(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: servidorController,
              decoration: const InputDecoration(labelText: 'Link do Servidor'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: salvarConfiguracao,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC3002),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
