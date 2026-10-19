export interface Expense {
  id: string;
  name: string;
  amount: number;
  currency: string;
  date: string;
  category: string;
  icon?: string;
  note?: string;
}

export function toJson(e: Expense) {
  return { ...e };
}

export function fromJson(j: any): Expense {
  return {
    id: j.id,
    name: j.name,
    amount: Number(j.amount),
    currency: j.currency,
    date: j.date,
    category: j.category,
    icon: j.icon ?? undefined,
    note: j.note ?? undefined,
  };
}
