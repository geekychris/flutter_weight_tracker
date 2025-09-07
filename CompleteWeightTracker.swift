import SwiftUI
import PhotosUI

// MARK: - Data Models (Simplified non-CoreData version)
struct WeightEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var weight: Double
    var bodyFat: Double?
    var muscleMass: Double?
    var waist: Double?
    var chest: Double?
    var arms: Double?
    var hips: Double?
    var legs: Double?
    var neck: Double?
    var systolicBP: Double?
    var diastolicBP: Double?
    var restingHeartRate: Double?
    var notes: String?
    var photoData: Data?
    
    init(date: Date = Date(), weight: Double = 0.0) {
        self.date = date
        self.weight = weight
    }
    
    // MARK: - Display Properties
    var displayWeight: String {
        weight > 0 ? String(format: "%.1f", weight) : ""
    }
    
    var displayBodyFat: String {
        guard let bodyFat = bodyFat, bodyFat > 0 else { return "" }
        return String(format: "%.1f", bodyFat)
    }
    
    var displayMuscleMass: String {
        guard let muscleMass = muscleMass, muscleMass > 0 else { return "" }
        return String(format: "%.1f", muscleMass)
    }
    
    var displayBloodPressure: String {
        if let systolic = systolicBP, let diastolic = diastolicBP, systolic > 0 && diastolic > 0 {
            return String(format: "%.0f/%.0f", systolic, diastolic)
        }
        return ""
    }
    
    var displayRestingHeartRate: String {
        if let hr = restingHeartRate, hr > 0 {
            return String(format: "%.0f", hr)
        }
        return ""
    }
    
    // MARK: - Helper Properties
    var hasVitalSigns: Bool {
        return (systolicBP ?? 0) > 0 || (diastolicBP ?? 0) > 0 || (restingHeartRate ?? 0) > 0
    }
    
    var hasMeasurements: Bool {
        return (bodyFat ?? 0) > 0 || (muscleMass ?? 0) > 0 || (waist ?? 0) > 0 || (chest ?? 0) > 0 || 
               (arms ?? 0) > 0 || (hips ?? 0) > 0 || (legs ?? 0) > 0 || (neck ?? 0) > 0
    }
    
    var hasPhoto: Bool {
        return photoData != nil
    }
    
    var wrappedNotes: String {
        return notes ?? ""
    }
    
    // MARK: - Health Categorization
    var bloodPressureCategory: String {
        guard let systolic = systolicBP, let diastolic = diastolicBP,
              systolic > 0 && diastolic > 0 else { return "" }
        
        if systolic < 120 && diastolic < 80 {
            return "Normal"
        } else if systolic < 130 && diastolic < 80 {
            return "Elevated"
        } else if (systolic >= 130 && systolic < 140) || (diastolic >= 80 && diastolic < 90) {
            return "Stage 1 High"
        } else if systolic >= 140 || diastolic >= 90 {
            return "Stage 2 High"
        } else {
            return "Check with doctor"
        }
    }
    
    var heartRateCategory: String {
        guard let hr = restingHeartRate, hr > 0 else { return "" }
        
        if hr < 60 {
            return "Low (Bradycardia)"
        } else if hr <= 100 {
            return "Normal"
        } else {
            return "High (Tachycardia)"
        }
    }
    
    var bloodPressureCategoryColor: Color {
        let category = bloodPressureCategory
        switch category {
        case "Normal": return .green
        case "Elevated": return .yellow
        case "Stage 1 High": return .orange
        case "Stage 2 High": return .red
        default: return .gray
        }
    }
    
    var heartRateCategoryColor: Color {
        let category = heartRateCategory
        switch category {
        case "Normal": return .green
        case "Low (Bradycardia)", "High (Tachycardia)": return .orange
        default: return .gray
        }
    }
    
    // MARK: - Photo Methods
    mutating func setPhoto(_ image: UIImage) {
        photoData = image.jpegData(compressionQuality: 0.8)
    }
    
    var photo: Image? {
        guard let photoData = photoData,
              let uiImage = UIImage(data: photoData) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}

// MARK: - Main App
@main
struct CompleteWeightTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - ContentView
struct ContentView: View {
    @State private var entries: [WeightEntry] = []
    
