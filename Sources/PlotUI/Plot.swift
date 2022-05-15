import Foundation
import SwiftUI

/// A view that arranges ticks in a horizontal line.
///
/// You create a horizontal axis by either providing a fixed amount of partitions
/// using ``HAxis/init(partitions:)``.
///
/// Usually `HAxis` is used altogether with ``PlotView`` which automatically handles
/// content disposition. If you use it separately, you should use
/// ``HAxis/contentDisposition(minX:maxX:minY:maxY:)`` to setup limits for axes.
///
/// In the following example an outer frame is partitioned by 10 sections generating
/// 11 ticks:
///
/// ```swift
/// HAxis(partititions: 10)
/// .contentDisposition(minX: 0, maxX: 200, minY: 0, maxY: 100)
/// ```
///
/// ## Styling Ticks
///
/// You can customize your axis' label appearance using one of the standard tick styles,
/// like ``TickStyle/bottom`` and apply the style with the ``Tick/tickStyle(_:)``
/// modifier.
///
/// ```swift
/// HStack {
///     PlotView { BarView(x: [1, 2], y: [10, 20]) }
///     PlotView { BarView(x: [1, 2], y: [1, 2]) }
/// }
/// .tickStyle(.bottom)
/// ```
///
/// If you apply the tick style to a container view, like in the example above, all the
/// axes in the container use the tick style.
///
/// You can also create custom tick styles. To add a custom appearance, create a style
/// that conforms to the ``TickStyle`` protocol. Custom styles can also use the axis'
/// orientation and use it to adjust the tick appearance.
///
/// Similarly, to customize the stroke of the axis' tick, use ``HAxis/tickStroke(style:)``:
///
/// ```swift
/// HAxis(partitions: 4)
/// .tickStroke(style: StrokeStyle(lineWidth: 0.5))
/// ```
///
/// Additionally you can change the insets of the axis' ticks from the content placement
/// using ``HAxis/tickInsets(_:)``:
///
/// ```swift
/// PlotView {
///     BarView(x: [1, 2], y: [10, 20])
/// } horizontal: {
///     HAxis(partitions: 10)
/// } vertical: {
///     VAxis(parititions: 4)
/// }
/// .tickInsets(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 20))
/// ```
///
/// See the full list of tick styling options in ``Tick`` documentation.
public struct HAxis: View {
    @Environment(\.contentDisposition) var contentDisposition

    /// The list of tick locations relative to the scaled axis.
    private var ticks: [Double] = []

    /// The labels to place at the given ticks locations.
    private var labels: [LocalizedStringKey] = []

    private var partitions: Int?

    /// Creates a horizontal axis using the given list of ticks and associated labels.
    public init(ticks: [Double] = [], labels: [LocalizedStringKey] = []) {
        self.ticks = ticks
        self.labels = labels
    }

    /// Creates a horizontal axis using the given list of ticks and format style.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    public init<F: FormatStyle>(ticks: [Double] = [], format: F) where
        F.FormatInput == Double, F.FormatOutput == String
    {
        self.ticks = ticks
        self.labels = ticks.map { LocalizedStringKey(format.format($0)) }
    }

    /// Creates a horizonal axis using the given list of ticks and format string.
    public init(ticks: [Double] = [], format: String) {
        self.ticks = ticks
        self.labels = ticks.formatEach(format)
    }

    /// Creates a horizontal axis that generates determined number of ticks.
    public init(partitions: Int) {
        self.partitions = partitions
    }

    /// The content and behavior of the view.
    public var body: some View {
        var ticks = self.ticks
        var labels = self.labels

        if partitions != nil {
            (ticks, _) = contentDisposition[0...partitions!, 0...0]
            labels = ticks.formatEach("%.2f")
        }

        return ForEach(ticks.indices, id: \.self) { i in
            Tick(labels[i, ""], orientation: .vertical, value: ticks[i])
        }
    }
}

