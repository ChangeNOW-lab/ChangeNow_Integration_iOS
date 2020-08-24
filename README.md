# Integration Guide

Here's how to integrate ChangeNOW exchange module natively and in just a few steps in your iOS.

### Requirements

Connection of ChangeNOW module using[  CocoaPods](https://cocoapods.org) manager:

`pod 'CNIntegration', :git => 'https://github.com/ChangeNOW-lab/ChangeNow_Integration_iOS.git', :tag => '0.1.1'`

### Example

Use of ChangeNOW module:

```swift
CNModule(apiKey: "your api key for ChangeNOW", 
         theme: Theme? = nil,
         navigationType: NavigationType = .main,
         languageCode: String? = nil).start()
```

## Integration steps:

1.  To perform integration, you need to get the API key by contacting ChangeNOW or just make your own here in a few steps: <https://changenow.io/affiliate> 

1.  You can create your own interface theme to be displayed based on the **Theme protocol**, or pass `nil` for the default theme.

1.  **NavigationType** - you can use one of 3 navigation types:
 *  **main** - when the module is the basis of your application and is built on the UIWindow
 *  **sequence** - when the module needs to be opened in the UINavigationController stack via `push` or made `present` with UIViewController. In this case the `start` function of the CNModule instance will return the UIViewController instance.
 *  **embed** - when the module needs to be added to the root of UITabBarController or UINavigationController. In this case the `start` function of the CNModule instance will return the UIViewController instance.

1.  **ExchangeType** - you can use the module in two modes:
 * **any** - when the module supports all currency exchange options
 * **specific** (currency: `String`, address: `String?`) - when you need to specify a particular currency in which you want to exchange with the ability to specify the default wallet address

7.  You can set the language yourself using the following **language codes**:

`["ar", "da", "de", "en", "es", "fr", "hi", "id", "it", "ja", "ko", "ms", "nl", "pt", "ru", "sv", "zh-Hans", "zh-Hant"]` or pass the `nil` parameter to detect the language automatically.

If you do not want to conventionalize the module, then the whole integration consists of adding a module connection string via CocoaPods and later a command from the instructions.

### Theme Configuration

Conventionalizing occurs with the following **Theme** parameters:

```swift
public protocol Theme {

    var mainButtonCornerRadius: CGFloat? { get }
    var cellSelectionCornerRadius: CGFloat { get }

    var colors: ThemeColors { get }
    var fonts: ThemeFonts { get }
}

public protocol ThemeColors {

    var lightBackground: UIColor { get }
    var primaryGray: UIColor { get }
    var darkBackground: UIColor { get }
    var background: UIColor { get }
    var main: UIColor { get }
    var mainLight: UIColor { get }
    var mainSelection: UIColor { get }
    var primarySelection: UIColor { get }
    var placeholder: UIColor { get }
    var primaryOrange: UIColor { get }
    var primaryRed: UIColor { get }

    var transactionSubTitle: UIColor { get }
    var transactionBackground: UIColor { get }
}

public protocol ThemeFonts {

    // MARK: Description
    var minorDescription: UIFont { get } 
    var normalDescription: UIFont { get }
    var regularDescription: UIFont { get }
    var mediumDescription: UIFont { get }

    // MARK: Text
    var minorText: UIFont { get }
    var smallText: UIFont { get }
    var normalText: UIFont { get }
    var regularText: UIFont { get }
    var mediumText: UIFont { get }

    // MARK: Title
    var minorTitle: UIFont { get }
    var smallTitle: UIFont { get }
    var normalTitle: UIFont { get }
    var regularTitle: UIFont { get }
    var medianTitle: UIFont { get }
    var mediumTitle: UIFont { get }
    var largeTitle: UIFont { get }

    // MARK: Headline
    var normalHeadline: UIFont { get }
    var mediumHeadline: UIFont { get }
    var bigHeadline: UIFont { get }
    var greatHeadline: UIFont { get }

    // MARK: Header
    var littleHeader: UIFont { get }
    var normalHeader: UIFont { get }
    var regularHeader: UIFont { get }
}
```
