import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { getMeta } from '../utils/categoryUtils';
import { formatCompactTRY } from '../utils/formatUtils';
import BouncingButton from './BouncingButton';

interface CategoryBudgetCardProps {
  category: string;
  spent: number;
  limit: number;
  onTap?: () => void;
}

export default function CategoryBudgetCompactCard({
  category,
  spent,
  limit,
  onTap,
}: CategoryBudgetCardProps) {
  const { theme } = useTheme();
  const meta = getMeta(category);
  const hasLimit = limit > 0;
  const progress = hasLimit ? Math.min(spent / limit, 1) : 0;
  const isOverBudget = hasLimit && spent > limit;

  return (
    <BouncingButton onPress={onTap}>
      <View
        style={[
          styles.card,
          {
            backgroundColor: theme.surface,
            borderColor: isOverBudget
              ? 'rgba(220, 38, 38, 0.4)'
              : theme.border,
          },
        ]}
      >
        <View style={styles.topRow}>
          <View
            style={[
              styles.iconContainer,
              { backgroundColor: meta.color + '1F' },
            ]}
          >
            <Ionicons name={meta.icon as any} size={16} color={meta.color} />
          </View>
          {hasLimit && (
            <Text
              style={[
                styles.percentText,
                { color: isOverBudget ? '#DC2626' : meta.color },
              ]}
            >
              %{Math.round((spent / limit) * 100)}
            </Text>
          )}
        </View>

        <View style={styles.middleSection}>
          <Text
            style={[styles.categoryName, { color: theme.text }]}
            numberOfLines={1}
            adjustsFontSizeToFit
            minimumFontScale={0.82}
          >
            {meta.displayName}
          </Text>
          <Text
            style={[styles.spentText, { color: theme.textMuted }]}
            numberOfLines={1}
            adjustsFontSizeToFit
            minimumFontScale={0.8}
          >
            {hasLimit
              ? `${formatCompactTRY(spent)} / ${formatCompactTRY(limit)}`
              : formatCompactTRY(spent)}
          </Text>
        </View>

        <View style={[styles.barBackground, { backgroundColor: theme.field }]}>
          <View
            style={[
              styles.barFill,
              {
                width: hasLimit ? `${Math.min(progress * 100, 100)}%` : '0%',
                backgroundColor: isOverBudget ? '#DC2626' : meta.color,
              },
            ]}
          />
        </View>
      </View>
    </BouncingButton>
  );
}

const styles = StyleSheet.create({
  card: {
    width: 146,
    height: 128,
    paddingHorizontal: 12,
    paddingVertical: 12,
    borderRadius: 18,
    borderWidth: 1,
    marginRight: 10,
    justifyContent: 'space-between',
  },
  topRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  iconContainer: {
    width: 32,
    height: 32,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  percentText: {
    fontSize: 11,
    fontWeight: '800',
  },
  middleSection: {
    marginVertical: 4,
  },
  categoryName: {
    fontSize: 13,
    fontWeight: '700',
    letterSpacing: -0.2,
  },
  spentText: {
    fontSize: 11,
    fontWeight: '600',
    marginTop: 2,
  },
  barBackground: {
    height: 4,
    borderRadius: 4,
    overflow: 'hidden',
  },
  barFill: {
    height: 4,
    borderRadius: 4,
  },
});
