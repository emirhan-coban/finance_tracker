import { categories } from '../utils/categoryUtils';

export interface CategoryBudget {
  category: string;
  icon: string;
  colorValue: string;
  limit: number;
}

export function defaults(): CategoryBudget[] {
  return categories.map((c) => ({
    category: c.id,
    icon: c.id,
    colorValue: c.color,
    limit: 0,
  }));
}

export function fromJson(j: any): CategoryBudget {
  return {
    category: j.category,
    icon: j.icon ?? '',
    colorValue: j.colorValue ?? '#10B981',
    limit: Number(j.limit ?? 0),
  };
}
