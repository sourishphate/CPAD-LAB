using Microsoft.Maui.Controls;
using Microsoft.Maui.Graphics;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;

namespace WidgetDemoApp
{
    // =====================================================================
    //  TRANSACTION MODEL
    // =====================================================================
    public class Transaction : INotifyPropertyChanged
    {
        public string Id       { get; set; } = Guid.NewGuid().ToString();
        public string Title    { get; set; } = string.Empty;
        public double Amount   { get; set; }
        public string Type     { get; set; } = "Income";
        public string Category { get; set; } = "Other";

        public string Icon        => Category;
        public string AmountText  => (Type == "Income" ? "+" : "-") + "Rs." + Amount.ToString("F2");
        public string AmountColor => Type == "Income" ? "#1B8A4E" : "#C62828";
        public string BadgeColor  => Type == "Income" ? "#E6F4ED" : "#FDEAEA";
        public string Meta        => Category + " - " + Type;

        public event PropertyChangedEventHandler? PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string? prop = null)
            => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(prop));
    }

    // =====================================================================
    //  SKILL MODEL  (for the horizontally scrolling CollectionView — Lab req)
    // =====================================================================
    public class SkillTag
    {
        public string Name { get; set; } = string.Empty;
    }

    // =====================================================================
    //  PAGE
    // =====================================================================
    public partial class MainPage : ContentPage
    {
        // ---- Transactions -----------------------------------------------
        private readonly ObservableCollection<Transaction> _all = new();

        private string _selectedType     = "Income";
        private string _selectedCategory = "Other";
        private bool   _filterExpenses   = false;

        private List<Button> _chipButtons = new();

        public Command<string> DeleteCommand { get; }

        // ---- Profile card state (Like counter — Lab req) ----------------
        private int _likeCount = 0;

        // ---- Skills list (CollectionView — Lab req) ---------------------
        public ObservableCollection<SkillTag> Skills { get; } = new()
        {
            new SkillTag { Name = "C#" },
            new SkillTag { Name = "Xamarin" },
            new SkillTag { Name = ".NET" },
            new SkillTag { Name = "MAUI" },
            new SkillTag { Name = "XAML" },
            new SkillTag { Name = "Git" },
            new SkillTag { Name = "MVVM" },
        };

        // -----------------------------------------------------------------
        public MainPage()
        {
            DeleteCommand = new Command<string>(id =>
            {
                var match = _all.FirstOrDefault(t => t.Id == id);
                if (match != null)
                {
                    _all.Remove(match);
                    RenderList();
                    UpdateStats();
                }
            });

            BindingContext = this;
            InitializeComponent();

            _chipButtons = new List<Button>
            {
                CatFood, CatTravel, CatShopping, CatBills, CatSalary, CatOther
            };

            SeedTransactions();
            RenderList();
            UpdateStats();
            HighlightChip("Other");
        }

        // ---- Seed data --------------------------------------------------
        private void SeedTransactions()
        {
            var seeds = new List<Transaction>
            {
                new Transaction { Title = "Monthly Salary",   Amount = 45000, Type = "Income",  Category = "Salary"   },
                new Transaction { Title = "Electricity Bill", Amount = 1200,  Type = "Expense", Category = "Bills"    },
                new Transaction { Title = "Grocery Run",      Amount = 850,   Type = "Expense", Category = "Food"     },
                new Transaction { Title = "Freelance Work",   Amount = 8000,  Type = "Income",  Category = "Other"    },
                new Transaction { Title = "Metro Card",       Amount = 500,   Type = "Expense", Category = "Travel"   },
                new Transaction { Title = "New Headphones",   Amount = 2200,  Type = "Expense", Category = "Shopping" },
            };
            foreach (var t in seeds) _all.Add(t);
        }

        // ---- Render transaction list via BindableLayout -----------------
        // CollectionView inside ScrollView causes sizing bugs in MAUI.
        // BindableLayout on a plain StackLayout renders inside ScrollView
        // correctly and shows all items without clipping.
        private void RenderList()
        {
            IEnumerable<Transaction> filtered = _all;

            if (_filterExpenses)
                filtered = filtered.Where(t => t.Type == "Expense");

            var list = filtered.ToList();

            BindableLayout.SetItemsSource(TransactionList, list);

            int count = list.Count;
            ListHeading.Text     = count > 0 ? "Transactions (" + count + ")" : "Transactions";
            EmptyState.IsVisible = count == 0;
        }

        // ---- Stats ------------------------------------------------------
        private void UpdateStats()
        {
            double income  = _all.Where(t => t.Type == "Income") .Sum(t => t.Amount);
            double expense = _all.Where(t => t.Type == "Expense").Sum(t => t.Amount);
            double balance = income - expense;

            IncomeLabel.Text  = "Rs." + income.ToString("F2");
            ExpenseLabel.Text = "Rs." + expense.ToString("F2");

            BalanceLabel.Text      = (balance < 0 ? "-" : "") + "Rs." + Math.Abs(balance).ToString("F2");
            BalanceLabel.TextColor = balance < 0
                ? Color.FromArgb("#FCA5A5")
                : Colors.White;
        }

        // ---- Profile: Like button (Lab req – interactive counter) -------
        private void OnLikeClicked(object sender, EventArgs e)
        {
            _likeCount++;
            LikeBtn.Text = $"👍 Like ({_likeCount})";
        }

        // ---- Profile: Message button (Lab req – DisplayAlert) -----------
        private async void OnMessageClicked(object sender, EventArgs e)
        {
            await DisplayAlert("Message", "Your message has been sent!", "OK");
        }

        // ---- Profile: Post comment (Lab req – Entry widget) -------------
        private async void OnPostCommentClicked(object sender, EventArgs e)
        {
            string comment = CommentEntry.Text?.Trim() ?? string.Empty;
            if (string.IsNullOrEmpty(comment))
            {
                await DisplayAlert("Empty Comment", "Please type something before posting.", "OK");
                return;
            }
            await DisplayAlert("Comment Posted", $"\"{comment}\" was posted!", "OK");
            CommentEntry.Text = string.Empty;
        }

        // ---- Type toggle ------------------------------------------------
        private void OnIncomeTypeClicked(object sender, EventArgs e)
        {
            _selectedType = "Income";
            IncomeTypeBtn.BackgroundColor  = Color.FromArgb("#1B8A4E");
            IncomeTypeBtn.TextColor        = Colors.White;
            IncomeTypeBtn.FontAttributes   = FontAttributes.Bold;
            ExpenseTypeBtn.BackgroundColor = Color.FromArgb("#E5E7EB");
            ExpenseTypeBtn.TextColor       = Color.FromArgb("#4B5563");
            ExpenseTypeBtn.FontAttributes  = FontAttributes.None;
            AddBtn.Text            = "+ Add Income";
            AddBtn.BackgroundColor = Color.FromArgb("#1B8A4E");
        }

        private void OnExpenseTypeClicked(object sender, EventArgs e)
        {
            _selectedType = "Expense";
            ExpenseTypeBtn.BackgroundColor = Color.FromArgb("#C62828");
            ExpenseTypeBtn.TextColor       = Colors.White;
            ExpenseTypeBtn.FontAttributes  = FontAttributes.Bold;
            IncomeTypeBtn.BackgroundColor  = Color.FromArgb("#E5E7EB");
            IncomeTypeBtn.TextColor        = Color.FromArgb("#4B5563");
            IncomeTypeBtn.FontAttributes   = FontAttributes.None;
            AddBtn.Text            = "- Add Expense";
            AddBtn.BackgroundColor = Color.FromArgb("#C62828");
        }

        // ---- Category chip ----------------------------------------------
        private void OnCategoryClicked(object sender, EventArgs e)
        {
            if (sender is Button btn)
            {
                _selectedCategory = btn.Text;
                HighlightChip(btn.Text);
            }
        }

        private void HighlightChip(string selected)
        {
            foreach (var btn in _chipButtons)
            {
                bool on = btn.Text == selected;
                btn.BackgroundColor = on ? Color.FromArgb("#1A237E") : Color.FromArgb("#F3F4F6");
                btn.TextColor       = on ? Colors.White               : Color.FromArgb("#4B5563");
                btn.FontAttributes  = on ? FontAttributes.Bold        : FontAttributes.None;
            }
        }

        // ---- Filter switch ----------------------------------------------
        private void OnFilterToggled(object sender, ToggledEventArgs e)
        {
            _filterExpenses = e.Value;
            RenderList();
        }

        // ---- Add transaction button -------------------------------------
        private async void OnAddClicked(object sender, EventArgs e)
        {
            string title  = TitleEntry.Text?.Trim()  ?? string.Empty;
            string amtStr = AmountEntry.Text?.Trim() ?? string.Empty;

            if (string.IsNullOrEmpty(title))
            {
                await DisplayAlert("Missing Title", "Please enter a title.", "OK");
                return;
            }

            if (!double.TryParse(amtStr, out double amount) || amount <= 0)
            {
                await DisplayAlert("Invalid Amount", "Please enter a valid positive amount.", "OK");
                return;
            }

            _all.Insert(0, new Transaction
            {
                Title    = title,
                Amount   = amount,
                Type     = _selectedType,
                Category = _selectedCategory,
            });

            TitleEntry.Text  = string.Empty;
            AmountEntry.Text = string.Empty;

            RenderList();
            UpdateStats();
        }
    }
}