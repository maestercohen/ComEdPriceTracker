import SwiftUI

struct SettingsView: View {
    @StateObject private var userSettings = UserSettings()
    @State private var notificationPermissionGranted = false
    
    var body: some View {
        NavigationView {
            Form {
                // Price thresholds section
                Section(header: Text("Price Thresholds")) {
                    ThresholdEditor(
                        threshold: $userSettings.highPriceThreshold,
                        title: "High Price Threshold",
                        description: "Get notified when price exceeds this value",
                        iconName: "arrow.up.circle.fill",
                        color: .red
                    )
                    
                    ThresholdEditor(
                        threshold: $userSettings.lowPriceThreshold,
                        title: "Low Price Threshold",
                        description: "Get notified when price falls below this value",
                        iconName: "arrow.down.circle.fill",
                        color: .green
                    )
                }
                
                // Notification settings section
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $userSettings.notificationsEnabled)
                        .onChange(of: userSettings.notificationsEnabled) { enabled in
                            if enabled {
                                requestNotificationPermission()
                            }
                        }
                    
                    if !notificationPermissionGranted && userSettings.notificationsEnabled {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text("Notification permission required")
                                .font(.footnote)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // Refresh interval section
                Section(header: Text("Refresh Interval")) {
                    Picker("Auto-refresh every", selection: $userSettings.refreshInterval) {
                        Text("5 minutes").tag(5)
                        Text("15 minutes").tag(15)
                        Text("30 minutes").tag(30)
                        Text("1 hour").tag(60)
                    }
                    .pickerStyle(DefaultPickerStyle())
                }
                
                // About section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Data Source")
                        Spacer()
                        Text("ComEd Hourly Pricing")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://hourlypricing.comed.com/live-prices/")!) {
                        HStack {
                            Text("Visit ComEd Pricing Website")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                    }
                }
                
                // Reset button section
                Section {
                    Button("Reset All Settings") {
                        userSettings.resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                checkNotificationPermission()
            }
        }
    }
    
    // Check notification permission status
    private func checkNotificationPermission() {
        NotificationService.shared.checkAuthorizationStatus { granted in
            notificationPermissionGranted = granted
            
            // If notifications are enabled but permission not granted, update the setting
            if userSettings.notificationsEnabled && !granted {
                userSettings.notificationsEnabled = false
            }
        }
    }
    
    // Request notification permission
    private func requestNotificationPermission() {
        NotificationService.shared.requestAuthorization { granted in
            notificationPermissionGranted = granted
            
            // If permission not granted, update the setting
            if !granted {
                userSettings.notificationsEnabled = false
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}