# Pomodoro Flip Clock - Flutter

Professional Pomodoro timer with beautiful flip clock animation, built with Flutter.

## Özellikler

### 🎯 Temel Özellikler
- **Flip Clock Animasyonu**: Her saniye ve dakika değişiminde gerçekçi flip animasyonu
- **Apple Tarzı Tasarım**: Glass morphism efektleri ve minimal tasarım
- **Otomatik Geçişler**: Odak → Mola → Odak döngüsü
- **Kullanıcı Seviyeleri**: Performansa göre otomatik seviye hesaplama

### 🎨 Tasarım
- **Soft Glow Efektleri**: Timer çalışırken yumuşak ışık efektleri
- **Gradient Arka Plan**: Profesyonel koyu tema
- **Smooth Animasyonlar**: 60fps akıcı geçişler
- **Responsive Layout**: Tüm ekran boyutlarına uyumlu

### 📊 İstatistikler
- Günlük odak süresi takibi
- Tamamlanan pomodoro sayısı
- Kullanıcı seviye sistemi (🌱 Başlangıç, 🌿 Orta, 🌳 Disiplinli)
- Otomatik günlük sıfırlama

## Kurulum

### Gereksinimler
- Flutter SDK (3.0.0+)
- Dart SDK
- Android Studio / VS Code

### Adımlar
1. **Flutter'ı kur**: https://docs.flutter.dev/get-started/install
2. **Projeyi klonla**:
   ```bash
   git clone <repo-url>
   cd pomodoro_flutter
   ```
3. **Bağımlılıkları yükle**:
   ```bash
   flutter pub get
   ```
4. **Çalıştır**:
   ```bash
   flutter run
   ```

## Kullanım

1. **Timer Başlatma**: Flip clock'a dokunun
2. **Timer Durdurma**: Çalışırken flip clock'a tekrar dokunun
3. **Otomatik Geçiş**: Süre bittiğinde otomatik olarak mola/odak moduna geçer

## Teknik Detaylar

### Animasyonlar
- **Flip Efekti**: 3D transform ile gerçekçi katlama animasyonu
- **Glow Efekti**: Timer aktifken yumuşak ışık efekti
- **Smooth Transitions**: Tüm geçişler 300-600ms sürede

### Performans
- **Optimized Rendering**: Sadece değişen widget'lar yeniden çizilir
- **Memory Efficient**: Stream-based state management
- **Battery Friendly**: Efficient timer implementation

### Mimari
```
lib/
├── main.dart                 # App entry point
├── screens/
│   └── pomodoro_screen.dart  # Ana ekran
├── widgets/
│   ├── flip_clock.dart       # Flip clock container
│   ├── flip_digit.dart       # Tek digit animasyonu
│   ├── phase_indicator.dart  # Durum göstergesi
│   └── level_indicator.dart  # Seviye göstergesi
├── models/
│   └── pomodoro_state.dart   # State model
└── services/
    ├── timer_service.dart    # Timer logic
    └── settings_service.dart # Ayarlar ve kayıt
```

## Özelleştirme

### Renkler
```dart
// Odak modu
Color(0xFFFF6B6B) // Kırmızı

// Mola modu  
Color(0xFF4ECDC4) // Yeşil
```

### Süreler
```dart
// Varsayılan değerler
focusDuration: 25,  // dakika
breakDuration: 5,   // dakika
```

## Platform Desteği

- ✅ **Windows** (Desktop)
- ✅ **macOS** (Desktop) 
- ✅ **Linux** (Desktop)
- ✅ **Android** (Mobile)
- ✅ **iOS** (Mobile)
- ✅ **Web** (Browser)

## Lisans

MIT License - Detaylar için LICENSE dosyasına bakın.