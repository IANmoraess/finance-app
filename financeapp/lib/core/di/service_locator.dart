import 'package:financeapp/features/transactions/data/repositories/mock_transaction_repository.dart';
import 'package:financeapp/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:financeapp/features/transactions/presentation/controllers/transaction_controller.dart';

abstract final class Injector {
  static late final TransactionRepository transactionRepository;
  static late final TransactionController transactionController;

  static void init() {
    transactionRepository = MockTransactionRepository();
    transactionController = TransactionController(transactionRepository);
  }
}
