<p align="center">
<img src="https://raw.githubusercontent.com/Alpensegler/TweaKit/master/Images/logo.png" alt="TweaKit" title="TweaKit" width="1200"/>
</p>

<p align="center">
<a href="https://img.shields.io/badge/Swift-5.4_5.5_5.6-orange?style=flat"><img src="https://img.shields.io/badge/Swift-5.4_5.5_5.6-Orange?style=flat"></a>
<a href="https://cocoapods.org/pods/TweaKit"><img src="https://img.shields.io/cocoapods/v/TweaKit.svg?style=flat"></a>
<a href="https://github.com/Carthage/Carthage/"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>
</p>

`TweaKit`, a.k.a. "Tweak It", is a pure-swift library for adjusting parameters and feature flagging.

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
pod 'TweaKit', '~> 1.0'
```

### Carthage

```ogdl
github "Alpensegler/TweaKit" ~> 1.0
```

### Swift Package Manager

```swift
.package(url: "https://github.com/Alpensegler/TweaKit.git", .upToNextMajor(from: "1.0.0"))
```

## Get Started

### Declare Tweaks

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

### Initialize Tweak Context

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    _ = Tweaks.context
    return true
}
```

You can initialize tweak context at any time, but you should make sure the context is initialized before using tweaks in it.

### Use Tweaks

```swift
myViewController.title = Tweaks.rootViewNavigationTitle
mySketchView.lineWidth = Tweaks.sketchLineWidth
```

### Show the Tweak UI

```swift
Tweaks.context.show()
```

<p align="center">
<img src="https://raw.githubusercontent.com/Alpensegler/TweaKit/master/Images/Screenshot1.png" alt="Screenshot1" title="Screenshot1" width="200"/>
<img src="https://raw.githubusercontent.com/Alpensegler/TweaKit/master/Images/Screenshot2.png" alt="Screenshot2" title="Screenshot2" width="200"/>
<img src="https://raw.githubusercontent.com/Alpensegler/TweaKit/master/Images/Screenshot3.png" alt="Screenshot3" title="Screenshot3" width="200"/>
<img src="https://raw.githubusercontent.com/Alpensegler/TweaKit/master/Images/Screenshot4.png" alt="Screenshot4" title="Screenshot4" width="200"/>
</p>
<p align="center">
<img src="https://raw.githubusercontent.com/Alpensegler/TweaKit/master/Images/Screenshot5.png" alt="Screenshot5" title="Screenshot5" width="200"/>
<img src="https://raw.githubusercontent.com/Alpensegler/TweaKit/master/Images/Screenshot6.png" alt="Screenshot6" title="Screenshot6" width="200"/>
<img src="https://raw.githubusercontent.com/Alpensegler/TweaKit/master/Images/Screenshot7.png" alt="Screenshot7" title="Screenshot7" width="200"/>
<img src="https://raw.githubusercontent.com/Alpensegler/TweaKit/master/Images/Screenshot8.png" alt="Screenshot8" title="Screenshot8" width="200"/>
</p>


That's all. Now you already know enough about `TweaKit`.



Feel free to play with the demo app or check [wiki](https://github.com/Alpensegler/TweaKit/wiki) and [documentation](https://Alpensegler.github.io/TweaKit) for more usage information.

## Credits

- UI/UX is designed by [@gggeeeeggge](https://twitter.com/gggeeeeggge).
- TweaKit is heavily inspired by [SwiftTweaks](https://github.com/Khan/SwiftTweaks).

## About The Logo

The logo of `TweaKit` is a cute stoat, a mustelid that can tweak fur color during summer and winter.
