import SwiftUI

struct ThresholdEditor: View {
    @ObservedObject private var settings = UserSettings.shared
    @State private var isManualEntrySheetPresented = false
    
    var body: some View {
        Button(action: {
            isManualEntrySheetPresented = true
        }) {
            HStack {
                Text("Manual Threshold Entry")
                Spacer()
                Image(systemName: "pencil")
            }
        }
        .sheet(isPresented: $isManualEntrySheetPresented) {
            ManualThresholdEntryView(isPresented: $isManualEntrySheetPresented)
        }
    }
}

struct ManualThresholdEntryView: View {
    @Binding var isPresented: Bool
    @ObservedObject private var settings = UserSettings.shared
    @State private var highThresholdString: String = ""
    @State private var lowThresholdString: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter Price Thresholds")) {
                    TextField("High Price Threshold (cents)", text: $highThresholdString)
                        .keyboardType(.decimalPad)
                    
                    TextField("Low Price Threshold (cents)", text: $lowThresholdString)
                        .keyboardType(.decimalPad)
                }
                
                Section(footer: Text("Enter the price thresholds in cents per kWh (e.g., '14.0' for 14 cents).")) {
                    Button("Save Thresholds") {
                        saveThresholds()
                    }
                }
            }
            .navigationTitle("Threshold Settings")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
            .onAppear {
                highThresholdString = String(format: "%.1f", settings.highPriceThreshold)
                lowThresholdString = String(format: "%.1f", settings.lowPriceThreshold)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invalid Input"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func saveThresholds() {
        // Validate high threshold
        guard let highThreshold = Double(highThresholdString.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "High price threshold must be a valid number."
            showAlert = true
            return
        }
        
        // Validate low threshold
        guard let lowThreshold = Double(lowThresholdString.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "Low price threshold must be a valid number."
            showAlert = true
            return
        }
        
        // Validate ranges
        if highThreshold < 6.0 || highThreshold > 20.0 {
            alertMessage = "High price threshold must be between 6.0 and 20.0 cents."
            showAlert = true
            return
        }
        
        if lowThreshold < 0.0 || lowThreshold > 5.0 {
            alertMessage = "Low price threshold must be between 0.0 and 5.0 cents."
            showAlert = true
            return
        }
        
        if lowThreshold >= highThreshold {
            alertMessage = "Low price threshold must be less than high price threshold."
            showAlert = true
            return
        }
        
        // Save valid thresholds
        settings.highPriceThreshold = highThreshold
        settings.lowPriceThreshold = lowThreshold
        isPresented = false
    }
}

struct ThresholdEditor_Previews: PreviewProvider {
    static var previews: some View {
        ThresholdEditor()
    }
}
