# ComEd Price Tracker

An iOS app that displays ComEd's hourly electricity pricing data as a homescreen widget and sends notifications based on user-defined price thresholds.

## Features

- **Live Price Display**: View the current ComEd hourly electricity price
- **Home Screen Widgets**: Small and medium widgets showing current price and price status
- **Price Notifications**: Get alerts when prices exceed high thresholds, drop below low thresholds, or become negative
- **Price History**: View today's hourly prices and 5-minute interval pricing data
- **Weekly Statistics**: Track price trends over the past week
- **Customizable Settings**: Set your own price thresholds and notification preferences

## Technical Features

- Built with SwiftUI and UIKit
- WidgetKit integration for home screen widgets
- Background refresh for up-to-date price data
- Local notifications for price alerts
- Chart visualizations for price history
- Shared UserDefaults for app and widget data sharing

## Requirements

- iOS 15.0 or later
- Xcode 13.0 or later
- Swift 5.5 or later

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/maestercohen/ComEdPriceTracker.git
   ```

2. Open the project in Xcode:
   ```
   cd ComEdPriceTracker
   open ComEdPriceTracker.xcodeproj
   ```

3. Select your development team in Xcode's signing & capabilities settings

4. Build and run the app on your iOS device or simulator

## API

This app uses the ComEd Hourly Pricing API available at:
https://hourlypricing.comed.com/hp-api/

The API endpoints used include:
- Current 5-minute price: `https://hourlypricing.comed.com/api?type=5minutefeed`
- Hourly price history: `https://hourlypricing.comed.com/api?type=hourlyfeed`
- Day-ahead prices: `https://hourlypricing.comed.com/api?type=dayahead`

No API key is required for these endpoints.

## Screenshots

(Screenshots will be added after the app is deployed)

## License

MIT
