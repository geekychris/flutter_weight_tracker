#!/bin/bash

echo "📷 Building WeightTracker to test camera functionality..."

# Get iPhone 16 Pro simulator ID
SIMULATOR_ID="3132920E-F8E5-4A3E-91FA-3E8E74A1A8D7"

echo "📱 Using device: iPhone 16 Pro ($SIMULATOR_ID)"

# Clean up old builds
rm -rf TestWeightTracker.app

# Create app bundle structure
mkdir -p TestWeightTracker.app

# Create simple Info.plist
cat > TestWeightTracker.app/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>TestWeightTracker</string>
    <key>CFBundleIdentifier</key>
    <string>com.test.WeightTracker</string>
    <key>CFBundleName</key>
    <string>TestWeightTracker</string>
    <key>CFBundleDisplayName</key>
    <string>Weight Tracker Camera Test</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>NSCameraUsageDescription</key>
    <string>Take progress photos to track your fitness journey</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Select photos from your library for progress tracking</string>
</dict>
</plist>
EOF

# Create a simple test app that shows the camera button
cat > CameraTest.swift << 'EOF'
import SwiftUI
import PhotosUI

@main
struct CameraTestApp: App {
    var body: some Scene {
        WindowGroup {
            CameraTestView()
        }
    }
}

struct CameraTestView: View {
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoImage: UIImage?
    @State private var showingCamera = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("📷 Camera Button Test")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // Photo section with camera button
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Progress Photo (Optional)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let photoImage = photoImage {
                            Image(uiImage: photoImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    Button("Remove Photo") {
                                        self.photoImage = nil
                                        self.selectedPhoto = nil
                                    }
                                    .foregroundColor(.red)
                                    .padding(8)
                                    .background(Color.white.opacity(0.8))
                                    .clipShape(Capsule()),
                                    alignment: .topTrailing
                                )
                        } else {
                            VStack(spacing: 15) {
                                // Camera button - should always appear
                                Button("📸 Take Photo") {
                                    showingCamera = true
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.blue)
                                
                                // Photo picker button
                                PhotosPicker("🖼️ Choose Photo", selection: $selectedPhoto, matching: .images)
                                    .buttonStyle(.bordered)
                                    .foregroundColor(.green)
                                
                                Text("ℹ️ Camera button should appear above")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("📱 Simulator: Camera won't work, but button should show")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Camera Test")
        }
        .onChange(of: selectedPhoto) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    photoImage = image
                }
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(image: $photoImage)
        }
        .alert("Camera Test", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        // Check if camera is available (it won't be in simulator)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            // Fallback to photo library in simulator
            picker.sourceType = .photoLibrary
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
EOF

# Compile the test app
echo "⚙️  Compiling camera test app..."
if xcrun -sdk iphonesimulator swiftc \
    -target arm64-apple-ios17.0-simulator \
    -parse-as-library \
    -o TestWeightTracker.app/TestWeightTracker \
    CameraTest.swift; then
    
    echo "✅ Compilation successful!"
    
    # Install and launch
    echo "📦 Installing camera test app..."
    if xcrun simctl install "$SIMULATOR_ID" TestWeightTracker.app; then
        echo "▶️  Launching camera test app..."
        xcrun simctl launch "$SIMULATOR_ID" com.test.WeightTracker
        
        echo ""
        echo "✅ Camera test app is now running!"
        echo ""
        echo "🔍 WHAT TO CHECK:"
        echo "   📸 You should see 'Take Photo' button"
        echo "   🖼️  You should see 'Choose Photo' button"  
        echo "   ℹ️  Camera button appears even in simulator"
        echo "   📱 Tapping camera will open photo library (simulator fallback)"
        echo "   🎯 This proves the button visibility issue"
    else
        echo "❌ Failed to install test app"
    fi
else
    echo "❌ Compilation failed"
fi

# Clean up
rm -f CameraTest.swift
