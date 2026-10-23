import { useState } from "react";
import {
  Alert,
  FlatList,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";

// ══════════════════════════════════════════════════════════════
//  COLOUR TOKENS
// ══════════════════════════════════════════════════════════════
const C = {
  bg: "#F4F6FB",
  card: "#FFFFFF",
  header: "#1A237E",
  headerDark: "#111766",
  accent: "#3949AB",
  income: "#1B8A4E",
  incomeBg: "#E6F4ED",
  expense: "#C62828",
  expenseBg: "#FDEAEA",
  text: "#111827",
  sub: "#4B5563",
  muted: "#9CA3AF",
  border: "#E5E7EB",
  white: "#FFFFFF",
};

// ══════════════════════════════════════════════════════════════
//  CONSTANTS
// ══════════════════════════════════════════════════════════════
const CATEGORIES = ["Food", "Travel", "Shopping", "Bills", "Salary", "Other"];

const CAT_ICON: Record<string, string> = {
  Food: "🍔",
  Travel: "✈️",
  Shopping: "🛍️",
  Bills: "📄",
  Salary: "💰",
  Other: "💸",
};

type TxType = "Income" | "Expense";

type Transaction = {
  id: string;
  title: string;
  amount: number;
  type: TxType;
  category: string;
};

// ══════════════════════════════════════════════════════════════
//  WIDGET 1 — NavHeader
//  Visible header bar showing current screen name
// ══════════════════════════════════════════════════════════════
function NavHeader({
  title,
  onBack,
  rightLabel,
  onRight,
}: {
  title: string;
  onBack?: () => void;
  rightLabel?: string;
  onRight?: () => void;
}) {
  return (
    <View style={styles.navHeader}>
      {/* Left — back button or spacer */}
      {onBack ? (
        <TouchableOpacity
          style={styles.navSide}
          onPress={onBack}
          activeOpacity={0.7}
        >
          <Text style={styles.navBackArrow}>‹</Text>
          <Text style={styles.navBackLabel}>Back</Text>
        </TouchableOpacity>
      ) : (
        <View style={styles.navSide} />
      )}

      {/* Centre — title */}
      <Text style={styles.navTitle}>{title}</Text>

      {/* Right — optional action */}
      {onRight && rightLabel ? (
        <TouchableOpacity
          style={[styles.navSide, styles.navSideRight]}
          onPress={onRight}
          activeOpacity={0.7}
        >
          <Text style={styles.navRightLabel}>{rightLabel}</Text>
        </TouchableOpacity>
      ) : (
        <View style={styles.navSide} />
      )}
    </View>
  );
}

// ══════════════════════════════════════════════════════════════
//  WIDGET 2 — SummaryCard
//  Shows total balance, total income and total expense
// ══════════════════════════════════════════════════════════════
function SummaryCard({
  balance,
  income,
  expense,
}: {
  balance: number;
  income: number;
  expense: number;
}) {
  return (
    <View style={styles.summaryCard}>
      {/* Balance */}
      <Text style={styles.summaryBalLabel}>Total Balance</Text>
      <Text style={styles.summaryBalAmount}>
        {balance < 0 ? "-" : ""}₹{Math.abs(balance).toFixed(2)}
      </Text>

      {/* Income / Expense row */}
      <View style={styles.summaryRow}>
        {/* Income box */}
        <View style={styles.summaryBox}>
          <View style={styles.summaryPill}>
            <Text style={styles.summaryPillText}>↑</Text>
          </View>
          <Text style={styles.summaryBoxLabel}>Income</Text>
          <Text style={[styles.summaryBoxAmt, { color: "#6EE7A8" }]}>
            ₹{income.toFixed(2)}
          </Text>
        </View>

        <View style={styles.summaryDivider} />

        {/* Expense box */}
        <View style={styles.summaryBox}>
          <View style={[styles.summaryPill, { backgroundColor: "#C62828" }]}>
            <Text style={styles.summaryPillText}>↓</Text>
          </View>
          <Text style={styles.summaryBoxLabel}>Expense</Text>
          <Text style={[styles.summaryBoxAmt, { color: "#FCA5A5" }]}>
            ₹{expense.toFixed(2)}
          </Text>
        </View>
      </View>
    </View>
  );
}

// ══════════════════════════════════════════════════════════════
//  WIDGET 3 — CategoryChip
//  Selectable category button (Food, Travel, etc.)
// ══════════════════════════════════════════════════════════════
function CategoryChip({
  label,
  selected,
  onPress,
}: {
  label: string;
  selected: boolean;
  onPress: () => void;
}) {
  return (
    <TouchableOpacity
      style={[styles.chip, selected && styles.chipSelected]}
      onPress={onPress}
      activeOpacity={0.75}
    >
      <Text style={styles.chipIcon}>{CAT_ICON[label]}</Text>
      <Text style={[styles.chipText, selected && styles.chipTextSelected]}>
        {label}
      </Text>
    </TouchableOpacity>
  );
}

// ══════════════════════════════════════════════════════════════
//  WIDGET 4 — TransactionItem
//  One row in the list with amount and delete button
// ══════════════════════════════════════════════════════════════
function TransactionItem({
  item,
  onDelete,
}: {
  item: Transaction;
  onDelete: (id: string) => void;
}) {
  const isIncome = item.type === "Income";

  return (
    <View style={styles.txItem}>
      {/* Icon badge */}
      <View
        style={[
          styles.txIconBadge,
          { backgroundColor: isIncome ? C.incomeBg : C.expenseBg },
        ]}
      >
        <Text style={{ fontSize: 18 }}>{CAT_ICON[item.category]}</Text>
      </View>

      {/* Title + meta */}
      <View style={styles.txLeft}>
        <Text style={styles.txTitle}>{item.title}</Text>
        <Text style={styles.txMeta}>
          {item.category} • {item.type}
        </Text>
      </View>

      {/* Amount */}
      <Text
        style={[styles.txAmount, { color: isIncome ? C.income : C.expense }]}
      >
        {isIncome ? "+" : "-"}₹{item.amount.toFixed(2)}
      </Text>

      {/* Delete button */}
      <TouchableOpacity
        style={styles.txDeleteBtn}
        onPress={() => onDelete(item.id)}
        activeOpacity={0.7}
      >
        <Text style={styles.txDeleteText}>✕</Text>
      </TouchableOpacity>
    </View>
  );
}

// ══════════════════════════════════════════════════════════════
//  WIDGET 5 — AddForm
//  Form to enter title, amount, type and category
// ══════════════════════════════════════════════════════════════
function AddForm({ onAdd }: { onAdd: (t: Transaction) => void }) {
  // Local state for all form fields
  const [title, setTitle] = useState("");
  const [amount, setAmount] = useState("");
  const [type, setType] = useState<TxType>("Income");
  const [category, setCategory] = useState("Other");

  function handleSubmit() {
    // Validate — title must not be empty
    if (!title.trim()) {
      Alert.alert("Invalid Input", "Please enter a title.");
      return;
    }
    // Validate — amount must be a positive number
    const parsed = parseFloat(amount);
    if (isNaN(parsed) || parsed <= 0) {
      Alert.alert("Invalid Input", "Please enter a valid positive amount.");
      return;
    }
    // Create transaction with unique id using Date.now()
    onAdd({
      id: Date.now().toString(),
      title: title.trim(),
      amount: parsed,
      type,
      category,
    });
    // Reset fields after successful add
    setTitle("");
    setAmount("");
    setType("Income");
    setCategory("Other");
  }

  const isExpense = type === "Expense";

  return (
    <ScrollView
      contentContainerStyle={styles.formScroll}
      keyboardShouldPersistTaps="handled"
    >
      {/* ── Type toggle ── */}
      <Text style={styles.fieldLabel}>Transaction Type</Text>
      <View style={styles.typeRow}>
        {(["Income", "Expense"] as TxType[]).map((t) => (
          <TouchableOpacity
            key={t}
            style={[
              styles.typeBtn,
              type === t &&
                (t === "Income" ? styles.typeBtnIncome : styles.typeBtnExpense),
            ]}
            onPress={() => setType(t)}
            activeOpacity={0.8}
          >
            <Text
              style={[styles.typeBtnText, type === t && styles.typeBtnTextOn]}
            >
              {t === "Income" ? "↑  Income" : "↓  Expense"}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* ── Title input ── */}
      <Text style={styles.fieldLabel}>Title</Text>
      <TextInput
        style={styles.input}
        placeholder="e.g. Lunch, Salary, Rent"
        placeholderTextColor={C.muted}
        value={title}
        onChangeText={setTitle}
      />

      {/* ── Amount input ── */}
      <Text style={styles.fieldLabel}>Amount (₹)</Text>
      <TextInput
        style={styles.input}
        placeholder="0.00"
        placeholderTextColor={C.muted}
        value={amount}
        onChangeText={setAmount}
        keyboardType="numeric"
      />

      {/* ── Category chips ── */}
      <Text style={styles.fieldLabel}>Category</Text>
      <View style={styles.chipRow}>
        {CATEGORIES.map((c) => (
          <CategoryChip
            key={c}
            label={c}
            selected={category === c}
            onPress={() => setCategory(c)}
          />
        ))}
      </View>

      {/* ── Submit button ── */}
      <TouchableOpacity
        style={[
          styles.addBtn,
          isExpense ? styles.addBtnExpense : styles.addBtnIncome,
        ]}
        onPress={handleSubmit}
        activeOpacity={0.85}
      >
        <Text style={styles.addBtnText}>
          {isExpense ? "↓  Add Expense" : "↑  Add Income"}
        </Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

// ══════════════════════════════════════════════════════════════
//  SCREEN 1 — Dashboard
//  Shows SummaryCard + transaction list + FAB to add
// ══════════════════════════════════════════════════════════════
function DashboardScreen({
  transactions,
  onGoAdd,
  onDelete,
}: {
  transactions: Transaction[];
  onGoAdd: () => void;
  onDelete: (id: string) => void;
}) {
  // Calculate totals using filter() and reduce() on every render
  const totalIncome = transactions
    .filter((t) => t.type === "Income")
    .reduce((sum, t) => sum + t.amount, 0);

  const totalExpense = transactions
    .filter((t) => t.type === "Expense")
    .reduce((sum, t) => sum + t.amount, 0);

  const balance = totalIncome - totalExpense;

  return (
    <SafeAreaView style={styles.safeArea} edges={["bottom"]}>
      <NavHeader title="Expense Manager" rightLabel="+ Add" onRight={onGoAdd} />

      <FlatList
        data={transactions}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.listContent}
        // SummaryCard and heading placed in header so whole screen scrolls
        ListHeaderComponent={
          <>
            <SummaryCard
              balance={balance}
              income={totalIncome}
              expense={totalExpense}
            />
            <Text style={styles.sectionHeading}>
              {transactions.length > 0
                ? `Transactions (${transactions.length})`
                : "Transactions"}
            </Text>
          </>
        }
        renderItem={({ item }) => (
          <TransactionItem item={item} onDelete={onDelete} />
        )}
        // Shown when transactions array is empty
        ListEmptyComponent={
          <View style={styles.emptyBox}>
            <Text style={styles.emptyIcon}>📭</Text>
            <Text style={styles.emptyTitle}>No transactions yet</Text>
            <Text style={styles.emptySub}>
              Tap the + button to record your first one.
            </Text>
            <TouchableOpacity
              style={styles.emptyBtn}
              onPress={onGoAdd}
              activeOpacity={0.8}
            >
              <Text style={styles.emptyBtnText}>Add Transaction</Text>
            </TouchableOpacity>
          </View>
        }
      />

      {/* Floating action button */}
      <TouchableOpacity
        style={styles.fab}
        onPress={onGoAdd}
        activeOpacity={0.85}
      >
        <Text style={styles.fabText}>+</Text>
      </TouchableOpacity>
    </SafeAreaView>
  );
}

// ══════════════════════════════════════════════════════════════
//  SCREEN 2 — Add Transaction
//  Contains the AddForm; navigates back on successful add
// ══════════════════════════════════════════════════════════════
function AddTransactionScreen({
  onAdd,
  onBack,
}: {
  onAdd: (t: Transaction) => void;
  onBack: () => void;
}) {
  // After a valid add, go back to dashboard automatically
  function handleAdd(t: Transaction) {
    onAdd(t);
    onBack();
  }

  return (
    <SafeAreaView style={styles.safeArea} edges={["bottom"]}>
      <NavHeader title="Add Transaction" onBack={onBack} />
      <AddForm onAdd={handleAdd} />
    </SafeAreaView>
  );
}

// ══════════════════════════════════════════════════════════════
//  ROOT — App Widget
//  Holds the transactions array in state.
//  Switches screens via useState — same pattern as Lab 6.
//  Passes addTransaction / deleteTransaction as props (callbacks)
//  to child screens so data flows correctly.
// ══════════════════════════════════════════════════════════════
export default function App() {
  // Screen navigation state — "dashboard" | "add"
  const [screen, setScreen] = useState<"dashboard" | "add">("dashboard");

  // Master transactions array in state
  const [transactions, setTransactions] = useState<Transaction[]>([]);

  // Add a new transaction — passed down as prop/callback
  function addTransaction(t: Transaction) {
    setTransactions((prev) => [t, ...prev]);
  }

  // Delete by id using filter() — passed down as prop/callback
  function deleteTransaction(id: string) {
    setTransactions((prev) => prev.filter((t) => t.id !== id));
  }

  return (
    // SafeAreaView with edges={["top"]} at root fixes the camera cutout
    // for ALL screens without needing to repeat it in each screen
    <SafeAreaView style={styles.root} edges={["top"]}>
      <StatusBar barStyle="light-content" backgroundColor={C.header} />

      {screen === "dashboard" && (
        <DashboardScreen
          transactions={transactions}
          onGoAdd={() => setScreen("add")}
          onDelete={deleteTransaction}
        />
      )}

      {screen === "add" && (
        <AddTransactionScreen
          onAdd={addTransaction}
          onBack={() => setScreen("dashboard")}
        />
      )}
    </SafeAreaView>
  );
}

// ══════════════════════════════════════════════════════════════
//  STYLES
// ══════════════════════════════════════════════════════════════
const styles = StyleSheet.create({
  // Root
  root: {
    flex: 1,
    backgroundColor: C.header, // header colour behind status bar
  },
  safeArea: {
    flex: 1,
    backgroundColor: C.bg,
  },

  // ── NavHeader ──────────────────────────────────────────────
  navHeader: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    backgroundColor: C.header,
    paddingHorizontal: 16,
    paddingVertical: 14,
  },
  navSide: {
    width: 72,
    flexDirection: "row",
    alignItems: "center",
  },
  navSideRight: {
    justifyContent: "flex-end",
  },
  navBackArrow: {
    fontSize: 30,
    color: C.white,
    lineHeight: 32,
  },
  navBackLabel: {
    fontSize: 15,
    color: C.white,
    marginLeft: 2,
  },
  navTitle: {
    fontSize: 17,
    fontWeight: "700",
    color: C.white,
    textAlign: "center",
    flex: 1,
  },
  navRightLabel: {
    fontSize: 15,
    color: "#A5B4FC",
    fontWeight: "600",
  },

  // ── SummaryCard ────────────────────────────────────────────
  summaryCard: {
    backgroundColor: C.header,
    borderRadius: 22,
    padding: 24,
    marginBottom: 20,
    alignItems: "center",
  },
  summaryBalLabel: {
    color: "#A5B4FC",
    fontSize: 13,
    marginBottom: 6,
    fontWeight: "500",
  },
  summaryBalAmount: {
    color: C.white,
    fontSize: 44,
    fontWeight: "800",
    marginBottom: 24,
    letterSpacing: -1,
  },
  summaryRow: {
    flexDirection: "row",
    width: "100%",
    justifyContent: "space-around",
    alignItems: "center",
  },
  summaryBox: {
    flex: 1,
    alignItems: "center",
  },
  summaryPill: {
    backgroundColor: C.income,
    width: 32,
    height: 32,
    borderRadius: 16,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 6,
  },
  summaryPillText: {
    color: C.white,
    fontSize: 16,
    fontWeight: "700",
  },
  summaryBoxLabel: {
    color: "#A5B4FC",
    fontSize: 12,
    marginBottom: 4,
  },
  summaryBoxAmt: {
    fontSize: 17,
    fontWeight: "700",
  },
  summaryDivider: {
    width: 1,
    height: 56,
    backgroundColor: "#2D3D8E",
    marginHorizontal: 12,
  },

  // ── FlatList ───────────────────────────────────────────────
  listContent: {
    padding: 16,
    paddingBottom: 110,
  },
  sectionHeading: {
    fontSize: 16,
    fontWeight: "700",
    color: C.text,
    marginBottom: 12,
  },

  // ── TransactionItem ────────────────────────────────────────
  txItem: {
    backgroundColor: C.card,
    borderRadius: 14,
    padding: 14,
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 10,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.06,
    shadowRadius: 3,
    elevation: 2,
  },
  txIconBadge: {
    width: 44,
    height: 44,
    borderRadius: 22,
    alignItems: "center",
    justifyContent: "center",
    marginRight: 12,
  },
  txLeft: {
    flex: 1,
  },
  txTitle: {
    fontSize: 15,
    fontWeight: "600",
    color: C.text,
  },
  txMeta: {
    fontSize: 12,
    color: C.muted,
    marginTop: 2,
  },
  txAmount: {
    fontSize: 15,
    fontWeight: "700",
    marginRight: 10,
  },
  txDeleteBtn: {
    backgroundColor: C.expenseBg,
    width: 30,
    height: 30,
    borderRadius: 15,
    alignItems: "center",
    justifyContent: "center",
  },
  txDeleteText: {
    color: C.expense,
    fontSize: 13,
    fontWeight: "700",
  },

  // ── Empty state ────────────────────────────────────────────
  emptyBox: {
    alignItems: "center",
    paddingTop: 48,
    paddingHorizontal: 32,
  },
  emptyIcon: {
    fontSize: 56,
    marginBottom: 16,
  },
  emptyTitle: {
    fontSize: 18,
    fontWeight: "700",
    color: C.sub,
    marginBottom: 8,
  },
  emptySub: {
    fontSize: 14,
    color: C.muted,
    textAlign: "center",
    lineHeight: 20,
    marginBottom: 24,
  },
  emptyBtn: {
    backgroundColor: C.accent,
    paddingHorizontal: 28,
    paddingVertical: 13,
    borderRadius: 12,
  },
  emptyBtnText: {
    color: C.white,
    fontWeight: "700",
    fontSize: 15,
  },

  // ── FAB ───────────────────────────────────────────────────
  fab: {
    position: "absolute",
    bottom: 28,
    right: 22,
    width: 58,
    height: 58,
    borderRadius: 29,
    backgroundColor: C.accent,
    alignItems: "center",
    justifyContent: "center",
    shadowColor: C.accent,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.45,
    shadowRadius: 8,
    elevation: 8,
  },
  fabText: {
    color: C.white,
    fontSize: 34,
    fontWeight: "300",
    lineHeight: 38,
  },

  // ── AddForm ────────────────────────────────────────────────
  formScroll: {
    padding: 16,
    paddingBottom: 60,
  },
  fieldLabel: {
    fontSize: 13,
    fontWeight: "600",
    color: C.sub,
    marginBottom: 8,
    marginTop: 6,
  },
  typeRow: {
    flexDirection: "row",
    marginBottom: 16,
  },
  typeBtn: {
    flex: 1,
    padding: 13,
    borderRadius: 10,
    borderWidth: 1.5,
    borderColor: C.border,
    alignItems: "center",
    backgroundColor: C.white,
    marginRight: 8,
  },
  typeBtnIncome: {
    backgroundColor: C.income,
    borderColor: C.income,
  },
  typeBtnExpense: {
    backgroundColor: C.expense,
    borderColor: C.expense,
  },
  typeBtnText: {
    color: C.muted,
    fontWeight: "600",
    fontSize: 14,
  },
  typeBtnTextOn: {
    color: C.white,
  },
  input: {
    borderWidth: 1.5,
    borderColor: C.border,
    borderRadius: 10,
    padding: 13,
    marginBottom: 16,
    fontSize: 15,
    backgroundColor: C.white,
    color: C.text,
  },

  // ── CategoryChip ───────────────────────────────────────────
  chipRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    marginBottom: 22,
  },
  chip: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 20,
    borderWidth: 1.5,
    borderColor: C.border,
    backgroundColor: C.white,
    marginRight: 8,
    marginBottom: 8,
  },
  chipSelected: {
    backgroundColor: C.header,
    borderColor: C.header,
  },
  chipIcon: {
    fontSize: 13,
    marginRight: 5,
  },
  chipText: {
    fontSize: 13,
    color: C.sub,
    fontWeight: "500",
  },
  chipTextSelected: {
    color: C.white,
    fontWeight: "700",
  },

  // ── Add button ─────────────────────────────────────────────
  addBtn: {
    padding: 16,
    borderRadius: 12,
    alignItems: "center",
    marginTop: 4,
  },
  addBtnIncome: {
    backgroundColor: C.income,
  },
  addBtnExpense: {
    backgroundColor: C.expense,
  },
  addBtnText: {
    color: C.white,
    fontWeight: "700",
    fontSize: 16,
  },
});
