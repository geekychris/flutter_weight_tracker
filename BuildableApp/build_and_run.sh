#!/bin/bash

echo "🩺 Building WeightTracker App with Enhanced Vital Signs Features..."

# Get iPhone 16 Pro simulator ID
SIMULATOR_ID=$(xcrun simctl list devices | grep "iPhone 16 Pro" | head -1 | sed 's/.*(\([^)]*\)).*/\1/')

if [ -z "$SIMULATOR_ID" ]; then
    echo "❌ iPhone 16 Pro simulator not found"
    echo "Available simulators:"
    xcrun simctl list devices | grep iPhone
    exit 1
fi

echo "📱 Using device: iPhone 16 Pro ($SIMULATOR_ID)"

# Boot simulator if not running
echo "🚀 Starting simulator..."
xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true
open -a Simulator

# Wait for simulator to be ready
sleep 3

# Clean up old builds
echo "🧹 Cleaning up old builds..."
rm -rf WeightTracker.app

# Create app bundle structure
mkdir -p WeightTracker.app

# Create Info.plist using defaults
defaults write "$PWD/WeightTracker.app/Info" CFBundleExecutable "WeightTracker"
defaults write "$PWD/WeightTracker.app/Info" CFBundleIdentifier "com.example.WeightTracker"
defaults write "$PWD/WeightTracker.app/Info" CFBundleName "WeightTracker"
defaults write "$PWD/WeightTracker.app/Info" CFBundleDisplayName "Weight Tracker with Vital Signs"
defaults write "$PWD/WeightTracker.app/Info" CFBundleVersion "2.0"
defaults write "$PWD/WeightTracker.app/Info" CFBundleShortVersionString "2.0"
defaults write "$PWD/WeightTracker.app/Info" CFBundlePackageType "APPL"
defaults write "$PWD/WeightTracker.app/Info" LSRequiresIPhoneOS -bool true
defaults write "$PWD/WeightTracker.app/Info" UISupportedInterfaceOrientations -array "UIInterfaceOrientationPortrait"
defaults write "$PWD/WeightTracker.app/Info" NSCameraUsageDescription "Take progress photos"
defaults write "$PWD/WeightTracker.app/Info" NSPhotoLibraryUsageDescription "Select photos for tracking"
defaults write "$PWD/WeightTracker.app/Info" MinimumOSVersion "17.0"

# Convert to proper plist format
plutil -convert xml1 "WeightTracker.app/Info.plist"

# Determine simulator architecture
SIMULATOR_ARCH=$(uname -m)
if [ "$SIMULATOR_ARCH" = "arm64" ]; then
    TARGET_ARCH="arm64"
else
    TARGET_ARCH="x86_64"
fi

echo "⚙️  Compiling WeightTracker with vital signs support..."
echo "   Architecture: $TARGET_ARCH"

# Compile the SwiftUI app
if xcrun -sdk iphonesimulator swiftc \
    -target ${TARGET_ARCH}-apple-ios17.0-simulator \
    -parse-as-library \
    -o WeightTracker.app/WeightTracker \
    WeightTrackerStandalone.swift; then
    
    echo "✅ Compilation successful!"
    
    # Install app on simulator
    echo "📦 Installing WeightTracker app on simulator..."
    if xcrun simctl install "$SIMULATOR_ID" WeightTracker.app; then
        
        # Launch the app
        echo "▶️  Launching WeightTracker app..."
        xcrun simctl launch "$SIMULATOR_ID" com.example.WeightTracker
        
        echo ""
        echo "🎉 WeightTracker app is now running in the simulator!"
        echo ""
        echo "🩺 ENHANCED VITAL SIGNS FEATURES:"
        echo "   ✅ Blood Pressure Tracking (Systolic/Diastolic)"
        echo "   ✅ Resting Heart Rate Monitoring" 
        echo "   ✅ Real-time Health Categorization"
        echo "   ✅ Color-coded Health Status Indicators"
        echo "   ✅ Enhanced History with Vital Signs Display"
        echo "   ✅ Sample Data Pre-loaded"
        echo ""
        echo "📋 TESTING THE NEW FEATURES:"
        echo "   1. 👁️  Check 'History' tab - see sample vital signs data"
        echo "   2. ➕ Tap 'Add Entry' tab to add new measurements"
        echo "   3. 🩺 Scroll to 'Vital Signs' section"
        echo "   4. 🔢 Enter blood pressure (try 130/85 to see orange warning)"
        echo "   5. ❤️  Enter heart rate (try 105 to see tachycardia warning)"
        echo "   6. ⚡ Watch real-time feedback as you type!"
        echo "   7. 💾 Save entry and check History tab"
        echo "   8. 📊 Check Charts tab for vital signs summary"
        
    else
        echo "❌ Failed to install app on simulator"
        exit 1
    fi
else
    echo "❌ Compilation failed"
    echo "Available SDKs:"
    xcodebuild -showsdks | grep -i ios
    exit 1
fi
