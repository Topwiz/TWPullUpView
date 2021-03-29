# TWPullUpView
Create pull up view with multiple sticky points with scrollView supported.

[![Platform](http://img.shields.io/badge/platform-ios-red.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Swift 5](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Version](https://img.shields.io/cocoapods/v/TWPullUpView.svg?style=flat)](https://cocoapods.org/pods/TWPullUpView)
[![License](https://img.shields.io/cocoapods/l/TWPullUpView.svg?style=flat)](https://cocoapods.org/pods/TWPullUpView)

<img src="https://github.com/Topwiz/TWPullUpView/blob/master/Readme/TWPullupView_example.gif?raw=true" height="500"/>

## Features
- Multiple sticky points
- Only Support's Portrait
- Support's scrollView scroll connection (like AirBnb)

<img src="https://github.com/Topwiz/TWPullUpView/blob/master/Readme/airbnb_example.gif?raw=true" height="250"/>

## Installation

TWPullUpView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```swift
pod 'TWPullUpView'
```

## Usage example
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    let pullUpView = MyPullUpView()
    pullUpView.addOn(view, initialStickyPoint: .percent(0.3), animated: true)
}


class MyPullUpView: TWPullUpView {

}

```

## Callback
```swift
// It get called before the view move to nearest sticky point
view.willMoveToPoint = { point in

}

// It get called after the view moved to the nearest sticky point
didMoveToPoint = { point in

}

// It get called when the user is panning the view
didChangePoint = { point in

}
```

## Usage for internal scrollView
```swift
class MyPullUpView: TWPullUpView {

  private func setOptions() {
      addScrollView(tableView)
  }
}
```

## Set Custom Options
```swift

struct TWCustomOptions: TWOptionProtocol {
    var animationDuration: Double = 0.3
    var animationDamping: CGFloat = 1
    var animationSpringVelocity: CGFloat = 0.4
    var overMaxHeight: Bool = true
    var underMinHeight: Bool = true
}

private let customOptions: TWOptionProtocol = TWCustomOptions()

private func setOptions() {
      stickyPoints = [.percent(0.3), .percent(0.6), .max]
      setOption(customOptions)
      addScrollView(tableView)
 }

```

## Example
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## License

TWPullUpView is available under the MIT license. See the LICENSE file for more info.
