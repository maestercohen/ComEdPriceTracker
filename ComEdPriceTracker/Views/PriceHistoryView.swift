import SwiftUI

struct PriceHistoryView: View {
    @StateObject private var priceDataStore = PriceDataStore()
    
    @State private var selectedTimeInterval: TimeInterval = .day
    
    var body: some View {
        NavigationView {
            VStack {
                // Time interval selector
                Picker("Time Interval", selection: $selectedTimeInterval) {
                    ForEach(TimeInterval.allCases, id: \.self) { interval in
                        Text(interval.rawValue).tag(interval)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Price chart
                PriceChart(
                    priceData: filteredPriceData,
                    highThreshold: 10.0,
                    lowThreshold: 2.0
                )
                .padding()
                
                // Stats section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Statistics")
                            .font(.headline)
                        Spacer()
                    }
                    
                    Divider()
                    
                    // Stats rows
                    StatRow(title: "Average", value: averagePrice)
                    StatRow(title: "Highest", value: highestPrice)
                    StatRow(title: "Lowest", value: lowestPrice)
                    StatRow(title: "Current", value: currentPrice)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
                
                // Loading indicator or refresh button
                if priceDataStore.isLoading {
                    ProgressView()
                        .padding()
                } else {
                    Button("Refresh Data") {
                        priceDataStore.fetchPriceHistory()
                    }
                    .padding()
                }
                
                // Error message
                if !priceDataStore.errorMessage.isEmpty {
                    Text(priceDataStore.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Price History")
            .onAppear {
                priceDataStore.fetchPriceHistory()
            }
        }
    }
    
    // Filter price data based on selected time interval
    private var filteredPriceData: [PricePoint] {
        let now = Date()
        
        return priceDataStore.priceHistory.filter { pricePoint in
            switch selectedTimeInterval {
            case .day:
                return pricePoint.timestamp > Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now
            case .week:
                return pricePoint.timestamp > Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
            case .month:
                return pricePoint.timestamp > Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
            }
        }
    }
    
    // Calculate average price
    private var averagePrice: Double {
        guard !filteredPriceData.isEmpty else { return 0.0 }
        let sum = filteredPriceData.reduce(0.0) { $0 + $1.price }
        return sum / Double(filteredPriceData.count)
    }
    
    // Calculate highest price
    private var highestPrice: Double {
        filteredPriceData.map { $0.price }.max() ?? 0.0
    }
    
    // Calculate lowest price
    private var lowestPrice: Double {
        filteredPriceData.map { $0.price }.min() ?? 0.0
    }
    
    // Get current price
    private var currentPrice: Double {
        filteredPriceData.last?.price ?? 0.0
    }
}

// Time interval enum
enum TimeInterval: String, CaseIterable {
    case day = "24h"
    case week = "Week"
    case month = "Month"
}

// Stats row component
struct StatRow: View {
    let title: String
    let value: Double
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text("\(String(format: "%.2f", value))¢")
                .fontWeight(.semibold)
        }
    }
}

struct PriceHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        PriceHistoryView()
    }
}