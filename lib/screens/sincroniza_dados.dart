import 'package:flutter/material.dart';
import '../controllers/sincronizacao_controller.dart';
import '../components/drawer_menu.dart';

class SincronizacaoScreen extends StatefulWidget {
  const SincronizacaoScreen({super.key});

  @override
  State<SincronizacaoScreen> createState() => _SincronizacaoScreenState();
}

class _SincronizacaoScreenState extends State<SincronizacaoScreen> {
  final SincronizacaoController sincronizacaoController =
      SincronizacaoController();

  String log = '';

  Future<void> sincronizar() async {
    setState(() => log = 'Sincronizando...');

    try {
      await sincronizacaoController.sincronizarTudo();
      setState(() => log = 'Sincronização concluída com sucesso!');
    } catch (e) {
      setState(() => log = 'Erro na sincronização: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronização de Dados')),
      drawer: DrawerCustom(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 65),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: sincronizar,
              child: const Text('Sincronizar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 100),
              ),
            ),
            const SizedBox(height: 20),
            Text(log),
          ],
        ),
      ),
    );
  }
}