/// A view that arranges ticks in a vertical line.
///
/// You create a vertical axis by either providing a fixed amount of partitions
/// using ``VAxis/init(partitions:)``.
///
/// Usually `VAxis` is used altogether with ``PlotView`` which automatically handles
/// content disposition. If you use it separately, you should use
/// ``VAxis/contentDisposition(minX:maxX:minY:maxY:)`` to setup limits for axes.
///
/// In the following example an outer frame is partitioned by 4 sections generating
/// 5 ticks:
///
/// ```swift
/// VAxis(partititions: 4)
/// .contentDisposition(minX: 0, maxX: 200, minY: 0, maxY: 100)
/// ```
///
/// ## Styling Ticks
///
/// You can customize your axis' label appearance using one of the standard tick styles,
/// like ``TickStyle/trailing`` and apply the style with the ``Tick/tickStyle(_:)``
/// modifier.
///
/// ```swift
/// HStack {
///     PlotView { BarView(x: [1, 2], y: [10, 20]) }
///     PlotView { BarView(x: [1, 2], y: [1, 2]) }
/// }
/// .tickStyle(.trailing)
/// ```
///
/// If you apply the tick style to a container view, like in the example above, all the
/// axes in the container use the tick style.
///
/// You can also create custom tick styles. To add a custom appearance, create a style
/// that conforms to the ``TickStyle`` protocol. Custom styles can also use the axis'
/// orientation and use it to adjust the tick appearance.
///
/// Similarly, to customize the stroke of the axis' tick, use ``VAxis/tickStroke(style:)``:
///
/// ```swift
/// VAxis(partitions: 4)
/// .tickStroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
/// ```
///
/// Additionally you can change the insets of the axis' ticks from the content placement
/// using ``VAxis/tickInsets(top:leading:bottom:trailing:)``:
///
/// ```swift
/// PlotView {
///     BarView(x: [1, 2], y: [10, 20])
/// } horizontal: {
///     HAxis(partitions: 10)
/// } vertical: {
///     VAxis(parititions: 4)
/// }
/// .tickInsets(bottom: 30)
/// ```
///
/// See the full list of tick styling options in ``Tick`` documentation.
public struct VAxis: View {
    @Environment(\.contentDisposition) var contentDisposition

    /// The list of tick locations relative to the scaled axis.
    private var ticks: [Double] = []

    /// The labels to place at the given ticks locations.
    private var labels: [LocalizedStringKey] = []

    private var partitions: Int?

    /// Creates a vertical axis using the given list of ticks and associated labels.
    public init(ticks: [Double] = [], labels: [LocalizedStringKey] = []) {
        self.ticks = ticks
        self.labels = labels
    }

    /// Creates a vertical axis using the given list of ticks and format style.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    public init<F: FormatStyle>(ticks: [Double] = [], format: F) where
        F.FormatInput == Double, F.FormatOutput == String
    {
        self.ticks = ticks
        self.labels = ticks.map { LocalizedStringKey(format.format($0)) }
    }

    /// Creates a vertical axis using the given list of ticks and format string.
    public init(ticks: [Double] = [], format: String) {
        self.ticks = ticks
        self.labels = ticks.formatEach(format)
    }

    /// Creates a vertical axis that generates determined number of ticks.
    public init(partitions: Int) {
        self.partitions = partitions
    }

    /// The content and behavior of the view.
    public var body: some View {
        var ticks = self.ticks
        var labels = self.labels

        if partitions != nil {
            (_, ticks) = contentDisposition[0...0, 0...partitions!]
            labels = ticks.formatEach("%.2f")
        }

        return ForEach(ticks.indices, id: \.self) { i in
            Tick(labels[i, ""], orientation: .horizontal, value: ticks[i])
        }
    }
}

