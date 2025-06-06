import 'package:app_vendas/controllers/pedido_controller.dart';
import 'package:app_vendas/models/pedido.dart';
import 'package:flutter/material.dart';
import 'list_client.dart';
import 'list_produto.dart';
import 'list_usuario.dart';
import 'list_pedidos.dart';
import 'sincroniza_dados.dart';
import 'configuracao_screen.dart';
import '../controllers/cliente_controller.dart';
import '../controllers/produto_controller.dart';
import '../controllers/usuario_controller.dart';
import 'login_screen.dart';
import '../components/drawer_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final clienteController = ClienteController();
  final produtoController = ProdutoController();
  final usuarioController = UsuarioController();
  final pedidoController = PedidoController();

  int totalClientes = 0;
  int totalProdutos = 0;
  int totalUsuarios = 0;
  int totalPedidos = 0;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final clientes = await clienteController.loadClientes();
    final produtos = await produtoController.listarProdutos();
    final usuarios = await usuarioController.listarUsuarios();
    final pedidos = await pedidoController.listarPedidos();

    setState(() {
      totalClientes = clientes.length;
      totalProdutos = produtos.length;
      totalUsuarios = usuarios.length;
      totalPedidos = pedidos.length;
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _resumoCard(String label, int total, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 35, color: const Color(0xFF00123C)),
            const SizedBox(height: 8),
            Text(
              '$total',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00123C),
              ),
            ),
            Text(label, style: const TextStyle(color: Color(0xFF00123C))),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(String label, IconData icon, Widget screen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          ).then((_) => _carregarDados()); // <-- Atualiza ao voltar
        },
        icon: Icon(icon, size: 24),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC3002),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem vindo(a)'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      drawer: const DrawerCustom(),
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Resumo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _resumoCard('Produtos', totalProdutos, Icons.inventory_2),
                  _resumoCard('Clientes', totalClientes, Icons.people),
                  _resumoCard('Usuários', totalUsuarios, Icons.person),
                  _resumoCard('Pedidos', totalPedidos, Icons.receipt_long),
                ],
              ),
              const SizedBox(height: 32),
              // Navegação
              _menuButton(
                'Produtos',
                Icons.inventory_2_outlined,
                const ListarProdutosScreen(),
              ),
              const SizedBox(height: 16),
              _menuButton(
                'Clientes',
                Icons.people_outline,
                const ListarClientesScreen(),
              ),
              const SizedBox(height: 16),
              _menuButton(
                'Usuários',
                Icons.person_outline,
                const ListarUsuariosScreen(),
              ),
              const SizedBox(height: 16),
              _menuButton(
                'Pedidos',
                Icons.receipt_long,
                const ListarPedidosScreen(),
              ),
              const SizedBox(height: 16),
              _menuButton(
                'Configuração',
                Icons.settings,
                const ConfiguracaoScreen(),
              ),
              const SizedBox(height: 16),
              _menuButton(
                'Sincronizar Dados',
                Icons.sync,
                const SincronizacaoScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
