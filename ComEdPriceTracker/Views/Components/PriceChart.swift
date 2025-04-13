import SwiftUI
import Charts

struct PriceChart: View {
    let prices: [HourlyPrice]
    @Environment(\.colorScheme) var colorScheme
    
    private var priceRange: (min: Double, max: Double) {
        let priceValues = prices.map { $0.price }
        let minPrice = priceValues.min() ?? 0
        let maxPrice = priceValues.max() ?? 0
        
        // Ensure there's always some vertical space in the chart
        return (min: min(0, minPrice - 1), max: max(5, maxPrice + 1))
    }
    
    var body: some View {
        Chart {
            ForEach(prices) { hourlyPrice in
                BarMark(
                    x: .value("Hour", hourlyPrice.formattedHour),
                    y: .value("Price", hourlyPrice.price)
                )
                .foregroundStyle(getBarColor(hourlyPrice.price))
                .annotation(position: .top) {
                    if hourlyPrice.price < 0 || hourlyPrice.price > 10 {
                        Text("\(String(format: "%.1f", hourlyPrice.price))")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            RuleMark(y: .value("Low Price Threshold", UserSettings.shared.lowPriceThreshold))
                .foregroundStyle(.green.opacity(0.7))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .annotation(position: .trailing) {
                    Text("Low")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            
            RuleMark(y: .value("High Price Threshold", UserSettings.shared.highPriceThreshold))
                .foregroundStyle(.red.opacity(0.7))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .annotation(position: .trailing) {
                    Text("High")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
        }
        .chartYScale(domain: priceRange.min...priceRange.max)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 12)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text("\(String(format: "%.1f¢", doubleValue))")
                    }
                }
            }
        }
    }
    
    private func getBarColor(_ price: Double) -> Color {
        if price < 0 {
            return .green
        } else if price < UserSettings.shared.lowPriceThreshold {
            return .green
        } else if price < UserSettings.shared.highPriceThreshold {
            return .yellow
        } else {
            return .red
        }
    }
}

struct PriceChart_Previews: PreviewProvider {
    static var previews: some View {
        // Create sample data for preview
        let sampleData: [HourlyPrice] = [
            HourlyPrice(price: 1.5, hour: 0, date: Date()),
            HourlyPrice(price: 2.3, hour: 1, date: Date()),
            HourlyPrice(price: -0.5, hour: 2, date: Date()),
            HourlyPrice(price: 0.7, hour: 3, date: Date()),
            HourlyPrice(price: 1.2, hour: 4, date: Date()),
            HourlyPrice(price: 3.5, hour: 5, date: Date()),
            HourlyPrice(price: 6.8, hour: 6, date: Date()),
            HourlyPrice(price: 8.3, hour: 7, date: Date()),
            HourlyPrice(price: 10.1, hour: 8, date: Date()),
            HourlyPrice(price: 12.5, hour: 9, date: Date()),
            HourlyPrice(price: 15.3, hour: 10, date: Date()),
            HourlyPrice(price: 14.7, hour: 11, date: Date()),
            HourlyPrice(price: 10.2, hour: 12, date: Date()),
            HourlyPrice(price: 8.5, hour: 13, date: Date()),
            HourlyPrice(price: 7.2, hour: 14, date: Date()),
            HourlyPrice(price: 5.8, hour: 15, date: Date()),
            HourlyPrice(price: 4.3, hour: 16, date: Date()),
            HourlyPrice(price: 3.9, hour: 17, date: Date()),
            HourlyPrice(price: 6.7, hour: 18, date: Date()),
            HourlyPrice(price: 9.8, hour: 19, date: Date()),
            HourlyPrice(price: 8.6, hour: 20, date: Date()),
            HourlyPrice(price: 5.3, hour: 21, date: Date()),
            HourlyPrice(price: 2.4, hour: 22, date: Date()),
            HourlyPrice(price: 1.1, hour: 23, date: Date())
        ]
        
        return PriceChart(prices: sampleData)
            .frame(height: 250)
            .padding()
    }
}
