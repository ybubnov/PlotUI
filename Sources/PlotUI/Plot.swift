import Foundation
import SwiftUI

public struct PlotAxis: View {
    /// The list of tick locations relative to the scaled axis.
    private var ticks: [Double] = []

    /// The labels to place at the given ticks locations.
    private var labels: [LocalizedStringKey] = []

    private var orientation: TickOrientation

    public init(
        _ orientation: TickOrientation, ticks: [Double] = [], labels: [LocalizedStringKey] = []
    ) {
        self.orientation = orientation
        self.ticks = ticks
        self.labels = labels
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
            Tick(subscriptLabel(i), orientation: orientation, value: ticks[i])
        }
    }

    //    public func ticks<S: Sequence>(_ ticks: S) -> Self where S.Element == Double {
    //        return Self(ticks: Array(ticks), labels: [])
    //    }
    //
    //    public func labels<S: Sequence>(_ labels: S) -> Self where S.Element == LocalizedStringKey {
    //        return Self(ticks: ticks, labels: Array(labels))
    //    }
}

public struct PlotView: View {
    @Environment(\.contentDisposition) var contentDisposition
    //    @Environment(\.horizontalLabelStyle) var hLabelStyle
    @Environment(\.horizontalTickStyle) var hTickStyle
    //    @Environment(\.verticalLabelStyle) var vLabelStyle
    @Environment(\.verticalTickStyle) var vTickStyle

    private var xaxis: PlotAxis
    private var yaxis: PlotAxis
    private var content: AnyFuncView

    internal init<Content: FuncView>(_ xaxis: PlotAxis, _ yaxis: PlotAxis, _ content: Content) {
        self.xaxis = xaxis
        self.yaxis = xaxis
        self.content = AnyFuncView(content)
    }

    public var body: some View {
        ZStack {
            xaxis
            yaxis
            content
            //            VStack{
            //                Text(String(describing: contentDisposition.bounds))
            //                Text(String(describing: content.disposition.bounds))
            //            }
        }
        .foregroundColor(.gray)
        .viewport([.bottom, .trailing], 30)
        .contentDisposition(contentDisposition.merge(content.disposition))
    }

    private func makeAxis<
        S: Sequence
    >(_ orientation: TickOrientation, _ ticks: S, _ labels: [LocalizedStringKey] = []) -> PlotAxis
    where S.Element == Double {
        let asLabel = { (tick: Double) -> LocalizedStringKey in
            LocalizedStringKey(String(format: "%.2f", tick))
        }

        let labels = ticks.map(asLabel)
        return PlotAxis(orientation, ticks: Array(ticks), labels: labels)
    }
}

extension PlotView {
    public init<Content: FuncView>(@ViewBuilder content: () -> Content) {
        self.content = AnyFuncView(content())
        self.xaxis = PlotAxis(.vertical)
        self.yaxis = PlotAxis(.horizontal)

        let numXTicks = 10
        let numYTicks = 4

        let (xticks, yticks) = self.content.disposition[0...numXTicks, 0...numYTicks]

        self.xaxis = makeAxis(.vertical, xticks, [])
        self.yaxis = makeAxis(.horizontal, yticks, [])
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

/*
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
 */

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
            //            .plotTicks()
            //            .horizontalTicks([2, 3, 7])
            //            .horizontalLabels(["-3", "-2", "-1", "0"], style: .bottom)
            .contentDisposition(right: 7)
            //            .verticalTickLabelStyle(.trailing)
            //            .verticalTicks([0, 20, 40, 60])
            //            .verticalLabels(["0m", "20m", "40m", "60m", "80m"])
            .padding(100)
            .background(Color.white)

            PlotView {
                BarView(
                    x: [-5, 1, 2, 3, 4, 5, 5.5],
                    y: [10, 50, 30, 40, 50, 55, 60, 70, 80, 90]
                )
                .barColor(.green)
            }
            //            .horizontalTicks([2, 3, 7, 5])
            //            .contentDisposition(left: -10)
            .padding(100)
            .background(Color.white)
        }
        .contentDisposition(left: -5, top: 150)
        .frame(height: 800)
    }
}
