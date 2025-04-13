# ComEd Price Tracker

An iOS app that displays ComEd's hourly electricity pricing data as a home screen widget and sends notifications based on user-defined price thresholds.

## Features

- **Live Price Updates**: View current ComEd electricity pricing data
- **Price History**: View historical price trends with interactive charts
- **Custom Notifications**: Set high and low price thresholds for alerts
- **Home Screen Widgets**: Keep track of prices at a glance with small and medium widgets

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.6+

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

3. Build and run the app on your device or simulator.

## Troubleshooting Xcode Issues

If you encounter build errors related to executable targets or library products, try these steps:

### Issue: "Library product 'ComEdPriceTracker' contains a target of type executable"

1. Open the project settings in Xcode:
   - Select the project file in the navigator
   - Select the ComEdPriceTracker target

2. Change the Product Type:
   - Under the "General" tab, find the "Packaging" section
   - Set "Product Type" to "Application" 
   - Set "Product Name" to "ComEdPriceTracker"

3. Verify Build Settings:
   - Go to the "Build Settings" tab
   - Search for "product type"
   - Ensure "PRODUCT_TYPE" is set to "com.apple.product-type.application"

4. Clean and rebuild:
   - Select Product > Clean Build Folder
   - Build the project again

If issues persist, you can also create a new Xcode project and copy the source files over:

1. Create a new iOS App using SwiftUI
2. Copy all files from the following folders:
   - ComEdPriceTracker/Models
   - ComEdPriceTracker/Views
   - ComEdPriceTracker/Services
3. Add the widget extension by following the standard Xcode widget creation workflow

## Data Source

This app uses data from [ComEd's Hourly Pricing API](https://hourlypricing.comed.com/live-prices/), which provides real-time and historical electricity pricing information for customers in the ComEd service territory.

## Privacy

This app does not collect any personal data. All user preferences are stored locally on your device using UserDefaults.

## License

This project is available under the MIT license. See the LICENSE file for more info.
