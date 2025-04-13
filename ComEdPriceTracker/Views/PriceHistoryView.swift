import SwiftUI
import Charts

struct PriceHistoryView: View {
    @StateObject private var priceDataModel = PriceDataModel()
    @State private var selectedTimeframe: Timeframe = .day
    @State private var selectedDate: Date = Date()
    
    enum Timeframe: String, CaseIterable, Identifiable {
        case day = "Day"
        case week = "Week"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Timeframe selector
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(Timeframe.allCases) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: selectedTimeframe) { newValue in
                    if newValue == .week && priceDataModel.weeklyPrices.isEmpty {
                        priceDataModel.fetchWeeklyPrices()
                    }
                }
                
                ScrollView {
                    VStack(spacing: 16) {
                        if selectedTimeframe == .day {
                            // Day view
                            VStack(alignment: .leading) {
                                Text("Today's Hourly Prices")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                if priceDataModel.todayPrices.isEmpty {
                                    Text("No hourly price data available")
                                        .foregroundColor(.secondary)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                } else {
                                    // Price stat summary
                                    HStack(spacing: 20) {
                                        VStack {
                                            Text("Low")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text(String(format: "%.1f¢", priceDataModel.todayPrices.map { $0.price }.min() ?? 0))
                                                .foregroundColor(.green)
                                                .font(.headline)
                                        }
                                        
                                        VStack {
                                            Text("Average")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text(String(format: "%.1f¢", priceDataModel.todayPrices.map { $0.price }.reduce(0, +) / Double(priceDataModel.todayPrices.count)))
                                                .foregroundColor(.blue)
                                                .font(.headline)
                                        }
                                        
                                        VStack {
                                            Text("High")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text(String(format: "%.1f¢", priceDataModel.todayPrices.map { $0.price }.max() ?? 0))
                                                .foregroundColor(.red)
                                                .font(.headline)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                    
                                    // Hourly chart
                                    PriceChart(prices: priceDataModel.todayPrices)
                                        .frame(height: 250)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                            
                            // 5-minute price detail
                            VStack(alignment: .leading) {
                                Text("Recent 5-Minute Prices")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                if priceDataModel.fiveMinutePrices.isEmpty {
                                    Text("No 5-minute price data available")
                                        .foregroundColor(.secondary)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                } else {
                                    // Price chart for 5-minute intervals
                                    Chart {
                                        ForEach(priceDataModel.fiveMinutePrices.prefix(12)) { pricePoint in
                                            LineMark(
                                                x: .value("Time", pricePoint.timestamp),
                                                y: .value("Price", pricePoint.price)
                                            )
                                            .foregroundStyle(Color.blue)
                                            
                                            PointMark(
                                                x: .value("Time", pricePoint.timestamp),
                                                y: .value("Price", pricePoint.price)
                                            )
                                            .foregroundStyle(Color.blue)
                                        }
                                    }
                                    .chartYScale(domain: [
                                        min(0, (priceDataModel.fiveMinutePrices.map { $0.price }.min() ?? 0) - 1),
                                        max(5, (priceDataModel.fiveMinutePrices.map { $0.price }.max() ?? 5) + 1)
                                    ])
                                    .chartXAxis {
                                        AxisMarks(values: .stride(by: .minute, count: 15)) { _ in
                                            AxisGridLine()
                                            AxisTick()
                                            AxisValueLabel(format: .dateTime.hour().minute())
                                        }
                                    }
                                    .frame(height: 200)
                                    .padding(.horizontal)
                                    
                                    // Recent prices list
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Recent Readings")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        ForEach(priceDataModel.fiveMinutePrices.prefix(6)) { pricePoint in
                                            HStack {
                                                Text(formatTime(pricePoint.timestamp))
                                                    .foregroundColor(.secondary)
                                                
                                                Spacer()
                                                
                                                Text(String(format: "%.1f¢", pricePoint.price))
                                                    .foregroundColor(getPriceColor(pricePoint.price))
                                                    .fontWeight(.medium)
                                            }
                                            .padding(.vertical, 4)
                                            
                                            if pricePoint.id != priceDataModel.fiveMinutePrices.prefix(6).last?.id {
                                                Divider()
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                            
                        } else {
                            // Week view
                            if priceDataModel.weeklyPrices.isEmpty {
                                VStack {
                                    if priceDataModel.isLoading {
                                        ProgressView()
                                            .padding()
                                        Text("Loading weekly data...")
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("No weekly price data available")
                                            .foregroundColor(.secondary)
                                            .padding()
                                    }
                                }
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(radius: 2)
                                .padding(.horizontal)
                            } else {
                                // Weekly average chart
                                VStack(alignment: .leading) {
                                    Text("Weekly Average Prices")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    Chart {
                                        ForEach(priceDataModel.weeklyPrices, id: \.date) { dailyData in
                                            BarMark(
                                                x: .value("Date", dailyData.date, unit: .day),
                                                y: .value("Average Price", dailyData.averagePrice)
                                            )
                                            .foregroundStyle(Color.blue)
                                        }
                                    }
                                    .chartXAxis {
                                        AxisMarks(values: .stride(by: .day)) { value in
                                            if let date = value.as(Date.self) {
                                                AxisValueLabel {
                                                    Text(formatDay(date))
                                                }
                                            }
                                        }
                                    }
                                    .frame(height: 200)
                                    .padding(.horizontal)
                                }
                                .padding(.vertical)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(radius: 2)
                                .padding(.horizontal)
                                
                                // Weekly high/low chart
                                VStack(alignment: .leading) {
                                    Text("Weekly Price Range")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    Chart {
                                        ForEach(priceDataModel.weeklyPrices, id: \.date) { dailyData in
                                            RectangleMark(
                                                x: .value("Date", dailyData.date, unit: .day),
                                                yStart: .value("Min Price", dailyData.minPrice),
                                                yEnd: .value("Max Price", dailyData.maxPrice),
                                                width: 20
                                            )
                                            .foregroundStyle(
                                                .linearGradient(
                                                    colors: [.green, .yellow, .red],
                                                    startPoint: .bottom,
                                                    endPoint: .top
                                                )
                                            )
                                        }
                                    }
                                    .chartXAxis {
                                        AxisMarks(values: .stride(by: .day)) { value in
                                            if let date = value.as(Date.self) {
                                                AxisValueLabel {
                                                    Text(formatDay(date))
                                                }
                                            }
                                        }
                                    }
                                    .frame(height: 200)
                                    .padding(.horizontal)
                                }
                                .padding(.vertical)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(radius: 2)
                                .padding(.horizontal)
                                
                                // Weekly stats summary
                                VStack(alignment: .leading) {
                                    Text("Weekly Statistics")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    // Weekly stat summary
                                    VStack(spacing: 12) {
                                        ForEach(priceDataModel.weeklyPrices.prefix(7), id: \.date) { dailyData in
                                            VStack(spacing: 8) {
                                                HStack {
                                                    Text(formatDate(dailyData.date))
                                                        .fontWeight(.medium)
                                                    
                                                    Spacer()
                                                    
                                                    Text("Avg: \(String(format: "%.1f¢", dailyData.averagePrice))")
                                                        .foregroundColor(.blue)
                                                        .fontWeight(.medium)
                                                }
                                                
                                                HStack {
                                                    Text("Low: \(String(format: "%.1f¢", dailyData.minPrice))")
                                                        .foregroundColor(.green)
                                                    
                                                    Spacer()
                                                    
                                                    Text("High: \(String(format: "%.1f¢", dailyData.maxPrice))")
                                                        .foregroundColor(.red)
                                                }
                                                .font(.subheadline)
                                            }
                                            .padding(.vertical, 8)
                                            
                                            if dailyData.date != priceDataModel.weeklyPrices.prefix(7).last?.date {
                                                Divider()
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                }
                                .padding(.vertical)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(radius: 2)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Price History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if selectedTimeframe == .day {
                            priceDataModel.fetchTodayPrices()
                            priceDataModel.fetchFiveMinutePrices()
                        } else {
                            priceDataModel.fetchWeeklyPrices()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                if priceDataModel.todayPrices.isEmpty {
                    priceDataModel.fetchTodayPrices()
                }
                
                if priceDataModel.fiveMinutePrices.isEmpty {
                    priceDataModel.fetchFiveMinutePrices()
                }
            }
        }
    }
    
    // Helper functions
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: date)
    }
    
    private func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    private func getPriceColor(_ price: Double) -> Color {
        if price < 0 {
            return .green
        } else if price < 5.0 {
            return .green
        } else if price < 14.0 {
            return .yellow
        } else {
            return .red
        }
    }
}

struct PriceHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        PriceHistoryView()
    }
}
