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

## API

This app uses the ComEd Hourly Pricing API available at:
https://hourlypricing.comed.com/hp-api/

## License

MIT
