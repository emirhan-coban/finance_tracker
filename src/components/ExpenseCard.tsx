import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { getMeta } from '../utils/categoryUtils';
import { Expense } from '../models/Expense';
import BouncingButton from './BouncingButton';

interface ExpenseCardProps {
  expense: Expense;
  usdRate: number;
  eurRate: number;
  onPress?: () => void;
  onDelete?: () => void;
}

export default function ExpenseCard({
  expense,
  usdRate,
  eurRate,
  onPress,
  onDelete,
}: ExpenseCardProps) {
  const { theme } = useTheme();
  const meta = getMeta(expense.category);

  // Currency symbols and formatting
  let currencySymbol = '₺';
  let formattedOriginal = `${expense.amount.toLocaleString('tr-TR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })} ₺`;

  if (expense.currency === 'USD') {
    currencySymbol = '$';
    formattedOriginal = `-$${expense.amount.toLocaleString('tr-TR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    })}`;
  } else if (expense.currency === 'EUR') {
    currencySymbol = '€';
    formattedOriginal = `-€${expense.amount.toLocaleString('tr-TR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    })}`;
  } else {
    formattedOriginal = `-${expense.amount.toLocaleString('tr-TR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    })} ₺`;
  }

  // TRY equivalent
  let tryAmount = expense.amount;
  if (expense.currency === 'USD') tryAmount = expense.amount * usdRate;
  if (expense.currency === 'EUR') tryAmount = expense.amount * eurRate;
  const formattedTRY = `≈ ${tryAmount.toLocaleString('tr-TR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })} ₺`;

  // Date formatting
  const dateObj = new Date(expense.date);
  const now = new Date();
  const isToday =
    dateObj.getDate() === now.getDate() &&
    dateObj.getMonth() === now.getMonth() &&
    dateObj.getFullYear() === now.getFullYear();

  const timeStr = dateObj.toLocaleTimeString('tr-TR', {
    hour: '2-digit',
    minute: '2-digit',
  });
  const dateStr = isToday
    ? `Bugün, ${timeStr}`
    : dateObj.toLocaleDateString('tr-TR', {
        day: 'numeric',
        month: 'short',
        hour: '2-digit',
        minute: '2-digit',
      });

  return (
    <BouncingButton onPress={onPress}>
      <View
        style={[
          styles.card,
          {
            backgroundColor: theme.surface,
            borderColor: theme.border,
          },
        ]}
      >
        <View
          style={[
            styles.iconContainer,
            { backgroundColor: meta.color + '1F' },
          ]}
        >
          <Ionicons
            name={meta.icon as any}
            size={20}
            color={meta.color}
          />
        </View>

        <View style={styles.content}>
          <Text
            style={[styles.name, { color: theme.text }]}
            numberOfLines={1}
          >
            {expense.name}
          </Text>
          <View style={styles.metaRow}>
            <Text
              style={[styles.categoryText, { color: theme.textMuted }]}
              numberOfLines={1}
            >
              {meta.displayName}
            </Text>
            <Text style={[styles.bullet, { color: theme.textMuted }]}>
              •
            </Text>
            <Text
              style={[styles.dateText, { color: theme.textMuted }]}
              numberOfLines={1}
            >
              {dateStr}
            </Text>
          </View>
        </View>

        <View style={styles.amountContainer}>
          <Text
            style={[styles.amountText, { color: theme.text }]}
            numberOfLines={1}
            adjustsFontSizeToFit
            minimumFontScale={0.7}
          >
            {formattedOriginal}
          </Text>
          {expense.currency !== 'TRY' && (
            <Text
              style={[styles.equivalentText, { color: theme.textMuted }]}
              numberOfLines={1}
              adjustsFontSizeToFit
              minimumFontScale={0.7}
            >
              {formattedTRY}
            </Text>
          )}
        </View>

        {onDelete && (
          <BouncingButton onPress={onDelete} style={styles.deleteButton}>
            <Ionicons name="trash-outline" size={18} color="#DC2626" />
          </BouncingButton>
        )}
      </View>
    </BouncingButton>
  );
}

const styles = StyleSheet.create({
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 14,
    borderRadius: 20,
    borderWidth: 1,
    marginBottom: 10,
  },
  iconContainer: {
    width: 44,
    height: 44,
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  content: {
    flex: 1,
    minWidth: 0,
    marginRight: 8,
  },
  name: {
    fontSize: 16,
    fontWeight: '700',
    letterSpacing: -0.3,
  },
  metaRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 3,
    minWidth: 0,
  },
  categoryText: {
    fontSize: 12,
    fontWeight: '500',
    flexShrink: 1,
  },
  bullet: {
    marginHorizontal: 4,
    fontSize: 12,
    opacity: 0.5,
  },
  dateText: {
    fontSize: 12,
    fontWeight: '400',
    flexShrink: 0,
  },
  amountContainer: {
    alignItems: 'flex-end',
    flexShrink: 0,
    maxWidth: '45%',
  },
  amountText: {
    fontSize: 16,
    fontWeight: '800',
    letterSpacing: -0.3,
    textAlign: 'right',
  },
  equivalentText: {
    fontSize: 11,
    fontWeight: '600',
    marginTop: 2,
    opacity: 0.7,
    textAlign: 'right',
  },
  deleteButton: {
    padding: 8,
    marginLeft: 6,
  },
});
