import '../entities/transaction.dart';

abstract class TransactionRepository {
  List<Transaction> getAll();
  List<Transaction> getByMonth(int year, int month);
  List<Transaction> getByDateRange(DateTime start, DateTime end);
  void add(Transaction transaction);
  void delete(String id);
  double getTotalByType(TransactionType type, {int? year, int? month});
}
