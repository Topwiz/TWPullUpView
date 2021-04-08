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
import TWPullUpView

override func viewDidLoad() {
    super.viewDidLoad()
    
    let pullUpView = MyPullUpViewController()
    pullUpView.stickyPoints = [.percent(0.3), .percent(0.6), .max]
    pullUpView.addOn(self, initialStickyPoint: .percent(0.3), animated: true)
    pullUpView.isPullUpScrollEnabled = true
    
    // Remove View
    pullUpView.removeView(animate: true)
}


class MyPullUpViewController: TWPullUpViewController {
    
}

```

## Callback
```swift
// It get called before the view move to nearest sticky point
willMoveToPoint = { point in

}

// It get called after the view moved to the nearest sticky point
didMoveToPoint = { point in

}

// It get called when the user is panning the view
didChangePoint = { point in

}

// It get called when the user is panning and return's percentage of how much the view is opened.
// You can change the starting point of the percent by overriding 'startPercentFromPoint' the default is the min point in sticky array.
percentOfMinToMax = { percent in 

}
```

## Usage for internal scrollView
```swift
class MyPullUpViewController: TWPullUpViewController {

    private func setView() {
        attachScrollView(tableView)
    }
}
```

## Set Custom Options
```swift

public struct TWPullUpOption {
    /// Animation option to nearest sticky point when panning is ended
    public var animationDuration: Double = 0.3
    public var animationDamping: CGFloat = 1
    public var animationSpringVelocity: CGFloat = 0.4

    /// If view can pull up then max height. (When there is no scrollview inside)
    public var overMaxHeight: Bool = true

    /// If view can pull down then min Height
    public var underMinHeight: Bool = true

    /// Velocity of the panning to go to next sticky point
    /// If it is 0 it will move to next point right away.
    /// If it is CGFloat.infinity view will need to move more than half up or down to move to the next sticky point
    /// Recommend to use between 1000 ~ 3000
    public var moveToNextPointVelocity: CGFloat = 1500
}

class MyPullUpViewController: TWPullUpViewController {

    override var option: TWPullUpOption {
        return TWPullUpOption()
    }
}

```

## Example
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## License

TWPullUpView is available under the MIT license. See the LICENSE file for more info.
