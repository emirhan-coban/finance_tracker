import React, { useState, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TextInput,
  Modal,
  Alert,
  Pressable,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { useTheme } from '../context/ThemeContext';
import { useExpenses } from '../context/ExpenseContext';
import {
  Subscription,
  POPULAR_SUBSCRIPTION_TEMPLATES,
  SubscriptionTemplate,
  getDaysUntilRenewal,
  formatRenewalBadge,
  BillingCycle,
} from '../models/Subscription';
import {
  getCurrencySymbol,
  AVAILABLE_CURRENCIES,
} from '../services/currencyService';
import { formatCompactTRY } from '../utils/formatUtils';
import BouncingButton from '../components/BouncingButton';
import ResponsiveContainer from '../components/ResponsiveContainer';

export default function SubscriptionsScreen() {
  const insets = useSafeAreaInsets();
  const { isDark, theme, colors } = useTheme();
  const exp = useExpenses();
  const nav = useNavigation<any>();

  const [modalVisible, setModalVisible] = useState(false);
  const [editingSub, setEditingSub] = useState<Subscription | null>(null);

  // Form State
  const [name, setName] = useState('');
  const [amount, setAmount] = useState('');
  const [currency, setCurrency] = useState('TRY');
  const [billingCycle, setBillingCycle] = useState<BillingCycle>('monthly');
  const [renewalDay, setRenewalDay] = useState('15');
  const [category, setCategory] = useState('Eğlence');
  const [color, setColor] = useState('#E50914');
  const [icon, setIcon] = useState('film-outline');

  // Currency Modal State
  const [currencyModalVisible, setCurrencyModalVisible] = useState(false);
  const [customCurrencyInput, setCustomCurrencyInput] = useState('');

  const handleSelectCurrency = (code: string) => {
    setCurrency(code);
    setCurrencyModalVisible(false);
    Haptics.selectionAsync().catch(() => {});
  };

  const handleCustomCurrencySubmit = () => {
    const code = customCurrencyInput.trim().toUpperCase();
    if (code.length >= 2 && code.length <= 5) {
      setCurrency(code);
      setCustomCurrencyInput('');
      setCurrencyModalVisible(false);
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success).catch(
        () => {}
      );
    } else {
      Alert.alert(
        'Geçersiz Kur',
        'Lütfen geçerli bir para birimi kodu girin (örn: USD, EUR, GBP, JPY).'
      );
    }
  };

  const monthlyTotalTRY = exp.getMonthlySubscriptionTotalTRY();
  const yearlyTotalTRY = exp.getYearlySubscriptionTotalTRY();

  // Sort subscriptions: active first, then closest renewal date
  const sortedSubscriptions = useMemo(() => {
    return [...exp.subscriptions].sort((a, b) => {
      if (a.isActive !== b.isActive) return a.isActive ? -1 : 1;
      return (
        getDaysUntilRenewal(a.renewalDay) - getDaysUntilRenewal(b.renewalDay)
      );
    });
  }, [exp.subscriptions]);

  const openAddModal = (template?: SubscriptionTemplate) => {
    setCurrencyModalVisible(false);
    if (template) {
      setName(template.name);
      setAmount(template.defaultAmount.toString());
      setCurrency(template.currency);
      setBillingCycle(template.billingCycle);
      setCategory(template.category);
      setColor(template.color);
      setIcon(template.icon);
    } else {
      setName('');
      setAmount('');
      setCurrency('TRY');
      setBillingCycle('monthly');
      setCategory('Eğlence');
      setColor('#9FE870');
      setIcon('card-outline');
    }
    setRenewalDay('15');
    setEditingSub(null);
    setModalVisible(true);
  };

  const openEditModal = (sub: Subscription) => {
    setCurrencyModalVisible(false);
    setEditingSub(sub);
    setName(sub.name);
    setAmount(sub.amount.toString());
    setCurrency(sub.currency);
    setBillingCycle(sub.billingCycle);
    setRenewalDay(sub.renewalDay.toString());
    setCategory(sub.category);
    setColor(sub.color);
    setIcon(sub.icon);
    setModalVisible(true);
  };

  const handleAmountChange = (text: string) => {
    if (!text) {
      setAmount('');
      return;
    }
    let cleaned = text.replace(/,/g, '.').replace(/[^0-9.]/g, '');
    if (cleaned.startsWith('.')) cleaned = '0' + cleaned;
    const parts = cleaned.split('.');
    if (parts.length > 2) cleaned = parts[0] + '.' + parts.slice(1).join('');
    if (cleaned.includes('.')) {
      const [intPart, decPart] = cleaned.split('.');
      cleaned = `${intPart}.${decPart.slice(0, 2)}`;
    }
    setAmount(cleaned);
  };

  const handleSave = async () => {
    const parsedAmount = parseFloat(amount.replace(',', '.'));
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      Alert.alert('Geçersiz Tutar', 'Lütfen geçerli bir abonelik ücreti girin.');
      return;
    }
    if (!name.trim()) {
      Alert.alert('Eksik Bilgi', 'Lütfen bir abonelik adı girin.');
      return;
    }
    const day = parseInt(renewalDay, 10);
    const validDay = isNaN(day) ? 15 : Math.max(1, Math.min(31, day));

    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium).catch(() => {});

    if (editingSub) {
      await exp.updateSubscription({
        ...editingSub,
        name: name.trim(),
        amount: parsedAmount,
        currency,
        billingCycle,
        renewalDay: validDay,
        category,
        color,
        icon,
      });
    } else {
      await exp.addSubscription({
        id: Date.now().toString(),
        name: name.trim(),
        amount: parsedAmount,
        currency,
        billingCycle,
        renewalDay: validDay,
        category,
        color,
        icon,
        isActive: true,
        createdAt: new Date().toISOString(),
      });
    }

    setModalVisible(false);
  };

  const handleDelete = (sub: Subscription) => {
    Alert.alert(
      'Aboneliği Sil',
      `"${sub.name}" aboneliğini silmek istediğinizden emin misiniz?`,
      [
        { text: 'Vazgeç', style: 'cancel' },
        {
          text: 'Sil',
          style: 'destructive',
          onPress: async () => {
            Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy).catch(() => {});
            await exp.deleteSubscription(sub.id);
          },
        },
      ]
    );
  };

  const handleSyncToExpense = async (sub: Subscription) => {
    await exp.syncSubscriptionToExpense(sub);
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success).catch(
      () => {}
    );
    Alert.alert(
      'Harcamalara Eklendi ✅',
      `"${sub.name}" için bu ayki ${sub.amount} ${getCurrencySymbol(
        sub.currency
      )} ödemesi harcamalarınıza kaydedildi.`
    );
  };

  return (
    <View style={[styles.root, { backgroundColor: theme.bg }]}>
      <ResponsiveContainer maxWidth={640}>
        {/* Fixed Top Bar */}
        <View
          style={[
            styles.topBar,
            {
              paddingTop: insets.top + 6,
              backgroundColor: theme.bg,
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

          <Text style={[styles.topBarTitle, { color: theme.text }]}>
            Abonelik Radarı
          </Text>

          <BouncingButton
            onPress={() => openAddModal()}
            style={[
              styles.addHeaderButton,
              {
                backgroundColor: isDark
                  ? colors.wiseLime
                  : colors.wiseForest,
              },
            ]}
          >
            <Ionicons
              name="add"
              size={18}
              color={isDark ? colors.wiseForest : colors.wiseLime}
            />
            <Text
              style={[
                styles.addHeaderText,
                {
                  color: isDark ? colors.wiseForest : colors.wiseLime,
                },
              ]}
            >
              Yeni Ekle
            </Text>
          </BouncingButton>
        </View>

        <ScrollView
          contentContainerStyle={[
            styles.scrollContent,
            { paddingBottom: insets.bottom + 40 },
          ]}
          showsVerticalScrollIndicator={false}
        >
          {/* Hero Burn Rate Card */}
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
              <View style={styles.radarBadge}>
                <View style={styles.radarDot} />
                <Text style={styles.radarLabel}>ABONELİK MALİYET RADARI</Text>
              </View>
              <Text style={styles.activeCountText}>
                {exp.subscriptions.filter((s) => s.isActive).length} Aktif
              </Text>
            </View>

            <Text
              style={styles.heroAmount}
              numberOfLines={1}
              adjustsFontSizeToFit
              minimumFontScale={0.6}
            >
              {monthlyTotalTRY.toLocaleString('tr-TR', {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2,
              })}{' '}
              ₺
            </Text>

            <View style={styles.heroSubRow}>
              <Text style={styles.yearlySubText}>
                Yıllık toplam yük:{' '}
                <Text style={{ fontWeight: '800', color: colors.wiseLime }}>
                  {yearlyTotalTRY.toLocaleString('tr-TR', {
                    maximumFractionDigits: 0,
                  })}{' '}
                  ₺
                </Text>
              </Text>
            </View>
          </View>

          {/* Quick Preset Templates Carousel */}
          <View style={styles.sectionContainer}>
            <Text style={[styles.sectionTitle, { color: theme.text }]}>
              Hızlı Abonelik Ekle
            </Text>
            <ScrollView
              horizontal
              showsHorizontalScrollIndicator={false}
              contentContainerStyle={styles.templateCarousel}
            >
              {POPULAR_SUBSCRIPTION_TEMPLATES.map((tmpl) => (
                <BouncingButton
                  key={tmpl.name}
                  onPress={() => openAddModal(tmpl)}
                  style={[
                    styles.templateChip,
                    {
                      backgroundColor: theme.surface,
                      borderColor: theme.border,
                    },
                  ]}
                >
                  <View
                    style={[
                      styles.templateIconBox,
                      { backgroundColor: tmpl.color + '1F' },
                    ]}
                  >
                    <Ionicons
                      name={tmpl.icon as any}
                      size={18}
                      color={tmpl.color}
                    />
                  </View>
                  <View>
                    <Text
                      style={[styles.templateName, { color: theme.text }]}
                      numberOfLines={1}
                    >
                      {tmpl.name}
                    </Text>
                    <Text style={[styles.templateAmount, { color: theme.textMuted }]}>
                      {tmpl.defaultAmount} {getCurrencySymbol(tmpl.currency)}/ay
                    </Text>
                  </View>
                </BouncingButton>
              ))}
            </ScrollView>
          </View>

          {/* Subscriptions List */}
          <View style={styles.sectionContainer}>
            <View style={styles.sectionHeader}>
              <Text style={[styles.sectionTitle, { color: theme.text }]}>
                Aboneliklerim ({exp.subscriptions.length})
              </Text>
            </View>

            {sortedSubscriptions.length === 0 ? (
              <View
                style={[
                  styles.emptyCard,
                  {
                    backgroundColor: theme.surface,
                    borderColor: theme.border,
                  },
                ]}
              >
                <Ionicons
                  name="calendar-clear-outline"
                  size={42}
                  color={theme.textMuted}
                />
                <Text style={[styles.emptyTitle, { color: theme.text }]}>
                  Henüz abonelik eklenmedi
                </Text>
                <Text style={[styles.emptySub, { color: theme.textMuted }]}>
                  Yukarıdaki popüler servislerden birine dokunarak veya "Yeni Ekle"
                  butonuna basarak ilk aboneliğinizi kaydedin.
                </Text>
              </View>
            ) : (
              sortedSubscriptions.map((sub) => {
                const days = getDaysUntilRenewal(sub.renewalDay);
                const badge = formatRenewalBadge(days);
                const tryEquivalent = exp.convertToTRY(sub.amount, sub.currency);
                const isForeign = sub.currency !== 'TRY';

                return (
                  <View
                    key={sub.id}
                    style={[
                      styles.subCard,
                      {
                        backgroundColor: theme.surface,
                        borderColor: !sub.isActive
                          ? theme.border
                          : badge.urgent
                          ? isDark
                            ? 'rgba(159, 232, 112, 0.4)'
                            : 'rgba(22, 51, 0, 0.2)'
                          : theme.border,
                        opacity: sub.isActive ? 1 : 0.6,
                      },
                    ]}
                  >
                    <View style={styles.subCardMainRow}>
                      {/* Brand Icon Box */}
                      <View
                        style={[
                          styles.subIconBox,
                          { backgroundColor: sub.color + '22' },
                        ]}
                      >
                        <Ionicons
                          name={sub.icon as any}
                          size={22}
                          color={sub.color}
                        />
                      </View>

                      {/* Info Column */}
                      <View style={{ flex: 1, minWidth: 0, marginRight: 8 }}>
                        <View style={styles.subTitleRow}>
                          <Text
                            style={[styles.subName, { color: theme.text }]}
                            numberOfLines={1}
                          >
                            {sub.name}
                          </Text>
                          {sub.isActive ? (
                            <View
                              style={[
                                styles.renewalBadge,
                                {
                                  backgroundColor: badge.urgent
                                    ? 'rgba(245, 158, 11, 0.16)'
                                    : isDark
                                    ? 'rgba(159, 232, 112, 0.16)'
                                    : 'rgba(22, 51, 0, 0.08)',
                                },
                              ]}
                            >
                              <Text
                                style={[
                                  styles.renewalBadgeText,
                                  {
                                    color: badge.urgent
                                      ? '#F59E0B'
                                      : isDark
                                      ? colors.wiseLime
                                      : colors.wiseForest,
                                  },
                                ]}
                              >
                                {badge.text}
                              </Text>
                            </View>
                          ) : (
                            <View style={styles.pausedBadge}>
                              <Text style={styles.pausedBadgeText}>Duraklatıldı</Text>
                            </View>
                          )}
                        </View>

                        <Text
                          style={[styles.subMetaText, { color: theme.textMuted }]}
                          numberOfLines={1}
                        >
                          {sub.category} • Her ayın {sub.renewalDay}. günü
                        </Text>
                      </View>

                      {/* Amount Column */}
                      <View style={{ alignItems: 'flex-end', flexShrink: 0 }}>
                        <Text
                          style={[styles.subAmountText, { color: theme.text }]}
                          numberOfLines={1}
                        >
                          {sub.amount.toLocaleString('tr-TR', {
                            minimumFractionDigits: 2,
                            maximumFractionDigits: 2,
                          })}{' '}
                          {getCurrencySymbol(sub.currency)}
                        </Text>
                        {isForeign && (
                          <Text
                            style={[
                              styles.subConvertedText,
                              { color: theme.textMuted },
                            ]}
                          >
                            ≈ {formatCompactTRY(tryEquivalent)}
                          </Text>
                        )}
                      </View>
                    </View>

                    {/* Bottom Action Strip */}
                    <View
                      style={[
                        styles.subCardActionStrip,
                        { borderTopColor: theme.border },
                      ]}
                    >
                      <BouncingButton
                        onPress={() => handleSyncToExpense(sub)}
                        style={[
                          styles.actionStripButton,
                          {
                            backgroundColor: isDark
                              ? 'rgba(159, 232, 112, 0.12)'
                              : 'rgba(22, 51, 0, 0.06)',
                          },
                        ]}
                      >
                        <Ionicons
                          name="receipt-outline"
                          size={14}
                          color={isDark ? colors.wiseLime : colors.wiseForest}
                        />
                        <Text
                          style={[
                            styles.actionStripButtonText,
                            {
                              color: isDark
                                ? colors.wiseLime
                                : colors.wiseForest,
                            },
                          ]}
                        >
                          Bu Ayı Harcamalara Ekle
                        </Text>
                      </BouncingButton>

                      <View style={{ flexDirection: 'row', gap: 6 }}>
                        <BouncingButton
                          onPress={() => openEditModal(sub)}
                          style={[
                            styles.actionMiniButton,
                            { backgroundColor: theme.field },
                          ]}
                        >
                          <Ionicons
                            name="create-outline"
                            size={16}
                            color={theme.text}
                          />
                        </BouncingButton>

                        <BouncingButton
                          onPress={() => exp.toggleSubscription(sub.id)}
                          style={[
                            styles.actionMiniButton,
                            { backgroundColor: theme.field },
                          ]}
                        >
                          <Ionicons
                            name={
                              sub.isActive
                                ? 'pause-circle-outline'
                                : 'play-circle-outline'
                            }
                            size={16}
                            color={sub.isActive ? '#F59E0B' : colors.wiseLime}
                          />
                        </BouncingButton>

                        <BouncingButton
                          onPress={() => handleDelete(sub)}
                          style={[
                            styles.actionMiniButton,
                            { backgroundColor: 'rgba(239, 68, 68, 0.12)' },
                          ]}
                        >
                          <Ionicons
                            name="trash-outline"
                            size={16}
                            color="#EF4444"
                          />
                        </BouncingButton>
                      </View>
                    </View>
                  </View>
                );
              })
            )}
          </View>
        </ScrollView>
      </ResponsiveContainer>

      {/* Add / Edit Subscription Modal */}
      <Modal
        visible={modalVisible}
        transparent
        animationType="slide"
        onRequestClose={() => {
          if (currencyModalVisible) {
            setCurrencyModalVisible(false);
          } else {
            setModalVisible(false);
          }
        }}
      >
        <View style={styles.modalOverlay}>
          <View
            style={[
              styles.modalSheet,
              {
                backgroundColor: theme.surface,
                borderColor: theme.border,
                maxHeight: '88%',
              },
            ]}
          >
            <View style={styles.modalHandle} />
            <View style={styles.modalHeaderRow}>
              <Text style={[styles.modalTitle, { color: theme.text }]}>
                {editingSub ? 'Aboneliği Düzenle' : 'Yeni Abonelik Ekle'}
              </Text>
              <BouncingButton onPress={() => setModalVisible(false)}>
                <Ionicons name="close" size={22} color={theme.text} />
              </BouncingButton>
            </View>

            <ScrollView
              style={{ marginTop: 14 }}
              showsVerticalScrollIndicator={false}
              keyboardShouldPersistTaps="handled"
            >
              {/* Name Input */}
              <Text style={[styles.inputLabel, { color: theme.text }]}>
                Servis / Abonelik Adı
              </Text>
              <TextInput
                value={name}
                onChangeText={setName}
                placeholder="Örn: Netflix, Spotify, iCloud..."
                placeholderTextColor={theme.textMuted + '88'}
                style={[
                  styles.textInput,
                  {
                    backgroundColor: theme.field,
                    borderColor: theme.border,
                    color: theme.text,
                  },
                ]}
              />

              {/* Amount & Currency Row */}
              <View style={{ flexDirection: 'row', gap: 10, marginTop: 14 }}>
                <View style={{ flex: 1 }}>
                  <Text style={[styles.inputLabel, { color: theme.text }]}>
                    Ücret
                  </Text>
                  <TextInput
                    value={amount}
                    onChangeText={handleAmountChange}
                    placeholder="0"
                    placeholderTextColor={theme.textMuted + '88'}
                    keyboardType="decimal-pad"
                    style={[
                      styles.textInput,
                      {
                        backgroundColor: theme.field,
                        borderColor: theme.border,
                        color: theme.text,
                        fontWeight: '800',
                      },
                    ]}
                  />
                </View>

                <View style={{ width: 140 }}>
                  <Text style={[styles.inputLabel, { color: theme.text }]}>
                    Para Birimi
                  </Text>
                  <View style={styles.currencyToggleRow}>
                    <BouncingButton
                      onPress={() => setCurrency('TRY')}
                      style={[
                        styles.currMiniChip,
                        {
                          backgroundColor:
                            currency === 'TRY'
                              ? isDark
                                ? colors.wiseLime
                                : colors.wiseForest
                              : theme.field,
                          borderColor:
                            currency === 'TRY'
                              ? isDark
                                ? colors.wiseLime
                                : colors.wiseForest
                              : theme.border,
                        },
                      ]}
                    >
                      <Text
                        style={[
                          styles.currMiniText,
                          {
                            color:
                              currency === 'TRY'
                                ? isDark
                                  ? colors.wiseForest
                                  : colors.wiseLime
                                : theme.text,
                          },
                        ]}
                      >
                        TRY (₺)
                      </Text>
                    </BouncingButton>

                    <BouncingButton
                      onPress={() => setCurrencyModalVisible(true)}
                      style={[
                        styles.currMiniChip,
                        {
                          backgroundColor:
                            currency !== 'TRY'
                              ? isDark
                                ? colors.wiseLime
                                : colors.wiseForest
                              : theme.field,
                          borderColor:
                            currency !== 'TRY'
                              ? isDark
                                ? colors.wiseLime
                                : colors.wiseForest
                              : theme.border,
                        },
                      ]}
                    >
                      <Text
                        style={[
                          styles.currMiniText,
                          {
                            color:
                              currency !== 'TRY'
                                ? isDark
                                  ? colors.wiseForest
                                  : colors.wiseLime
                                : theme.text,
                          },
                        ]}
                        numberOfLines={1}
                      >
                        {currency !== 'TRY'
                          ? `${currency} (${getCurrencySymbol(currency)}) ▾`
                          : 'Diğer ▾'}
                      </Text>
                    </BouncingButton>
                  </View>
                </View>
              </View>

              {/* Renewal Day Picker */}
              <View style={{ marginTop: 14 }}>
                <Text style={[styles.inputLabel, { color: theme.text }]}>
                  Yenilenme Günü (Her ayın kaçıncı günü?)
                </Text>
                <TextInput
                  value={renewalDay}
                  onChangeText={(val) => {
                    const cleaned = val.replace(/[^0-9]/g, '');
                    setRenewalDay(cleaned);
                  }}
                  placeholder="15"
                  maxLength={2}
                  keyboardType="number-pad"
                  style={[
                    styles.textInput,
                    {
                      backgroundColor: theme.field,
                      borderColor: theme.border,
                      color: theme.text,
                      fontWeight: '700',
                    },
                  ]}
                />
              </View>

              {/* Category Picker */}
              <View style={{ marginTop: 14 }}>
                <Text style={[styles.inputLabel, { color: theme.text }]}>
                  Kategori
                </Text>
                <View style={styles.categoryPillsRow}>
                  {[
                    'Eğlence',
                    'Müzik',
                    'Bulut & Depolama',
                    'Yapay Zeka & Araçlar',
                    'Sağlık & Spor',
                    'Eğitim',
                    'Diğer',
                  ].map((cat) => {
                    const isSel = category === cat;
                    return (
                      <BouncingButton
                        key={cat}
                        onPress={() => setCategory(cat)}
                        style={[
                          styles.categoryPill,
                          {
                            backgroundColor: isSel
                              ? isDark
                                ? colors.wiseLime
                                : colors.wiseForest
                              : theme.field,
                            borderColor: isSel
                              ? isDark
                                ? colors.wiseLime
                                : colors.wiseForest
                              : theme.border,
                          },
                        ]}
                      >
                        <Text
                          style={[
                            styles.categoryPillText,
                            {
                              color: isSel
                                ? isDark
                                  ? colors.wiseForest
                                  : colors.wiseLime
                                : theme.text,
                            },
                          ]}
                        >
                          {cat}
                        </Text>
                      </BouncingButton>
                    );
                  })}
                </View>
              </View>

              {/* Submit Button */}
              <BouncingButton
                onPress={handleSave}
                style={[
                  styles.saveModalButton,
                  {
                    backgroundColor: isDark
                      ? colors.wiseLime
                      : colors.wiseForest,
                  },
                ]}
              >
                <Text
                  style={[
                    styles.saveModalButtonText,
                    {
                      color: isDark
                        ? colors.wiseForest
                        : colors.wiseLime,
                    },
                  ]}
                >
                  {editingSub ? 'Güncelle' : 'Aboneliği Kaydet'}
                </Text>
              </BouncingButton>
            </ScrollView>
          </View>

          {/* Diğer Kur Seçim Katmanı (Modal İçi Overlay - iOS Nested Modal çakışmasını çözer) */}
          {currencyModalVisible && (
            <View
              style={[
                StyleSheet.absoluteFill,
                {
                  backgroundColor: 'rgba(0,0,0,0.6)',
                  justifyContent: 'flex-end',
                  zIndex: 999,
                },
              ]}
            >
              <Pressable
                style={StyleSheet.absoluteFill}
                onPress={() => setCurrencyModalVisible(false)}
              />
              <View
                style={[
                  styles.modalSheet,
                  {
                    backgroundColor: theme.surface,
                    borderColor: theme.border,
                    maxHeight: '80%',
                    zIndex: 1000,
                  },
                ]}
              >
                <View style={styles.modalHandle} />
                <View style={styles.modalHeaderRow}>
                  <Text style={[styles.modalTitle, { color: theme.text }]}>
                    Abonelik Para Birimi Seç
                  </Text>
                  <BouncingButton onPress={() => setCurrencyModalVisible(false)}>
                    <Ionicons name="close" size={22} color={theme.text} />
                  </BouncingButton>
                </View>

                <ScrollView
                  style={{ marginTop: 12 }}
                  showsVerticalScrollIndicator={false}
                  keyboardShouldPersistTaps="handled"
                >
                  {AVAILABLE_CURRENCIES.map((item) => {
                    const isSelected = currency === item.code;
                    const liveRate = exp.rates[item.code] ?? item.fallbackRate;
                    return (
                      <BouncingButton
                        key={item.code}
                        onPress={() => handleSelectCurrency(item.code)}
                        style={[
                          styles.currencyListItem,
                          {
                            backgroundColor: isSelected
                              ? isDark
                                ? 'rgba(159, 232, 112, 0.16)'
                                : 'rgba(22, 51, 0, 0.08)'
                              : theme.field,
                            borderColor: isSelected
                              ? isDark
                                ? colors.wiseLime
                                : colors.wiseForest
                              : theme.border,
                          },
                        ]}
                      >
                        <View style={styles.currencyBadge}>
                          <Text style={styles.currencyBadgeText}>{item.symbol}</Text>
                        </View>
                        <View style={{ flex: 1, marginLeft: 12 }}>
                          <Text
                            style={[
                              styles.currencyCodeText,
                              {
                                color: theme.text,
                                fontWeight: isSelected ? '800' : '600',
                              },
                            ]}
                          >
                            {item.code} — {item.name}
                          </Text>
                          {item.code !== 'TRY' && (
                            <Text
                              style={[
                                styles.currencyRateSub,
                                { color: theme.textMuted },
                              ]}
                            >
                              1 {item.code} ≈ {liveRate.toFixed(2)} ₺
                            </Text>
                          )}
                        </View>
                        {isSelected && (
                          <Ionicons
                            name="checkmark-circle"
                            size={20}
                            color={isDark ? colors.wiseLime : colors.wiseForest}
                          />
                        )}
                      </BouncingButton>
                    );
                  })}

                  {/* Özel Kur Girişi */}
                  <View
                    style={[
                      styles.customCurrencyCard,
                      {
                        backgroundColor: theme.field,
                        borderColor: theme.border,
                      },
                    ]}
                  >
                    <Text style={[styles.customCurrencyTitle, { color: theme.text }]}>
                      Özel Kur Kodu Ekle
                    </Text>
                    <View style={styles.customInputRow}>
                      <TextInput
                        value={customCurrencyInput}
                        onChangeText={setCustomCurrencyInput}
                        placeholder="Örn: NOK, SEK, DKK"
                        placeholderTextColor={theme.textMuted + '88'}
                        autoCapitalize="characters"
                        maxLength={5}
                        style={[
                          styles.customTextInput,
                          {
                            backgroundColor: theme.surface,
                            borderColor: theme.border,
                            color: theme.text,
                          },
                        ]}
                      />
                      <BouncingButton
                        onPress={handleCustomCurrencySubmit}
                        style={[
                          styles.customAddButton,
                          {
                            backgroundColor: isDark
                              ? colors.wiseLime
                              : colors.wiseForest,
                          },
                        ]}
                      >
                        <Text
                          style={[
                            styles.customAddText,
                            {
                              color: isDark
                                ? colors.wiseForest
                                : colors.wiseLime,
                            },
                          ]}
                        >
                          Uygula
                        </Text>
                      </BouncingButton>
                    </View>
                  </View>
                </ScrollView>
              </View>
            </View>
          )}
        </View>
      </Modal>
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
    paddingBottom: 8,
    zIndex: 10,
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
  addHeaderButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 12,
    gap: 4,
  },
  addHeaderText: {
    fontSize: 13,
    fontWeight: '800',
  },
  scrollContent: {
    paddingHorizontal: 20,
    paddingTop: 10,
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
  radarBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  radarDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#9FE870',
  },
  radarLabel: {
    color: 'rgba(255,255,255,0.72)',
    fontSize: 11,
    fontWeight: '800',
    letterSpacing: 1.1,
  },
  activeCountText: {
    fontSize: 12,
    fontWeight: '700',
    color: '#9FE870',
  },
  heroAmount: {
    color: '#FFFFFF',
    fontSize: 38,
    fontWeight: '900',
    letterSpacing: -1,
    marginVertical: 6,
  },
  heroSubRow: {
    marginTop: 4,
  },
  yearlySubText: {
    color: 'rgba(255,255,255,0.75)',
    fontSize: 13,
    fontWeight: '500',
  },
  sectionContainer: {
    marginTop: 22,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  sectionTitle: {
    fontSize: 17,
    fontWeight: '800',
    letterSpacing: -0.3,
    marginBottom: 10,
  },
  templateCarousel: {
    gap: 10,
    paddingRight: 20,
  },
  templateChip: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderRadius: 16,
    borderWidth: 1,
    gap: 10,
    minWidth: 140,
  },
  templateIconBox: {
    width: 36,
    height: 36,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  templateName: {
    fontSize: 13,
    fontWeight: '700',
  },
  templateAmount: {
    fontSize: 11,
    marginTop: 2,
    fontWeight: '500',
  },
  emptyCard: {
    borderRadius: 20,
    borderWidth: 1,
    padding: 24,
    alignItems: 'center',
    marginTop: 8,
  },
  emptyTitle: {
    fontSize: 16,
    fontWeight: '800',
    marginTop: 10,
  },
  emptySub: {
    fontSize: 13,
    textAlign: 'center',
    marginTop: 6,
    lineHeight: 18,
  },
  subCard: {
    borderRadius: 20,
    borderWidth: 1,
    marginBottom: 12,
    overflow: 'hidden',
  },
  subCardMainRow: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
  },
  subIconBox: {
    width: 44,
    height: 44,
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  subTitleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    flexWrap: 'wrap',
  },
  subName: {
    fontSize: 15,
    fontWeight: '800',
  },
  renewalBadge: {
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 6,
  },
  renewalBadgeText: {
    fontSize: 11,
    fontWeight: '800',
  },
  pausedBadge: {
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 6,
    backgroundColor: 'rgba(150,150,150,0.2)',
  },
  pausedBadgeText: {
    fontSize: 11,
    fontWeight: '700',
    color: '#888',
  },
  subMetaText: {
    fontSize: 12,
    marginTop: 4,
    fontWeight: '500',
  },
  subAmountText: {
    fontSize: 16,
    fontWeight: '900',
    letterSpacing: -0.3,
  },
  subConvertedText: {
    fontSize: 11,
    marginTop: 2,
    fontWeight: '600',
  },
  subCardActionStrip: {
    borderTopWidth: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  actionStripButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 10,
  },
  actionStripButtonText: {
    fontSize: 12,
    fontWeight: '700',
  },
  actionMiniButton: {
    width: 32,
    height: 32,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'flex-end',
  },
  modalSheet: {
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    borderWidth: 1,
    paddingHorizontal: 20,
    paddingTop: 10,
    paddingBottom: 36,
  },
  modalHandle: {
    width: 36,
    height: 4,
    backgroundColor: 'rgba(150,150,150,0.4)',
    borderRadius: 2,
    alignSelf: 'center',
    marginBottom: 14,
  },
  modalHeaderRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: '800',
  },
  inputLabel: {
    fontSize: 13,
    fontWeight: '700',
    marginBottom: 6,
  },
  textInput: {
    borderWidth: 1,
    borderRadius: 14,
    paddingHorizontal: 14,
    paddingVertical: 12,
    fontSize: 15,
  },
  currencyToggleRow: {
    flexDirection: 'row',
    gap: 4,
  },
  currMiniChip: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: 12,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  currMiniText: {
    fontSize: 11,
    fontWeight: '800',
  },
  categoryPillsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  categoryPill: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 12,
    borderWidth: 1,
  },
  categoryPillText: {
    fontSize: 12,
    fontWeight: '700',
  },
  saveModalButton: {
    marginTop: 22,
    paddingVertical: 16,
    borderRadius: 16,
    alignItems: 'center',
  },
  saveModalButtonText: {
    fontSize: 16,
    fontWeight: '900',
  },
  currencyListItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 14,
    paddingVertical: 12,
    borderRadius: 16,
    borderWidth: 1,
    marginBottom: 8,
  },
  currencyBadge: {
    width: 36,
    height: 36,
    borderRadius: 11,
    backgroundColor: 'rgba(150,150,150,0.15)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  currencyBadgeText: {
    fontSize: 16,
    fontWeight: '800',
  },
  currencyCodeText: {
    fontSize: 14,
  },
  currencyRateSub: {
    fontSize: 11,
    marginTop: 2,
    fontWeight: '500',
  },
  customCurrencyCard: {
    borderRadius: 16,
    borderWidth: 1,
    padding: 14,
    marginTop: 10,
    marginBottom: 10,
  },
  customCurrencyTitle: {
    fontSize: 13,
    fontWeight: '700',
    marginBottom: 8,
  },
  customInputRow: {
    flexDirection: 'row',
    gap: 8,
  },
  customTextInput: {
    flex: 1,
    borderWidth: 1,
    borderRadius: 12,
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 14,
    fontWeight: '700',
  },
  customAddButton: {
    paddingHorizontal: 16,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  customAddText: {
    fontSize: 13,
    fontWeight: '800',
  },
});
