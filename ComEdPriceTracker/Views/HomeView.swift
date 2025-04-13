import SwiftUI

struct HomeView: View {
    @StateObject private var priceDataStore = PriceDataStore()
    @StateObject private var userSettings = UserSettings()
    
    // Timer for auto-refresh
    @State private var timer: Timer?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Price display component
                PriceDisplay(price: priceDataStore.currentPrice, 
                           highThreshold: userSettings.highPriceThreshold,
                           lowThreshold: userSettings.lowPriceThreshold)
                    .padding()
                
                VStack(alignment: .leading) {
                    // Alert status
                    if priceDataStore.currentPrice >= userSettings.highPriceThreshold {
                        AlertBanner(message: "Price is above your high threshold!", type: .high)
                    } else if priceDataStore.currentPrice <= userSettings.lowPriceThreshold {
                        AlertBanner(message: "Price is below your low threshold!", type: .low)
                    }
                    
                    // Last updated time
                    HStack {
                        Text("Last updated:")
                            .font(.footnote)
                        Text(Date(), style: .time)
                            .font(.footnote)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.top, 5)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Manual refresh button
                Button(action: {
                    refreshData()
                }) {
                    Label("Refresh Price", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding()
                .disabled(priceDataStore.isLoading)
                
                // Loading indicator
                if priceDataStore.isLoading {
                    ProgressView()
                }
                
                // Error message display
                if !priceDataStore.errorMessage.isEmpty {
                    Text(priceDataStore.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Current Price")
            .onAppear {
                refreshData()
                startAutoRefresh()
            }
            .onDisappear {
                stopAutoRefresh()
            }
        }
    }
    
    // Refresh data method
    private func refreshData() {
        priceDataStore.fetchCurrentPrice()
        checkPriceThresholds()
    }
    
    // Start auto-refresh timer
    private func startAutoRefresh() {
        stopAutoRefresh() // Stop any existing timer
        
        let refreshSeconds = Double(userSettings.refreshInterval) * 60
        timer = Timer.scheduledTimer(withTimeInterval: refreshSeconds, repeats: true) { _ in
            refreshData()
        }
    }
    
    // Stop auto-refresh timer
    private func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
    }
    
    // Check and send notifications based on thresholds
    private func checkPriceThresholds() {
        guard userSettings.notificationsEnabled else { return }
        
        if priceDataStore.currentPrice >= userSettings.highPriceThreshold {
            NotificationService.shared.schedulePriceAlert(for: .high, price: priceDataStore.currentPrice)
        } else if priceDataStore.currentPrice <= userSettings.lowPriceThreshold {
            NotificationService.shared.schedulePriceAlert(for: .low, price: priceDataStore.currentPrice)
        }
    }
}

// Alert banner component
struct AlertBanner: View {
    let message: String
    let type: PriceAlertType
    
    var body: some View {
        HStack {
            Image(systemName: type == .high ? "exclamationmark.triangle" : "checkmark.circle")
            Text(message)
                .font(.headline)
            Spacer()
        }
        .padding()
        .background(type == .high ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
        .foregroundColor(type == .high ? .red : .green)
        .cornerRadius(8)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}