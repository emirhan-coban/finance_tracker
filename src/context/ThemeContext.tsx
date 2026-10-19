import React, { createContext, useContext, useState, useEffect, useMemo } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { colors } from '../theme/colors';

export type ThemeMode = 'light' | 'dark';

const THEME_KEY = 'user_theme_mode';

interface ThemeContextValue {
  mode: ThemeMode;
  isDark: boolean;
  toggle: () => void;
  colors: typeof colors;
  theme: {
    bg: string;
    surface: string;
    surfaceSecondary: string;
    field: string;
    border: string;
    text: string;
    textMuted: string;
    hero: string;
    accent: string;
    accentText: string;
  };
}

const ThemeContext = createContext<ThemeContextValue | null>(null);

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [mode, setMode] = useState<ThemeMode>('light');

  useEffect(() => {
    AsyncStorage.getItem(THEME_KEY).then((stored) => {
      if (stored === 'light' || stored === 'dark') {
        setMode(stored);
      }
    });
  }, []);

  const isDark = mode === 'dark';

  const toggle = () => {
    setMode((prev) => {
      const next = prev === 'dark' ? 'light' : 'dark';
      AsyncStorage.setItem(THEME_KEY, next);
      return next;
    });
  };

  const theme = useMemo(
    () => ({
      bg: isDark ? colors.backgroundDark : colors.backgroundLight,
      surface: isDark ? colors.surfaceDark : colors.surfaceLight,
      surfaceSecondary: isDark ? colors.surfaceElevatedDark : colors.surfaceSecondaryLight,
      field: isDark ? colors.fieldDark : colors.fieldLight,
      border: isDark ? colors.borderDark : colors.borderLight,
      text: isDark ? colors.textWhite : colors.textForest,
      textMuted: isDark ? colors.textSecondary : colors.textForestMuted,
      hero: isDark ? colors.heroDark : colors.wiseForest,
      accent: isDark ? colors.wiseLime : colors.wiseForest,
      accentText: isDark ? colors.wiseForest : colors.wiseLime,
    }),
    [isDark]
  );

  return (
    <ThemeContext.Provider value={{ mode, isDark, toggle, colors, theme }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error('useTheme must be used within ThemeProvider');
  return ctx;
}
