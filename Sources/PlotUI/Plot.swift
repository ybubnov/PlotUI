import SwiftUI
import Foundation


public class CoordinateSpace: ObservableObject {
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

    public var normalized: CoordinateSpace {
        CoordinateSpace(w: (0, width), h: (0, height))
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


public struct PlotAxis<Axis: AxisShape, LabelStyle: TickLabelStyle>: View {
    /// The list of tick locations relative to the scaled axis.
    private var ticks: [CGFloat] = []
    private var tickStyle: StrokeStyle = .tinyDashed

    /// The labels to place at the given ticks locations.
    private var labels: [LocalizedStringKey] = []
    private var labelStyle: LabelStyle

    @EnvironmentObject var coords: CoordinateSpace

    internal init(
        _ ticks: [CGFloat] = [],
        _ tickStyle: StrokeStyle,
        _ labels: [LocalizedStringKey] = [],
        _ labelStyle: LabelStyle
    ) {
        self.ticks = ticks
        self.labels = labels
        self.tickStyle = tickStyle
        self.labelStyle = labelStyle
    }

    private func subscriptLabel(_ index: Int, defaultValue: LocalizedStringKey = "") -> LocalizedStringKey {
        if (0..<labels.count).contains(index) {
            return labels[index]
        }
        return defaultValue
    }
    
    public var body: some View {
        ForEach(ticks.indices, id: \.self) { i in
            Axis(coords, at: ticks[i])
                .stroke(style: tickStyle)
                .tick(subscriptLabel(i), style: labelStyle)
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

    public func labelStyle<S: TickLabelStyle>(_ style: S) -> PlotAxis<Axis, S> {
        return PlotAxis<Axis, S>(ticks, tickStyle, labels, style)
    }
}


public typealias PlotYAxis = PlotAxis<HorizontalAxis, TrailingTickLabelStyle>


extension PlotYAxis {
    public init() { labelStyle = .trailing }
}


public typealias PlotXAxis = PlotAxis<VerticalAxis, BottomTrailingTickLabelStyle>


extension PlotXAxis {
    public init() { labelStyle = .bottomTrailing }
}


//public struct PlotBoundaryView: View {
//
//    @EnvironmentObject var coords: CoordinateSpace
//
//    public var strokeStyle: StrokeStyle = StrokeStyle(lineWidth: 0.2)
//
//    public var body: some View {
//        ZStack {
//            HorizontalAxis(coords.normalized, at: 0).stroke(style: strokeStyle)
//            HorizontalAxis(coords.normalized, at: coords.normalized.height).stroke(style: strokeStyle)
//            VerticalAxis(coords.normalized, at: 0).stroke(style: strokeStyle)
//            VerticalAxis(coords.normalized, at: coords.normalized.width).stroke(style: strokeStyle)
//        }
//    }
//}



public struct PlotView<XAxis: View, YAxis: View>: View {
    
    @StateObject var coords = CoordinateSpace()
    
    public var content: BarView<Color>
    
    private var xaxis: XAxis
    private var yaxis: YAxis
    
//    public typealias HorizontalAxis = PlotAxis<HorizontalAxis
    
    internal init(_ xaxis: XAxis, _ yaxis: YAxis, _ content: BarView<Color>) {
        self.xaxis = xaxis
        self.yaxis = yaxis
        self.content = content
    }

    public var body: some View {
        ZStack {
            xaxis
            yaxis
            content
        }
        .onAppear(perform: {
            coords.xlim = (content.xmin, content.xmax)
            coords.ylim = (content.ymin, content.ymax)
        })
        .padding(100)
        .background(Color.white)
        .foregroundColor(.gray)
        .environmentObject(coords)
    }
}


extension PlotView where XAxis == PlotXAxis, YAxis == PlotYAxis {
    public init(@ViewBuilder content: () -> BarView<Color>) {
        self.content = content()
        self.xaxis = PlotXAxis()
        self.yaxis = PlotYAxis()

        let numXTicks = 10
        let numYTicks = 4
        
        let xInterval = Double(abs(self.content.xmax - self.content.xmin)) / Double(numXTicks)
        let yInterval = Double(abs(self.content.ymax - self.content.ymin)) / Double(numYTicks)
        
        let xticks = (0...numXTicks).map { tick in
            self.content.xmin + Double(tick) * xInterval
        }
        let yticks = (0...numYTicks).map { tick in
            self.content.ymin + Double(tick) * yInterval
        }

        let asLabel = { (tick: Double) -> LocalizedStringKey in LocalizedStringKey(String(tick)) }
        let xlabels = xticks.map(asLabel)
        let ylabels = yticks.map(asLabel)
        
        self.xaxis = xaxis.ticks(Array.make(xticks)).labels(xlabels)
        self.yaxis = yaxis.ticks(Array.make(yticks)).labels(ylabels).tickStyle(.tiny)
    }
}


extension Array where Self.Element == CGFloat {

    public static func make<S: Sequence, E: BinaryInteger>(_ elements: S) -> Self where S.Element == E {
        return elements.map { e in CGFloat(e) }
    }
    
    public static func make<S: Sequence, E: BinaryFloatingPoint>(_ elements: S) -> Self where S.Element == E {
        return elements.map { e in CGFloat(e) }
    }
}


extension PlotView where XAxis == PlotXAxis {

    public func horizontalTicks<S: Sequence, Tick: BinaryInteger>(
        _ ticks: S, style: StrokeStyle = .tinyDashed
    ) -> Self where S.Element == Tick {
        
        let axis = xaxis.ticks(Array.make(ticks)).tickStyle(style)
        return Self(axis, yaxis, content)
    }
    
    public func horizontalLabels<S: Sequence>(_ labels: S) -> Self where S.Element == LocalizedStringKey {
        let axis = xaxis.labels(labels)
        return Self(axis, yaxis, content)
    }

    public func horizontalLabels<S: Sequence, LabelStyle: TickLabelStyle>(
        _ labels: S, style: LabelStyle
    ) -> PlotView<PlotAxis<VerticalAxis, LabelStyle>, YAxis> where S.Element == LocalizedStringKey {
        
        let axis = xaxis.labels(labels).labelStyle(style)
        return PlotView<PlotAxis<VerticalAxis, LabelStyle>, YAxis>(axis, yaxis, content)
    }
}


extension PlotView where YAxis == PlotYAxis {

    public func verticalTicks<S: Sequence, Tick: BinaryInteger>(
        _ ticks: S, style: StrokeStyle = .tiny
    ) -> Self where S.Element == Tick {
        
        let axis = yaxis.ticks(Array.make(ticks)).tickStyle(style)
        return Self(xaxis, axis, content)
    }
    
    public func verticalLabels<S: Sequence>(_ labels: S) -> Self where S.Element == LocalizedStringKey {
        let axis = yaxis.labels(labels)
        return Self(xaxis, axis, content)
    }

    public func verticalLabels<S: Sequence, LabelStyle: TickLabelStyle>(
        _ labels: S, style: LabelStyle
    ) -> PlotView<XAxis, PlotAxis<HorizontalAxis, LabelStyle>> where S.Element == LocalizedStringKey {

        let axis = yaxis.labels(labels).labelStyle(style)
        return PlotView<XAxis, PlotAxis<HorizontalAxis, LabelStyle>>(xaxis, axis, content)
    }
}



struct PlotViewPreview: PreviewProvider {
    static var previews: some View {
        PlotView {
            BarView(
                x:      [0, 1, 2, 3, 4, 5, 5.5],
                height: [10, 50, 30, 40, 50, 55, 60, 70, 80, 90],
                xmin: -3,
                xmax: 7,
                ymin: 0,
                ymax: 60
            )
            .fill(.green)
        }
//        .horizontalTicks(-3...0)
//        .horizontalLabels(["-3", "-2", "-1", "0"], style: .bottomTrailing)
//        .verticalTicks([0, 20, 40, 60])
//        .verticalLabels(["0m", "20m", "40m", "60m"])
    }
}
