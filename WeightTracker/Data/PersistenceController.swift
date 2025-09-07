import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Add sample data for previews
        let sampleEntry = WeightEntry(context: viewContext)
        sampleEntry.id = UUID()
        sampleEntry.date = Date()
        sampleEntry.weight = 175.5
        sampleEntry.bodyFat = 15.2
        sampleEntry.muscleMass = 145.0
        sampleEntry.waist = 32.0
        sampleEntry.chest = 42.0
        sampleEntry.arms = 15.5
        sampleEntry.notes = "Feeling great today!"
        
        let sampleEntry2 = WeightEntry(context: viewContext)
        sampleEntry2.id = UUID()
        sampleEntry2.date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        sampleEntry2.weight = 177.2
        sampleEntry2.bodyFat = 15.8
        sampleEntry2.muscleMass = 144.2
        sampleEntry2.waist = 32.5
        sampleEntry2.chest = 41.8
        sampleEntry2.arms = 15.2
        sampleEntry2.notes = "Started new workout routine"
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DataModel")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