    var body: some View {
        TabView {
            AddWeightView(entries: $entries)
                .tabItem {
                    Label("Add Entry", systemImage: "plus.circle")
                }
            
            HistoryView(entries: $entries)
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }
            
            ChartsView(entries: $entries)
                .tabItem {
                    Label("Charts", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
        .accentColor(.blue)
        .onAppear {
            loadSampleData()
        }
    }
    
    private func loadSampleData() {
        if entries.isEmpty {
            // Sample entry with vital signs
            let sampleEntry1 = WeightEntry(date: Date().addingTimeInterval(-86400 * 7), weight: 180.5)
            var modifiedEntry1 = sampleEntry1
            modifiedEntry1.systolicBP = 128
            modifiedEntry1.diastolicBP = 85
            modifiedEntry1.restingHeartRate = 72
            modifiedEntry1.bodyFat = 18.5
            modifiedEntry1.muscleMass = 145.0
            modifiedEntry1.notes = "Feeling good this week!"
            
            let sampleEntry2 = WeightEntry(date: Date().addingTimeInterval(-86400 * 3), weight: 179.2)
            var modifiedEntry2 = sampleEntry2
            modifiedEntry2.systolicBP = 135
            modifiedEntry2.diastolicBP = 88
            modifiedEntry2.restingHeartRate = 78
            modifiedEntry2.muscleMass = 142.0
            modifiedEntry2.notes = "Good workout today"
            
            entries = [modifiedEntry1, modifiedEntry2]
        }
    }
}

// MARK: - Add Weight View
struct AddWeightView: View {
    @Binding var entries: [WeightEntry]
    
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
    @State private var systolicBP = ""
    @State private var diastolicBP = ""
    @State private var restingHeartRate = ""
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoImage: UIImage?
    
    @State private var showingCamera = false
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
                    
                    // Vital signs section - ENHANCED
                    VStack(alignment: .leading, spacing: 15) {
                        Text("🩺 Vital Signs (Optional)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 15) {
                            // Blood Pressure Section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Blood Pressure")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .fontWeight(.medium)
                                
                                HStack(spacing: 10) {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Systolic")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        HStack {
                                            TextField("120", text: $systolicBP)
                                                .keyboardType(.numberPad)
                                                .textFieldStyle(.roundedBorder)
                                            Text("mmHg")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Text("/")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 15)
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Diastolic")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        HStack {
                                            TextField("80", text: $diastolicBP)
                                                .keyboardType(.numberPad)
                                                .textFieldStyle(.roundedBorder)
                                            Text("mmHg")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                
                                // Real-time BP feedback
                                if !systolicBP.isEmpty && !diastolicBP.isEmpty,
                                   let systolic = Double(systolicBP),
                                   let diastolic = Double(diastolicBP) {
                                    let tempEntry = createTempEntryForPreview()
                                    HStack {
                                        Image(systemName: "heart.circle.fill")
                                            .foregroundColor(tempEntry.bloodPressureCategoryColor)
                                        Text(tempEntry.bloodPressureCategory)
                                            .font(.caption)
                                            .foregroundColor(tempEntry.bloodPressureCategoryColor)
                                            .fontWeight(.medium)
                                    }
                                }
                            }
                            
                            // Heart Rate Section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Resting Heart Rate")
                                    .font(.subheadline)
                                    .foregroundColor(.pink)
                                    .fontWeight(.medium)
                                
                                HStack {
                                    TextField("72", text: $restingHeartRate)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(maxWidth: 120)
                                    Text("bpm")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                
                                // Real-time HR feedback
                                if !restingHeartRate.isEmpty,
                                   let heartRate = Double(restingHeartRate) {
                                    let tempEntry = createTempEntryForPreview()
                                    HStack {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(tempEntry.heartRateCategoryColor)
                                        Text(tempEntry.heartRateCategory)
                                            .font(.caption)
                                            .foregroundColor(tempEntry.heartRateCategoryColor)
                                            .fontWeight(.medium)
                                    }
                                }
                            }
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
                    
                    // PHOTO SECTION - FIXED CAMERA FUNCTIONALITY
                    VStack(alignment: .leading, spacing: 10) {
                        Text("📸 Progress Photo (Optional)")
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
                                // FIXED: Camera button always appears
                                Button("📸 Take Photo") {
                                    showingCamera = true
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.blue)
                                
                                // Photo picker button
                                PhotosPicker("🖼️ Choose Photo", selection: $selectedPhoto, matching: .images)
                                    .buttonStyle(.bordered)
                                    .foregroundColor(.green)
                                
                                Text("📱 Camera opens photo library in simulator")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
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
        .alert("Entry Saved", isPresented: $showingAlert) {
            Button("OK") {
                clearForm()
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func createTempEntryForPreview() -> WeightEntry {
        var temp = WeightEntry()
        temp.systolicBP = Double(systolicBP)
        temp.diastolicBP = Double(diastolicBP)
        temp.restingHeartRate = Double(restingHeartRate)
        return temp
    }
    
    private func saveEntry() {
        guard let weightValue = Double(weight), weightValue > 0 else {
            alertMessage = "Please enter a valid weight"
            showingAlert = true
            return
        }
        
        var newEntry = WeightEntry(date: date, weight: weightValue)
        
        // Optional measurements
        newEntry.bodyFat = Double(bodyFat)
        newEntry.muscleMass = Double(muscleMass)
        newEntry.waist = Double(waist)
        newEntry.chest = Double(chest)
        newEntry.arms = Double(arms)
        newEntry.hips = Double(hips)
        newEntry.legs = Double(legs)
        newEntry.neck = Double(neck)
        
        // Vital signs
        newEntry.systolicBP = Double(systolicBP)
        newEntry.diastolicBP = Double(diastolicBP)
        newEntry.restingHeartRate = Double(restingHeartRate)
        
        newEntry.notes = notes.isEmpty ? nil : notes
        
        // Save photo if available
        if let photoImage = photoImage {
            newEntry.setPhoto(photoImage)
        }
        
        entries.append(newEntry)
        entries.sort { $0.date > $1.date }
        
        alertMessage = "Weight entry with vital signs saved successfully!"
        showingAlert = true
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
        systolicBP = ""
        diastolicBP = ""
        restingHeartRate = ""
        notes = ""
        photoImage = nil
        selectedPhoto = nil
        date = Date()
    }
}

// MARK: - History View
struct HistoryView: View {
    @Binding var entries: [WeightEntry]
    @State private var selectedEntry: WeightEntry?
    
    var body: some View {
        NavigationView {
            Group {
                if entries.isEmpty {
                    VStack {
                        Image(systemName: "scale.3d")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No entries yet")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Add your first weight entry to get started!")
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        ForEach(entries.sorted(by: { $0.date > $1.date })) { entry in
                            WeightEntryRow(entry: entry)
                                .onTapGesture {
                                    selectedEntry = entry
                                }
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Weight & Vital Signs History")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedEntry) { entry in
            EditWeightView(entry: entry, entries: $entries)
        }
    }
    
    private func deleteEntries(offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
    }
}

// MARK: - Weight Entry Row (Enhanced with Vital Signs)
struct WeightEntryRow: View {
    let entry: WeightEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.weight, specifier: "%.1f") lbs")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(entry.date, formatter: dateFormatter)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if entry.hasMeasurements || entry.hasVitalSigns || !entry.wrappedNotes.isEmpty {
                    HStack {
                        if entry.hasMeasurements {
                            Image(systemName: "ruler")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                        if entry.hasVitalSigns {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        if !entry.wrappedNotes.isEmpty {
                            Image(systemName: "note.text")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                        if entry.hasPhoto {
                            Image(systemName: "camera")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }
                    .font(.caption2)
                }
                
                // Display body measurements if available - NEW SECTION
                if entry.hasMeasurements {
                    VStack(alignment: .leading, spacing: 4) {
                        let measurements = [
                            ("Arms", entry.arms, "💪"),
                            ("Chest", entry.chest, "🫁"),
                            ("Waist", entry.waist, "⚖️"),
                            ("Hips", entry.hips, "🍑"),
                            ("Legs", entry.legs, "🦵"),
                            ("Neck", entry.neck, "🧣")
                        ]
                        
                        let availableMeasurements = measurements.filter { $0.1 != nil && $0.1! > 0 }
                        
                        if !availableMeasurements.isEmpty {
                            HStack {
                                Image(systemName: "ruler")
                                    .foregroundColor(.blue)
                                Text("Body: ")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                
                                Text(availableMeasurements.map { "\($0.2)\(String(format: "%.1f\"", $0.1!))" }.joined(separator: " "))
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        if let bodyFat = entry.bodyFat, bodyFat > 0 {
                            HStack {
                                Image(systemName: "percent")
                                    .foregroundColor(.orange)
                                Text("Body Fat: \(String(format: "%.1f", bodyFat))%")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        if let muscleMass = entry.muscleMass, muscleMass > 0 {
                            HStack {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .foregroundColor(.green)
                                Text("Muscle: \(String(format: "%.1f", muscleMass)) lbs")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
                
                // Display vital signs if available - ENHANCED DISPLAY
                if entry.hasVitalSigns {
                    VStack(alignment: .leading, spacing: 4) {
                        if !entry.displayBloodPressure.isEmpty {
                            HStack {
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.red)
                                Text("BP: \(entry.displayBloodPressure) mmHg")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                
                                Text("(\(entry.bloodPressureCategory))")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(entry.bloodPressureCategoryColor.opacity(0.2))
                                    .foregroundColor(entry.bloodPressureCategoryColor)
                                    .cornerRadius(4)
                            }
                        }
                        if !entry.displayRestingHeartRate.isEmpty {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("HR: \(entry.displayRestingHeartRate) bpm")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                
                                Text("(\(entry.heartRateCategory))")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(entry.heartRateCategoryColor.opacity(0.2))
                                    .foregroundColor(entry.heartRateCategoryColor)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if entry.hasPhoto, let photo = entry.photo {
                    photo
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Edit Weight View
struct EditWeightView: View {
    @Environment(\.dismiss) private var dismiss
    let entry: WeightEntry
    @Binding var entries: [WeightEntry]
    
    @State private var date: Date
    @State private var weight: String
    @State private var notes: String
    @State private var systolicBP: String
    @State private var diastolicBP: String
    @State private var restingHeartRate: String
    
    init(entry: WeightEntry, entries: Binding<[WeightEntry]>) {
        self.entry = entry
        self._entries = entries
        self._date = State(initialValue: entry.date)
        self._weight = State(initialValue: String(format: "%.1f", entry.weight))
        self._notes = State(initialValue: entry.notes ?? "")
        self._systolicBP = State(initialValue: entry.systolicBP != nil && entry.systolicBP! > 0 ? String(format: "%.0f", entry.systolicBP!) : "")
        self._diastolicBP = State(initialValue: entry.diastolicBP != nil && entry.diastolicBP! > 0 ? String(format: "%.0f", entry.diastolicBP!) : "")
        self._restingHeartRate = State(initialValue: entry.restingHeartRate != nil && entry.restingHeartRate! > 0 ? String(format: "%.0f", entry.restingHeartRate!) : "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Info") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    HStack {
                        Text("Weight")
                        TextField("lbs", text: $weight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("🩺 Vital Signs") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Blood Pressure")
                            .font(.subheadline)
                        HStack {
                            TextField("120", text: $systolicBP)
                                .keyboardType(.numberPad)
                            Text("/")
                            TextField("80", text: $diastolicBP)
                                .keyboardType(.numberPad)
                            Text("mmHg")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Heart Rate")
                        TextField("72", text: $restingHeartRate)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("bpm")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveChanges() {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index].date = date
            if let weightValue = Double(weight) {
                entries[index].weight = weightValue
            }
            entries[index].notes = notes.isEmpty ? nil : notes
            entries[index].systolicBP = Double(systolicBP)
            entries[index].diastolicBP = Double(diastolicBP)
            entries[index].restingHeartRate = Double(restingHeartRate)
            entries.sort { $0.date > $1.date }
        }
        dismiss()
    }
}

// MARK: - Charts View
struct ChartsView: View {
    @Binding var entries: [WeightEntry]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if entries.isEmpty {
                        VStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("No data to display")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Add some weight entries to see charts!")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("📊 Weight Summary")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            let mostRecent = entries.sorted { $0.date > $1.date }.first
                            let earliest = entries.sorted { $0.date < $1.date }.first
                            
                            VStack(alignment: .leading, spacing: 8) {
                                if let current = mostRecent {
                                    Text("Current Weight: \(current.displayWeight) lbs")
                                        .fontWeight(.medium)
                                }
                                
                                if let start = earliest, let current = mostRecent {
                                    let change = current.weight - start.weight
                                    HStack {
                                        Text("Total Change:")
                                        Text("\(change >= 0 ? "+" : "")\(change, specifier: "%.1f") lbs")
                                            .fontWeight(.medium)
                                            .foregroundColor(change >= 0 ? .red : .green)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            if entries.contains(where: { $0.hasVitalSigns }) {
                                Divider()
                                
                                Text("🩺 Vital Signs Summary")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                if let mostRecent = mostRecent {
                                    VStack(alignment: .leading, spacing: 8) {
                                        if !mostRecent.displayBloodPressure.isEmpty {
                                            HStack {
                                                Text("Latest Blood Pressure:")
                                                Text(mostRecent.displayBloodPressure + " mmHg")
                                                    .fontWeight(.medium)
                                                Text("(\(mostRecent.bloodPressureCategory))")
                                                    .foregroundColor(mostRecent.bloodPressureCategoryColor)
                                            }
                                        }
                                        
                                        if !mostRecent.displayRestingHeartRate.isEmpty {
                                            HStack {
                                                Text("Latest Resting HR:")
                                                Text(mostRecent.displayRestingHeartRate + " bpm")
                                                    .fontWeight(.medium)
                                                Text("(\(mostRecent.heartRateCategory))")
                                                    .foregroundColor(mostRecent.heartRateCategoryColor)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.top)
                    }
                }
            }
            .navigationTitle("Charts & Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Camera View (FIXED)
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

// MARK: - Measurement Field Component
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

// MARK: - Date Formatter
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()
