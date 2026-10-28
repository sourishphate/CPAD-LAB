import NetInfo, { NetInfoState } from "@react-native-community/netinfo";
import { useEffect, useState } from "react";
import {
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
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
  online: "#16A34A",
  onlineBg: "#DCFCE7",
  onlineBorder: "#86EFAC",
  offline: "#DC2626",
  offlineBg: "#FEE2E2",
  offlineBorder: "#FCA5A5",
  warning: "#D97706",
  warningBg: "#FEF3C7",
  warningBorder: "#FCD34D",
  text: "#111827",
  sub: "#4B5563",
  muted: "#9CA3AF",
  border: "#E5E7EB",
  white: "#FFFFFF",
};

// ══════════════════════════════════════════════════════════════
//  TYPES
// ══════════════════════════════════════════════════════════════
type ConnectivityState = {
  isConnected: boolean;
  connectionType: string;
  isInternetReachable: boolean | null;
};

// ══════════════════════════════════════════════════════════════
//  WIDGET 1 — NavHeader
//  Visible header bar showing current screen name
// ══════════════════════════════════════════════════════════════
function NavHeader({ title }: { title: string }) {
  return (
    <View style={styles.navHeader}>
      <View style={styles.navSide} />
      <Text style={styles.navTitle}>{title}</Text>
      <View style={styles.navSide} />
    </View>
  );
}

// ══════════════════════════════════════════════════════════════
//  WIDGET 2 — StatusIndicator
//  Large coloured circle showing online / offline at a glance
// ══════════════════════════════════════════════════════════════
function StatusIndicator({ isConnected }: { isConnected: boolean }) {
  return (
    <View style={styles.indicatorWrapper}>
      {/* Outer glow ring */}
      <View
        style={[
          styles.indicatorRing,
          {
            borderColor: isConnected ? C.online : C.offline,
            backgroundColor: isConnected ? C.onlineBg : C.offlineBg,
          },
        ]}
      >
        {/* Inner filled circle */}
        <View
          style={[
            styles.indicatorCircle,
            { backgroundColor: isConnected ? C.online : C.offline },
          ]}
        >
          <Text style={styles.indicatorEmoji}>{isConnected ? "✓" : "✕"}</Text>
        </View>
      </View>

      {/* Status label below circle */}
      <Text
        style={[
          styles.indicatorLabel,
          { color: isConnected ? C.online : C.offline },
        ]}
      >
        {isConnected ? "Online" : "Offline"}
      </Text>
    </View>
  );
}

// ══════════════════════════════════════════════════════════════
//  WIDGET 3 — ConnectionTypeCard
//  Shows connection type with an icon and label
// ══════════════════════════════════════════════════════════════
function ConnectionTypeCard({ connectionType }: { connectionType: string }) {
  function getIcon(type: string): string {
    switch (type.toLowerCase()) {
      case "wifi":
        return "📶";
      case "cellular":
        return "📡";
      case "ethernet":
        return "🔌";
      case "bluetooth":
        return "🔵";
      case "none":
        return "❌";
      default:
        return "❓";
    }
  }

  function getLabel(type: string): string {
    switch (type.toLowerCase()) {
      case "wifi":
        return "Wi-Fi";
      case "cellular":
        return "Cellular / Mobile Data";
      case "ethernet":
        return "Ethernet";
      case "bluetooth":
        return "Bluetooth";
      case "none":
        return "No Connection";
      default:
        return type.charAt(0).toUpperCase() + type.slice(1);
    }
  }

  return (
    <View style={styles.infoCard}>
      <Text style={styles.infoCardHeading}>Connection Type</Text>
      <View style={styles.infoCardRow}>
        <Text style={styles.infoCardIcon}>{getIcon(connectionType)}</Text>
        <Text style={styles.infoCardValue}>{getLabel(connectionType)}</Text>
      </View>
    </View>
  );
}

// ══════════════════════════════════════════════════════════════
//  WIDGET 4 — ReachabilityCard
//  Shows whether the connection has actual internet reachability
// ══════════════════════════════════════════════════════════════
function ReachabilityCard({
  isInternetReachable,
}: {
  isInternetReachable: boolean | null;
}) {
  function getStyle() {
    if (isInternetReachable === true)
      return {
        bg: C.onlineBg,
        border: C.onlineBorder,
        color: C.online,
        icon: "✅",
        label: "Internet Reachable",
        sub: "The network can reach the internet.",
      };
    if (isInternetReachable === false)
      return {
        bg: C.offlineBg,
        border: C.offlineBorder,
        color: C.offline,
        icon: "🚫",
        label: "Internet Not Reachable",
        sub: "Connected to a network but no internet access.",
      };
    return {
      bg: C.warningBg,
      border: C.warningBorder,
      color: C.warning,
      icon: "⏳",
      label: "Checking Reachability",
      sub: "Determining internet reachability...",
    };
  }

  const s = getStyle();

  return (
    <View
      style={[
        styles.reachabilityCard,
        { backgroundColor: s.bg, borderColor: s.border },
      ]}
    >
      <View style={styles.reachabilityRow}>
        <Text style={styles.reachabilityIcon}>{s.icon}</Text>
        <View style={styles.reachabilityTextCol}>
          <Text style={[styles.reachabilityLabel, { color: s.color }]}>
            {s.label}
          </Text>
          <Text style={styles.reachabilitySub}>{s.sub}</Text>
        </View>
      </View>
    </View>
  );
}

