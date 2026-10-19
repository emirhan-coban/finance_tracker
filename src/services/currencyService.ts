export async function fetchRates(): Promise<{ USD: number; EUR: number }> {
  try {
    const url = 'https://api.genelpara.com/json/?list=doviz&sembol=USD,EUR';
    const res = await fetch(url);
    const json = await res.json();
    const data = json?.data ?? {};
    const usd = parseFloat(data?.USD?.satis ?? '0') || 0;
    const eur = parseFloat(data?.EUR?.satis ?? '0') || 0;
    return { USD: usd || 43.6, EUR: eur || 46.5 };
  } catch {
    return { USD: 43.6, EUR: 46.5 };
  }
}
