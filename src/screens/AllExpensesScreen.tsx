import React, { useState, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TextInput,
  Alert,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { useExpenses } from '../context/ExpenseContext';
import { Expense } from '../models/Expense';
import { getMeta, categories } from '../utils/categoryUtils';
import ExpenseCard from '../components/ExpenseCard';
import BouncingButton from '../components/BouncingButton';
import ResponsiveContainer from '../components/ResponsiveContainer';

export default function AllExpensesScreen() {
  const insets = useSafeAreaInsets();
  const { isDark, theme, colors } = useTheme();
  const exp = useExpenses();
  const nav = useNavigation<any>();

  const [filter, setFilter] = useState('All');
  const [search, setSearch] = useState('');
  const [searching, setSearching] = useState(false);

  // Filter expenses by category and search query
  const filtered = useMemo(() => {
    return exp.expenses.filter((e) => {
      const matchCat = filter === 'All' || e.category === filter;
      const q = search.trim().toLowerCase();
      const matchSearch =
        !q ||
        e.name.toLowerCase().includes(q) ||
        (e.note || '').toLowerCase().includes(q) ||
        getMeta(e.category).displayName.toLowerCase().includes(q);
      return matchCat && matchSearch;
    });
  }, [exp.expenses, filter, search]);

  const totalTRY = useMemo(() => {
    return filtered.reduce(
      (sum, e) => sum + exp.convertToTRY(e.amount, e.currency),
      0
    );
  }, [filtered, exp]);

  // Spending breakdown for the multi-color bar
  const categorySums = useMemo(() => {
    const map: Record<string, number> = {};
    for (const e of filtered) {
      const tryVal = exp.convertToTRY(e.amount, e.currency);
      map[e.category] = (map[e.category] || 0) + tryVal;
    }
    return map;
  }, [filtered, exp]);

  // Group filtered expenses by date
  const groupedExpenses = useMemo(() => {
    const groups: { title: string; items: Expense[] }[] = [];
    const map = new Map<string, Expense[]>();

    const now = new Date();
    const todayStr = new Date(now.getFullYear(), now.getMonth(), now.getDate()).toDateString();
    const yesterday = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 1);
    const yesterdayStr = yesterday.toDateString();

    for (const e of filtered) {
      const d = new Date(e.date);
      const dayDateStr = new Date(d.getFullYear(), d.getMonth(), d.getDate()).toDateString();

      let headerTitle: string;
      if (dayDateStr === todayStr) {
        headerTitle = 'Bugün';
      } else if (dayDateStr === yesterdayStr) {
        headerTitle = 'Dün';
      } else {
        headerTitle = d.toLocaleDateString('tr-TR', {
          day: 'numeric',
          month: 'long',
          year: d.getFullYear() !== now.getFullYear() ? 'numeric' : undefined,
        });
      }

      if (!map.has(headerTitle)) {
        map.set(headerTitle, []);
        groups.push({ title: headerTitle, items: map.get(headerTitle)! });
      }
      map.get(headerTitle)!.push(e);
    }

    return groups;
  }, [filtered]);

  const handleDelete = (id: string, name: string) => {
    Alert.alert(
      'Harcamayı Sil',
      `"${name}" harcamasını silmek istediğinize emin misiniz?`,
      [
        { text: 'İptal', style: 'cancel' },
        {
          text: 'Sil',
          style: 'destructive',
          onPress: () => exp.deleteExpense(id),
        },
      ]
    );
  };

  const currentMonthName = new Date().toLocaleDateString('tr-TR', {
    month: 'long',
    year: 'numeric',
  });

  return (
    <View style={[styles.root, { backgroundColor: theme.bg }]}>
      <ResponsiveContainer maxWidth={640}>
        {/* Top Header Bar */}
        <View
          style={[
            styles.topBar,
            {
              paddingTop: insets.top + 6,
            },
          ]}
        >
          <BouncingButton
            onPress={() => nav.goBack()}
            style={[
              styles.iconButton,
              {
                backgroundColor: theme.surface,
                borderColor: theme.border,
              },
            ]}
          >
            <Ionicons name="chevron-back" size={20} color={theme.text} />
          </BouncingButton>

          {searching ? (
            <TextInput
              value={search}
              onChangeText={setSearch}
              placeholder="Harcama ara..."
              placeholderTextColor={theme.textMuted + '88'}
              autoFocus
              style={[styles.searchInput, { color: theme.text }]}
            />
          ) : (
            <Text style={[styles.topBarTitle, { color: theme.text }]}>
              Tüm Harcamalar
            </Text>
          )}

          <BouncingButton
            onPress={() => {
              if (searching) {
                setSearching(false);
                setSearch('');
              } else {
                setSearching(true);
              }
            }}
            style={[
              styles.iconButton,
              {
                backgroundColor: theme.surface,
                borderColor: theme.border,
              },
            ]}
          >
            <Ionicons
              name={searching ? 'close' : 'search'}
              size={19}
              color={theme.text}
            />
          </BouncingButton>
        </View>

        {/* Content */}
        <ScrollView
          contentContainerStyle={[
            styles.scrollContent,
            { paddingBottom: insets.bottom + 40 },
          ]}
          showsVerticalScrollIndicator={false}
          keyboardShouldPersistTaps="handled"
        >
          {/* Summary Card */}
          <View
            style={[
              styles.summaryCard,
              {
                backgroundColor: theme.surface,
                borderColor: theme.border,
              },
            ]}
          >
            <View style={styles.summaryTopRow}>
              <Text style={[styles.summarySubtitle, { color: theme.textMuted }]}>
                Dönem Toplamı ({currentMonthName})
              </Text>
              <View
                style={[
                  styles.activeBadge,
                  {
                    backgroundColor: isDark
                      ? 'rgba(159, 232, 112, 0.16)'
                      : 'rgba(22, 51, 0, 0.08)',
                  },
                ]}
              >
                <Text
                  style={[
                    styles.activeBadgeText,
                    { color: isDark ? colors.wiseLime : colors.wiseForest },
                  ]}
                >
                  Aktif
                </Text>
              </View>
            </View>

            <View style={styles.summaryMainRow}>
              <Text
                style={[styles.summaryAmount, { color: theme.text }]}
                numberOfLines={1}
                adjustsFontSizeToFit
                minimumFontScale={0.5}
              >
                {totalTRY.toLocaleString('tr-TR', {
                  minimumFractionDigits: 2,
                  maximumFractionDigits: 2,
                })}{' '}
                TL
              </Text>
              <Text style={[styles.summaryCount, { color: theme.textMuted }]}>
                {filtered.length} İşlem
              </Text>
            </View>

            {/* Multi-color Breakdown Bar */}
            {totalTRY > 0 && (
              <View style={styles.breakdownBar}>
                {Object.entries(categorySums).map(([cat, sum]) => {
                  const ratio = sum / totalTRY;
                  if (ratio <= 0) return null;
                  return (
                    <View
                      key={cat}
                      style={{
                        flex: ratio,
                        height: 6,
                        backgroundColor: getMeta(cat).color,
                      }}
                    />
                  );
                })}
              </View>
            )}
          </View>

          {/* Category Filter Chips */}
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={styles.filterScroll}
          >
            <BouncingButton
              onPress={() => setFilter('All')}
              style={[
                styles.filterChip,
                {
                  backgroundColor:
                    filter === 'All'
                      ? isDark
                        ? colors.wiseLime
                        : colors.wiseForest
                      : theme.surface,
                  borderColor:
                    filter === 'All'
                      ? isDark
                        ? colors.wiseLime
                        : colors.wiseForest
                      : theme.border,
                },
              ]}
            >
              <Text
                style={[
                  styles.filterText,
                  {
                    color:
                      filter === 'All'
                        ? isDark
                          ? colors.wiseForest
                          : colors.wiseLime
                        : theme.text,
                  },
                ]}
              >
                Tümü
              </Text>
            </BouncingButton>

            {categories.map((c) => {
              const active = filter === c.id;
              return (
                <BouncingButton
                  key={c.id}
                  onPress={() => setFilter(c.id)}
                  style={[
                    styles.filterChip,
                    {
                      backgroundColor: active
                        ? isDark
                          ? colors.wiseLime
                          : colors.wiseForest
                        : theme.surface,
                      borderColor: active
                        ? isDark
                          ? colors.wiseLime
                          : colors.wiseForest
                        : theme.border,
                    },
                  ]}
                >
                  <Ionicons
                    name={c.icon as any}
                    size={14}
                    color={
                      active
                        ? isDark
                          ? colors.wiseForest
                          : colors.wiseLime
                        : c.color
                    }
                    style={{ marginRight: 6 }}
                  />
                  <Text
                    style={[
                      styles.filterText,
                      {
                        color: active
                          ? isDark
                            ? colors.wiseForest
                            : colors.wiseLime
                          : theme.text,
                      },
                    ]}
                  >
                    {c.displayName}
                  </Text>
                </BouncingButton>
              );
            })}
          </ScrollView>

          {/* Grouped Expenses List */}
          {filtered.length === 0 ? (
            <View style={styles.emptyContainer}>
              <Ionicons
                name="search-outline"
                size={44}
                color={theme.textMuted}
              />
              <Text style={[styles.emptyText, { color: theme.textMuted }]}>
                {search.trim().length > 0
                  ? 'Aramanızla eşleşen harcama bulunamadı.'
                  : 'Bu kategoride henüz harcama bulunmuyor.'}
              </Text>
            </View>
          ) : (
            groupedExpenses.map((group) => (
              <View key={group.title} style={styles.groupContainer}>
                <Text style={[styles.groupHeader, { color: theme.textMuted }]}>
                  {group.title}
                </Text>
                {group.items.map((e) => (
                  <ExpenseCard
                    key={e.id}
                    expense={e}
                    usdRate={exp.usdRate}
                    eurRate={exp.eurRate}
                    onDelete={() => handleDelete(e.id, e.name)}
                  />
                ))}
              </View>
            ))
          )}
        </ScrollView>
      </ResponsiveContainer>
    </View>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
  },
  topBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingBottom: 6,
  },
  topBarTitle: {
    fontSize: 18,
    fontWeight: '800',
    letterSpacing: -0.3,
  },
  iconButton: {
    width: 38,
    height: 38,
    borderRadius: 12,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  searchInput: {
    flex: 1,
    fontSize: 16,
    fontWeight: '600',
    marginHorizontal: 12,
  },
  scrollContent: {
    paddingHorizontal: 20,
    paddingTop: 6,
  },
  summaryCard: {
    borderRadius: 20,
    borderWidth: 1,
    paddingHorizontal: 18,
    paddingVertical: 16,
    marginBottom: 14,
  },
  summaryTopRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  summarySubtitle: {
    fontSize: 13,
    fontWeight: '600',
  },
  activeBadge: {
    paddingHorizontal: 9,
    paddingVertical: 3,
    borderRadius: 8,
  },
  activeBadgeText: {
    fontSize: 11,
    fontWeight: '800',
  },
  summaryMainRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'baseline',
    marginTop: 8,
  },
  summaryAmount: {
    fontSize: 28,
    fontWeight: '900',
    letterSpacing: -0.6,
  },
  summaryCount: {
    fontSize: 13,
    fontWeight: '700',
  },
  breakdownBar: {
    flexDirection: 'row',
    height: 6,
    borderRadius: 3,
    overflow: 'hidden',
    marginTop: 12,
  },
  filterScroll: {
    paddingVertical: 4,
    gap: 8,
    marginBottom: 12,
  },
  filterChip: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 14,
    paddingVertical: 7,
    borderRadius: 14,
    borderWidth: 1,
  },
  filterText: {
    fontSize: 13,
    fontWeight: '700',
  },
  groupContainer: {
    marginTop: 10,
  },
  groupHeader: {
    fontSize: 14,
    fontWeight: '800',
    letterSpacing: -0.2,
    marginBottom: 8,
    marginLeft: 4,
  },
  emptyContainer: {
    alignItems: 'center',
    paddingVertical: 48,
  },
  emptyText: {
    fontSize: 14,
    fontWeight: '500',
    marginTop: 10,
    textAlign: 'center',
  },
});
