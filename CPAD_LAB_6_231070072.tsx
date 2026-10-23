import { useState } from "react";
import {
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";

// ── Quiz Data ──────────────────────────────────────────────
const QUESTIONS = [
  {
    question: "What is the closest star to Earth?",
    options: ["Sirius", "Proxima Centauri", "Betelgeuse", "Vega"],
    answer: 1,
  },
  {
    question: "Which planet has the most moons?",
    options: ["Jupiter", "Saturn", "Uranus", "Neptune"],
    answer: 1,
  },
  {
    question: "What is a light-year a measure of?",
    options: ["Time", "Speed", "Distance", "Brightness"],
    answer: 2,
  },
  {
    question: "Which planet is known as the Red Planet?",
    options: ["Venus", "Mars", "Jupiter", "Mercury"],
    answer: 1,
  },
  {
    question: "What type of galaxy is the Milky Way?",
    options: ["Elliptical", "Irregular", "Barred Spiral", "Lenticular"],
    answer: 2,
  },
  {
    question: "What phenomenon occurs when a massive star collapses?",
    options: ["Solar Flare", "Pulsar", "Black Hole", "Nebula"],
    answer: 2,
  },
  {
    question: "Which space telescope was launched in 1990?",
    options: ["James Webb", "Hubble", "Spitzer", "Chandra"],
    answer: 1,
  },
  {
    question: "What is the force that keeps planets in orbit?",
    options: ["Magnetism", "Nuclear Force", "Gravity", "Dark Energy"],
    answer: 2,
  },
  {
    question: "How long does light from the Sun take to reach Earth?",
    options: ["8 seconds", "8 minutes", "8 hours", "8 days"],
    answer: 1,
  },
  {
    question: "What is the largest planet in our Solar System?",
    options: ["Saturn", "Neptune", "Jupiter", "Uranus"],
    answer: 2,
  },
];

// ── Colour tokens ───────────────────────────────────────────
const C = {
  bg: "#0B0F1A",
  surface: "#141929",
  card: "#1C2340",
  border: "#252D4A",
  accent: "#7C6AF7",
  accentLt: "#9D94F8",
  correct: "#3FB950",
  wrong: "#F85149",
  text: "#E6EDF3",
  muted: "#8B949E",
  star: "#F0C419",
  header: "#0F1420",
};

// ── Navigation Header ───────────────────────────────────────
// Simulates a native Stack Navigator header bar
function NavHeader({ title, onBack }) {
  return (
    <View style={styles.navHeader}>
      {onBack ? (
        <TouchableOpacity
          style={styles.backBtn}
          onPress={onBack}
          activeOpacity={0.7}
        >
          <Text style={styles.backArrow}>‹</Text>
          <Text style={styles.backLabel}>Back</Text>
        </TouchableOpacity>
      ) : (
        <View style={styles.backBtn} />
      )}
      <Text style={styles.navTitle}>{title}</Text>
      <View style={styles.backBtn} />
    </View>
  );
}

// ══════════════════════════════════════════════════════════════
//  SCREEN 1 — Welcome
// ══════════════════════════════════════════════════════════════
function WelcomeScreen({ onStart }) {
  return (
    <SafeAreaView style={styles.safeArea}>
      <NavHeader title="AstroQuiz" onBack={null} />

      <ScrollView contentContainerStyle={styles.welcomeContainer}>
        {/* Space banner */}
        <View style={styles.heroBanner}>
          <Text style={styles.heroBannerText}>🌌 Explore the Universe</Text>
        </View>

        <Text style={styles.bigEmoji}>🔭</Text>
        <Text style={styles.welcomeTitle}>AstroQuiz</Text>
        <Text style={styles.welcomeSub}>
          Test your knowledge of{"\n"}space, stars, and the cosmos
        </Text>

        {/* Info chips row */}
        <View style={styles.infoRow}>
          <View style={styles.infoChip}>
            <Text style={styles.infoChipText}>
              ⭐ {QUESTIONS.length} Questions
            </Text>
          </View>
          <View style={{ width: 10 }} />
          <View style={styles.infoChip}>
            <Text style={styles.infoChipText}>🪐 Astronomy</Text>
          </View>
          <View style={{ width: 10 }} />
          <View style={styles.infoChip}>
            <Text style={styles.infoChipText}>🎯 Multiple Choice</Text>
          </View>
        </View>

        {/* Feature list */}
        <View style={styles.featureBox}>
          {[
            "10 astronomy questions",
            "Instant answer feedback",
            "Full answer key at the end",
          ].map((f, i) => (
            <View key={i} style={styles.featureRow}>
              <Text style={styles.featureDot}>✦</Text>
              <Text style={styles.featureText}>{f}</Text>
            </View>
          ))}
        </View>

        <TouchableOpacity
          style={styles.startBtn}
          onPress={onStart}
          activeOpacity={0.8}
        >
          <Text style={styles.startBtnText}>Start Quiz →</Text>
        </TouchableOpacity>
      </ScrollView>
    </SafeAreaView>
  );
}

// ══════════════════════════════════════════════════════════════
//  SCREEN 2 — Quiz
// ══════════════════════════════════════════════════════════════
function QuizScreen({ onFinish, onBack }) {
  const [current, setCurrent] = useState(0);
  const [score, setScore] = useState(0);
  const [selected, setSelected] = useState(null);
  const [answered, setAnswered] = useState(false);
  // Store user's answers for result screen
  const [userAnswers, setUserAnswers] = useState([]);

  const q = QUESTIONS[current];

  function handleOptionPress(index) {
    if (answered) return;
    setSelected(index);
    setAnswered(true);
    const newScore = index === q.answer ? score + 1 : score;
    if (index === q.answer) setScore(newScore);
    setUserAnswers((prev) => [...prev, index]);
  }

  function handleNext() {
    if (current + 1 < QUESTIONS.length) {
      setCurrent((prev) => prev + 1);
      setSelected(null);
      setAnswered(false);
    } else {
      onFinish(score + (selected === q.answer ? 1 : 0), [
        ...userAnswers,
        selected,
      ]);
    }
  }

  function optionStyle(index) {
    if (!answered) return styles.optionDefault;
    if (index === q.answer) return styles.optionCorrect;
    if (index === selected) return styles.optionWrong;
    return styles.optionDefault;
  }

  function optionTextStyle(index) {
    if (!answered) return styles.optionTextDefault;
    if (index === q.answer) return styles.optionTextCorrect;
    if (index === selected) return styles.optionTextWrong;
    return styles.optionTextDefault;
  }

  const progress = ((current + 1) / QUESTIONS.length) * 100;

  return (
    <SafeAreaView style={styles.safeArea}>
      <NavHeader
        title={`Question ${current + 1} of ${QUESTIONS.length}`}
        onBack={onBack}
      />

      <ScrollView contentContainerStyle={styles.quizContainer}>
        {/* Score chip */}
        <View style={styles.quizTopRow}>
          <View style={styles.progressLabelRow}>
            <Text style={styles.progressLabel}>
              {Math.round(progress)}% complete
            </Text>
          </View>
          <View style={styles.scoreChip}>
            <Text style={styles.scoreChipText}>⭐ {score} pts</Text>
          </View>
        </View>

        {/* Progress bar */}
        <View style={styles.progressTrack}>
          <View style={[styles.progressFill, { width: `${progress}%` }]} />
        </View>

        {/* Question card */}
        <View style={styles.questionCard}>
          <Text style={styles.questionNum}>Q{current + 1}</Text>
          <Text style={styles.questionText}>{q.question}</Text>
        </View>

        {/* Options */}
        <View style={styles.optionsContainer}>
          {q.options.map((option, index) => (
            <TouchableOpacity
              key={index}
              style={[styles.optionBtn, optionStyle(index)]}
              onPress={() => handleOptionPress(index)}
              activeOpacity={answered ? 1 : 0.8}
            >
              <View style={[styles.optionLabelBox, optionStyle(index)]}>
                <Text style={[styles.optionLabel, optionTextStyle(index)]}>
                  {String.fromCharCode(65 + index)}
                </Text>
              </View>
              <Text style={[styles.optionText, optionTextStyle(index)]}>
                {option}
              </Text>
              {answered && index === q.answer && (
                <Text style={styles.tickMark}>✓</Text>
              )}
              {answered && index === selected && index !== q.answer && (
                <Text style={styles.crossMark}>✗</Text>
              )}
            </TouchableOpacity>
          ))}
        </View>

        {/* Feedback message */}
        {answered && (
          <View
            style={
              selected === q.answer
                ? styles.feedbackCorrect
                : styles.feedbackWrong
            }
          >
            <Text style={styles.feedbackText}>
              {selected === q.answer
                ? "✓  Correct!"
                : `✗  The answer is: ${q.options[q.answer]}`}
            </Text>
          </View>
        )}

        {/* Next button */}
        {answered && (
          <TouchableOpacity
            style={styles.nextBtn}
            onPress={handleNext}
            activeOpacity={0.8}
          >
            <Text style={styles.nextBtnText}>
              {current + 1 === QUESTIONS.length
                ? "See Results  →"
                : "Next Question  →"}
            </Text>
          </TouchableOpacity>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

// ══════════════════════════════════════════════════════════════
//  SCREEN 3 — Results  (tab layout: Score | Answers)
// ══════════════════════════════════════════════════════════════
function ResultScreen({ score, userAnswers, onRestart, onBack }) {
  const [activeTab, setActiveTab] = useState("score"); // 'score' | 'answers'
  const total = QUESTIONS.length;
  const percent = Math.round((score / total) * 100);

  function getMessage() {
    if (percent === 100)
      return {
        emoji: "🚀",
        title: "Perfect Score!",
        sub: "You know your cosmos!",
      };
    if (percent >= 70)
      return {
        emoji: "🌟",
        title: "Great Job!",
        sub: "A true space enthusiast.",
      };
    if (percent >= 40)
      return {
        emoji: "🪐",
        title: "Not Bad!",
        sub: "Keep exploring the stars.",
      };
    return {
      emoji: "🌑",
      title: "Keep Studying!",
      sub: "The universe awaits.",
    };
  }

  const msg = getMessage();

  return (
    <SafeAreaView style={styles.safeArea}>
      <NavHeader title="Results" onBack={onBack} />

      {/* Tab bar — demonstrates Tab Navigator concept */}
      <View style={styles.tabBar}>
        <TouchableOpacity
          style={[
            styles.tabItem,
            activeTab === "score" && styles.tabItemActive,
          ]}
          onPress={() => setActiveTab("score")}
          activeOpacity={0.8}
        >
          <Text
            style={[
              styles.tabLabel,
              activeTab === "score" && styles.tabLabelActive,
            ]}
          >
            Score
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[
            styles.tabItem,
            activeTab === "answers" && styles.tabItemActive,
          ]}
          onPress={() => setActiveTab("answers")}
          activeOpacity={0.8}
        >
          <Text
            style={[
              styles.tabLabel,
              activeTab === "answers" && styles.tabLabelActive,
            ]}
          >
            Answer Key
          </Text>
        </TouchableOpacity>
      </View>

      {/* TAB 1 — Score summary */}
      {activeTab === "score" && (
        <ScrollView contentContainerStyle={styles.resultContainer}>
          <Text style={styles.resultEmoji}>{msg.emoji}</Text>
          <Text style={styles.resultTitle}>{msg.title}</Text>
          <Text style={styles.resultSub}>{msg.sub}</Text>

          <View style={styles.scoreCircle}>
            <Text style={styles.scoreCircleNum}>
              {score}/{total}
            </Text>
            <Text style={styles.scoreCirclePct}>{percent}%</Text>
          </View>

          {/* Stat grid */}
          <View style={styles.statGrid}>
            <View style={styles.statCard}>
              <Text style={styles.statValue}>{score}</Text>
              <Text style={styles.statLabel}>Correct</Text>
            </View>
            <View style={styles.statDivider} />
            <View style={styles.statCard}>
              <Text style={[styles.statValue, { color: C.wrong }]}>
                {total - score}
              </Text>
              <Text style={styles.statLabel}>Wrong</Text>
            </View>
            <View style={styles.statDivider} />
            <View style={styles.statCard}>
              <Text style={[styles.statValue, { color: C.star }]}>
                {percent}%
              </Text>
              <Text style={styles.statLabel}>Score</Text>
            </View>
          </View>

          <TouchableOpacity
            style={styles.restartBtn}
            onPress={onRestart}
            activeOpacity={0.8}
          >
            <Text style={styles.restartBtnText}>Try Again ↺</Text>
          </TouchableOpacity>
        </ScrollView>
      )}

      {/* TAB 2 — Answer key */}
      {activeTab === "answers" && (
        <ScrollView contentContainerStyle={styles.answerTabContainer}>
          <Text style={styles.answerKeyHeading}>Full Answer Key</Text>
          <View style={styles.answerKey}>
            {QUESTIONS.map((q, i) => {
              const userAns = userAnswers ? userAnswers[i] : null;
              const correct = userAns === q.answer;
              return (
                <View key={i} style={styles.resultRow}>
                  <View
                    style={[
                      styles.resultNumBadge,
                      correct ? styles.badgeCorrect : styles.badgeWrong,
                    ]}
                  >
                    <Text style={styles.resultRowNum}>{i + 1}</Text>
                  </View>
                  <View style={styles.resultRowContent}>
                    <Text style={styles.resultRowQ} numberOfLines={2}>
                      {q.question}
                    </Text>
                    <Text style={styles.resultRowAns}>
                      ✓ {q.options[q.answer]}
                    </Text>
                    {userAns !== null && userAns !== q.answer && (
                      <Text style={styles.resultRowUserAns}>
                        ✗ You chose: {q.options[userAns]}
                      </Text>
                    )}
                  </View>
                </View>
              );
            })}
          </View>

          <TouchableOpacity
            style={styles.restartBtn}
            onPress={onRestart}
            activeOpacity={0.8}
          >
            <Text style={styles.restartBtnText}>Try Again ↺</Text>
          </TouchableOpacity>
        </ScrollView>
      )}
    </SafeAreaView>
  );
}

// ══════════════════════════════════════════════════════════════
//  ROOT — App  (stack navigation via useState)
// ══════════════════════════════════════════════════════════════
export default function HomeScreen() {
  const [screen, setScreen] = useState("welcome");
  const [finalScore, setFinalScore] = useState(0);
  const [userAnswers, setUserAnswers] = useState([]);

  function handleStart() {
    setScreen("quiz");
  }
  function handleFinish(score, answers) {
    setFinalScore(score);
    setUserAnswers(answers);
    setScreen("result");
  }
  function handleRestart() {
    setFinalScore(0);
    setUserAnswers([]);
    setScreen("welcome");
  }
  function handleBack() {
    setScreen("welcome");
  }

  return (
    <View style={styles.root}>
      <StatusBar barStyle="light-content" backgroundColor={C.bg} />
      {screen === "welcome" && <WelcomeScreen onStart={handleStart} />}
      {screen === "quiz" && (
        <QuizScreen onFinish={handleFinish} onBack={handleBack} />
      )}
      {screen === "result" && (
        <ResultScreen
          score={finalScore}
          userAnswers={userAnswers}
          onRestart={handleRestart}
          onBack={() => setScreen("quiz")}
        />
      )}
    </View>
  );
}

// ══════════════════════════════════════════════════════════════
//  STYLES
// ══════════════════════════════════════════════════════════════
const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: C.bg },
  safeArea: { flex: 1 },

  // ── Nav Header ──
  navHeader: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    backgroundColor: C.header,
    borderBottomWidth: 1,
    borderBottomColor: C.border,
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  backBtn: { width: 64, flexDirection: "row", alignItems: "center" },
  backArrow: { fontSize: 28, color: C.accent, lineHeight: 30 },
  backLabel: { fontSize: 15, color: C.accent, marginLeft: 2 },
  navTitle: { fontSize: 16, fontWeight: "700", color: C.text },

  // ── Welcome ──
  welcomeContainer: {
    alignItems: "center",
    paddingHorizontal: 24,
    paddingBottom: 48,
    paddingTop: 8,
  },
  heroBanner: {
    width: "100%",
    backgroundColor: C.card,
    borderWidth: 1,
    borderColor: C.border,
    borderRadius: 12,
    paddingVertical: 14,
    alignItems: "center",
    marginBottom: 24,
  },
  heroBannerText: { fontSize: 15, color: C.accentLt, fontWeight: "600" },
  bigEmoji: { fontSize: 68, marginBottom: 14 },
  welcomeTitle: {
    fontSize: 34,
    fontWeight: "800",
    color: C.text,
    letterSpacing: -0.5,
  },
  welcomeSub: {
    fontSize: 15,
    color: C.muted,
    textAlign: "center",
    marginTop: 8,
    lineHeight: 22,
  },

  infoRow: {
    flexDirection: "row",
    marginTop: 24,
    marginBottom: 20,
    alignItems: "center",
  },
  infoChip: {
    backgroundColor: C.card,
    borderWidth: 1,
    borderColor: C.border,
    borderRadius: 20,
    paddingVertical: 7,
    paddingHorizontal: 13,
  },
  infoChipText: { color: C.muted, fontSize: 12, fontWeight: "500" },

  featureBox: {
    width: "100%",
    backgroundColor: C.card,
    borderWidth: 1,
    borderColor: C.border,
    borderRadius: 14,
    padding: 18,
    marginBottom: 28,
  },
  featureRow: { flexDirection: "row", alignItems: "center", marginBottom: 10 },
  featureDot: { color: C.accent, fontSize: 12, marginRight: 10 },
  featureText: { color: C.text, fontSize: 14 },

  startBtn: {
    backgroundColor: C.accent,
    borderRadius: 14,
    paddingVertical: 16,
    paddingHorizontal: 60,
  },
  startBtnText: { color: "#fff", fontSize: 17, fontWeight: "700" },

  // ── Quiz ──
  quizContainer: { padding: 20, paddingBottom: 40 },
  quizTopRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 10,
  },
  progressLabelRow: {},
  progressLabel: { fontSize: 12, color: C.muted },
  scoreChip: {
    backgroundColor: C.card,
    borderWidth: 1,
    borderColor: C.border,
    borderRadius: 20,
    paddingVertical: 4,
    paddingHorizontal: 12,
  },
  scoreChipText: { color: C.star, fontSize: 13, fontWeight: "600" },

  progressTrack: {
    height: 6,
    backgroundColor: C.card,
    borderRadius: 3,
    marginBottom: 22,
    overflow: "hidden",
  },
  progressFill: { height: 6, backgroundColor: C.accent, borderRadius: 3 },

  questionCard: {
    backgroundColor: C.card,
    borderWidth: 1,
    borderColor: C.border,
    borderRadius: 16,
    padding: 20,
    marginBottom: 20,
  },
  questionNum: {
    fontSize: 11,
    color: C.accent,
    fontWeight: "700",
    marginBottom: 8,
    letterSpacing: 1,
  },
  questionText: {
    fontSize: 18,
    color: C.text,
    fontWeight: "600",
    lineHeight: 26,
  },

  optionsContainer: { marginBottom: 4 },
  optionBtn: {
    flexDirection: "row",
    alignItems: "center",
    borderRadius: 12,
    borderWidth: 1,
    padding: 14,
    marginBottom: 10,
  },
  optionDefault: { backgroundColor: C.card, borderColor: C.border },
  optionCorrect: {
    backgroundColor: "rgba(63,185,80,0.12)",
    borderColor: C.correct,
  },
  optionWrong: {
    backgroundColor: "rgba(248,81,73,0.12)",
    borderColor: C.wrong,
  },

  optionLabelBox: {
    width: 32,
    height: 32,
    borderRadius: 16,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: C.border,
    marginRight: 12,
  },
  optionLabel: { fontSize: 13, fontWeight: "700" },
  optionTextDefault: { color: C.text },
  optionTextCorrect: { color: C.correct },
  optionTextWrong: { color: C.wrong },
  optionText: { flex: 1, fontSize: 15, fontWeight: "500" },
  tickMark: {
    color: C.correct,
    fontSize: 18,
    fontWeight: "700",
    marginLeft: 6,
  },
  crossMark: { color: C.wrong, fontSize: 18, fontWeight: "700", marginLeft: 6 },

  feedbackCorrect: {
    backgroundColor: "rgba(63,185,80,0.12)",
    borderWidth: 1,
    borderColor: C.correct,
    borderRadius: 10,
    padding: 12,
    marginTop: 4,
    marginBottom: 4,
  },
  feedbackWrong: {
    backgroundColor: "rgba(248,81,73,0.12)",
    borderWidth: 1,
    borderColor: C.wrong,
    borderRadius: 10,
    padding: 12,
    marginTop: 4,
    marginBottom: 4,
  },
  feedbackText: { color: C.text, fontSize: 14, fontWeight: "600" },

  nextBtn: {
    backgroundColor: C.accent,
    borderRadius: 12,
    padding: 16,
    alignItems: "center",
    marginTop: 16,
  },
  nextBtnText: { color: "#fff", fontSize: 16, fontWeight: "700" },

  // ── Tab Bar ──
  tabBar: {
    flexDirection: "row",
    backgroundColor: C.header,
    borderBottomWidth: 1,
    borderBottomColor: C.border,
  },
  tabItem: {
    flex: 1,
    paddingVertical: 14,
    alignItems: "center",
    borderBottomWidth: 2,
    borderBottomColor: "transparent",
  },
  tabItemActive: { borderBottomColor: C.accent },
  tabLabel: { fontSize: 14, fontWeight: "600", color: C.muted },
  tabLabelActive: { color: C.accent },

  // ── Result ──
  resultContainer: { alignItems: "center", padding: 24, paddingBottom: 48 },
  resultEmoji: { fontSize: 60, marginTop: 8, marginBottom: 8 },
  resultTitle: { fontSize: 28, fontWeight: "800", color: C.text },
  resultSub: { fontSize: 14, color: C.muted, marginTop: 4, marginBottom: 24 },

  scoreCircle: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: C.card,
    borderWidth: 3,
    borderColor: C.accent,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 24,
  },
  scoreCircleNum: { fontSize: 26, fontWeight: "800", color: C.text },
  scoreCirclePct: { fontSize: 13, color: C.muted, marginTop: 2 },

  statGrid: {
    flexDirection: "row",
    width: "100%",
    backgroundColor: C.card,
    borderWidth: 1,
    borderColor: C.border,
    borderRadius: 14,
    padding: 20,
    marginBottom: 28,
    alignItems: "center",
    justifyContent: "space-around",
  },
  statCard: { alignItems: "center" },
  statValue: { fontSize: 26, fontWeight: "800", color: C.correct },
  statLabel: { fontSize: 12, color: C.muted, marginTop: 4 },
  statDivider: { width: 1, height: 40, backgroundColor: C.border },

  restartBtn: {
    backgroundColor: C.accent,
    borderRadius: 12,
    paddingVertical: 15,
    paddingHorizontal: 56,
  },
  restartBtnText: { color: "#fff", fontSize: 16, fontWeight: "700" },

  // ── Answer Tab ──
  answerTabContainer: { padding: 16, paddingBottom: 48 },
  answerKeyHeading: {
    fontSize: 13,
    fontWeight: "700",
    color: C.muted,
    letterSpacing: 0.8,
    marginBottom: 12,
  },
  answerKey: {
    width: "100%",
    backgroundColor: C.card,
    borderWidth: 1,
    borderColor: C.border,
    borderRadius: 14,
    overflow: "hidden",
    marginBottom: 24,
  },
  resultRow: {
    flexDirection: "row",
    alignItems: "flex-start",
    padding: 12,
    borderBottomWidth: 1,
    borderBottomColor: C.border,
  },
  resultNumBadge: {
    width: 26,
    height: 26,
    borderRadius: 13,
    alignItems: "center",
    justifyContent: "center",
    marginRight: 10,
    marginTop: 2,
  },
  badgeCorrect: { backgroundColor: "rgba(63,185,80,0.2)" },
  badgeWrong: { backgroundColor: "rgba(248,81,73,0.2)" },
  resultRowNum: { color: C.text, fontSize: 11, fontWeight: "700" },
  resultRowContent: { flex: 1 },
  resultRowQ: { color: C.text, fontSize: 12, marginBottom: 4 },
  resultRowAns: { color: C.correct, fontSize: 12, fontWeight: "600" },
  resultRowUserAns: { color: C.wrong, fontSize: 12, marginTop: 2 },
});
