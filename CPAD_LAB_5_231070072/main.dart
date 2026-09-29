// ignore: deprecated_member_use
import 'dart:html';

// ══════════════════════════════════════════════════════════════
//  Data model
// ══════════════════════════════════════════════════════════════

class Transaction {
  final String id;
  final String description;
  final double amount;
  final String category;
  final bool isExpense;
  final DateTime date;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.isExpense,
    required this.date,
  });
}

// ══════════════════════════════════════════════════════════════
//  State
// ══════════════════════════════════════════════════════════════

final List<Transaction> _transactions = [];
bool _isExpense = true;

// ══════════════════════════════════════════════════════════════
//  Category helpers
// ══════════════════════════════════════════════════════════════

const Map<String, String> _catColor = {
  'food': 'var(--cat-food)',
  'transport': 'var(--cat-transport)',
  'shopping': 'var(--cat-shopping)',
  'health': 'var(--cat-health)',
  'bills': 'var(--cat-bills)',
  'income': 'var(--cat-income)',
  'other': 'var(--cat-other)',
};

const Map<String, String> _catLabel = {
  'food': 'Food & Drinks',
  'transport': 'Transport',
  'shopping': 'Shopping',
  'health': 'Health',
  'bills': 'Bills & Utilities',
  'income': 'Salary / Income',
  'other': 'Other',
};

// ══════════════════════════════════════════════════════════════
//  Formatting helpers
// ══════════════════════════════════════════════════════════════

String _rupee(double v) => '₹${v.abs().toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    )}';

String _formatDate(DateTime d) {
  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${months[d.month]} ${d.day}, ${d.year}';
}

String _formatMonth(DateTime d) {
  const months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return '${months[d.month]} ${d.year}';
}

// ══════════════════════════════════════════════════════════════
//  DOM element references
// ══════════════════════════════════════════════════════════════

late final InputElement _descInput;
late final InputElement _amountInput;
late final SelectElement _categorySelect;
late final ButtonElement _btnExpense;
late final ButtonElement _btnIncome;
late final ButtonElement _btnAdd;

late final DivElement _balanceDisplay;
late final DivElement _totalIncomeEl;
late final DivElement _totalExpenseEl;
late final UListElement _catBreakdown;
late final DivElement _monthLabelEl;

late final UListElement _txList;
late final SpanElement _txCount;
late final DivElement _emptyState;

// ══════════════════════════════════════════════════════════════
//  Render — sidebar stats
// ══════════════════════════════════════════════════════════════

void _renderStats() {
  double income = 0;
  double expense = 0;
  final Map<String, double> byCat = {};

  for (final tx in _transactions) {
    if (tx.isExpense) {
      expense += tx.amount;
      byCat[tx.category] = (byCat[tx.category] ?? 0) + tx.amount;
    } else {
      income += tx.amount;
    }
  }

  final balance = income - expense;

  // Balance display + colour class
  _balanceDisplay.text = _rupee(balance);
  _balanceDisplay.classes.removeAll(['positive', 'negative']);
  if (balance > 0)
    _balanceDisplay.classes.add('positive');
  else if (balance < 0) _balanceDisplay.classes.add('negative');

  // Income / Expense totals
  _totalIncomeEl.text = _rupee(income);
  _totalExpenseEl.text = _rupee(expense);

  // Category breakdown list — clear and rebuild
  _catBreakdown.children.clear();

  if (byCat.isEmpty) {
    _catBreakdown.append(
      LIElement()
        ..style.cssText = 'font-size:0.78rem; color:var(--muted);'
        ..text = 'No expense categories yet.',
    );
  } else {
    final sorted = byCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sorted) {
      final dot = SpanElement()
        ..className = 'cat-dot'
        ..style.background = _catColor[entry.key] ?? 'var(--cat-other)';

      final name = SpanElement()
        ..className = 'cat-name'
        ..text = _catLabel[entry.key] ?? entry.key;

      final amt = SpanElement()
        ..className = 'cat-amount'
        ..text = _rupee(entry.value);

      _catBreakdown.append(
        LIElement()
          ..className = 'cat-item'
          ..append(dot)
          ..append(name)
          ..append(amt),
      );
    }
  }

  // Month label
  _monthLabelEl.text = _formatMonth(DateTime.now());
}

// ══════════════════════════════════════════════════════════════
//  Render — transaction list
// ══════════════════════════════════════════════════════════════

