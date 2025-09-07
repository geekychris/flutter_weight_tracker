import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WeightEntry.date, ascending: false)],
        animation: .default)
    private var entries: FetchedResults<WeightEntry>
    
    @State private var selectedEntry: WeightEntry?
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var entryToDelete: WeightEntry?
    
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
                        ForEach(entries, id: \.id) { entry in
                            WeightEntryRow(entry: entry)
                                .contextMenu {
                                    Button("Edit") {
                                        selectedEntry = entry
                                        showingEditSheet = true
                                    }
                                    Button("Delete", role: .destructive) {
                                        entryToDelete = entry
                                        showingDeleteAlert = true
                                    }
                                }
                                .onTapGesture {
                                    selectedEntry = entry
                                    showingEditSheet = true
                                }
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    #if os(iOS)
                    .listStyle(.plain)
                    #endif
                }
            }
            .navigationTitle("Weight History")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
        .sheet(item: $selectedEntry) { entry in
            EditWeightView(entry: entry)
        }
        .alert("Delete Entry", isPresented: $showingDeleteAlert, presenting: entryToDelete) { entry in
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteEntry(entry)
            }
        } message: { entry in
            Text("Are you sure you want to delete this weight entry from \(entry.wrappedDate, formatter: dateFormatter)?")
        }
    }
    
    private func deleteEntries(offsets: IndexSet) {
        withAnimation {
            offsets.map { entries[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Handle error
                print("Error deleting entries: \(error)")
            }
        }
    }
    
    private func deleteEntry(_ entry: WeightEntry) {
        withAnimation {
            viewContext.delete(entry)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting entry: \(error)")
            }
        }
    }
}

struct WeightEntryRow: View {
    let entry: WeightEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.weight, specifier: "%.1f") lbs")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(entry.wrappedDate, formatter: dateFormatter)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if entry.hasMeasurements || !entry.wrappedNotes.isEmpty {
                    HStack {
                        if entry.hasMeasurements {
                            Image(systemName: "ruler")
                                .foregroundColor(.blue)
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
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Show weight change if there's a previous entry
                if let previousEntry = getPreviousEntry(for: entry) {
                    let change = entry.weight - previousEntry.weight
                    HStack {
                        Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                            .foregroundColor(change >= 0 ? .red : .green)
                        Text("\(abs(change), specifier: "%.1f")")
                            .foregroundColor(change >= 0 ? .red : .green)
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                }
                
                if entry.hasPhoto {
                    if let photo = entry.photo {
                        photo
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func getPreviousEntry(for entry: WeightEntry) -> WeightEntry? {
        // This is a simplified approach - in a real app you might want to use a more efficient method
        return nil // For now, weight change calculation is disabled
    }
}

struct EditWeightView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    let entry: WeightEntry
    
    @State private var date: Date
    @State private var weight: String
    @State private var bodyFat: String
    @State private var muscleMass: String
    @State private var waist: String
    @State private var chest: String
    @State private var arms: String
    @State private var hips: String
    @State private var legs: String
    @State private var neck: String
    @State private var notes: String
    @State private var photoImage: UIImage?
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(entry: WeightEntry) {
        self.entry = entry
        _date = State(initialValue: entry.wrappedDate)
        _weight = State(initialValue: String(format: "%.1f", entry.weight))
        _bodyFat = State(initialValue: entry.bodyFat > 0 ? String(format: "%.1f", entry.bodyFat) : "")
        _muscleMass = State(initialValue: entry.muscleMass > 0 ? String(format: "%.1f", entry.muscleMass) : "")
        _waist = State(initialValue: entry.waist > 0 ? String(format: "%.1f", entry.waist) : "")
        _chest = State(initialValue: entry.chest > 0 ? String(format: "%.1f", entry.chest) : "")
        _arms = State(initialValue: entry.arms > 0 ? String(format: "%.1f", entry.arms) : "")
        _hips = State(initialValue: entry.hips > 0 ? String(format: "%.1f", entry.hips) : "")
        _legs = State(initialValue: entry.legs > 0 ? String(format: "%.1f", entry.legs) : "")
        _neck = State(initialValue: entry.neck > 0 ? String(format: "%.1f", entry.neck) : "")
        _notes = State(initialValue: entry.wrappedNotes)
        
        if let photoData = entry.photoData, let image = UIImage(data: photoData) {
            _photoImage = State(initialValue: image)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Date picker
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding(.horizontal)
                    
                    // Weight
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Weight")
                            .font(.headline)
                        
                        HStack {
                            TextField("Enter weight", text: $weight)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                            Text("lbs")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Body measurements
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Body Measurements")
                            .font(.headline)
                        
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
                    
                    // Photo
                    if let photoImage = photoImage {
                        VStack(alignment: .leading) {
                            Text("Progress Photo")
                                .font(.headline)
                            
                            Image(uiImage: photoImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(.horizontal)
                    }
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notes")
                            .font(.headline)
                        
                        TextField("Notes", text: $notes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }
                    .padding(.horizontal)
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
        .alert("Entry Updated", isPresented: $showingAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveChanges() {
        guard let weightValue = Double(weight), weightValue > 0 else {
            alertMessage = "Please enter a valid weight"
            showingAlert = true
            return
        }
        
        entry.date = date
        entry.weight = weightValue
        entry.bodyFat = Double(bodyFat) ?? 0
        entry.muscleMass = Double(muscleMass) ?? 0
        entry.waist = Double(waist) ?? 0
        entry.chest = Double(chest) ?? 0
        entry.arms = Double(arms) ?? 0
        entry.hips = Double(hips) ?? 0
        entry.legs = Double(legs) ?? 0
        entry.neck = Double(neck) ?? 0
        entry.notes = notes
        
        do {
            try viewContext.save()
            alertMessage = "Entry updated successfully!"
            showingAlert = true
        } catch {
            alertMessage = "Error updating entry: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

#Preview {
    HistoryView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
