<p align="center">
<img src="Images/logo.png" alt="TweaKit" title="TweaKit" width="1200"/>
</p>


TweaKit, a.k.a. "Tweak It", is a pure-swift library for adjusting parameters and feature flagging.

## Features

- Declaring tweaks with property wrapper and result builder.
- Tweaking frequently used types on the fly.
- Carefully designed UI/UX.
- Searching tweaks fuzzily.
- Importing and exporting tweaks with json.

## Requirements

- iOS 13 and later
- Swift 5.4 and later

## Installation

### CocoaPods

```ruby
pod 'TweaKit'
```

### Carthage

```ogdl
github 'Cokile/TweaKit'
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/Cokile/TweaKit.git", .branch("master"))
]
```

## Get Started

### Declare Your Tweaks

```swift
import TweaKit

enum Tweaks {
  	@Tweak<CGFloat>(name: "Line Width", defaultValue: 1, from: 0.5, to: 2, stride: 0.05)
    static var sketchLineWidth
    @Tweak(name: "Line Color", defaultValue: UIColor(red: 0.227, green: 0.529, blue: 0.992, alpha: 1))
    static var sketchLineColor
    @Tweak(name: "Order", defaultValue: SketchAction.allCases)
    static var sketchActionsOrder
    @Tweak(name: "Name", defaultValue: "My Sketch")
    static var sketchName
    
    @Tweak(name: "Navigation Title", defaultValue: "Demo", options: ["Demo", "Example", "Guide"])
    static var rootViewNavigationTitle
    @Tweak(name: "Shake To Show Tweaks", defaultValue: true)
    static var rootViewEnableShake
    
    static let context = TweakContext {
        TweakList("Sketch") {
            TweakSection("Line") {
                $sketchLineWidth
                $sketchLineColor
            }
            TweakSection("Info") {
                $sketchName
            }
            TweakSection("Actions") {
                $sketchActionsOrder
            }
        }
        TweakList("Root View") {
            TweakSection("UI") {
                $rootViewNavigationTitle
            }
            TweakSection("Interaction") {
                $rootViewEnableShake
            }
        }
    }
}
```

You can tweak the following types:

- `Bool`
- Numeric Types: `Int[8|16|32|64]`, `UInt[8|16|32|64]`, `Float`, `Double` and `CGFloat`
- `String`
- `Array` that `Element` conforming some protocols
- `UIColor`

Aside from changing value in place, you can also select value from given options.

### Initialize YourTweak Context

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    _ = Tweaks.context
    return true
}
```

You can initialize tweak context at any time, but you should make sure the context is initialized before using tweaks in it.

### Use Your Tweaks

```swift
myViewController.title = Tweaks.rootViewNavigationTitle
mySketchView.lineWidth = Tweaks.sketchLineWidth
```

That's all. Now you already know enough about `TweaKit`.

Feel free to play with the demo app or check [wiki](https://github.com/Cokile/TweaKit/wiki) for more advanced usage.

## Credits

- UI/UX is designed by [@愉悦地瓜](https://twitter.com/gggeeeeggge).
- TweaKit is heavily inspired by [SwiftTweak](https://github.com/Khan/SwiftTweaks).

## About The Logo

The logo of TweaKit is a cute stoat, a mustelid that can tweak fur color during summer and winter.
