# Ansi [![Status](https://travis-ci.org/oleander/Ansi.svg?branch=master)](https://travis-ci.org/oleander/Ansi)

Swift 3 Ansi parser which yields `NSAttributedString`. Take a look at the tests for more information.

## Usage

```swift
import Ansi

"ABC\\e[3;4;33mDEF\\e[0mGHI".ansified // => "ABC" + "DEF".italic.underline.yellow + "GHI"
```

## Install

Add `pod 'Ansi'` to your `Podfile` and run `pod install`.
