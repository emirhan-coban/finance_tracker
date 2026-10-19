# Finance Tracker 💰

Modern, responsive ve minimal kişisel finans takip uygulaması. React Native & Expo kullanılarak Wise ve Cash App estetiğinden (Forest & Lime yeşili, modern grafit yüzeyler) esinlenilerek geliştirilmiştir.

## ✨ Özellikler

* **📊 Dinamik Dashboard**: Aylık harcama toplamı, harcama hedefi ilerleme çubuğu ve anlık kategori özetleri.
* **🎯 Kategori Bazlı Bütçeleme**: Her kategori için özel limit belirleme, harcama oranı çubukları ve anlık uyarılar.
* **💱 Çoklu Para Birimi & Canlı Kurlar**: TRY (₺), USD ($) ve EUR (€) para birimleriyle harcama ekleme ve TCMB / canlı döviz kuru ile otomatik TL karşılığı hesaplama.
* **📱 Tam Responsive & Taşma Korumalı**: Her ekran boyutunda font otomatik ölçeklendirme (`adjustsFontSizeToFit`), taşmaları ve çakışmaları engelleyen esnek flexbox yapısı.
* **🌓 Dinamik Tema**: Modern karanlık (Graphite Dark) ve aydınlık (Soft Mint) mod geçişi.
* **💾 Yerel Depolama (AsyncStorage)**: Harcamalarınız ve bütçe limitleriniz cihazınızda güvenle saklanır, çevrimdışı tam erişim sağlanır.
* **⚡ Hızlı İşlemler**: Tek dokunuşla harcama silme, kategori filtreleme ve arama.

## 🛠️ Kullanılan Teknolojiler

* **Framework**: [React Native](https://reactnative.dev/) & [Expo](https://expo.dev/) (SDK 58)
* **Dil**: [TypeScript](https://www.typescriptlang.org/)
* **Navigasyon**: [@react-navigation/native-stack](https://reactnavigation.org/)
* **Durum Yönetimi (State Management)**: React Context API (`ExpenseContext`, `ThemeContext`)
* **Yerel Depolama**: [@react-native-async-storage/async-storage](https://react-native-async-storage.github.io/async-storage/)
* **İkonlar**: [@expo/vector-icons](https://icons.expo.fyi/) (Ionicons)
* **Tarih Seçici**: [@react-native-community/datetimepicker](https://github.com/react-native-datetimepicker/datetimepicker)
* **Haptik Geri Bildirim**: `expo-haptics`

## 🚀 Başlarken

### Ön Koşullar

* [Node.js](https://nodejs.org/) (v18 veya üzeri)
* [Expo Go](https://expo.dev/go) mobil uygulaması (iOS veya Android cihazınızda test etmek için) ya da iOS Simulator / Android Emulator.

### Kurulum

1. **Depoyu Klonlayın**
   ```bash
   git clone https://github.com/emirhan-coban/finance_tracker.git
   cd finance_tracker
   ```

2. **Bağımlılıkları Yükleyin**
   ```bash
   npm install
   ```

3. **Uygulamayı Başlatın**
   ```bash
   npx expo start
   ```

4. **Çalıştırma Seçenekleri**
   * **iOS Simulator**: Terminalde `i` tuşuna basın.
   * **Android Emulator**: Terminalde `a` tuşuna basın.
   * **Fiziksel Cihaz**: Terminaldeki QR kodu Expo Go uygulaması ile tarayın.

## 📁 Proje Yapısı

```
src/
├── components/          # Yeniden kullanılabilir UI bileşenleri (ExpenseCard, CategoryBudgetCard, BouncingButton, ResponsiveContainer)
├── context/             # Global Context sağlayıcıları (ExpenseContext, ThemeContext)
├── models/              # TypeScript veri tipleri ve modelleri (Expense, CategoryBudget)
├── screens/             # Ekranlar (DashboardScreen, AllExpensesScreen, AddExpenseScreen)
├── services/            # Servisler (storageService, currencyService)
├── theme/               # Renk paleti ve tasarım tokenları
└── utils/               # Yardımcı fonksiyonlar ve formatlayıcılar (categoryUtils, formatUtils)
```

## 📄 Lisans

MIT Lisansı altında dağıtılmaktadır. Daha fazla bilgi için `LICENSE` dosyasına bakın.
