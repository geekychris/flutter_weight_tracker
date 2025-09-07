import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView {
            #if os(iOS)
            AddWeightView()
                .tabItem {
                    Label("Add Entry", systemImage: "plus.circle")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }
            
            ChartsView()
                .tabItem {
                    Label("Charts", systemImage: "chart.line.uptrend.xyaxis")
                }
            #else
            // macOS layout with sidebar navigation
            NavigationSplitView {
                List {
                    NavigationLink("Add Entry", destination: AddWeightView())
                        .tag("add")
                    NavigationLink("History", destination: HistoryView())
                        .tag("history")
                    NavigationLink("Charts", destination: ChartsView())
                        .tag("charts")
                }
                .navigationTitle("Weight Tracker")
            } detail: {
                AddWeightView()
            }
            #endif
        }
        #if os(iOS)
        .accentColor(.blue)
        #endif
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
