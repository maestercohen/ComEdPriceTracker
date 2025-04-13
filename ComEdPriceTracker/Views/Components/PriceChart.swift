import SwiftUI

struct PriceChart: View {
    let priceData: [PricePoint]
    let highThreshold: Double
    let lowThreshold: Double
    
    @State private var selectedPoint: PricePoint?
    
    private var maxPrice: Double {
        let maxDataPrice = priceData.map { $0.price }.max() ?? 0
        return max(maxDataPrice, highThreshold) * 1.1 // 10% margin above max
    }
    
    private var minPrice: Double {
        let minDataPrice = priceData.map { $0.price }.min() ?? 0
        return min(minDataPrice, lowThreshold) * 0.9 // 10% margin below min
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    // Draw chart grid lines
                    VStack(alignment: .leading) {
                        ForEach(0..<5) { i in
                            Divider()
                            Spacer()
                                .frame(maxHeight: .infinity)
                        }
                        Divider()
                    }
                    
                    // High price threshold line
                    if highThreshold > 0 {
                        ThresholdLine(
                            threshold: highThreshold,
                            minPrice: minPrice,
                            maxPrice: maxPrice,
                            width: geometry.size.width,
                            height: geometry.size.height,
                            color: .red
                        )
                    }
                    
                    // Low price threshold line
                    if lowThreshold > 0 {
                        ThresholdLine(
                            threshold: lowThreshold,
                            minPrice: minPrice,
                            maxPrice: maxPrice,
                            width: geometry.size.width,
                            height: geometry.size.height,
                            color: .green
                        )
                    }
                    
                    // Price data points
                    if priceData.count > 1 {
                        // Path for the price line
                        Path { path in
                            let xStep = geometry.size.width / CGFloat(priceData.count - 1)
                            
                            guard let firstPoint = priceData.first else { return }
                            let y = yPosition(for: firstPoint.price, in: geometry.size.height)
                            path.move(to: CGPoint(x: 0, y: y))
                            
                            for (index, point) in priceData.dropFirst().enumerated() {
                                let x = xStep * CGFloat(index + 1)
                                let y = yPosition(for: point.price, in: geometry.size.height)
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                        .stroke(Color.blue, lineWidth: 2)
                        
                        // Draw data points
                        ForEach(0..<priceData.count, id: \.self) { index in
                            let point = priceData[index]
                            let xStep = geometry.size.width / CGFloat(priceData.count - 1)
                            let x = xStep * CGFloat(index)
                            let y = yPosition(for: point.price, in: geometry.size.height)
                            
                            Circle()
                                .fill(circleColor(for: point.price))
                                .frame(width: 6, height: 6)
                                .position(x: x, y: y)
                                .onTapGesture {
                                    selectedPoint = point
                                }
                        }
                    }
                    
                    // Show selected point info
                    if selectedPoint != nil {
                        // Safely unwrap the optional
                        let point = selectedPoint!
                        let index = priceData.firstIndex(where: { $0.id == point.id }) ?? 0
                        let xStep = geometry.size.width / CGFloat(priceData.count - 1)
                        let x = xStep * CGFloat(index)
                        let y = yPosition(for: point.price, in: geometry.size.height)
                        
                        // Highlight selected point
                        Circle()
                            .fill(Color.white)
                            .frame(width: 12, height: 12)
                            .position(x: x, y: y)
                        
                        Circle()
                            .fill(circleColor(for: point.price))
                            .frame(width: 8, height: 8)
                            .position(x: x, y: y)
                        
                        // Show tooltip
                        VStack(alignment: .leading, spacing: 4) {
                            Text(formattedDate(point.timestamp))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(String(format: "%.2f", point.price))¢")
                                .font(.headline)
                                .foregroundColor(circleColor(for: point.price))
                        }
                        .padding(8)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 3)
                        .position(
                            x: min(max(x, 80), geometry.size.width - 80),
                            y: max(y - 50, 35)
                        )
                    }
                }
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if priceData.count > 1 {
                            let xStep = geometry.size.width / CGFloat(priceData.count - 1)
                            let index = min(Int(value.location.x / xStep), priceData.count - 1)
                            if index >= 0 && index < priceData.count {
                                selectedPoint = priceData[index]
                            }
                        }
                    }
                    .onEnded { _ in
                        // Keep the selected point visible
                    }
                )
                .onTapGesture {
                    // Clear selection when tapping outside of data points
                    selectedPoint = nil
                }
            }
            
            // X-axis labels (time)
            HStack {
                if let first = priceData.first {
                    Text(formattedTime(first.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if priceData.count > 1, let middle = priceData[priceData.count / 2] {
                    Text(formattedTime(middle.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let last = priceData.last {
                    Text(formattedTime(last.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .aspectRatio(16/9, contentMode: .fit)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // Helper function to calculate y position
    private func yPosition(for price: Double, in height: CGFloat) -> CGFloat {
        let range = maxPrice - minPrice
        if range == 0 { return height / 2 }
        
        let relativePosition = 1 - ((price - minPrice) / range)
        return CGFloat(relativePosition) * height
    }
    
    // Helper function to format time
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    // Helper function to format date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
    
    // Helper function to determine point color
    private func circleColor(for price: Double) -> Color {
        if price >= highThreshold {
            return .red
        } else if price <= lowThreshold {
            return .green
        } else {
            return .blue
        }
    }
}

// Threshold line component
struct ThresholdLine: View {
    let threshold: Double
    let minPrice: Double
    let maxPrice: Double
    let width: CGFloat
    let height: CGFloat
    let color: Color
    
    var body: some View {
        let range = maxPrice - minPrice
        if range == 0 { return EmptyView().eraseToAnyView() }
        
        let relativePosition = 1 - ((threshold - minPrice) / range)
        let y = CGFloat(relativePosition) * height
        
        return HStack {
            Text(String(format: "%.1f¢", threshold))
                .font(.caption)
                .foregroundColor(color)
                .padding(.horizontal, 4)
                .background(Color(UIColor.systemBackground))
            
            Rectangle()
                .fill(color)
                .frame(height: 1)
        }
        .position(x: width / 2, y: y)
        .eraseToAnyView()
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

struct PriceChart_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData: [PricePoint] = [
            PricePoint(id: UUID(), millisUTC: 1642032000000, price: 3.5),
            PricePoint(id: UUID(), millisUTC: 1642035600000, price: 4.2),
            PricePoint(id: UUID(), millisUTC: 1642039200000, price: 6.8),
            PricePoint(id: UUID(), millisUTC: 1642042800000, price: 9.3),
            PricePoint(id: UUID(), millisUTC: 1642046400000, price: 12.1),
            PricePoint(id: UUID(), millisUTC: 1642050000000, price: 8.7),
            PricePoint(id: UUID(), millisUTC: 1642053600000, price: 5.4),
            PricePoint(id: UUID(), millisUTC: 1642057200000, price: 2.1)
        ]
        
        PriceChart(priceData: sampleData, highThreshold: 10.0, lowThreshold: 2.5)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}