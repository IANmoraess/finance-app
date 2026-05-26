import 'package:flutter/foundation.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';

class TransactionController extends ChangeNotifier {
  final TransactionRepository _repo;

  TransactionController(this._repo);

  List<Transaction> getAll() => _repo.getAll();

  List<Transaction> getByMonth(int year, int month) =>
      _repo.getByMonth(year, month);

  List<Transaction> getByDateRange(DateTime start, DateTime end) =>
      _repo.getByDateRange(start, end);

  double getTotalByType(TransactionType type, {int? year, int? month}) =>
      _repo.getTotalByType(type, year: year, month: month);

  List<Transaction> getRecent({int limit = 5}) {
    final all = _repo.getAll().toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return all.take(limit).toList();
  }

  void add(Transaction t) {
    _repo.add(t);
    notifyListeners();
  }

  void delete(String id) {
    _repo.delete(id);
    notifyListeners();
  }
}
