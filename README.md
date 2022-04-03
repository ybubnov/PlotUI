# [PlotUI](https://plotui.pages.dev) &middot; [![Tests][Tests]](https://github.com/ybubnov/PlotUI)

Integrate beautiful minimalistic plots into your app.

## Installation

You can use PlotUI as package dependency to your app using
[Xcode](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app):

```text
github.com/ybubnov/PlotUI
```

## Documentation

The [PlotUI Documentation](https://plotui.pages.dev) contains additional details on how
to get started with PlotUI.

## Usage

Define your plot using the `PlotView` structure, and populate it with concrete data
representation, like `BarView`, to render data in your app's user interface.

The following example creates a bar chart with 3 data points, where horizontal ticks
are labeled with week days instead of numbers:

```swift
PlotView {
    BarView(
        x: [3, 4, 5],
        y: [2000, 2100, 2300]
    )
} horizontal: {
    HAxis(
        ticks: [1, 2, 3, 4, 5],
        labels: ["Sun", "Mon", "Tue", "Wed", "Thu"]
    )
} vertical: {
    VAxis(ticks: [1000, 2000, 3000])
}
.contentDisposition(minX: 1, maxX: 5, minY: 0, maxY: 3000)
.frame(width: 500, height: 300)
```

## License

PlotUI is [MIT licensed](LICENSE).

[Tests]: https://github.com/ybubnov/PlotUI/workflows/Tests/badge.svg
