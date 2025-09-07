import Foundation
import CoreData
import SwiftUI

extension WeightEntry {
    
    var wrappedDate: Date {
        date ?? Date()
    }
    
    var wrappedNotes: String {
        notes ?? ""
    }
    
    var hasPhoto: Bool {
        photoData != nil
    }
    
    var photo: Image? {
        guard let photoData = photoData,
              let uiImage = UIImage(data: photoData) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
    
    func setPhoto(_ image: UIImage) {
        photoData = image.jpegData(compressionQuality: 0.8)
    }
    
    // Computed properties for measurements that might be zero
    var displayWeight: String {
        weight > 0 ? String(format: "%.1f", weight) : ""
    }
    
    var displayBodyFat: String {
        bodyFat > 0 ? String(format: "%.1f", bodyFat) : ""
    }
    
    var displayMuscleMass: String {
        muscleMass > 0 ? String(format: "%.1f", muscleMass) : ""
    }
    
    var displayWaist: String {
        waist > 0 ? String(format: "%.1f", waist) : ""
    }
    
    var displayChest: String {
        chest > 0 ? String(format: "%.1f", chest) : ""
    }
    
    var displayArms: String {
        arms > 0 ? String(format: "%.1f", arms) : ""
    }
    
    var displayHips: String {
        hips > 0 ? String(format: "%.1f", hips) : ""
    }
    
    var displayLegs: String {
        legs > 0 ? String(format: "%.1f", legs) : ""
    }
    
    var displayNeck: String {
        neck > 0 ? String(format: "%.1f", neck) : ""
    }
    
    // Blood pressure and heart rate display properties
    var displaySystolic: String {
        systolicBP > 0 ? String(format: "%.0f", systolicBP) : ""
    }
    
    var displayDiastolic: String {
        diastolicBP > 0 ? String(format: "%.0f", diastolicBP) : ""
    }
    
    var displayBloodPressure: String {
        if systolicBP > 0 && diastolicBP > 0 {
            return String(format: "%.0f/%.0f", systolicBP, diastolicBP)
        } else if systolicBP > 0 {
            return String(format: "%.0f/-", systolicBP)
        } else if diastolicBP > 0 {
            return String(format: "-/%.0f", diastolicBP)
        }
        return ""
    }
    
    var displayRestingHeartRate: String {
        restingHeartRate > 0 ? String(format: "%.0f", restingHeartRate) : ""
    }
    
    // Helper method to check if measurements exist
    var hasMeasurements: Bool {
        return bodyFat > 0 || muscleMass > 0 || waist > 0 || chest > 0 || arms > 0 || hips > 0 || legs > 0 || neck > 0
    }
    
    // Helper method to check if vital signs exist
    var hasVitalSigns: Bool {
        return systolicBP > 0 || diastolicBP > 0 || restingHeartRate > 0
    }
    
    // Blood pressure category helper
    var bloodPressureCategory: String {
        guard systolicBP > 0 && diastolicBP > 0 else { return "" }
        
        if systolicBP < 120 && diastolicBP < 80 {
            return "Normal"
        } else if systolicBP < 130 && diastolicBP < 80 {
            return "Elevated"
        } else if (systolicBP >= 130 && systolicBP < 140) || (diastolicBP >= 80 && diastolicBP < 90) {
            return "Stage 1 High"
        } else if systolicBP >= 140 || diastolicBP >= 90 {
            return "Stage 2 High"
        } else {
            return "Check with doctor"
        }
    }
    
    // Heart rate category helper
    var heartRateCategory: String {
        guard restingHeartRate > 0 else { return "" }
        
        if restingHeartRate < 60 {
            return "Low (Bradycardia)"
        } else if restingHeartRate <= 100 {
            return "Normal"
        } else {
            return "High (Tachycardia)"
        }
    }
}
