#!/bin/bash

echo "🏋️‍♂️ Building Complete WeightTracker App with Camera & Vital Signs..."

# Get iPhone 16 Pro simulator ID  
SIMULATOR_ID="3132920E-F8E5-4A3E-91FA-3E8E74A1A8D7"

echo "📱 Using device: iPhone 16 Pro ($SIMULATOR_ID)"

# Terminate existing apps
xcrun simctl terminate "$SIMULATOR_ID" com.test.WeightTracker 2>/dev/null || true
xcrun simctl terminate "$SIMULATOR_ID" com.complete.WeightTracker 2>/dev/null || true

# Clean up old builds
rm -rf CompleteWeightTracker.app TestWeightTracker.app

# Create app bundle structure
mkdir -p CompleteWeightTracker.app

# Create proper Info.plist using defaults
defaults write "$PWD/CompleteWeightTracker.app/Info" CFBundleExecutable "CompleteWeightTracker"
defaults write "$PWD/CompleteWeightTracker.app/Info" CFBundleIdentifier "com.complete.WeightTracker"
defaults write "$PWD/CompleteWeightTracker.app/Info" CFBundleName "CompleteWeightTracker"
defaults write "$PWD/CompleteWeightTracker.app/Info" CFBundleDisplayName "WeightTracker: Complete Edition"
defaults write "$PWD/CompleteWeightTracker.app/Info" CFBundleVersion "2.0"
defaults write "$PWD/CompleteWeightTracker.app/Info" CFBundleShortVersionString "2.0"
defaults write "$PWD/CompleteWeightTracker.app/Info" CFBundlePackageType "APPL"
defaults write "$PWD/CompleteWeightTracker.app/Info" LSRequiresIPhoneOS -bool true
defaults write "$PWD/CompleteWeightTracker.app/Info" UISupportedInterfaceOrientations -array "UIInterfaceOrientationPortrait"
defaults write "$PWD/CompleteWeightTracker.app/Info" NSCameraUsageDescription "Take progress photos to track your fitness journey"
defaults write "$PWD/CompleteWeightTracker.app/Info" NSPhotoLibraryUsageDescription "Select photos from your library for progress tracking"
defaults write "$PWD/CompleteWeightTracker.app/Info" MinimumOSVersion "17.0"

# Convert to proper plist format
plutil -convert xml1 "CompleteWeightTracker.app/Info.plist"

# Compile the complete WeightTracker app
echo "⚙️  Compiling Complete WeightTracker with ALL features..."
if xcrun -sdk iphonesimulator swiftc \
    -target arm64-apple-ios17.0-simulator \
    -parse-as-library \
    -o CompleteWeightTracker.app/CompleteWeightTracker \
    CompleteWeightTracker.swift; then
    
    echo "✅ Compilation successful!"
    
    # Install app on simulator
    echo "📦 Installing Complete WeightTracker app..."
    if xcrun simctl install "$SIMULATOR_ID" CompleteWeightTracker.app; then
        
        # Launch the app
        echo "▶️  Launching Complete WeightTracker app..."
        xcrun simctl launch "$SIMULATOR_ID" com.complete.WeightTracker
        
        echo ""
        echo "🎉 COMPLETE WEIGHTTRACKER APP IS NOW RUNNING!"
        echo ""
        echo "✅ ALL FEATURES INCLUDED:"
        echo "   🏋️‍♂️ Weight & Body Measurements Tracking"
        echo "   🩺 Blood Pressure Monitoring (Systolic/Diastolic)"
        echo "   ❤️  Resting Heart Rate Tracking"
        echo "   ⚡ Real-time Health Status Feedback"
        echo "   🎨 Color-coded Health Categories"
        echo "   📸 CAMERA FUNCTIONALITY (FIXED!)"
        echo "   🖼️  Photo Library Selection"
        echo "   📝 Notes & Progress Tracking"
        echo "   📊 Charts & Analytics"
        echo "   ✏️  Edit & Delete Entries"
        echo "   💾 Sample Data Pre-loaded"
        echo ""
        echo "📋 TEST THE CAMERA FIX:"
        echo "   1. 📱 Go to 'Add Entry' tab"
        echo "   2. 🏃‍♂️ Enter weight and vital signs"
        echo "   3. 📸 Look for 'Take Photo' button in Photo section"
        echo "   4. ✅ Camera button should now be VISIBLE"
        echo "   5. 🖼️  Tap it to open photo picker"
        echo "   6. 💾 Save entry and check History tab"
        echo ""
        echo "🔍 WHAT'S FIXED:"
        echo "   ✅ Camera button always appears"
        echo "   ✅ Works in iOS Simulator (opens photo library)"
        echo "   ✅ Photo selection and display working"
        echo "   ✅ All vital signs functionality intact"
        echo "   ✅ Complete feature set restored"
        
    else
        echo "❌ Failed to install Complete WeightTracker app"
        exit 1
    fi
else
    echo "❌ Compilation failed"
    echo "Available SDKs:"
    xcodebuild -showsdks | grep -i ios
    exit 1
fi