/// A view for presenting plot data alongside with vertical and horizontal axes.
///
/// In it's simplest form, a `PlotView` creates horizontal and vertical ticks
/// for a provided plot automatically. Ten ticks for horizontal axis and four for
/// a vertical axis.
///
/// The following example presents a bar view using ``BarView`` with five data points:
///
/// ```swift
/// PlotView {
///     BarView(
///         x: [0, 1, 2, 3, 4],
///         y: [10, 20, 30, 40, 50]
///     )
/// }
/// ```
///
/// You can optionally customize appearance of horizontal and vertical axes with
/// ``HAxis`` and ``VAxis`` respectively. For example, you can use a different
/// partitioning for the axes using ``HAxis/init(partitions:)``:
///
/// ```swift
/// PlotView {
///     BarView(
///         x: [0, 1, 2],
///         y: [50, 15, 5]
///     )
/// } horizontal: {
///     HAxis(partitions: 2)
/// } vertical: {
///     VAxis(partitions: 3)
/// }
/// ```
///
/// ## Content Disposition
///
/// You can provide a fixed set of ticks for both axes using ``HAxis/init(ticks:labels:)``
/// for horizontal axis and ``VAxis/init(ticks:labels:)``. In order to make them visible
/// use ``PlotView/contentDisposition(minX:maxX:minY:maxY:)`` modifier to adjust the limits
/// of axes.
///
/// For example, to make the horizontal and vertical ticks visible, adjust limits of the
/// axes by setting content disposition:
///
/// ```swift
/// PlotView {
///     BarView(
///         x: [3, 4, 5],
///         y: [2000, 2100, 2300]
///     ),
/// } horizontal: {
///     HAxis(
///         ticks: [1, 2, 3, 4, 5],
///         labels: ["Sun", "Mon", "Tue", "Wed", "Thu"]
///     )
/// } vertical: {
///     VAxis(ticks: [1000, 2000, 3000])
/// }
/// .contentDisposition(minX: 1, maxX: 5, minY: 0, maxY: 3000)
/// ```
public struct PlotView: View {
    @Environment(\.contentDisposition) var contentDisposition

    private var haxis: AnyView
    private var vaxis: AnyView
    private var content: AnyFuncView

    /// Creates a plot view using the given axes and specified content.
    public init<Content: FuncView, HAxis: View, VAxis: View>(
        @ViewBuilder content: () -> Content,
        @ViewBuilder horizontal: () -> HAxis,
        @ViewBuilder vertical: () -> VAxis
    ) {
        self.haxis = AnyView(horizontal())
        self.vaxis = AnyView(vertical())
        self.content = AnyFuncView(content())
    }

    /// Creates a plot view with determined horizontal and vertical axes.
    public init<Content: FuncView>(@ViewBuilder content: () -> Content) {
        self.content = AnyFuncView(content())
        self.haxis = AnyView(HAxis(partitions: 10))
        self.vaxis = AnyView(VAxis(partitions: 4))
    }

    /// The content and behavior of the view.
    public var body: some View {
        ZStack {
            haxis
            vaxis
            content
        }
        .contentDisposition(contentDisposition.merge(content.disposition))
    }
}

struct PlotViewPreview: PreviewProvider {
    static var previews: some View {
        ZStack {
            PlotView {
                BarView(
                    x: [0.5, 1.5, 4.5, 6, 10, 11, 12, 18, 19, 20, 21, 22, 15],
                    y: [1, 12, 20, 35, 8, 32, 50, 60, 55, 45, 50, 48, 10]
                )
                .barWidth(15)
                .barColor(.blue)
            } horizontal: {
                HAxis(
                    ticks: [0, 3, 6, 9, 12, 15, 18, 21, 24],
                    labels: ["00", "03", "06", "09", "12", "15", "18", "21"]
                )
                .tickStyle(.bottomTrailing)
                .tickStroke(style: .tinyDashed)
            } vertical: {
                VAxis(
                    ticks: [0, 20, 40, 60],
                    labels: ["0m", "20m", "40m", "60m"]
                )
                .tickStyle(.trailing)
                .tickStroke(style: StrokeStyle(lineWidth: 0.2))
            }
            .tickColor(.gray)
            .tickInsets(bottom: 15)
            .contentDisposition(minX: 0, maxX: 24, minY: 0, maxY: 60)
            .padding(50)
            .background(Color.white)

            Text("Screen on Usage")
                .foregroundColor(.black.opacity(0.7))
                .fontWeight(.bold)
                .padding(.top, 200)
            //            PlotView {
            //                BarView(
            //                    x: [-5, 1, 2, 3, 4, 5, 5.5],
            //                    y: [10, 50, 30, 40, 50, 55, 60, 70, 80, 90]
            //                )
            //                .barColor(.green)
            //            }
            //            .tickInsets(bottom: 10, trailing: 20)
            //            .padding(100)
            //            .background(Color.white)
        }
        .foregroundColor(.gray)
        .contentDisposition(minY: 8)
        .frame(height: 250)
    }
}
