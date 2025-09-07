import SwiftUI
import CoreData
import PhotosUI

struct AddWeightView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var date = Date()
    @State private var weight = ""
    @State private var bodyFat = ""
    @State private var muscleMass = ""
    @State private var waist = ""
    @State private var chest = ""
    @State private var arms = ""
    @State private var hips = ""
    @State private var legs = ""
    @State private var neck = ""
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoImage: UIImage?
    
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header
                    VStack {
                        Text("Add Weight Entry")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding(.horizontal)
                    }
                    
                    // Weight section (required)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Weight")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            TextField("Enter weight", text: $weight)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                            Text("lbs")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Body measurements section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Body Measurements (Optional)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            MeasurementField(title: "Body Fat %", value: $bodyFat, unit: "%")
                            MeasurementField(title: "Muscle Mass", value: $muscleMass, unit: "lbs")
                            MeasurementField(title: "Waist", value: $waist, unit: "in")
                            MeasurementField(title: "Chest", value: $chest, unit: "in")
                            MeasurementField(title: "Arms", value: $arms, unit: "in")
                            MeasurementField(title: "Hips", value: $hips, unit: "in")
                            MeasurementField(title: "Legs", value: $legs, unit: "in")
                            MeasurementField(title: "Neck", value: $neck, unit: "in")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Photo section
                    VStack(alignment: .leading, spacing: 10) {
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
                            HStack(spacing: 20) {
                                #if os(iOS)
                                Button("Take Photo") {
                                    showingCamera = true
                                }
                                .buttonStyle(.bordered)
                                #endif
                                
                                PhotosPicker("Choose Photo", selection: $selectedPhoto, matching: .images)
                                    .buttonStyle(.bordered)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Notes section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notes (Optional)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Add notes about your progress...", text: $notes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }
                    .padding(.horizontal)
                    
                    // Save button
                    Button("Save Entry") {
                        saveEntry()
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .onChange(of: selectedPhoto) { newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    photoImage = image
                }
            }
        }
        #if os(iOS)
        .sheet(isPresented: $showingCamera) {
            CameraView(image: $photoImage)
        }
        #endif
        .alert("Entry Saved", isPresented: $showingAlert) {
            Button("OK") {
                clearForm()
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveEntry() {
        guard let weightValue = Double(weight), weightValue > 0 else {
            alertMessage = "Please enter a valid weight"
            showingAlert = true
            return
        }
        
        let newEntry = WeightEntry(context: viewContext)
        newEntry.id = UUID()
        newEntry.date = date
        newEntry.weight = weightValue
        
        // Optional measurements
        newEntry.bodyFat = Double(bodyFat) ?? 0
        newEntry.muscleMass = Double(muscleMass) ?? 0
        newEntry.waist = Double(waist) ?? 0
        newEntry.chest = Double(chest) ?? 0
        newEntry.arms = Double(arms) ?? 0
        newEntry.hips = Double(hips) ?? 0
        newEntry.legs = Double(legs) ?? 0
        newEntry.neck = Double(neck) ?? 0
        newEntry.notes = notes
        
        // Save photo if available
        if let photoImage = photoImage {
            newEntry.setPhoto(photoImage)
        }
        
        do {
            try viewContext.save()
            alertMessage = "Weight entry saved successfully!"
            showingAlert = true
        } catch {
            alertMessage = "Error saving entry: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func clearForm() {
        weight = ""
        bodyFat = ""
        muscleMass = ""
        waist = ""
        chest = ""
        arms = ""
        hips = ""
        legs = ""
        neck = ""
        notes = ""
        photoImage = nil
        selectedPhoto = nil
        date = Date()
    }
}

struct MeasurementField: View {
    let title: String
    @Binding var value: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                TextField("0.0", text: $value)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#if os(iOS)
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
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
    }
}
#endif

#Preview {
    AddWeightView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
