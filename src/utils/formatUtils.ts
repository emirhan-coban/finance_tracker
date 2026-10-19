/**
 * Turkish Compact Currency & Number Formatter
 * Corrects React Native Hermes compact notation issues.
 */
export function formatCompactTRY(amount: number): string {
  if (isNaN(amount) || amount === 0) return '0 ₺';

  const abs = Math.abs(amount);
  const sign = amount < 0 ? '-' : '';

  if (abs >= 1_000_000_000) {
    const val = abs / 1_000_000_000;
    return `${sign}${val.toLocaleString('tr-TR', {
      minimumFractionDigits: 0,
      maximumFractionDigits: 1,
    })} Mr ₺`;
  }

  if (abs >= 1_000_000) {
    const val = abs / 1_000_000;
    return `${sign}${val.toLocaleString('tr-TR', {
      minimumFractionDigits: 0,
      maximumFractionDigits: 1,
    })} M ₺`;
  }

  if (abs >= 10_000) {
    const val = abs / 1_000;
    return `${sign}${val.toLocaleString('tr-TR', {
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    })} B ₺`;
  }

  if (abs >= 1_000) {
    const val = abs / 1_000;
    return `${sign}${val.toLocaleString('tr-TR', {
      minimumFractionDigits: 0,
      maximumFractionDigits: 1,
    })} B ₺`;
  }

  return `${sign}${abs.toLocaleString('tr-TR', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  })} ₺`;
}
