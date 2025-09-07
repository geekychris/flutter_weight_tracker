# Weight Tracker

A comprehensive weight and body measurement tracking app for iOS, iPadOS, and macOS built with SwiftUI and Core Data.

## Features

### 📊 Weight Tracking
- Record daily weight measurements
- Track weight changes over time
- Visual progress indicators

### 📏 Body Measurements
- Optional body measurements including:
  - Body Fat Percentage
  - Muscle Mass
  - Waist, Chest, Arms, Hips, Legs, Neck measurements
- Flexible measurement recording (track what matters to you)

### 📸 Progress Photos
- Take progress photos with the camera (iOS only)
- Select photos from your photo library
- Attach photos to weight entries
- Visual progress tracking

### 📈 Interactive Charts
- Beautiful line charts showing progress over time
- Multiple time ranges: 1 week, 1 month, 3 months, 6 months, 1 year, all time
- Switch between different measurements (weight, body fat, muscle mass, etc.)
- Statistics including current value, average, and total change

### 📱 Cross-Platform Support
- **iPhone**: Optimized mobile experience with tab navigation
- **iPad**: Enhanced layout for larger screens
- **macOS**: Native macOS app with sidebar navigation

### 💾 Data Management
- Core Data persistence for reliable data storage
- Edit and delete existing entries
- Swipe-to-delete functionality on iOS
- Context menus for quick actions

## Requirements

- **iOS 16.0+** or **macOS 13.0+**
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone this repository
2. Open `WeightTracker.xcodeproj` in Xcode
3. Select your target device/simulator
4. Build and run the app

## Architecture

### Core Components

- **SwiftUI**: Modern declarative UI framework
- **Core Data**: Persistent data storage
- **Swift Charts**: Native charting framework for beautiful visualizations
- **PhotosUI**: Photo selection and camera integration

### Project Structure

```
WeightTracker/
├── WeightTrackerApp.swift          # Main app entry point
├── ContentView.swift               # Main navigation structure
├── Models/
│   └── WeightEntry.swift          # Core Data model extensions
├── Views/
│   ├── AddWeightView.swift        # Entry creation form
│   ├── HistoryView.swift          # Entry history and editing
│   └── ChartsView.swift           # Progress visualization
└── Data/
    ├── DataModel.xcdatamodeld     # Core Data model
    └── PersistenceController.swift # Core Data stack
```

### Data Model

The app uses a single Core Data entity `WeightEntry` with the following attributes:

- `id`: UUID (Primary Key)
- `date`: Date (Required)
- `weight`: Double (Required)
- `bodyFat`: Double (Optional)
- `muscleMass`: Double (Optional)
- `waist`, `chest`, `arms`, `hips`, `legs`, `neck`: Double (Optional measurements)
- `notes`: String (Optional)
- `photoData`: Binary Data (Optional progress photo)

## Privacy

The app requests the following permissions:
- **Camera**: To take progress photos (iOS only)
- **Photo Library**: To select existing photos for progress tracking

All data is stored locally on your device using Core Data. No data is transmitted to external servers.

## Platform Adaptations

### iOS (iPhone/iPad)
- Tab-based navigation
- Native iOS UI components
- Camera integration for progress photos
- Swipe gestures for deletion

### macOS
- Sidebar navigation
- Window-based interface
- Photo library integration
- Context menus and keyboard shortcuts

## Future Enhancements

Potential features for future versions:
- Export data to CSV/PDF
- Health app integration (iOS)
- Reminders and notifications
- Goal setting and tracking
- Multiple user profiles
- Cloud sync between devices
- Advanced statistics and insights
- BMI calculations
- Custom measurement units (kg/metric support)

## License

This project is available under the MIT License. See the LICENSE file for more info.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
