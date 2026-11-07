using Microsoft.Maui.Controls;
using Microsoft.Maui.Graphics;
using System;
using System.Collections.Generic;

namespace WidgetDemoApp
{
    public partial class MainPage : ContentPage
    {
        // ── State ────────────────────────────────────────────────────────
        private bool _cookingStarted = false;
        private bool _isSaved        = false;
        private int  _servings       = 4;
        private int  _stepsComplete  = 0;

        // Tracks which steps are done (1–6)
        private readonly HashSet<int> _doneSteps = new();

        // Base ingredient quantities at 4 servings
        // Stored as (value, unit) so we can scale the numeric part
        private readonly (double value, string unit)[] _baseIngredients =
        {
            (250,  "g"),
            (150,  "ml"),
            (200,  "g"),
            (10,   "leaves"),
            (2,    "tbsp"),
            (1,    "tsp"),
        };

        // Named ingredient labels — matched by index to _baseIngredients
        private Label[] _ingLabels = null!;

        // ── Constructor ──────────────────────────────────────────────────
        public MainPage()
        {
            InitializeComponent();

            // Build the ingredient label array after InitializeComponent
            // so the x:Name references are resolved
            _ingLabels = new[] { Ing1, Ing2, Ing3, Ing4, Ing5, Ing6 };
        }

        // ── FEATURE 1: Save / Heart toggle ───────────────────────────────
        // Tapping the heart frame on the hero image toggles saved state.
        // Heart fills red and label changes to show it is saved.
        private void OnSaveTapped(object sender, EventArgs e)
        {
            _isSaved = !_isSaved;

            HeartLabel.Text      = _isSaved ? "♥" : "♡";
            HeartLabel.TextColor = _isSaved
                ? Color.FromArgb("#FF4444")
                : Colors.White;
            SaveLabel.Text = _isSaved ? "Saved!" : "Save";
        }

        // ── FEATURE 2: Serving size adjuster ─────────────────────────────
        // + and - buttons change _servings (min 1, max 20).
        // All ingredient quantities scale proportionally from the base (4).
        private void OnServingPlus(object sender, EventArgs e)
        {
            if (_servings >= 20) return;
            _servings++;
            UpdateServings();
        }

        private void OnServingMinus(object sender, EventArgs e)
        {
            if (_servings <= 1) return;
            _servings--;
            UpdateServings();
        }

        private void UpdateServings()
        {
            ServingLabel.Text = _servings.ToString();

            double ratio = (double)_servings / 4.0;

            for (int i = 0; i < _baseIngredients.Length; i++)
            {
                double scaled = _baseIngredients[i].value * ratio;
                string unit   = _baseIngredients[i].unit;

                // Format cleanly: whole number if no decimal part
                string formatted = scaled == Math.Floor(scaled)
                    ? ((int)scaled).ToString()
                    : scaled.ToString("F1");

                _ingLabels[i].Text = formatted + " " + unit;
            }
        }

        // ── FEATURE 3: Step checker ───────────────────────────────────────
        // Tapping a step Frame marks it done: green background, grey text.
        // Tapping again unchecks it. Counter at top updates live.
        private void OnStepTapped(object sender, TappedEventArgs e)
        {
            if (e.Parameter is not string param) return;
            if (!int.TryParse(param, out int stepNum)) return;

            // Look up the Frame and Label for this step by name
            Frame  stepFrame = GetStepFrame(stepNum);
            Label  stepLabel = GetStepLabel(stepNum);
            Frame  stepBadge = GetStepBadge(stepNum);

            if (_doneSteps.Contains(stepNum))
            {
                // Uncheck
                _doneSteps.Remove(stepNum);
                stepFrame.BackgroundColor = Colors.White;
                stepFrame.BorderColor     = Color.FromArgb("#F0E6DC");
                stepLabel.TextColor       = Color.FromArgb("#4E342E");
                stepLabel.TextDecorations = TextDecorations.None;
                stepBadge.BackgroundColor = Color.FromArgb("#E64A19");
            }
            else
            {
                // Check
                _doneSteps.Add(stepNum);
                stepFrame.BackgroundColor = Color.FromArgb("#F0FFF4");
                stepFrame.BorderColor     = Color.FromArgb("#A5D6A7");
                stepLabel.TextColor       = Color.FromArgb("#9E9E9E");
                stepLabel.TextDecorations = TextDecorations.Strikethrough;
                stepBadge.BackgroundColor = Color.FromArgb("#4CAF50");
            }

            _stepsComplete    = _doneSteps.Count;
            StepsLabel.Text   = _stepsComplete + " / 6 done";
            StepsLabel.TextColor = _stepsComplete == 6
                ? Color.FromArgb("#4CAF50")
                : Color.FromArgb("#9E9E9E");

            // If all 6 steps done, show a congratulation alert
            if (_stepsComplete == 6)
            {
                Dispatcher.Dispatch(async () =>
                {
                    await DisplayAlert("All Done!", "Your pizza is ready. Enjoy!", "Let's Eat!");
                });
            }
        }

        // ── Helper: get named controls by step number ─────────────────────
        private Frame GetStepFrame(int n) => n switch
        {
            1 => Step1Frame, 2 => Step2Frame, 3 => Step3Frame,
            4 => Step4Frame, 5 => Step5Frame, _ => Step6Frame,
        };

        private Label GetStepLabel(int n) => n switch
        {
            1 => Step1Label, 2 => Step2Label, 3 => Step3Label,
            4 => Step4Label, 5 => Step5Label, _ => Step6Label,
        };

        private Frame GetStepBadge(int n) => n switch
        {
            1 => Step1Badge, 2 => Step2Badge, 3 => Step3Badge,
            4 => Step4Badge, 5 => Step5Badge, _ => Step6Badge,
        };

        // ── FEATURE 4: Personal Notes Entry ──────────────────────────────
        // Triggered when the user taps the Return / Done key on the
        // keyboard after typing a note. Dismisses the keyboard and
        // confirms the note was saved with a brief alert.
        private async void OnNotesCompleted(object sender, EventArgs e)
        {
            string note = NotesEntry.Text?.Trim() ?? string.Empty;
            if (!string.IsNullOrEmpty(note))
            {
                await DisplayAlert("Note Saved", $"\"{note}\" has been noted!", "OK");
            }
        }

        // ── FEATURE 5: Start / Stop cooking button ────────────────────────
        // Toggles _cookingStarted. While cooking is active the
        // ActivityIndicator spins and the status row is visible,
        // giving live visual feedback that the session is running.
        private async void OnCookClicked(object sender, EventArgs e)
        {
            if (!_cookingStarted)
            {
                _cookingStarted = true;

                // Show and start the ActivityIndicator
                CookingStatusRow.IsVisible    = true;
                CookingIndicator.IsRunning    = true;

                CookBtn.Text            = "Stop Cooking";
                CookBtn.BackgroundColor = Color.FromArgb("#4E342E");

                await DisplayAlert("Let's Cook!", "Follow the steps above. Good luck!", "OK");
            }
            else
            {
                _cookingStarted = false;

                // Hide and stop the ActivityIndicator
                CookingIndicator.IsRunning    = false;
                CookingStatusRow.IsVisible    = false;

                CookBtn.Text            = "Start Cooking";
                CookBtn.BackgroundColor = Color.FromArgb("#E64A19");

                await DisplayAlert("Cooking Stopped", "Come back when you are ready.", "OK");
            }
        }
    }
}