import * as ImagePicker from 'expo-image-picker';

export interface ReceiptScanResult {
  success: boolean;
  amount?: number;
  date?: Date;
  merchant?: string;
  category?: string;
  rawText?: string;
  errorMessage?: string;
}

/**
 * Prompt user to select image from camera or photo library.
 */
export async function pickReceiptImage(
  source: 'camera' | 'gallery'
): Promise<ImagePicker.ImagePickerAsset | null> {
  if (source === 'camera') {
    const perm = await ImagePicker.requestCameraPermissionsAsync();
    if (!perm.granted) {
      throw new Error('Kamera izni verilmedi. Lütfen ayarlardan izin verin.');
    }
    const result = await ImagePicker.launchCameraAsync({
      mediaTypes: ['images'],
      allowsEditing: false,
      quality: 0.8,
      base64: true,
    });
    if (!result.canceled && result.assets && result.assets.length > 0) {
      return result.assets[0];
    }
  } else {
    const perm = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!perm.granted) {
      throw new Error('Galeri izni verilmedi. Lütfen ayarlardan izin verin.');
    }
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ['images'],
      allowsEditing: false,
      quality: 0.8,
      base64: true,
    });
    if (!result.canceled && result.assets && result.assets.length > 0) {
      return result.assets[0];
    }
  }
  return null;
}

/**
 * Scan receipt image via online OCR engine and extract relevant fields.
 */
export async function analyzeReceiptImage(
  asset: ImagePicker.ImagePickerAsset
): Promise<ReceiptScanResult> {
  try {
    let recognizedText = '';

    if (asset.base64) {
      const formData = new FormData();
      formData.append(
        'base64Image',
        `data:image/jpeg;base64,${asset.base64}`
      );
      formData.append('language', 'tur');
      formData.append('isOverlayRequired', 'false');
      formData.append('filetype', 'JPG');

      const response = await fetch('https://api.ocr.space/parse/image', {
        method: 'POST',
        headers: {
          apikey: 'K87899142388957', // Public OCR space key
        },
        body: formData,
      });

      const json = await response.json();
      if (
        json &&
        json.ParsedResults &&
        json.ParsedResults.length > 0 &&
        json.ParsedResults[0].ParsedText
      ) {
        recognizedText = json.ParsedResults[0].ParsedText;
      }
    }

    if (!recognizedText.trim()) {
      return {
        success: false,
        errorMessage: 'Fiş üzerindeki metin net olarak okunamadı. Lütfen bilgileri manuel giriniz.',
      };
    }

    const amount = extractAmount(recognizedText);
    const date = extractDate(recognizedText);
    const merchant = extractMerchant(recognizedText);
    const category = guessCategory(merchant || '', recognizedText);

    return {
      success: true,
      amount,
      date,
      merchant,
      category,
      rawText: recognizedText,
    };
  } catch (error: any) {
    return {
      success: false,
      errorMessage: error?.message || 'Fiş analiz edilirken bir hata oluştu.',
    };
  }
}

/**
 * Extract total amount using keywords and regex patterns.
 */
export function extractAmount(text: string): number | undefined {
  const lines = text.split('\n');

  // Regex for price formats: 1.250,50 or 1250.50 or 125,50
  const amountRegex = /(\d{1,3}(?:[.,]\d{3})*[.,]\d{2})|(\d+[.,]\d{2})/;

  // First priority: search in lines containing total keywords
  const totalKeywords = ['toplam', 'total', 'tutar', 'kdv dahil', 'ödenen', 'kredi k', 'nakit'];
  for (const line of lines) {
    const lower = line.toLowerCase();
    if (totalKeywords.some((k) => lower.includes(k))) {
      const match = line.match(amountRegex);
      if (match) {
        const val = normalizeAmountStr(match[0]);
        if (val && val > 0) return val;
      }
    }
  }

  // Second priority: find maximum valid number in whole text
  let maxVal: number | undefined;
  const allMatches = text.match(new RegExp(amountRegex, 'g'));
  if (allMatches) {
    for (const m of allMatches) {
      const val = normalizeAmountStr(m);
      if (val && val > 0) {
        if (!maxVal || val > maxVal) {
          maxVal = val;
        }
      }
    }
  }

  return maxVal;
}

