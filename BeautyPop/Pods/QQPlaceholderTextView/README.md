# QQPlaceholderTextView

Adding placeholder property for UITextView without subclass, written in Swift

**Note: this libray is inspired from original source of [devxoul](https://github.com/devxoul/UITextView-Placeholder) that written in Obj-C**

![QQPlaceholderTextView](https://raw.githubusercontent.com/quangtqag/QQPlaceholderTextView/master/Screenshots/preview.png)

## Usage
* You can set the value of the `placeholder` property just like using UITextField. 
* Because it does not subclass from UITextView so you don't need to edit anything.
* Additionally, you can also apply style of UITextField into it as figure above

### Code

You need to import QQPlaceholderTextView into place that you want to use

```swift
import QQPlaceholderTextView
```

And set properties for it

```swift
textView.placeholder = "I'am a placeholder"
textView.isApplyTextFieldStyle = true
```

## Installation
### CocoaPods

You can install the latest release version of CocoaPods with the following command:

```bash
$ gem install cocoapods
```

*CocoaPods v0.36 or later required*

Simply add the following line to your Podfile:

```ruby
platform :ios, '8.0' 
use_frameworks!

pod 'QQPlaceholderTextView', '~> 0.0.2' 
```

Then, run the following command:

```bash
$ pod install
```

## Requirements

- iOS 8.0+
- Xcode 7+

## License

QQPlaceholderTextView is released under the MIT license. See LICENSE for details.