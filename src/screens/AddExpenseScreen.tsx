import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  ScrollView,
  Platform,
  Alert,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import DateTimePicker, {
  DateTimePickerEvent,
} from '@react-native-community/datetimepicker';
import * as Haptics from 'expo-haptics';
import { useTheme } from '../context/ThemeContext';
import { useExpenses } from '../context/ExpenseContext';
import { categories, getDisplayName } from '../utils/categoryUtils';
import BouncingButton from '../components/BouncingButton';
import ResponsiveContainer from '../components/ResponsiveContainer';

export default function AddExpenseScreen() {
  const insets = useSafeAreaInsets();
  const { isDark, theme, colors } = useTheme();
  const exp = useExpenses();
  const nav = useNavigation<any>();

  const [name, setName] = useState('');
  const [amount, setAmount] = useState('');
  const [currency, setCurrency] = useState('TRY');
  const [selectedCategory, setSelectedCategory] = useState(categories[0].id);
  const [note, setNote] = useState('');
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [showDatePicker, setShowDatePicker] = useState(false);
  const [showExtraDetails, setShowExtraDetails] = useState(false);

  // Quick preset amount pills (+50, +100, +250, +500)
  const addQuickAmount = (val: number) => {
    const current = parseFloat(amount.replace(',', '.')) || 0;
    const next = current + val;
    setAmount(next % 1 === 0 ? next.toString() : next.toFixed(2));
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light).catch(() => {});
  };

  // Auto-populate title when category changes if user hasn't typed a custom title
  const onCategorySelected = (catId: string, displayName: string) => {
    setSelectedCategory(catId);
    const isDefaultOrEmpty =
      !name.trim() ||
      categories.some((c) => c.displayName.toLowerCase() === name.trim().toLowerCase());
    if (isDefaultOrEmpty) {
      setName(displayName);
    }
    Haptics.selectionAsync().catch(() => {});
  };

  const onDateChange = (event: DateTimePickerEvent, date?: Date) => {
    if (Platform.OS === 'android') {
      setShowDatePicker(false);
    }
    if (date) {
      setSelectedDate(date);
    }
  };

  const saveExpense = async () => {
    const parsedAmount = parseFloat(amount.replace(',', '.'));
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      Alert.alert('Geçersiz Tutar', 'Lütfen geçerli bir harcama tutarı giriniz.');
      return;
    }

    const title = name.trim() || getDisplayName(selectedCategory);

    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy).catch(() => {});

    await exp.addExpense({
      id: Date.now().toString(),
      name: title,
      amount: parsedAmount,
      currency,
      date: selectedDate.toISOString(),
      category: selectedCategory,
      note: note.trim() || undefined,
    });

    nav.goBack();
  };

  const getCurrencySymbol = (curr: string) => {
    if (curr === 'USD') return '$';
    if (curr === 'EUR') return '€';
    return '₺';
  };

  const formattedDateStr = selectedDate.toLocaleDateString('tr-TR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });

  // Dynamic font scaling when amount digits increase
  const amountLen = (amount || '0').length;
  let amountFontSize = 48;
  let currencyFontSize = 42;
  if (amountLen >= 12) {
    amountFontSize = 22;
    currencyFontSize = 20;
  } else if (amountLen >= 10) {
    amountFontSize = 26;
    currencyFontSize = 24;
  } else if (amountLen >= 8) {
    amountFontSize = 32;
    currencyFontSize = 28;
  } else if (amountLen >= 6) {
    amountFontSize = 38;
    currencyFontSize = 34;
  }

  return (
    <View style={[styles.root, { backgroundColor: theme.bg }]}>
      <ResponsiveContainer maxWidth={580}>
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
            <Ionicons name="close" size={22} color={theme.text} />
          </BouncingButton>

          <Text style={[styles.topBarTitle, { color: theme.text }]}>
            Harcama Ekle
          </Text>

          <View style={{ width: 38 }} />
        </View>

        {/* Scrollable Form Content */}
        <ScrollView
          contentContainerStyle={[
            styles.formScroll,
            { paddingBottom: insets.bottom + 90 },
          ]}
          showsVerticalScrollIndicator={false}
          keyboardShouldPersistTaps="handled"
        >
          {/* Large Hero Amount Input */}
          <View style={styles.amountSection}>
            <View style={styles.amountInputRow}>
              <Text
                style={[
                  styles.currencySymbol,
                  {
                    color: isDark ? colors.wiseLime : colors.wiseForest,
                    fontSize: currencyFontSize,
                  },
                ]}
              >
                {getCurrencySymbol(currency)}
              </Text>
              <TextInput
                value={amount}
                onChangeText={setAmount}
                placeholder="0"
                placeholderTextColor={theme.textMuted + '66'}
                keyboardType="decimal-pad"
                autoFocus
                numberOfLines={1}
                style={[
                  styles.amountInput,
                  {
                    color: isDark ? colors.textWhite : colors.wiseForest,
                    fontSize: amountFontSize,
                  },
                ]}
              />
            </View>

            {/* Quick Presets */}
            <View style={styles.quickPresetsRow}>
              {[50, 100, 250, 500].map((preset) => (
                <BouncingButton
                  key={preset}
                  onPress={() => addQuickAmount(preset)}
                  style={[
                    styles.presetChip,
                    {
                      backgroundColor: theme.field,
                      borderColor: theme.border,
                    },
                  ]}
                >
                  <Text style={[styles.presetText, { color: theme.text }]}>
                    +{preset} ₺
                  </Text>
                </BouncingButton>
              ))}
            </View>
          </View>

          {/* Currency Selector */}
          <View style={styles.currencyRow}>
            {['TRY', 'USD', 'EUR'].map((curr) => {
              const active = currency === curr;
              return (
                <BouncingButton
                  key={curr}
                  onPress={() => setCurrency(curr)}
                  style={[
                    styles.currencyChip,
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
                  <Text
                    style={[
                      styles.currencyText,
                      {
                        color: active
                          ? isDark
                            ? colors.wiseForest
                            : colors.wiseLime
                          : theme.text,
                      },
                    ]}
                  >
                    {curr}
                  </Text>
                </BouncingButton>
              );
            })}
          </View>

          {/* Category Selector Grid */}
          <View style={styles.fieldSection}>
            <Text style={[styles.fieldLabel, { color: theme.text }]}>
              Kategori
            </Text>
            <View style={styles.categoryGrid}>
              {categories.map((cat) => {
                const isSelected = selectedCategory === cat.id;
                return (
                  <BouncingButton
                    key={cat.id}
                    onPress={() => onCategorySelected(cat.id, cat.displayName)}
                    style={[
                      styles.categoryCard,
                      {
                        backgroundColor: isSelected
                          ? isDark
                            ? 'rgba(159, 232, 112, 0.16)'
                            : 'rgba(22, 51, 0, 0.08)'
                          : theme.surface,
                        borderColor: isSelected
                          ? isDark
                            ? colors.wiseLime
                            : colors.wiseForest
                          : theme.border,
                      },
                    ]}
                  >
                    <View
                      style={[
                        styles.categoryIconBox,
                        { backgroundColor: cat.color + '22' },
                      ]}
                    >
                      <Ionicons
                        name={cat.icon as any}
                        size={18}
                        color={cat.color}
                      />
                    </View>
                    <Text
                      style={[
                        styles.categoryCardText,
                        {
                          color: isSelected
                            ? theme.text
                            : theme.textMuted,
                          fontWeight: isSelected ? '800' : '600',
                        },
                      ]}
                      numberOfLines={1}
                    >
                      {cat.displayName}
                    </Text>
                    {isSelected && (
                      <Ionicons
                        name="checkmark-circle"
                        size={16}
                        color={isDark ? colors.wiseLime : colors.wiseForest}
                        style={{ marginLeft: 'auto' }}
                      />
                    )}
                  </BouncingButton>
                );
              })}
            </View>
          </View>

          {/* Name / Title Input */}
          <View style={styles.fieldSection}>
            <Text style={[styles.fieldLabel, { color: theme.text }]}>
              Harcama Adı
            </Text>
            <TextInput
              value={name}
              onChangeText={setName}
              placeholder="Örn: Kahve, Market, Taksi..."
              placeholderTextColor={theme.textMuted + '88'}
              style={[
                styles.textInput,
                {
                  backgroundColor: theme.surface,
                  borderColor: theme.border,
                  color: theme.text,
                },
              ]}
            />
          </View>

          {/* Collapsible Details (Date & Note) */}
          <View
            style={[
              styles.accordionCard,
              {
                backgroundColor: theme.surface,
                borderColor: theme.border,
              },
            ]}
          >
            <BouncingButton
              onPress={() => setShowExtraDetails(!showExtraDetails)}
              style={styles.accordionHeader}
            >
              <View style={styles.accordionTitleRow}>
                <Ionicons
                  name="options-outline"
                  size={18}
                  color={isDark ? colors.wiseLime : colors.wiseForest}
                />
                <Text style={[styles.accordionTitle, { color: theme.text }]}>
                  Tarih & Not Seçenekleri
                </Text>
              </View>

              <View style={styles.accordionRightRow}>
                <Text
                  style={[
                    styles.accordionRightText,
                    { color: theme.textMuted },
                  ]}
                >
                  {showExtraDetails ? 'Gizle' : formattedDateStr}
                </Text>
                <Ionicons
                  name={showExtraDetails ? 'chevron-up' : 'chevron-down'}
                  size={18}
                  color={theme.textMuted}
                />
              </View>
            </BouncingButton>

            {showExtraDetails && (
              <View
                style={[
                  styles.accordionContent,
                  { borderTopColor: theme.border },
                ]}
              >
                {/* Date Picker Row */}
                <View style={styles.dateRow}>
                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                    <Ionicons
                      name="calendar-outline"
                      size={18}
                      color={theme.textMuted}
                    />
                    <Text style={[styles.dateLabel, { color: theme.text }]}>
                      {formattedDateStr}
                    </Text>
                  </View>

                  <BouncingButton
                    onPress={() => setShowDatePicker(true)}
                    style={[
                      styles.changeDateChip,
                      {
                        backgroundColor: theme.field,
                        borderColor: theme.border,
                      },
                    ]}
                  >
                    <Text
                      style={[
                        styles.changeDateText,
                        {
                          color: isDark
                            ? colors.wiseLime
                            : colors.wiseForest,
                        },
                      ]}
                    >
                      Değiştir
                    </Text>
                  </BouncingButton>
                </View>

                {showDatePicker && (
                  <DateTimePicker
                    value={selectedDate}
                    mode="date"
                    display={Platform.OS === 'ios' ? 'inline' : 'default'}
                    onChange={onDateChange}
                    maximumDate={new Date(2030, 11, 31)}
                    minimumDate={new Date(2020, 0, 1)}
                  />
                )}

                {/* Note Field */}
                <Text
                  style={[
                    styles.fieldLabel,
                    { color: theme.text, marginTop: 14 },
                  ]}
                >
                  Açıklama Notu
                </Text>
                <TextInput
                  value={note}
                  onChangeText={setNote}
                  placeholder="Opsiyonel harcama notu..."
                  placeholderTextColor={theme.textMuted + '88'}
                  multiline
                  numberOfLines={2}
                  style={[
                    styles.textInput,
                    {
                      backgroundColor: theme.field,
                      borderColor: theme.border,
                      color: theme.text,
                      height: 70,
                      textAlignVertical: 'top',
                    },
                  ]}
                />
              </View>
            )}
          </View>
        </ScrollView>

        {/* Pinned Bottom Button */}
        <View
          style={[
            styles.bottomBar,
            {
              backgroundColor: theme.bg,
              borderTopColor: theme.border,
              paddingBottom: insets.bottom + 12,
            },
          ]}
        >
          <BouncingButton
            onPress={saveExpense}
            style={[
              styles.saveButton,
              {
                backgroundColor: isDark
                  ? colors.wiseLime
                  : colors.wiseForest,
              },
            ]}
          >
            <Text
              style={[
                styles.saveButtonText,
                {
                  color: isDark
                    ? colors.wiseForest
                    : colors.wiseLime,
                },
              ]}
            >
              Harcamayı Kaydet
            </Text>
          </BouncingButton>
        </View>
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
    fontSize: 17,
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
  formScroll: {
    paddingHorizontal: 20,
    paddingTop: 8,
  },
  amountSection: {
    alignItems: 'center',
    marginVertical: 12,
  },
  amountInputRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  currencySymbol: {
    fontSize: 44,
    fontWeight: '900',
    marginRight: 8,
  },
  amountInput: {
    fontSize: 48,
    fontWeight: '900',
    letterSpacing: -1,
    padding: 0,
    margin: 0,
  },
  quickPresetsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    gap: 8,
    marginTop: 14,
  },
  presetChip: {
    paddingHorizontal: 14,
    paddingVertical: 7,
    borderRadius: 12,
    borderWidth: 1,
  },
  presetText: {
    fontSize: 12,
    fontWeight: '700',
  },
  currencyRow: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 10,
    marginVertical: 14,
  },
  currencyChip: {
    paddingHorizontal: 18,
    paddingVertical: 8,
    borderRadius: 14,
    borderWidth: 1,
  },
  currencyText: {
    fontSize: 13,
    fontWeight: '800',
  },
  fieldSection: {
    marginTop: 16,
  },
  fieldLabel: {
    fontSize: 14,
    fontWeight: '700',
    marginBottom: 10,
  },
  categoryGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    gap: 10,
  },
  categoryCard: {
    width: '48%',
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 12,
    borderRadius: 16,
    borderWidth: 1,
    minHeight: 54,
  },
  categoryIconBox: {
    width: 34,
    height: 34,
    borderRadius: 11,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 10,
  },
  categoryCardText: {
    fontSize: 13,
    flex: 1,
  },
  textInput: {
    borderWidth: 1,
    borderRadius: 16,
    paddingHorizontal: 16,
    paddingVertical: 14,
    fontSize: 15,
    fontWeight: '500',
  },
  accordionCard: {
    borderRadius: 18,
    borderWidth: 1,
    marginTop: 18,
    overflow: 'hidden',
  },
  accordionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 14,
  },
  accordionTitleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  accordionTitle: {
    fontSize: 14,
    fontWeight: '700',
  },
  accordionRightRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  accordionRightText: {
    fontSize: 12,
    fontWeight: '600',
  },
  accordionContent: {
    borderTopWidth: 1,
    padding: 16,
  },
  dateRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  dateLabel: {
    fontSize: 14,
    fontWeight: '600',
  },
  changeDateChip: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 10,
    borderWidth: 1,
  },
  changeDateText: {
    fontSize: 13,
    fontWeight: '700',
  },
  bottomBar: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    paddingHorizontal: 20,
    paddingTop: 12,
    borderTopWidth: 1,
  },
  saveButton: {
    width: '100%',
    paddingVertical: 17,
    borderRadius: 18,
    alignItems: 'center',
  },
  saveButtonText: {
    fontSize: 17,
    fontWeight: '900',
    letterSpacing: -0.2,
  },
});