function normalizeAmountStr(str: string): number | undefined {
  // Convert 1.234,56 or 1234,56 or 1234.56 to valid float
  let cleaned = str.trim();
  if (cleaned.includes(',') && cleaned.includes('.')) {
    // Determine which is decimal
    if (cleaned.lastIndexOf(',') > cleaned.lastIndexOf('.')) {
      // 1.234,56
      cleaned = cleaned.replace(/\./g, '').replace(',', '.');
    } else {
      // 1,234.56
      cleaned = cleaned.replace(/,/g, '');
    }
  } else if (cleaned.includes(',')) {
    cleaned = cleaned.replace(',', '.');
  }
  const parsed = parseFloat(cleaned);
  return isNaN(parsed) ? undefined : parsed;
}

/**
 * Extract date from receipt text.
 */
export function extractDate(text: string): Date | undefined {
  const dateRegex = /(\d{1,2})[./-](\d{1,2})[./-](\d{2,4})/;
  const match = text.match(dateRegex);
  if (match) {
    const day = parseInt(match[1], 10);
    const month = parseInt(match[2], 10) - 1;
    let year = parseInt(match[3], 10);
    if (year < 100) year += 2000;

    const d = new Date(year, month, day);
    if (!isNaN(d.getTime())) {
      return d;
    }
  }
  return undefined;
}

/**
 * Extract merchant / store name from receipt header lines.
 */
export function extractMerchant(text: string): string | undefined {
  const lines = text
    .split('\n')
    .map((l) => l.trim())
    .filter((l) => l.length > 2);

  const ignoredKeywords = [
    'fiş',
    'fatura',
    'bilgi',
    'hoşgeldiniz',
    'mali',
    'tarih',
    'saat',
    'tckn',
    'vkn',
    'kdv',
  ];

  for (const line of lines.slice(0, 5)) {
    const lower = line.toLowerCase();
    if (!ignoredKeywords.some((k) => lower.includes(k))) {
      // Clean leading special chars
      return line.replace(/^[*\-#\s]+/, '').slice(0, 40);
    }
  }
  return lines[0]?.slice(0, 40);
}

/**
 * Intelligent category guessing based on merchant and keywords.
 */
export function guessCategory(merchant: string, fullText: string): string {
  const combined = (merchant + ' ' + fullText).toLowerCase();

  if (
    combined.includes('market') ||
    combined.includes('migros') ||
    combined.includes('bim') ||
    combined.includes('bım') ||
    combined.includes('a101') ||
    combined.includes('şok') ||
    combined.includes('sok') ||
    combined.includes('carrefour') ||
    combined.includes('restoran') ||
    combined.includes('cafe') ||
    combined.includes('kahve') ||
    combined.includes('starbucks') ||
    combined.includes('yemek') ||
    combined.includes('burger') ||
    combined.includes('döner') ||
    combined.includes('fırın') ||
    combined.includes('pastane') ||
    combined.includes('lokanta')
  ) {
    return 'Food & Drinks';
  }

  if (
    combined.includes('petrol') ||
    combined.includes('opet') ||
    combined.includes('shell') ||
    combined.includes('bp') ||
    combined.includes('benzin') ||
    combined.includes('otopark') ||
    combined.includes('taksi') ||
    combined.includes('uber') ||
    combined.includes('bilet') ||
    combined.includes('metro') ||
    combined.includes('otobüs') ||
    combined.includes('ulaşım')
  ) {
    return 'Transportation';
  }

  if (
    combined.includes('zara') ||
    combined.includes('h&m') ||
    combined.includes('lcw') ||
    combined.includes('boyner') ||
    combined.includes('teknosa') ||
    combined.includes('mediamarkt') ||
    combined.includes('avm') ||
    combined.includes('giyim') ||
    combined.includes('ayakkabı') ||
    combined.includes('kitap') ||
    combined.includes('d&r')
  ) {
    return 'Shopping';
  }

  if (
    combined.includes('otel') ||
    combined.includes('hotel') ||
    combined.includes('pansiyon') ||
    combined.includes('airbnb') ||
    combined.includes('konaklama') ||
    combined.includes('booking')
  ) {
    return 'Accommodation';
  }

  if (
    combined.includes('müze') ||
    combined.includes('sinema') ||
    combined.includes('tiyatro') ||
    combined.includes('konser') ||
    combined.includes('gezi') ||
    combined.includes('biletix')
  ) {
    return 'Sightseeing';
  }

  return 'Other';
}
