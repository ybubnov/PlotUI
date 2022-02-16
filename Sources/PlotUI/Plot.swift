import Foundation
import SwiftUI

extension StrokeStyle {
    static public var tinyDashed: StrokeStyle {
        StrokeStyle(lineWidth: 0.2, dash: [2])
    }

    static public var tiny: StrokeStyle {
        StrokeStyle(lineWidth: 0.2)
    }
}

public struct PlotAxis<Tick: TickShape>: View {
    /// The list of tick locations relative to the scaled axis.
    private var ticks: [Double] = []
    private var tickStyle: StrokeStyle = .tinyDashed

    /// The labels to place at the given ticks locations.
    private var labels: [LocalizedStringKey] = []
    private var labelStyle: AnyTickLabelStyle

    @Environment(\.contentDisposition) var disposition
    @Environment(\.viewport) var viewport

    internal init<S: TickLabelStyle>(
        _ ticks: [Double] = [],
        _ tickStyle: StrokeStyle = .tinyDashed,
        _ labels: [LocalizedStringKey] = [],
        _ labelStyle: S
    ) {
        self.ticks = ticks
        self.labels = labels
        self.tickStyle = tickStyle
        self.labelStyle = AnyTickLabelStyle(labelStyle)
    }

    public init<S: TickLabelStyle>(labelStyle: S) {
        self.labelStyle = AnyTickLabelStyle(labelStyle)
    }

    private func subscriptLabel(_ index: Int, defaultValue: LocalizedStringKey = "")
        -> LocalizedStringKey
    {
        if (0..<labels.count).contains(index) {
            return labels[index]
        }
        return defaultValue
    }

    public var body: some View {
        ForEach(ticks.indices, id: \.self) { i in
            Tick(disposition, viewport, at: ticks[i])
                .stroke(style: tickStyle)
                .tickLabel(subscriptLabel(i), style: labelStyle)
        }
    }

    public func ticks<S: Sequence>(_ ticks: S) -> Self where S.Element == Double {
        return Self(Array(ticks), tickStyle, [], labelStyle)
    }

    public func tickStyle(_ style: StrokeStyle) -> Self {
        return Self(ticks, style, labels, labelStyle)
    }

    public func labels<S: Sequence>(_ labels: S) -> Self where S.Element == LocalizedStringKey {
        return Self(ticks, tickStyle, Array(labels), labelStyle)
    }

    public func labelStyle<S: TickLabelStyle>(_ style: S) -> Self {
        return Self<Tick>(ticks, tickStyle, labels, style)
    }
}

public struct PlotView: View {
    @Environment(\.contentDisposition) var contentDisposition

    public var content: AnyFuncView

    public typealias XAxis = PlotAxis<VerticalTick>
    public typealias YAxis = PlotAxis<HorizontalTick>

    private var xaxis: XAxis
    private var yaxis: YAxis

    internal init<Content: FuncView>(_ xaxis: XAxis, _ yaxis: YAxis, _ content: Content) {
        self.xaxis = xaxis
        self.yaxis = yaxis
        self.content = AnyFuncView(content)
    }

    public var body: some View {
        ZStack {
            xaxis
            yaxis
            content
        }
        .foregroundColor(.gray)
        .viewport([.bottom, .trailing], 30)
        .contentDisposition(contentDisposition.merge(content.disposition))
    }

    private func makeAxis<
        Tick: TickShape,
        T: Sequence
    >(_ axis: PlotAxis<Tick>, _ ticks: T, _ labels: [LocalizedStringKey]? = nil) -> PlotAxis<Tick>
    where T.Element == Double {
        let asLabel = { (tick: Double) -> LocalizedStringKey in
            LocalizedStringKey(String(format: "%.2f", tick))
        }

        let labels = ticks.map(asLabel)
        return axis.ticks(ticks).labels(labels)
    }
}

extension PlotView {
    public init<Content: FuncView>(@ViewBuilder content: () -> Content) {
        self.content = AnyFuncView(content())
        self.xaxis = XAxis(labelStyle: .bottomTrailing)
        self.yaxis = YAxis(labelStyle: .trailing)

        let numXTicks = 10
        let numYTicks = 4

        let (xticks, yticks) = self.content.disposition[0...numXTicks, 0...numYTicks]

        self.xaxis = self.makeAxis(xaxis, xticks, [])
        self.yaxis = self.makeAxis(yaxis, yticks, []).tickStyle(.tiny)
    }
}

extension Array where Self.Element == Double {

    static func asDouble<S: Sequence, E: BinaryInteger>(_ elements: S) -> Self
    where S.Element == E {
        return elements.map { e in Double(e) }
    }

    static func asDouble<S: Sequence, E: BinaryFloatingPoint>(_ elements: S) -> Self
    where S.Element == E {
        return elements.map { e in Double(e) }
    }
}

extension PlotView {

    public func horizontalTicks<S: Sequence, Tick: BinaryInteger>(
        _ ticks: S, style: StrokeStyle = .tinyDashed
    ) -> Self where S.Element == Tick {
        let newAxis = makeAxis(xaxis, Array.asDouble(ticks))
        return Self(newAxis.tickStyle(style), yaxis, content)
    }

    public func horizontalLabels<S: Sequence>(_ labels: S) -> Self
    where S.Element == LocalizedStringKey {
        return Self(xaxis.labels(labels), yaxis, content)
    }

    public func horizontalLabels<S: Sequence, LabelStyle: TickLabelStyle>(
        _ labels: S, style: LabelStyle
    ) -> Self where S.Element == LocalizedStringKey {
        return Self(xaxis.labels(labels).labelStyle(style), yaxis, content)
    }
}

extension PlotView {

    public func verticalTicks<S: Sequence, Tick: BinaryInteger>(
        _ ticks: S, style: StrokeStyle = .tiny
    ) -> Self where S.Element == Tick {
        let newAxis = makeAxis(yaxis, Array.asDouble(ticks))
        return Self(xaxis, newAxis.tickStyle(style), content)
    }

    public func verticalLabels<S: Sequence>(_ labels: S) -> Self
    where S.Element == LocalizedStringKey {
        return Self(xaxis, yaxis.labels(labels), content)
    }

    public func verticalLabels<S: Sequence, LabelStyle: TickLabelStyle>(
        _ labels: S, style: LabelStyle
    ) -> Self where S.Element == LocalizedStringKey {
        return Self(xaxis, yaxis.labels(labels).labelStyle(style), content)
    }
}

struct PlotViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            PlotView {
                BarView(
                    x: [0, 1, 2, 3, 4, 5, 5.5],
                    y: [10, 50, 30, 40, 50, 55, 60, 70, 80, 90]
                )
                .barWidth(10)
                .barColor(.blue)
            }
            .horizontalTicks([2, 3, 7])
            //            .horizontalLabels(["-3", "-2", "-1", "0"], style: .bottom)
            .contentDisposition(right: 15)
            //         .verticalTicks([0, 20, 40, 60])
            //         .verticalLabels(["0m", "20m", "40m", "60m", "80m"])
            .padding(100)
            .background(Color.white)

            PlotView {
                BarView(
                    x: [-5, 1, 2, 3, 4, 5, 5.5],
                    y: [10, 50, 30, 40, 50, 55, 60, 70, 80, 90]
                )
                .barColor(.green)
            }
            .horizontalTicks([2, 3, 7, 5])
            .padding(100)
            .background(Color.white)
        }
        .contentDisposition(left: -5, top: 150)
        .frame(height: 800)
    }
}
