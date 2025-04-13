import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = UserSettings.shared
    @State private var isShowingResetAlert = false
    
    // Local state to track slider values before committing
    @State private var highThreshold: Double = UserSettings.shared.highPriceThreshold
    @State private var lowThreshold: Double = UserSettings.shared.lowPriceThreshold
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Price Threshold Settings")) {
                    VStack(alignment: .leading) {
                        Text("High Price Threshold: \(String(format: "%.1f", highThreshold))¢")
                            .fontWeight(.medium)
                        
                        Slider(value: $highThreshold, in: 6...20, step: 0.5) { editing in
                            if !editing {
                                settings.highPriceThreshold = highThreshold
                            }
                        }
                        .accentColor(.red)
                        
                        Text("You'll be notified when the price exceeds this threshold")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading) {
                        Text("Low Price Threshold: \(String(format: "%.1f", lowThreshold))¢")
                            .fontWeight(.medium)
                        
                        Slider(value: $lowThreshold, in: 0...5, step: 0.5) { editing in
                            if !editing {
                                settings.lowPriceThreshold = lowThreshold
                            }
                        }
                        .accentColor(.green)
                        
                        Text("You'll be notified when the price drops below this threshold")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    Toggle("Negative Price Alerts", isOn: $settings.negativePriceAlerts)
                        .tint(.blue)
                }
                
                Section(header: Text("Notification Settings")) {
                    Toggle("Enable Notifications", isOn: $settings.notificationsEnabled)
                        .tint(.blue)
                    
                    if settings.notificationsEnabled {
                        HStack {
                            Text("Refresh Interval")
                            Spacer()
                            Picker("Refresh Interval", selection: $settings.refreshInterval) {
                                Text("5 minutes").tag(5)
                                Text("15 minutes").tag(15)
                                Text("30 minutes").tag(30)
                                Text("60 minutes").tag(60)
                            }
                            .pickerStyle(MenuPickerStyle())
                            .tint(.blue)
                        }
                    }
                }
                
                Section(header: Text("Widget Settings")) {
                    HStack {
                        Text("Widget Update Frequency")
                        Spacer()
                        Picker("Widget Update Frequency", selection: $settings.widgetUpdateFrequency) {
                            Text("15 minutes").tag(15)
                            Text("30 minutes").tag(30)
                            Text("60 minutes").tag(60)
                        }
                        .pickerStyle(MenuPickerStyle())
                        .tint(.blue)
                    }
                }
                
                Section {
                    Button(action: {
                        isShowingResetAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Reset to Default Settings")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://hourlypricing.comed.com/")!) {
                        HStack {
                            Text("ComEd Hourly Pricing")
                            Spacer()
                            Image(systemName: "link")
                        }
                    }
                    
                    ThresholdEditor()
                }
            }
            .navigationTitle("Settings")
            .alert(isPresented: $isShowingResetAlert) {
                Alert(
                    title: Text("Reset Settings"),
                    message: Text("Are you sure you want to reset all settings to default values?"),
                    primaryButton: .destructive(Text("Reset")) {
                        resetToDefaults()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func resetToDefaults() {
        settings.highPriceThreshold = 14.0
        settings.lowPriceThreshold = 2.0
        settings.negativePriceAlerts = true
        settings.notificationsEnabled = true
        settings.refreshInterval = 15
        settings.widgetUpdateFrequency = 30
        
        // Update local state
        highThreshold = settings.highPriceThreshold
        lowThreshold = settings.lowPriceThreshold
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