void _renderList() {
  _txList.children.clear();

  final count = _transactions.length;
  _txCount.text = '$count ${count == 1 ? "entry" : "entries"}';

  if (count == 0) {
    _emptyState.style.display = 'block';
    return;
  }
  _emptyState.style.display = 'none';

  // Newest first
  final reversed = _transactions.reversed.toList();

  for (final tx in reversed) {
    final dot = SpanElement()
      ..className = 'tx-dot'
      ..style.background = _catColor[tx.category] ?? 'var(--cat-other)';

    final descDiv = DivElement()
      ..className = 'tx-desc'
      ..append(Element.tag('strong')..text = tx.description)
      ..append(SpanElement()
        ..text =
            '${_catLabel[tx.category] ?? tx.category}  ·  ${_formatDate(tx.date)}');

    final amountLabel =
        tx.isExpense ? '- ${_rupee(tx.amount)}' : '+ ${_rupee(tx.amount)}';

    final amountDiv = DivElement()
      ..className = 'tx-amount ${tx.isExpense ? "expense" : "income"}'
      ..text = amountLabel;

    // Remove button — DOM node removal demo
    final delBtn = ButtonElement()
      ..className = 'tx-delete'
      ..title = 'Remove'
      ..text = '×';

    delBtn.onClick.listen((_) {
      _transactions.removeWhere((t) => t.id == tx.id);
      _renderList();
      _renderStats();
    });

    _txList.append(
      LIElement()
        ..className = 'tx-item'
        ..append(dot)
        ..append(descDiv)
        ..append(amountDiv)
        ..append(delBtn),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  Type toggle
// ══════════════════════════════════════════════════════════════

void _setType(bool expense) {
  _isExpense = expense;

  _btnExpense.classes.removeAll(['active-expense', 'active-income']);
  _btnIncome.classes.removeAll(['active-expense', 'active-income']);

  if (expense) {
    _btnExpense.classes.add('active-expense');
  } else {
    _btnIncome.classes.add('active-income');
  }
}

// ══════════════════════════════════════════════════════════════
//  Add transaction
// ══════════════════════════════════════════════════════════════

void _addTransaction() {
  final desc = (_descInput.value ?? '').trim();
  final rawAmt = (_amountInput.value ?? '').trim();
  final cat = _categorySelect.value ?? 'other';

  if (desc.isEmpty) {
    _shake(_descInput);
    return;
  }

  final amount = double.tryParse(rawAmt);
  if (amount == null || amount <= 0) {
    _shake(_amountInput);
    return;
  }

  final tx = Transaction(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    description: desc,
    amount: amount,
    category: cat,
    isExpense: _isExpense,
    date: DateTime.now(),
  );

  _transactions.add(tx);

  _descInput.value = '';
  _amountInput.value = '';
  _descInput.focus();

  _renderList();
  _renderStats();
}

void _shake(Element el) {
  el.style.borderColor = 'var(--danger)';
  Future.delayed(const Duration(milliseconds: 600), () {
    el.style.borderColor = '';
  });
}

// ══════════════════════════════════════════════════════════════
//  Entry point
// ══════════════════════════════════════════════════════════════

void main() {
  _descInput = querySelector('#tx-desc') as InputElement;
  _amountInput = querySelector('#tx-amount') as InputElement;
  _categorySelect = querySelector('#tx-category') as SelectElement;
  _btnExpense = querySelector('#btn-expense') as ButtonElement;
  _btnIncome = querySelector('#btn-income') as ButtonElement;
  _btnAdd = querySelector('#btn-add') as ButtonElement;

  _balanceDisplay = querySelector('#balance-display') as DivElement;
  _totalIncomeEl = querySelector('#total-income') as DivElement;
  _totalExpenseEl = querySelector('#total-expense') as DivElement;
  _catBreakdown = querySelector('#cat-breakdown') as UListElement;
  _monthLabelEl = querySelector('#month-label') as DivElement;

  _txList = querySelector('#transaction-list') as UListElement;
  _txCount = querySelector('#tx-count') as SpanElement;
  _emptyState = querySelector('#empty-state') as DivElement;

  _btnExpense.onClick.listen((_) => _setType(true));
  _btnIncome.onClick.listen((_) => _setType(false));
  _btnAdd.onClick.listen((_) => _addTransaction());

  _descInput.onKeyDown.listen((e) {
    if (e.keyCode == KeyCode.ENTER) _addTransaction();
  });
  _amountInput.onKeyDown.listen((e) {
    if (e.keyCode == KeyCode.ENTER) _addTransaction();
  });

  _renderStats();
  _renderList();
}
