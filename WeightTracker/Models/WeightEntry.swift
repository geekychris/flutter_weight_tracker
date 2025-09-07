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
    
    // Helper method to check if measurements exist
    var hasMeasurements: Bool {
        return bodyFat > 0 || muscleMass > 0 || waist > 0 || chest > 0 || arms > 0 || hips > 0 || legs > 0 || neck > 0
    }
}