// ══════════════════════════════════════════════════════════════
//  WIDGET 5 — DetailRow
//  A single key-value row inside the details card
// ══════════════════════════════════════════════════════════════
function DetailRow({
  label,
  value,
  valueColor,
}: {
  label: string;
  value: string;
  valueColor?: string;
}) {
  return (
    <View style={styles.detailRow}>
      <Text style={styles.detailLabel}>{label}</Text>
      <Text
        style={[styles.detailValue, valueColor ? { color: valueColor } : {}]}
      >
        {value}
      </Text>
    </View>
  );
}

// ══════════════════════════════════════════════════════════════
//  WIDGET 6 — DetailsCard
//  Summary card showing all connectivity values in one place
// ══════════════════════════════════════════════════════════════
function DetailsCard({ state }: { state: ConnectivityState }) {
  return (
    <View style={styles.detailsCard}>
      <Text style={styles.detailsHeading}>Connection Details</Text>

      <DetailRow
        label="Status"
        value={state.isConnected ? "Connected" : "Disconnected"}
        valueColor={state.isConnected ? C.online : C.offline}
      />
      <View style={styles.detailDivider} />

      <DetailRow
        label="Type"
        value={
          state.connectionType.charAt(0).toUpperCase() +
          state.connectionType.slice(1)
        }
      />
      <View style={styles.detailDivider} />

      <DetailRow
        label="Internet Reachable"
        value={
          state.isInternetReachable === null
            ? "Checking..."
            : state.isInternetReachable
              ? "Yes"
              : "No"
        }
        valueColor={
          state.isInternetReachable === null
            ? C.warning
            : state.isInternetReachable
              ? C.online
              : C.offline
        }
      />
    </View>
  );
}

// ══════════════════════════════════════════════════════════════
//  WIDGET 7 — RefreshButton
//  Manual refresh button to re-check connectivity on demand
// ══════════════════════════════════════════════════════════════
function RefreshButton({
  onRefresh,
  isRefreshing,
}: {
  onRefresh: () => void;
  isRefreshing: boolean;
}) {
  return (
    <TouchableOpacity
      style={[styles.refreshBtn, isRefreshing && styles.refreshBtnDisabled]}
      onPress={onRefresh}
      activeOpacity={0.8}
      disabled={isRefreshing}
    >
      <Text style={styles.refreshBtnText}>
        {isRefreshing ? "⏳  Checking..." : "🔄  Refresh Status"}
      </Text>
    </TouchableOpacity>
  );
}

// ══════════════════════════════════════════════════════════════
//  WIDGET 8 — LiveBanner
//  Small banner showing the listener is active and watching
// ══════════════════════════════════════════════════════════════
function LiveBanner() {
  return (
    <View style={styles.liveBanner}>
      <View style={styles.liveDot} />
      <Text style={styles.liveBannerText}>
        Live — updates automatically when connectivity changes
      </Text>
    </View>
  );
}

