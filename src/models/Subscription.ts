export type BillingCycle = 'monthly' | 'yearly' | 'weekly';

export interface Subscription {
  id: string;
  name: string;
  amount: number;
  currency: string;
  billingCycle: BillingCycle;
  renewalDay: number; // 1-31 (Day of month for renewal)
  category: string;
  color: string;
  icon: string; // Ionicons glyph name
  isActive: boolean;
  note?: string;
  createdAt: string;
}

export interface SubscriptionTemplate {
  name: string;
  defaultAmount: number;
  currency: string;
  category: string;
  color: string;
  icon: string;
  billingCycle: BillingCycle;
}

export const POPULAR_SUBSCRIPTION_TEMPLATES: SubscriptionTemplate[] = [
  {
    name: 'Netflix',
    defaultAmount: 299,
    currency: 'TRY',
    category: 'Eğlence',
    color: '#E50914',
    icon: 'film-outline',
    billingCycle: 'monthly',
  },
  {
    name: 'Spotify',
    defaultAmount: 99,
    currency: 'TRY',
    category: 'Müzik',
    color: '#1DB954',
    icon: 'musical-notes-outline',
    billingCycle: 'monthly',
  },
  {
    name: 'iCloud+',
    defaultAmount: 39.99,
    currency: 'TRY',
    category: 'Bulut & Depolama',
    color: '#007AFF',
    icon: 'cloud-outline',
    billingCycle: 'monthly',
  },
  {
    name: 'YouTube Premium',
    defaultAmount: 115,
    currency: 'TRY',
    category: 'Eğlence',
    color: '#FF0000',
    icon: 'play-circle-outline',
    billingCycle: 'monthly',
  },
  {
    name: 'ChatGPT Plus',
    defaultAmount: 20,
    currency: 'USD',
    category: 'Yapay Zeka & Araçlar',
    color: '#10A37F',
    icon: 'sparkles-outline',
    billingCycle: 'monthly',
  },
  {
    name: 'Amazon Prime',
    defaultAmount: 59,
    currency: 'TRY',
    category: 'Alışveriş & Kargo',
    color: '#00A8E1',
    icon: 'cart-outline',
    billingCycle: 'monthly',
  },
  {
    name: 'Disney+',
    defaultAmount: 190,
    currency: 'TRY',
    category: 'Eğlence',
    color: '#113CCF',
    icon: 'tv-outline',
    billingCycle: 'monthly',
  },
  {
    name: 'Spor Salonu (Gym)',
    defaultAmount: 1200,
    currency: 'TRY',
    category: 'Sağlık & Spor',
    color: '#F59E0B',
    icon: 'barbell-outline',
    billingCycle: 'monthly',
  },
  {
    name: 'Duolingo Super',
    defaultAmount: 85,
    currency: 'TRY',
    category: 'Eğitim',
    color: '#58CC02',
    icon: 'school-outline',
    billingCycle: 'monthly',
  },
];

export function fromJson(j: any): Subscription {
  return {
    id: String(j.id || Date.now().toString()),
    name: String(j.name || ''),
    amount: Number(j.amount || 0),
    currency: String(j.currency || 'TRY'),
    billingCycle: (j.billingCycle || 'monthly') as BillingCycle,
    renewalDay: Math.max(1, Math.min(31, Number(j.renewalDay || 1))),
    category: String(j.category || 'Genel'),
    color: String(j.color || '#9FE870'),
    icon: String(j.icon || 'card-outline'),
    isActive: j.isActive !== undefined ? Boolean(j.isActive) : true,
    note: j.note ? String(j.note) : undefined,
    createdAt: j.createdAt || new Date().toISOString(),
  };
}

/**
 * Calculates days remaining until the next renewal day.
 */
export function getDaysUntilRenewal(renewalDay: number): number {
  const now = new Date();
  const currentYear = now.getFullYear();
  const currentMonth = now.getMonth();
  const currentDay = now.getDate();

  // Find target date for current month
  // Account for shorter months (e.g. Feb 28/29, April 30)
  const daysInCurrentMonth = new Date(currentYear, currentMonth + 1, 0).getDate();
  const clampedDayThisMonth = Math.min(renewalDay, daysInCurrentMonth);
  const targetThisMonth = new Date(currentYear, currentMonth, clampedDayThisMonth);

  // If today is before or on renewal day
  if (clampedDayThisMonth >= currentDay) {
    const diffTime = targetThisMonth.getTime() - new Date(currentYear, currentMonth, currentDay).getTime();
    return Math.round(diffTime / (1000 * 60 * 60 * 24));
  }

  // Renewal day already passed this month -> look at next month
  const nextMonth = currentMonth + 1;
  const daysInNextMonth = new Date(currentYear, nextMonth + 1, 0).getDate();
  const clampedDayNextMonth = Math.min(renewalDay, daysInNextMonth);
  const targetNextMonth = new Date(currentYear, nextMonth, clampedDayNextMonth);

  const diffTime = targetNextMonth.getTime() - new Date(currentYear, currentMonth, currentDay).getTime();
  return Math.max(0, Math.round(diffTime / (1000 * 60 * 60 * 24)));
}

/**
 * Human readable badge text for upcoming renewal.
 */
export function formatRenewalBadge(days: number): { text: string; urgent: boolean } {
  if (days === 0) return { text: 'Bugün yenileniyor!', urgent: true };
  if (days === 1) return { text: 'Yarın yenileniyor', urgent: true };
  if (days <= 3) return { text: `${days} gün kaldı`, urgent: true };
  return { text: `${days} gün sonra`, urgent: false };
}
