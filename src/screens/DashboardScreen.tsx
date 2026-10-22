import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  RefreshControl,
  Modal,
  TextInput,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { useExpenses } from '../context/ExpenseContext';
import { getMeta, categories } from '../utils/categoryUtils';
import { formatCompactTRY } from '../utils/formatUtils';
import ExpenseCard from '../components/ExpenseCard';
import CategoryBudgetCompactCard from '../components/CategoryBudgetCard';
import BouncingButton from '../components/BouncingButton';
import ResponsiveContainer from '../components/ResponsiveContainer';

export default function DashboardScreen() {
  const insets = useSafeAreaInsets();
  const { isDark, toggle, theme, colors } = useTheme();
  const exp = useExpenses();
  const nav = useNavigation<any>();

  const [refreshing, setRefreshing] = useState(false);
  const [limitsModalVisible, setLimitsModalVisible] = useState(false);
  const [editLimitCategory, setEditLimitCategory] = useState<string | null>(null);
  const [limitInput, setLimitInput] = useState('');

  const onRefresh = async () => {
    setRefreshing(true);
    await exp.refresh();
    setRefreshing(false);
  };

  const totalTRY = exp.getTotalInTRY();
  const totalLimit = exp.budgets.reduce((sum, b) => sum + b.limit, 0);
  const remainingBudget = totalLimit > 0 ? totalLimit - totalTRY : 0;
  const budgetProgress = totalLimit > 0 ? Math.min(totalTRY / totalLimit, 1) : 0;

  const foodSpent = exp.getSpentByCategory('Food & Drinks');
  const transportSpent = exp.getSpentByCategory('Transportation');
  const shoppingSpent = exp.getSpentByCategory('Shopping');

  const openEditLimit = (catId: string) => {
    const existing = exp.budgets.find((b) => b.category === catId);
    setEditLimitCategory(catId);
    setLimitInput(existing && existing.limit > 0 ? existing.limit.toString() : '');
  };

  const saveCategoryLimit = async () => {
    if (!editLimitCategory) return;
    const val = parseFloat(limitInput.replace(',', '.')) || 0;
    await exp.setBudgetLimit(editLimitCategory, val);
    setEditLimitCategory(null);
    setLimitInput('');
  };

  return (
    <View style={[styles.root, { backgroundColor: theme.bg }]}>
      <ResponsiveContainer>
        {/* Fixed Header */}
        <View
          style={[
            styles.headerRow,
            {
              paddingTop: insets.top + 8,
              paddingHorizontal: 20,
              paddingBottom: 8,
              backgroundColor: theme.bg,
            },
          ]}
        >
          <View style={{ flex: 1 }}>
            <Text style={[styles.greetingSub, { color: theme.textMuted }]}>
              Hoş geldiniz
            </Text>
            <Text
              style={[styles.greetingTitle, { color: theme.text }]}
              numberOfLines={1}
            >
              Merhaba, Emirhan
            </Text>
          </View>

          <View style={styles.headerActions}>
            <View
              style={[
                styles.rateChip,
                {
                  backgroundColor: theme.surface,
                  borderColor: theme.border,
                },
              ]}
            >
              <Text style={[styles.rateText, { color: theme.text }]}>
                {exp.isLoadingRates
                  ? '...'
                  : `1$ = ${exp.usdRate.toFixed(2)} ₺`}
              </Text>
            </View>

            <BouncingButton
              onPress={toggle}
              style={[
                styles.iconButton,
                {
                  backgroundColor: theme.surface,
                  borderColor: theme.border,
                },
              ]}
            >
              <Ionicons
                name={isDark ? 'sunny-outline' : 'moon-outline'}
                size={18}
                color={theme.text}
              />
            </BouncingButton>
          </View>
        </View>

        <ScrollView
          contentContainerStyle={[
            styles.scrollContent,
            {
              paddingTop: 8,
              paddingBottom: insets.bottom + 100,
            },
          ]}
          showsVerticalScrollIndicator={false}
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={onRefresh}
              tintColor={theme.accent}
              colors={[theme.accent]}
            />
          }
        >
          {/* Hero Card */}
          <View
            style={[
              styles.heroCard,
              {
                backgroundColor: theme.hero,
                borderColor: isDark ? '#233223' : 'rgba(0,0,0,0.08)',
              },
            ]}
          >
            <View style={styles.heroTopRow}>
              <Text style={styles.heroLabel}>BU AYKİ HARCAMA</Text>
              <View style={styles.trendBadge}>
                <Ionicons
                  name="arrow-down-outline"
                  size={12}
                  color={colors.wiseLime}
                />
                <Text style={styles.trendText}>%12.5 azaldı</Text>
              </View>
            </View>

            <Text
              style={styles.heroAmount}
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

            {totalLimit > 0 ? (
              <View style={styles.budgetProgressSection}>
                <View style={styles.budgetInfoRow}>
                  <Text
                    style={[
                      styles.budgetTextLeft,
                      {
                        color:
                          remainingBudget < 0
                            ? '#F87171'
                            : colors.wiseLime,
                      },
                    ]}
                  >
                    Kalan: {remainingBudget.toLocaleString('tr-TR', {
                      maximumFractionDigits: 0,
                    })} TL
                  </Text>
                  <Text style={styles.budgetTextRight}>
                    Hedef: {totalLimit.toLocaleString('tr-TR', {
                      maximumFractionDigits: 0,
                    })} TL
                  </Text>
                </View>
                <View style={styles.progressBarBg}>
                  <View
                    style={[
                      styles.progressBarFill,
                      {
                        width: `${budgetProgress * 100}%`,
                        backgroundColor:
                          remainingBudget < 0 ? '#EF4444' : colors.wiseLime,
                      },
                    ]}
                  />
                </View>
              </View>
            ) : (
              <Text style={styles.budgetHint}>
                Aylık harcama hedefinizi 'Limitler' bölümünden belirleyebilirsiniz.
              </Text>
            )}

            {/* 3 Mini Stat Pills */}
            <View style={styles.miniStatsRow}>
              {[
                { label: 'Yiyecek', amount: foodSpent, color: '#F59E0B' },
                { label: 'Ulaşım', amount: transportSpent, color: '#38BDF8' },
                { label: 'Alışveriş', amount: shoppingSpent, color: '#FB7185' },
              ].map((item) => (
                <View key={item.label} style={styles.statPill}>
                  <View style={styles.statDotRow}>
                    <View
                      style={[
                        styles.statDot,
                        { backgroundColor: item.color },
                      ]}
                    />
                    <Text style={styles.statLabel} numberOfLines={1}>
                      {item.label}
                    </Text>
                  </View>
                  <Text
                    style={styles.statAmount}
                    numberOfLines={1}
                    adjustsFontSizeToFit
                    minimumFontScale={0.7}
                  >
                    {formatCompactTRY(item.amount)}
                  </Text>
                </View>
              ))}
            </View>
          </View>

          {/* Category Budgets Carousel */}
          <View style={styles.sectionContainer}>
            <View style={styles.sectionHeader}>
              <Text style={[styles.sectionTitle, { color: theme.text }]}>
                Kategori Bütçeleri
              </Text>
              <BouncingButton
                onPress={() => setLimitsModalVisible(true)}
                style={styles.tuneButton}
              >
                <Ionicons
                  name="options-outline"
                  size={15}
                  color={isDark ? colors.wiseLime : colors.wiseForest}
                />
                <Text
                  style={[
                    styles.tuneButtonText,
                    { color: isDark ? colors.wiseLime : colors.wiseForest },
                  ]}
                >
                  Limitler
                </Text>
              </BouncingButton>
            </View>

            <ScrollView
              horizontal
              showsHorizontalScrollIndicator={false}
              contentContainerStyle={styles.carouselContainer}
            >
              {exp.budgets.map((b) => (
                <CategoryBudgetCompactCard
                  key={b.category}
                  category={b.category}
                  spent={exp.getSpentByCategory(b.category)}
                  limit={b.limit}
                  onTap={() => openEditLimit(b.category)}
                />
              ))}
            </ScrollView>
          </View>

          {/* Recent Transactions */}
          <View style={styles.sectionContainer}>
            <View style={styles.sectionHeader}>
              <Text style={[styles.sectionTitle, { color: theme.text }]}>
                Son Harcamalar
              </Text>
              {exp.expenses.length > 0 && (
                <BouncingButton
                  onPress={() => nav.navigate('AllExpenses')}
                  style={styles.seeAllButton}
                >
                  <Text
                    style={[
                      styles.seeAllText,
                      {
                        color: isDark
                          ? colors.wiseLime
                          : colors.wiseForest,
                      },
                    ]}
                  >
                    Tümünü Gör ({exp.expenses.length})
                  </Text>
                  <Ionicons
                    name="chevron-forward"
                    size={14}
                    color={isDark ? colors.wiseLime : colors.wiseForest}
                  />
                </BouncingButton>
              )}
            </View>

            {exp.expenses.length === 0 ? (
              <View style={styles.emptyContainer}>
                <Ionicons
                  name="receipt-outline"
                  size={48}
                  color={theme.textMuted}
                />
                <Text style={[styles.emptyTitle, { color: theme.textMuted }]}>
                  Henüz harcama eklenmedi
                </Text>
                <Text style={[styles.emptySubtitle, { color: theme.textMuted }]}>
                  Aşağıdaki + butonuna basarak ilk harcamanızı kaydedin.
                </Text>
              </View>
            ) : (
              exp.expenses.slice(0, 4).map((e) => (
                <ExpenseCard
                  key={e.id}
                  expense={e}
                  usdRate={exp.usdRate}
                  eurRate={exp.eurRate}
                  rates={exp.rates}
                />
              ))
            )}
          </View>
        </ScrollView>

        {/* Floating Action Button */}
        <View style={styles.fabWrapper}>
          <BouncingButton
            onPress={() => nav.navigate('AddExpense')}
            style={[
              styles.fab,
              {
                backgroundColor: isDark
                  ? colors.wiseLime
                  : colors.wiseForest,
              },
            ]}
          >
            <Ionicons
              name="add"
              size={32}
              color={isDark ? colors.wiseForest : colors.wiseLime}
            />
          </BouncingButton>
        </View>
      </ResponsiveContainer>

      {/* Budget Limits Modal */}
      <Modal
        visible={limitsModalVisible}
        animationType="slide"
        transparent
        onRequestClose={() => setLimitsModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View
            style={[
              styles.modalSheet,
              {
                backgroundColor: theme.surface,
                borderColor: theme.border,
              },
            ]}
          >
            <View style={styles.modalHandle} />
            <View style={styles.modalHeaderRow}>
              <Text style={[styles.modalTitle, { color: theme.text }]}>
                Bütçe Limitleri
              </Text>
              <BouncingButton onPress={() => setLimitsModalVisible(false)}>
                <Ionicons name="close" size={22} color={theme.text} />
              </BouncingButton>
            </View>
            <Text style={[styles.modalSubtitle, { color: theme.textMuted }]}>
              Aylık harcama hedeflerinizi belirleyin
            </Text>

            <ScrollView style={{ marginTop: 14 }}>
              {exp.budgets.map((budget) => {
                const meta = getMeta(budget.category);
                const spent = exp.getSpentByCategory(budget.category);

                return (
                  <View
                    key={budget.category}
                    style={[
                      styles.limitRow,
                      { borderBottomColor: theme.border },
                    ]}
                  >
                    <View
                      style={[
                        styles.limitIcon,
                        { backgroundColor: meta.color + '1F' },
                      ]}
                    >
                      <Ionicons
                        name={meta.icon as any}
                        size={18}
                        color={meta.color}
                      />
                    </View>
                    <View style={{ flex: 1, marginLeft: 12 }}>
                      <Text style={[styles.limitName, { color: theme.text }]}>
                        {meta.displayName}
                      </Text>
                      <Text
                        style={[
                          styles.limitSpentText,
                          { color: theme.textMuted },
                        ]}
                      >
                        Harcama:{' '}
                        {spent.toLocaleString('tr-TR', {
                          maximumFractionDigits: 0,
                        })}{' '}
                        ₺
                      </Text>
                    </View>
                    <BouncingButton
                      onPress={() => {
                        setLimitsModalVisible(false);
                        openEditLimit(budget.category);
                      }}
                      style={[
                        styles.limitActionChip,
                        {
                          backgroundColor:
                            budget.limit > 0
                              ? theme.field
                              : isDark
                              ? colors.wiseLime
                              : colors.wiseForest,
                        },
                      ]}
                    >
                      <Text
                        style={[
                          styles.limitActionText,
                          {
                            color:
                              budget.limit > 0
                                ? theme.text
                                : isDark
                                ? colors.wiseForest
                                : colors.wiseLime,
                          },
                        ]}
                      >
                        {budget.limit > 0
                          ? `${budget.limit.toLocaleString('tr-TR')} ₺`
                          : 'Limit Koy'}
                      </Text>
                    </BouncingButton>
                  </View>
                );
              })}
            </ScrollView>
          </View>
        </View>
      </Modal>

      {/* Edit Limit Dialog */}
      <Modal
        visible={!!editLimitCategory}
        animationType="fade"
        transparent
        onRequestClose={() => setEditLimitCategory(null)}
      >
        <View style={styles.modalOverlay}>
          <View
            style={[
              styles.editDialog,
              {
                backgroundColor: theme.surface,
                borderColor: theme.border,
              },
            ]}
          >
            {editLimitCategory && (
              <>
                <Text style={[styles.dialogTitle, { color: theme.text }]}>
                  {getMeta(editLimitCategory).displayName} Limiti
                </Text>
                <Text
                  style={[styles.dialogSubtitle, { color: theme.textMuted }]}
                >
                  Aylık harcama hedefinizi belirleyin (TRY)
                </Text>

                <TextInput
                  value={limitInput}
                  onChangeText={setLimitInput}
                  placeholder="0"
                  placeholderTextColor={theme.textMuted}
                  keyboardType="decimal-pad"
                  autoFocus
                  style={[
                    styles.dialogInput,
                    {
                      backgroundColor: theme.field,
                      color: theme.text,
                      borderColor: theme.border,
                    },
                  ]}
                />

                <View style={styles.dialogActions}>
                  <BouncingButton
                    onPress={async () => {
                      if (editLimitCategory) {
                        await exp.setBudgetLimit(editLimitCategory, 0);
                        setEditLimitCategory(null);
                      }
                    }}
                    style={styles.dialogRemoveButton}
                  >
                    <Text style={styles.dialogRemoveText}>Kaldır</Text>
                  </BouncingButton>

                  <BouncingButton
                    onPress={saveCategoryLimit}
                    style={[
                      styles.dialogSaveButton,
                      {
                        backgroundColor: isDark
                          ? colors.wiseLime
                          : colors.wiseForest,
                      },
                    ]}
                  >
                    <Text
                      style={[
                        styles.dialogSaveText,
                        {
                          color: isDark
                            ? colors.wiseForest
                            : colors.wiseLime,
                        },
                      ]}
                    >
                      Kaydet
                    </Text>
                  </BouncingButton>
                </View>
              </>
            )}
          </View>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: 20,
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  greetingSub: {
    fontSize: 13,
    fontWeight: '500',
  },
  greetingTitle: {
    fontSize: 22,
    fontWeight: '800',
    letterSpacing: -0.5,
    marginTop: 1,
  },
  headerActions: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  rateChip: {
    paddingHorizontal: 10,
    paddingVertical: 7,
    borderRadius: 12,
    borderWidth: 1,
  },
  rateText: {
    fontSize: 12,
    fontWeight: '700',
  },
  iconButton: {
    width: 38,
    height: 38,
    borderRadius: 12,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  heroCard: {
    borderRadius: 24,
    padding: 22,
    borderWidth: 1,
    shadowColor: '#000',
    shadowOpacity: 0.15,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 6 },
    elevation: 4,
  },
  heroTopRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  heroLabel: {
    color: 'rgba(255,255,255,0.72)',
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 1.1,
  },
  trendBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(159, 232, 112, 0.18)',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 8,
    gap: 3,
  },
  trendText: {
    color: '#9FE870',
    fontSize: 11,
    fontWeight: '800',
  },
  heroAmount: {
    color: '#FFFFFF',
    fontSize: 38,
    fontWeight: '900',
    letterSpacing: -1,
    marginVertical: 6,
  },
  budgetProgressSection: {
    marginTop: 4,
    marginBottom: 4,
  },
  budgetInfoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 6,
  },
  budgetTextLeft: {
    fontSize: 13,
    fontWeight: '700',
  },
  budgetTextRight: {
    fontSize: 12,
    fontWeight: '500',
    color: 'rgba(255,255,255,0.68)',
  },
  progressBarBg: {
    height: 5,
    backgroundColor: 'rgba(255,255,255,0.15)',
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressBarFill: {
    height: 5,
    borderRadius: 4,
  },
  budgetHint: {
    fontSize: 12,
    color: 'rgba(255,255,255,0.65)',
    marginVertical: 4,
  },
  miniStatsRow: {
    flexDirection: 'row',
    gap: 8,
    marginTop: 16,
  },
  statPill: {
    flex: 1,
    minWidth: 0,
    backgroundColor: 'rgba(255,255,255,0.1)',
    borderRadius: 13,
    paddingVertical: 9,
    paddingHorizontal: 6,
    alignItems: 'center',
  },
  statDotRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    maxWidth: '100%',
  },
  statDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
  },
  statLabel: {
    fontSize: 11,
    fontWeight: '600',
    color: 'rgba(255,255,255,0.85)',
  },
  statAmount: {
    fontSize: 13,
    fontWeight: '800',
    color: '#FFFFFF',
    marginTop: 2,
    textAlign: 'center',
    width: '100%',
  },
  sectionContainer: {
    marginTop: 22,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '800',
    letterSpacing: -0.3,
  },
  tuneButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: 6,
    paddingVertical: 2,
  },
  tuneButtonText: {
    fontSize: 13,
    fontWeight: '700',
  },
  carouselContainer: {
    paddingRight: 10,
  },
  seeAllButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 2,
  },
  seeAllText: {
    fontSize: 13,
    fontWeight: '700',
  },
  emptyContainer: {
    alignItems: 'center',
    paddingVertical: 36,
  },
  emptyTitle: {
    fontSize: 15,
    fontWeight: '600',
    marginTop: 12,
  },
  emptySubtitle: {
    fontSize: 13,
    opacity: 0.7,
    marginTop: 4,
    textAlign: 'center',
  },
  fabWrapper: {
    position: 'absolute',
    right: 20,
    bottom: 28,
  },
  fab: {
    width: 60,
    height: 60,
    borderRadius: 30,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOpacity: 0.25,
    shadowRadius: 14,
    shadowOffset: { width: 0, height: 6 },
    elevation: 6,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'flex-end',
    alignItems: 'center',
  },
  modalSheet: {
    width: '100%',
    maxWidth: 640,
    maxHeight: '75%',
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    borderWidth: 1,
    padding: 20,
  },
  modalHandle: {
    width: 36,
    height: 4,
    borderRadius: 2,
    backgroundColor: 'rgba(150,150,150,0.4)',
    alignSelf: 'center',
    marginBottom: 14,
  },
  modalHeaderRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  modalTitle: {
    fontSize: 19,
    fontWeight: '800',
  },
  modalSubtitle: {
    fontSize: 13,
    marginTop: 2,
  },
  limitRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
  },
  limitIcon: {
    width: 38,
    height: 38,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  limitName: {
    fontSize: 15,
    fontWeight: '700',
  },
  limitSpentText: {
    fontSize: 12,
    marginTop: 2,
  },
  limitActionChip: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 12,
  },
  limitActionText: {
    fontSize: 13,
    fontWeight: '700',
  },
  editDialog: {
    width: '88%',
    maxWidth: 400,
    borderRadius: 24,
    borderWidth: 1,
    padding: 22,
    alignSelf: 'center',
    marginVertical: 'auto',
  },
  dialogTitle: {
    fontSize: 19,
    fontWeight: '800',
    textAlign: 'center',
  },
  dialogSubtitle: {
    fontSize: 13,
    textAlign: 'center',
    marginTop: 4,
    marginBottom: 18,
  },
  dialogInput: {
    borderWidth: 1,
    borderRadius: 16,
    paddingVertical: 14,
    paddingHorizontal: 18,
    fontSize: 26,
    fontWeight: '800',
    textAlign: 'center',
  },
  dialogActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 20,
    gap: 12,
  },
  dialogRemoveButton: {
    flex: 1,
    paddingVertical: 13,
    alignItems: 'center',
  },
  dialogRemoveText: {
    color: '#EF4444',
    fontSize: 15,
    fontWeight: '700',
  },
  dialogSaveButton: {
    flex: 2,
    paddingVertical: 13,
    borderRadius: 14,
    alignItems: 'center',
  },
  dialogSaveText: {
    fontSize: 15,
    fontWeight: '800',
  },
});
