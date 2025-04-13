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

## Fixing Common Xcode Errors

### Fixing "No such module 'UIKit'" Error

If you encounter the "No such module 'UIKit'" error when opening the project in Xcode, follow these steps:

1. **Check Target Membership**:
   - In Xcode, select each Swift file that imports UIKit
   - In the File Inspector panel (right panel), ensure the file is included in the main app target
   - Check "Target Membership" for the main app target

2. **Update Build Settings**:
   - Select your project in the navigator
   - Select the app target
   - Go to "Build Settings" tab
   - Search for "Framework Search Paths"
   - Add entry: `$(SDKROOT)/System/Library/Frameworks`
   
3. **Set Proper iOS Deployment Target**:
   - Go to the "General" tab for your target
   - Make sure iOS Deployment Target is set to iOS 15.0 or later

4. **Import UIKit Properly**:
   - Ensure imports are at the top of the file and formatted correctly:
   ```swift
   import UIKit
   import SwiftUI
   ```

5. **Alternative Solution**:
   - Create a new iOS App project using Xcode's template
   - Copy the source files from this repository into the new project
   - This will ensure all proper framework references are set up correctly

### Fixing Localization Errors

If you see errors related to localization such as "defaultLocalization not set", follow these steps:

1. **Set Default Localization in Project Settings**:
   - Select your project in the navigator
   - Go to the "Info" tab
   - Under "Localizations", ensure "English" is listed
   - If not, click the "+" button and add "English"
   - Set "Development Language" to "English" (en)

2. **Verify Localization Files**:
   - Ensure the project contains the proper localization structure:
     - ComEdPriceTracker/Base.lproj/
     - ComEdPriceTracker/en.lproj/
   - Each should contain a Localizable.strings file

3. **Add Default Localization to Package.swift**:
   - If you're using Swift Package Manager, ensure your Package.swift includes:
   ```swift
   let package = Package(
       name: "ComEdPriceTracker",
       defaultLocalization: "en",
       // ...rest of your package definition
   )
   ```

4. **Clean and Rebuild**:
   - Select Product > Clean Build Folder
   - Build the project again

If you continue having issues with any of these errors, try cleaning the build folder (Product > Clean Build Folder) and restarting Xcode.

## Data Source

This app uses data from [ComEd's Hourly Pricing API](https://hourlypricing.comed.com/live-prices/), which provides real-time and historical electricity pricing information for customers in the ComEd service territory.

## Privacy

This app does not collect any personal data. All user preferences are stored locally on your device using UserDefaults.

## License

This project is available under the MIT license. See the LICENSE file for more info.
