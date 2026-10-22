export interface CurrencyDefinition {
  code: string;
  name: string;
  symbol: string;
  fallbackRate: number;
}

export const AVAILABLE_CURRENCIES: CurrencyDefinition[] = [
  { code: 'TRY', name: 'Türk Lirası', symbol: '₺', fallbackRate: 1 },
  { code: 'USD', name: 'Amerikan Doları', symbol: '$', fallbackRate: 49.7 },
  { code: 'EUR', name: 'Euro', symbol: '€', fallbackRate: 55.8 },
  { code: 'GBP', name: 'İngiliz Sterlini', symbol: '£', fallbackRate: 66.7 },
  { code: 'CHF', name: 'İsviçre Frangı', symbol: '₣', fallbackRate: 60.5 },
  { code: 'CAD', name: 'Kanada Doları', symbol: 'C$', fallbackRate: 35.5 },
  { code: 'AUD', name: 'Avustralya Doları', symbol: 'A$', fallbackRate: 34.9 },
  { code: 'AED', name: 'BAE Dirhemi', symbol: 'د.إ', fallbackRate: 13.5 },
  { code: 'SAR', name: 'Suudi Arabistan Riyali', symbol: '﷼', fallbackRate: 13.2 },
  { code: 'JPY', name: 'Japon Yeni', symbol: '¥', fallbackRate: 0.32 },
];

export function getCurrencySymbol(currencyCode: string): string {
  const found = AVAILABLE_CURRENCIES.find((c) => c.code === currencyCode);
  return found ? found.symbol : currencyCode;
}

export async function fetchRates(): Promise<Record<string, number>> {
  const defaultRates: Record<string, number> = {
    TRY: 1,
    USD: 49.7,
    EUR: 55.8,
    GBP: 66.7,
    CHF: 60.5,
    CAD: 35.5,
    AUD: 34.9,
    AED: 13.5,
    SAR: 13.2,
    JPY: 0.32,
  };

  try {
    const symbols = 'USD,EUR,GBP,CHF,CAD,AUD,AED,SAR,JPY';
    const url = `https://api.genelpara.com/json/?list=doviz&sembol=${symbols}`;
    const res = await fetch(url);
    const json = await res.json();
    const data = json?.data ?? {};

    const rates: Record<string, number> = { ...defaultRates };
    for (const key of Object.keys(data)) {
      const val = parseFloat(data[key]?.satis ?? '0');
      if (val > 0) {
        if (key === 'JPY') {
          // Genelpara JPY is quoted per 100 units
          rates[key] = val / 100;
        } else {
          rates[key] = val;
        }
      }
    }
    return rates;
  } catch {
    return defaultRates;
  }
}

