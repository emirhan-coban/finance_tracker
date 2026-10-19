import { colors } from '../theme/colors';

export interface CategoryMeta {
  id: string;
  displayName: string;
  icon: string; // Ionicons glyph name
  color: string;
}

export const categories: CategoryMeta[] = [
  {
    id: 'Food & Drinks',
    displayName: 'Yiyecek & İçecek',
    icon: 'restaurant-outline',
    color: '#F59E0B', // Amber
  },
  {
    id: 'Transportation',
    displayName: 'Ulaşım',
    icon: 'subway-outline',
    color: '#38BDF8', // Sky Blue
  },
  {
    id: 'Shopping',
    displayName: 'Alışveriş',
    icon: 'bag-handle-outline',
    color: '#FB7185', // Soft Rose
  },
  {
    id: 'Sightseeing',
    displayName: 'Gezi & Kültür',
    icon: 'ticket-outline',
    color: '#A78BFA', // Lavender
  },
  {
    id: 'Accommodation',
    displayName: 'Konaklama',
    icon: 'bed-outline',
    color: '#34D399', // Mint Green
  },
];

export function getMeta(categoryOrId?: string | null): CategoryMeta {
  if (!categoryOrId) {
    return {
      id: 'Other',
      displayName: 'Diğer',
      icon: 'wallet-outline',
      color: '#10B981',
    };
  }

  const query = categoryOrId.toLowerCase();
  const found = categories.find(
    (c) => c.id.toLowerCase() === query || c.displayName.toLowerCase() === query
  );

  return (
    found ?? {
      id: 'Other',
      displayName: 'Diğer',
      icon: 'wallet-outline',
      color: '#10B981',
    }
  );
}

export function getColor(category?: string | null): string {
  return getMeta(category).color;
}

export function getDisplayName(category?: string | null): string {
  return getMeta(category).displayName;
}
