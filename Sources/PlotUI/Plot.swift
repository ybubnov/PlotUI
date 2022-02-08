import Foundation
import SwiftUI

public class ContentDisposition: ObservableObject {
    public typealias WBounds = (left: Double, right: Double)
    public typealias HBounds = (bottom: Double, top: Double)

    @Published var xlim: WBounds
    @Published var ylim: HBounds

    public var width: Double { abs(xlim.right - xlim.left) }

    public var height: Double { abs(ylim.top - ylim.bottom) }

    public init(w: WBounds = (0, 1), h: HBounds = (0, 1)) {
        self.xlim = w
        self.ylim = h
    }

    public var normalized: ContentDisposition {
        ContentDisposition(w: (0, width), h: (0, height))
    }
}

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
    private var ticks: [CGFloat] = []
    private var tickStyle: StrokeStyle = .tinyDashed

    /// The labels to place at the given ticks locations.
    private var labels: [LocalizedStringKey] = []

    private var labelStyle: AnyTickLabelStyle

    @EnvironmentObject var disposition: ContentDisposition

    internal init<S: TickLabelStyle>(
        _ ticks: [CGFloat] = [],
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
            Tick(disposition, at: ticks[i])
                .stroke(style: tickStyle)
                .tickLabel(subscriptLabel(i), style: labelStyle)
        }
    }

    public func ticks<S: Sequence>(_ ticks: S) -> Self where S.Element == CGFloat {
        return Self(Array(ticks), tickStyle, labels, labelStyle)
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

    @StateObject var disposition = ContentDisposition()

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
        .onAppear(perform: {
            disposition.xlim = (content.domain.lowerBound, content.domain.upperBound)
            disposition.ylim = (content.image.lowerBound, content.image.upperBound)
        })
        .padding(100)
        .background(Color.white)
        .foregroundColor(.gray)
        .environmentObject(disposition)
    }
}

extension PlotView {
    public init<Content: FuncView>(@ViewBuilder content: () -> Content) {
        self.content = AnyFuncView(content())
        self.xaxis = XAxis(labelStyle: .bottomTrailing)
        self.yaxis = YAxis(labelStyle: .trailing)

        let numXTicks = 10
        let numYTicks = 4

        let xInterval = Double(self.content.domain.length) / Double(numXTicks)
        let yInterval = Double(self.content.image.length) / Double(numYTicks)

        let xticks = (0...numXTicks).map { tick in
            self.content.domain.lowerBound + Double(tick) * xInterval
        }
        let yticks = (0...numYTicks).map { tick in
            self.content.image.lowerBound + Double(tick) * yInterval
        }

        let asLabel = { (tick: Double) -> LocalizedStringKey in
            LocalizedStringKey(String(format: "%.2f", tick))
        }
        let xlabels = xticks.map(asLabel)
        let ylabels = yticks.map(asLabel)

        self.xaxis = xaxis.ticks(Array.make(xticks)).labels(xlabels)
        self.yaxis = yaxis.ticks(Array.make(yticks)).labels(ylabels).tickStyle(.tiny)
    }
}

extension Array where Self.Element == CGFloat {

    public static func make<S: Sequence, E: BinaryInteger>(_ elements: S) -> Self
    where S.Element == E {
        return elements.map { e in CGFloat(e) }
    }

    public static func make<S: Sequence, E: BinaryFloatingPoint>(_ elements: S) -> Self
    where S.Element == E {
        return elements.map { e in CGFloat(e) }
    }
}

extension PlotView {

    public func horizontalTicks<S: Sequence, Tick: BinaryInteger>(
        _ ticks: S, style: StrokeStyle = .tinyDashed
    ) -> Self where S.Element == Tick {

        let axis = xaxis.ticks(Array.make(ticks)).tickStyle(style)
        return Self(axis, yaxis, content)
    }

    public func horizontalLabels<S: Sequence>(_ labels: S) -> Self
    where S.Element == LocalizedStringKey {
        let axis = xaxis.labels(labels)
        return Self(axis, yaxis, content)
    }

    public func horizontalLabels<S: Sequence, LabelStyle: TickLabelStyle>(
        _ labels: S, style: LabelStyle
    ) -> Self where S.Element == LocalizedStringKey {

        let axis = xaxis.labels(labels).labelStyle(style)
        return Self(axis, yaxis, content)
    }
}

extension PlotView {

    public func verticalTicks<S: Sequence, Tick: BinaryInteger>(
        _ ticks: S, style: StrokeStyle = .tiny
    ) -> Self where S.Element == Tick {

        let axis = yaxis.ticks(Array.make(ticks)).tickStyle(style)
        return Self(xaxis, axis, content)
    }

    public func verticalLabels<S: Sequence>(_ labels: S) -> Self
    where S.Element == LocalizedStringKey {
        let axis = yaxis.labels(labels)
        return Self(xaxis, axis, content)
    }

    public func verticalLabels<S: Sequence, LabelStyle: TickLabelStyle>(
        _ labels: S, style: LabelStyle
    ) -> Self where S.Element == LocalizedStringKey {

        let axis = yaxis.labels(labels).labelStyle(style)
        return Self(xaxis, axis, content)
    }
}

struct PlotViewPreview: PreviewProvider {
    static var previews: some View {
        PlotView {
            BarView(
                x: [0, 1, 2, 3, 4, 5, 5.5],
                height: [10, 50, 30, 40, 50, 55, 60, 70, 80, 90]
                //                domain: -3.0...7.0,
                //                image: 0.0...60.0
                //                xmin: -3,
                //                xmax: 7,
                //                ymin: 0,
                //                ymax: 60
            )
            .fill(.green)
        }
        //        .horizontalTicks(-3...0)
        //        .horizontalLabels(["-3", "-2", "-1", "0"], style: .bottom)
        //        .verticalTicks([0, 20, 40, 60])
        //        .verticalLabels(["0m", "20m", "40m", "60m", "80m"])
    }
}
