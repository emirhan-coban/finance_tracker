import AsyncStorage from '@react-native-async-storage/async-storage';
import { Expense, fromJson as expenseFromJson } from '../models/Expense';
import { CategoryBudget, fromJson as budgetFromJson, defaults } from '../models/CategoryBudget';
import { Subscription, fromJson as subscriptionFromJson } from '../models/Subscription';

const EXPENSES_KEY = 'expenses';
const BUDGETS_KEY = 'category_budgets';
const SUBSCRIPTIONS_KEY = 'subscriptions';

export async function saveExpenses(expenses: Expense[]) {
  await AsyncStorage.setItem(EXPENSES_KEY, JSON.stringify(expenses));
}

export async function loadExpenses(): Promise<Expense[]> {
  const s = await AsyncStorage.getItem(EXPENSES_KEY);
  if (!s) return [];
  const arr = JSON.parse(s);
  return arr.map(expenseFromJson);
}

export async function saveBudgets(budgets: CategoryBudget[]) {
  await AsyncStorage.setItem(BUDGETS_KEY, JSON.stringify(budgets));
}

export async function loadBudgets(): Promise<CategoryBudget[]> {
  const s = await AsyncStorage.getItem(BUDGETS_KEY);
  if (!s) return defaults();
  const arr = JSON.parse(s);
  return arr.map(budgetFromJson);
}

export async function saveSubscriptions(subscriptions: Subscription[]) {
  await AsyncStorage.setItem(SUBSCRIPTIONS_KEY, JSON.stringify(subscriptions));
}

export async function loadSubscriptions(): Promise<Subscription[]> {
  const s = await AsyncStorage.getItem(SUBSCRIPTIONS_KEY);
  if (!s) return [];
  const arr = JSON.parse(s);
  return arr.map(subscriptionFromJson);
}
