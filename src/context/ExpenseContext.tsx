import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { Expense } from '../models/Expense';
import { CategoryBudget, defaults as budgetDefaults } from '../models/CategoryBudget';
import * as storage from '../services/storageService';
import { fetchRates } from '../services/currencyService';

interface ExpenseContextValue {
  expenses: Expense[];
  budgets: CategoryBudget[];
  usdRate: number;
  eurRate: number;
  rates: Record<string, number>;
  isLoadingRates: boolean;
  addExpense: (e: Expense) => Promise<void>;
  deleteExpense: (id: string) => Promise<void>;
  setBudgetLimit: (category: string, limit: number) => Promise<void>;
  refresh: () => Promise<void>;
  getTotalInTRY: () => number;
  getSpentByCategory: (category: string) => number;
  convertToTRY: (amount: number, currency: string) => number;
}

const ExpenseContext = createContext<ExpenseContextValue | null>(null);

export function ExpenseProvider({ children }: { children: React.ReactNode }) {
  const [expenses, setExpenses] = useState<Expense[]>([]);
  const [budgets, setBudgets] = useState<CategoryBudget[]>(budgetDefaults());
  const [rates, setRates] = useState<Record<string, number>>({
    TRY: 1,
    USD: 49.7,
    EUR: 55.8,
    GBP: 66.7,
    CHF: 60.5,
  });
  const [usdRate, setUsdRate] = useState(49.7);
  const [eurRate, setEurRate] = useState(55.8);
  const [isLoadingRates, setIsLoadingRates] = useState(true);

  const loadExpenses = useCallback(async () => {
    const list = await storage.loadExpenses();
    setExpenses(list);
  }, []);

  const loadBudgets = useCallback(async () => {
    const list = await storage.loadBudgets();
    setBudgets(list);
  }, []);

  const fetchR = useCallback(async () => {
    try {
      const r = await fetchRates();
      setRates(r);
      setUsdRate(r.USD || 49.7);
      setEurRate(r.EUR || 55.8);
    } catch {
      // Fallback rates already set
    }
    setIsLoadingRates(false);
  }, []);

  useEffect(() => {
    loadExpenses();
    loadBudgets();
    fetchR();
  }, [loadExpenses, loadBudgets, fetchR]);

  const refresh = useCallback(async () => {
    await Promise.all([loadExpenses(), loadBudgets(), fetchR()]);
  }, [loadExpenses, loadBudgets, fetchR]);

  const addExpense = useCallback(async (e: Expense) => {
    setExpenses((prev) => {
      const next = [e, ...prev];
      storage.saveExpenses(next);
      return next;
    });
  }, []);

  const deleteExpense = useCallback(async (id: string) => {
    setExpenses((prev) => {
      const next = prev.filter((item) => item.id !== id);
      storage.saveExpenses(next);
      return next;
    });
  }, []);

  const setBudgetLimit = useCallback(async (category: string, limit: number) => {
    setBudgets((prev) => {
      const next = prev.map((b) => (b.category === category ? { ...b, limit } : b));
      storage.saveBudgets(next);
      return next;
    });
  }, []);

  const convertToTRY = useCallback(
    (amount: number, currency: string) => {
      if (currency === 'TRY') return amount;
      const rate =
        rates[currency] ??
        (currency === 'USD' ? usdRate : currency === 'EUR' ? eurRate : 1);
      return amount * rate;
    },
    [rates, usdRate, eurRate]
  );

  const getTotalInTRY = useCallback(() => {
    return expenses.reduce((sum, e) => sum + convertToTRY(e.amount, e.currency), 0);
  }, [expenses, convertToTRY]);

  const getSpentByCategory = useCallback(
    (category: string) => {
      return expenses
        .filter((e) => e.category === category)
        .reduce((sum, e) => sum + convertToTRY(e.amount, e.currency), 0);
    },
    [expenses, convertToTRY]
  );

  return (
    <ExpenseContext.Provider
      value={{
        expenses,
        budgets,
        usdRate,
        eurRate,
        rates,
        isLoadingRates,
        addExpense,
        deleteExpense,
        setBudgetLimit,
        refresh,
        getTotalInTRY,
        getSpentByCategory,
        convertToTRY,
      }}
    >
      {children}
    </ExpenseContext.Provider>
  );
}

export function useExpenses() {
  const ctx = useContext(ExpenseContext);
  if (!ctx) throw new Error('useExpenses must be used within ExpenseProvider');
  return ctx;
}
