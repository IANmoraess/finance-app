/// Constantes globais do app: rotas, strings de UI e limites de negócio.
abstract final class AppRoutes {
  static const home          = '/';
  static const addTransaction = '/add-transaction';
}

abstract final class AppStrings {
  static const appName    = 'FinanciApp';
  static const dashboard  = 'Início';
  static const history    = 'Histórico';
  static const reports    = 'Relatórios';
  static const more       = 'Mais';
  static const newEntry   = 'Nova Movimentação';
  static const save       = 'Salvar';
}

abstract final class AppLimits {
  static const maxAmountCents = 999999999; // R$ 9.999.999,99
  static const recentLimit    = 5;
}
