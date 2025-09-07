import SwiftUI
import CoreData
import Charts

struct ChartsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WeightEntry.date, ascending: true)],
        animation: .default)
    private var entries: FetchedResults<WeightEntry>
    
    @State private var selectedTimeRange: TimeRange = .month
    @State private var selectedMeasurement: MeasurementType = .weight
    
    enum TimeRange: String, CaseIterable {
        case week = "1W"
        case month = "1M"
        case threeMonths = "3M"
        case sixMonths = "6M"
        case year = "1Y"
        case all = "All"
        
        var displayName: String {
            switch self {
            case .week: return "1 Week"
            case .month: return "1 Month"
            case .threeMonths: return "3 Months"
            case .sixMonths: return "6 Months"
            case .year: return "1 Year"
            case .all: return "All Time"
            }
        }
        
        var daysPast: Int? {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            case .sixMonths: return 180
            case .year: return 365
            case .all: return nil
            }
        }
    }
    
    enum MeasurementType: String, CaseIterable {
        case weight = "Weight"
        case bodyFat = "Body Fat %"
        case muscleMass = "Muscle Mass"
        case waist = "Waist"
        case chest = "Chest"
        case arms = "Arms"
        
        var unit: String {
            switch self {
            case .weight, .muscleMass: return "lbs"
            case .bodyFat: return "%"
            case .waist, .chest, .arms: return "in"
            }
        }
        
        func getValue(from entry: WeightEntry) -> Double {
            switch self {
            case .weight: return entry.weight
            case .bodyFat: return entry.bodyFat
            case .muscleMass: return entry.muscleMass
            case .waist: return entry.waist
            case .chest: return entry.chest
            case .arms: return entry.arms
            }
        }
    }
    
    var filteredEntries: [WeightEntry] {
        let allEntries = Array(entries)
        
        guard let daysPast = selectedTimeRange.daysPast else {
            return allEntries
        }
        
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -daysPast, to: Date()) ?? Date()
        return allEntries.filter { $0.wrappedDate >= cutoffDate }
    }
    
    var chartData: [ChartDataPoint] {
        return filteredEntries.compactMap { entry in
            let value = selectedMeasurement.getValue(from: entry)
            guard value > 0 else { return nil }
            return ChartDataPoint(date: entry.wrappedDate, value: value)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if entries.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("No data to display")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Add some weight entries to see your progress charts!")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 100)
                    } else {
                        // Time range picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Time Range")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(TimeRange.allCases, id: \.self) { range in
                                        Button(range.displayName) {
                                            selectedTimeRange = range
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .controlSize(.small)
                                        .disabled(selectedTimeRange == range)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Measurement type picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Measurement")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Picker("Measurement Type", selection: $selectedMeasurement) {
                                ForEach(MeasurementType.allCases, id: \.self) { measurement in
                                    Text(measurement.rawValue).tag(measurement)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                        }
                        
                        // Chart
                        if !chartData.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("\(selectedMeasurement.rawValue) Over Time")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                Chart(chartData, id: \.date) { dataPoint in
                                    LineMark(
                                        x: .value("Date", dataPoint.date),
                                        y: .value(selectedMeasurement.rawValue, dataPoint.value)
                                    )
                                    .foregroundStyle(.blue)
                                    .lineStyle(StrokeStyle(lineWidth: 2))
                                    
                                    PointMark(
                                        x: .value("Date", dataPoint.date),
                                        y: .value(selectedMeasurement.rawValue, dataPoint.value)
                                    )
                                    .foregroundStyle(.blue)
                                    .symbolSize(30)
                                }
                                .frame(height: 300)
                                .padding(.horizontal)
                                .chartYAxisLabel(selectedMeasurement.unit, position: .leading)
                                .chartXAxisLabel("Date", position: .bottom)
                            }
                            .padding(.vertical)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(radius: 2)
                            )
                            .padding(.horizontal)
                            
                            // Statistics
                            if let stats = calculateStatistics() {
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Statistics")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    LazyVGrid(columns: [
                                        GridItem(.flexible()),
                                        GridItem(.flexible()),
                                        GridItem(.flexible())
                                    ], spacing: 15) {
                                        StatCard(title: "Current", value: stats.current, unit: selectedMeasurement.unit)
                                        StatCard(title: "Average", value: stats.average, unit: selectedMeasurement.unit)
                                        StatCard(title: "Change", value: stats.change, unit: selectedMeasurement.unit, showSign: true)
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.vertical)
                            }
                        } else {
                            VStack(spacing: 15) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange)
                                Text("No data for \(selectedMeasurement.rawValue)")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("This measurement hasn't been recorded in the selected time range.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 50)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Progress Charts")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
    
    private func calculateStatistics() -> Statistics? {
        guard !chartData.isEmpty else { return nil }
        
        let values = chartData.map { $0.value }
        let current = values.last ?? 0
        let average = values.reduce(0, +) / Double(values.count)
        let first = values.first ?? 0
        let change = current - first
        
        return Statistics(current: current, average: average, change: change)
    }
}

struct ChartDataPoint {
    let date: Date
    let value: Double
}

struct Statistics {
    let current: Double
    let average: Double
    let change: Double
}

struct StatCard: View {
    let title: String
    let value: Double
    let unit: String
    let showSign: Bool
    
    init(title: String, value: Double, unit: String, showSign: Bool = false) {
        self.title = title
        self.value = value
        self.unit = unit
        self.showSign = showSign
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if showSign {
                HStack(spacing: 2) {
                    Image(systemName: value >= 0 ? "arrow.up" : "arrow.down")
                        .foregroundColor(value >= 0 ? .red : .green)
                        .font(.caption)
                    Text("\(abs(value), specifier: "%.1f")")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(value >= 0 ? .red : .green)
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                HStack(spacing: 2) {
                    Text("\(value, specifier: "%.1f")")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    ChartsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
