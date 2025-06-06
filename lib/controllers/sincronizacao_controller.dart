import 'package:app_vendas/sincronizacoes/sincroniza_clientes.dart';
import 'package:app_vendas/sincronizacoes/sincroniza_pedidos.dart';
import 'package:app_vendas/sincronizacoes/sincroniza_produtos.dart';
import 'package:app_vendas/sincronizacoes/sincroniza_usuarios.dart';

class SincronizacaoController {
  final SincronizacaoCliente sincronizacaoCliente = SincronizacaoCliente();
  final SincronizacaoUsuario sincronizacaoUsuario = SincronizacaoUsuario();
  final SincronizacaoProduto sincronizacaoProduto = SincronizacaoProduto();
  final SincronizacaoPedido sincronizacaoPedido = SincronizacaoPedido();

  /// CHAMADA GERAL
  Future<void> sincronizarTudo() async {
    //  SINCRONIZA CLIENTE
    //  ========================================================================
    await sincronizacaoCliente.excluiClientesLocal();
    await sincronizacaoCliente.excluirClientesNoServidor();
    await sincronizacaoCliente.sincronizarClientes();
    await sincronizacaoCliente.enviarClientesParaServidor();

    //  SINCRONIZA USUARIO
    //  ========================================================================
    await sincronizacaoUsuario.excluiUsuariosLocal();
    await sincronizacaoUsuario.excluirUsuariosNoServidor();
    await sincronizacaoUsuario.sincronizarUsuarios();
    await sincronizacaoUsuario.enviarUsuariosParaServidor();

    //  SINCRONIZA PRODUTO
    //  ========================================================================
    await sincronizacaoProduto.excluiProdutosLocal();
    await sincronizacaoProduto.excluirProdutosNoServidor();
    await sincronizacaoProduto.sincronizarProdutos();
    await sincronizacaoProduto.enviarProdutosParaServidor();

    //  SINCRONIZA PEDIDOS
    //  ========================================================================
    await sincronizacaoPedido.excluirPedidosLocalmenteSeRemovidosNoServidor();
    await sincronizacaoPedido.excluirPedidosNoServidor();
    await sincronizacaoPedido.sincronizarPedidos();
    await sincronizacaoPedido.enviarPedidosParaServidor();
  }
}
