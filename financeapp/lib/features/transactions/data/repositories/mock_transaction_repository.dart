import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class MockTransactionRepository implements TransactionRepository {
  final List<Transaction> _data = _build();

  static List<Transaction> _build() {
    final now = DateTime.now();
    DateTime d(int days) => now.subtract(Duration(days: days));

    return [
      Transaction(id: '1',  title: 'Salário',       amount: 5200,   type: TransactionType.income,     category: TransactionCategory.salary,        date: d(5)),
      Transaction(id: '2',  title: 'iFood',          amount: 45.90,  type: TransactionType.expense,    category: TransactionCategory.food,          date: d(0)),
      Transaction(id: '3',  title: 'Farmácia',       amount: 32.00,  type: TransactionType.expense,    category: TransactionCategory.health,        date: d(0)),
      Transaction(id: '4',  title: 'Uber',           amount: 18.50,  type: TransactionType.expense,    category: TransactionCategory.transport,     date: d(0)),
      Transaction(id: '5',  title: 'Tesouro Direto', amount: 500,    type: TransactionType.investment, category: TransactionCategory.investment,    date: d(1)),
      Transaction(id: '6',  title: 'Mercado',        amount: 230,    type: TransactionType.expense,    category: TransactionCategory.food,          date: d(1)),
      Transaction(id: '7',  title: 'Aluguel',        amount: 1200,   type: TransactionType.expense,    category: TransactionCategory.housing,       date: d(3)),
      Transaction(id: '8',  title: 'Netflix',        amount: 45.90,  type: TransactionType.expense,    category: TransactionCategory.entertainment, date: d(4)),
      Transaction(id: '9',  title: 'Freelance',      amount: 800,    type: TransactionType.income,     category: TransactionCategory.freelance,     date: d(6)),
      Transaction(id: '10', title: 'Ações ITSA4',    amount: 300,    type: TransactionType.investment, category: TransactionCategory.investment,    date: d(6)),
      Transaction(id: '11', title: 'Restaurante',    amount: 95,     type: TransactionType.expense,    category: TransactionCategory.food,          date: d(7)),
      Transaction(id: '12', title: 'Academia',       amount: 120,    type: TransactionType.expense,    category: TransactionCategory.health,        date: d(8)),
      Transaction(id: '13', title: 'Spotify',        amount: 21.90,  type: TransactionType.expense,    category: TransactionCategory.entertainment, date: d(10)),
      Transaction(id: '14', title: 'Curso Online',   amount: 199,    type: TransactionType.expense,    category: TransactionCategory.education,     date: d(12)),
      Transaction(id: '15', title: 'Gasolina',       amount: 180,    type: TransactionType.expense,    category: TransactionCategory.transport,     date: d(14)),
      // mês anterior
      Transaction(id: '16', title: 'Salário',        amount: 5200,   type: TransactionType.income,     category: TransactionCategory.salary,        date: d(35)),
      Transaction(id: '17', title: 'Mercado',        amount: 310,    type: TransactionType.expense,    category: TransactionCategory.food,          date: d(36)),
      Transaction(id: '18', title: 'Aluguel',        amount: 1200,   type: TransactionType.expense,    category: TransactionCategory.housing,       date: d(37)),
      Transaction(id: '19', title: 'Tesouro Direto', amount: 600,    type: TransactionType.investment, category: TransactionCategory.investment,    date: d(38)),
      Transaction(id: '20', title: 'Uber',           amount: 65,     type: TransactionType.expense,    category: TransactionCategory.transport,     date: d(40)),
      Transaction(id: '21', title: 'Freelance',      amount: 1200,   type: TransactionType.income,     category: TransactionCategory.freelance,     date: d(42)),
      Transaction(id: '22', title: 'Restaurante',    amount: 150,    type: TransactionType.expense,    category: TransactionCategory.food,          date: d(44)),
      // 2 meses atrás
      Transaction(id: '23', title: 'Salário',        amount: 5200,   type: TransactionType.income,     category: TransactionCategory.salary,        date: d(65)),
      Transaction(id: '24', title: 'Mercado',        amount: 280,    type: TransactionType.expense,    category: TransactionCategory.food,          date: d(67)),
      Transaction(id: '25', title: 'Aluguel',        amount: 1200,   type: TransactionType.expense,    category: TransactionCategory.housing,       date: d(68)),
      Transaction(id: '26', title: 'CDB',            amount: 400,    type: TransactionType.investment, category: TransactionCategory.investment,    date: d(70)),
      // 3 meses atrás
      Transaction(id: '27', title: 'Salário',        amount: 5200,   type: TransactionType.income,     category: TransactionCategory.salary,        date: d(95)),
      Transaction(id: '28', title: 'Mercado',        amount: 350,    type: TransactionType.expense,    category: TransactionCategory.food,          date: d(97)),
      Transaction(id: '29', title: 'Aluguel',        amount: 1200,   type: TransactionType.expense,    category: TransactionCategory.housing,       date: d(98)),
      Transaction(id: '30', title: 'Freelance',      amount: 900,    type: TransactionType.income,     category: TransactionCategory.freelance,     date: d(100)),
      // 4 meses atrás
      Transaction(id: '31', title: 'Salário',        amount: 5200,   type: TransactionType.income,     category: TransactionCategory.salary,        date: d(125)),
      Transaction(id: '32', title: 'Mercado',        amount: 290,    type: TransactionType.expense,    category: TransactionCategory.food,          date: d(127)),
      Transaction(id: '33', title: 'Aluguel',        amount: 1200,   type: TransactionType.expense,    category: TransactionCategory.housing,       date: d(128)),
      // 5 meses atrás
      Transaction(id: '34', title: 'Salário',        amount: 5200,   type: TransactionType.income,     category: TransactionCategory.salary,        date: d(155)),
      Transaction(id: '35', title: 'Mercado',        amount: 320,    type: TransactionType.expense,    category: TransactionCategory.food,          date: d(157)),
      Transaction(id: '36', title: 'Aluguel',        amount: 1200,   type: TransactionType.expense,    category: TransactionCategory.housing,       date: d(158)),
    ];
  }

  @override
  List<Transaction> getAll() => List.unmodifiable(_data);

  @override
  List<Transaction> getByMonth(int year, int month) => _data
      .where((t) => t.date.year == year && t.date.month == month)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  @override
  List<Transaction> getByDateRange(DateTime start, DateTime end) => _data
      .where((t) =>
          !t.date.isBefore(DateTime(start.year, start.month, start.day)) &&
          !t.date.isAfter(DateTime(end.year, end.month, end.day, 23, 59, 59)))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  @override
  void add(Transaction t) => _data.add(t);

  @override
  void delete(String id) => _data.removeWhere((t) => t.id == id);

  @override
  double getTotalByType(TransactionType type, {int? year, int? month}) => _data
      .where((t) =>
          t.type == type &&
          (year == null  || t.date.year  == year) &&
          (month == null || t.date.month == month))
      .fold(0.0, (sum, t) => sum + t.amount);
}
