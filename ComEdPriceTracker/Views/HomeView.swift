import SwiftUI

struct HomeView: View {
    @StateObject private var priceDataModel = PriceDataModel()
    @State private var showRefreshAnimation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current price display
                    if let currentPrice = priceDataModel.currentPrice {
                        PriceDisplay(price: currentPrice)
                    } else if priceDataModel.isLoading {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding()
                            Text("Loading current price...")
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 200)
                    } else if let error = priceDataModel.errorMessage {
                        VStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                                .padding()
                            
                            Text("Error Loading Data")
                                .font(.headline)
                            
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: {
                                priceDataModel.fetchCurrentPrice()
                            }) {
                                Text("Try Again")
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.top, 10)
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 3)
                    }
                    
                    Divider()
                    
                    // Today's hourly price chart
                    VStack(alignment: .leading) {
                        Text("Today's Hourly Prices")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if priceDataModel.todayPrices.isEmpty && !priceDataModel.isLoading {
                            Text("No price data available for today")
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            PriceChart(prices: priceDataModel.todayPrices)
                                .frame(height: 200)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 3)
                    
                    // Advice based on current price
                    if let currentPrice = priceDataModel.currentPrice {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Price Insight")
                                .font(.headline)
                            
                            HStack {
                                Image(systemName: currentPrice.price < 5.0 ? "lightbulb.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(currentPrice.price < 5.0 ? .green : (currentPrice.price < 14.0 ? .yellow : .red))
                                
                                Text(currentPrice.priceDescription)
                                    .foregroundColor(.primary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 3)
                    }
                }
                .padding()
            }
            .refreshable {
                showRefreshAnimation = true
                priceDataModel.fetchCurrentPrice()
                priceDataModel.fetchFiveMinutePrices()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showRefreshAnimation = false
                }
            }
            .navigationTitle("ComEd Price Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showRefreshAnimation = true
                        priceDataModel.fetchCurrentPrice()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            showRefreshAnimation = false
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(showRefreshAnimation ? 360 : 0))
                            .animation(showRefreshAnimation ? Animation.linear(duration: 1).repeatCount(1, autoreverses: false) : .default, value: showRefreshAnimation)
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