// ══════════════════════════════════════════════════════════════
//  ROOT — App Widget
//  Holds connectivity state, subscribes to NetInfo listener
//  on mount, unsubscribes on unmount, handles manual refresh
// ══════════════════════════════════════════════════════════════
export default function App() {
  // Master connectivity state
  const [connectivity, setConnectivity] = useState<ConnectivityState>({
    isConnected: false,
    connectionType: "unknown",
    isInternetReachable: null,
  });

  // Tracks whether a manual refresh is in progress
  const [isRefreshing, setIsRefreshing] = useState(false);

  // Helper — maps a raw NetInfoState to our ConnectivityState shape
  function parseNetInfo(state: NetInfoState): ConnectivityState {
    return {
      isConnected: state.isConnected ?? false,
      connectionType: state.type ?? "unknown",
      isInternetReachable: state.isInternetReachable ?? null,
    };
  }

  // ── Fetch initial state and subscribe to live changes ──────
  useEffect(() => {
    // Step 1 — fetch the current state once when the screen mounts
    NetInfo.fetch().then((state) => {
      setConnectivity(parseNetInfo(state));
    });

    // Step 2 — subscribe to live connectivity changes
    // The unsubscribe function is returned by addEventListener
    // and called automatically when the component unmounts,
    // preventing memory leaks or duplicate callbacks
    const unsubscribe = NetInfo.addEventListener((state) => {
      setConnectivity(parseNetInfo(state));
    });

    // Step 3 — clean up the listener when the component unmounts
    return () => {
      unsubscribe();
    };
  }, []);

  // ── Manual refresh handler ──────────────────────────────────
  function handleRefresh() {
    setIsRefreshing(true);
    setTimeout(() => {
      NetInfo.fetch().then((state) => {
        setConnectivity(parseNetInfo(state));
        setIsRefreshing(false);
      });
    }, 2000); // 2 second delay so you can see and screenshot the checking state
  }

  return (
    // Root SafeAreaView with edges={["top"]} fixes the camera
    // cutout for all screens across all devices
    <SafeAreaView style={styles.root} edges={["top"]}>
      <StatusBar barStyle="light-content" backgroundColor={C.header} />
      <NavHeader title="Connectivity Status" />

      <SafeAreaView style={styles.safeArea} edges={["bottom"]}>
        <ScrollView
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          {/* Live listener banner */}
          <LiveBanner />

          {/* Large visual status indicator */}
          <StatusIndicator isConnected={connectivity.isConnected} />

          {/* Connection type card */}
          <ConnectionTypeCard connectionType={connectivity.connectionType} />

          {/* Internet reachability card */}
          <ReachabilityCard
            isInternetReachable={connectivity.isInternetReachable}
          />

          {/* Full details summary card */}
          <DetailsCard state={connectivity} />

          {/* Manual refresh button */}
          <RefreshButton
            onRefresh={handleRefresh}
            isRefreshing={isRefreshing}
          />
        </ScrollView>
      </SafeAreaView>
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
    backgroundColor: C.header,
  },
  safeArea: {
    flex: 1,
    backgroundColor: C.bg,
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 48,
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
  },
  navTitle: {
    fontSize: 17,
    fontWeight: "700",
    color: C.white,
    textAlign: "center",
    flex: 1,
  },

  // ── LiveBanner ─────────────────────────────────────────────
  liveBanner: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: C.card,
    borderRadius: 10,
    paddingHorizontal: 14,
    paddingVertical: 10,
    marginBottom: 20,
    borderWidth: 1,
    borderColor: C.border,
  },
  liveDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: C.online,
    marginRight: 10,
  },
  liveBannerText: {
    fontSize: 13,
    color: C.sub,
    fontWeight: "500",
  },

  // ── StatusIndicator ────────────────────────────────────────
  indicatorWrapper: {
    alignItems: "center",
    marginBottom: 28,
  },
  indicatorRing: {
    width: 160,
    height: 160,
    borderRadius: 80,
    borderWidth: 6,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 16,
  },
  indicatorCircle: {
    width: 110,
    height: 110,
    borderRadius: 55,
    alignItems: "center",
    justifyContent: "center",
  },
  indicatorEmoji: {
    fontSize: 44,
    color: C.white,
    fontWeight: "700",
  },
  indicatorLabel: {
    fontSize: 26,
    fontWeight: "800",
    letterSpacing: -0.5,
  },

  // ── ConnectionTypeCard ─────────────────────────────────────
  infoCard: {
    backgroundColor: C.card,
    borderRadius: 14,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: C.border,
  },
  infoCardHeading: {
    fontSize: 12,
    fontWeight: "600",
    color: C.muted,
    marginBottom: 10,
    textTransform: "uppercase",
    letterSpacing: 0.5,
  },
  infoCardRow: {
    flexDirection: "row",
    alignItems: "center",
  },
  infoCardIcon: {
    fontSize: 26,
    marginRight: 12,
  },
  infoCardValue: {
    fontSize: 18,
    fontWeight: "700",
    color: C.text,
  },

  // ── ReachabilityCard ───────────────────────────────────────
  reachabilityCard: {
    borderRadius: 14,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1.5,
  },
  reachabilityRow: {
    flexDirection: "row",
    alignItems: "flex-start",
  },
  reachabilityIcon: {
    fontSize: 22,
    marginRight: 12,
    marginTop: 2,
  },
  reachabilityTextCol: {
    flex: 1,
  },
  reachabilityLabel: {
    fontSize: 15,
    fontWeight: "700",
    marginBottom: 4,
  },
  reachabilitySub: {
    fontSize: 13,
    color: C.sub,
    lineHeight: 18,
  },

  // ── DetailsCard ────────────────────────────────────────────
  detailsCard: {
    backgroundColor: C.card,
    borderRadius: 14,
    padding: 16,
    marginBottom: 20,
    borderWidth: 1,
    borderColor: C.border,
  },
  detailsHeading: {
    fontSize: 12,
    fontWeight: "600",
    color: C.muted,
    marginBottom: 12,
    textTransform: "uppercase",
    letterSpacing: 0.5,
  },
  detailRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingVertical: 10,
  },
  detailDivider: {
    height: 1,
    backgroundColor: C.border,
  },
  detailLabel: {
    fontSize: 14,
    color: C.sub,
    fontWeight: "500",
  },
  detailValue: {
    fontSize: 14,
    fontWeight: "700",
    color: C.text,
  },

  // ── RefreshButton ──────────────────────────────────────────
  refreshBtn: {
    backgroundColor: C.header,
    borderRadius: 12,
    padding: 16,
    alignItems: "center",
  },
  refreshBtnDisabled: {
    backgroundColor: C.muted,
  },
  refreshBtnText: {
    color: C.white,
    fontWeight: "700",
    fontSize: 16,
  },
});
