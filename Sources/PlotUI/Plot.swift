import Foundation
import SwiftUI

public struct HAxis: View {
    @Environment(\.contentDisposition) var contentDisposition

    /// The list of tick locations relative to the scaled axis.
    private var ticks: [Double] = []

    /// The labels to place at the given ticks locations.
    private var labels: [LocalizedStringKey] = []

    private var partitions: Int?

    public init(ticks: [Double] = [], labels: [LocalizedStringKey] = []) {
        self.ticks = ticks
        self.labels = labels
    }

    public init(partitions: Int) {
        self.partitions = partitions
    }

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

public struct VAxis: View {
    @Environment(\.contentDisposition) var contentDisposition

    /// The list of tick locations relative to the scaled axis.
    private var ticks: [Double] = []

    /// The labels to place at the given ticks locations.
    private var labels: [LocalizedStringKey] = []

    private var partitions: Int?

    public init(ticks: [Double] = [], labels: [LocalizedStringKey] = []) {
        self.ticks = ticks
        self.labels = labels
    }

    public init(partitions: Int) {
        self.partitions = partitions
    }

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

public struct PlotView: View {
    @Environment(\.contentDisposition) var contentDisposition
    @Environment(\.viewport) var viewport

    private var haxis: AnyView
    private var vaxis: AnyView
    private var content: AnyFuncView

    public init<Content: FuncView, HAxis: View, VAxis: View>(
        @ViewBuilder content: () -> Content,
        @ViewBuilder horizontal: () -> HAxis,
        @ViewBuilder vertical: () -> VAxis
    ) {
        self.haxis = AnyView(horizontal())
        self.vaxis = AnyView(vertical())
        self.content = AnyFuncView(content())
    }

    public init<Content: FuncView>(@ViewBuilder content: () -> Content) {
        self.content = AnyFuncView(content())
        self.haxis = AnyView(HAxis(partitions: 10))
        self.vaxis = AnyView(VAxis(partitions: 4))
    }

    public var body: some View {
        ZStack {
            haxis
            vaxis
            content
        }
        .foregroundColor(.gray)
        .viewport([.bottom, .trailing], 30)
        .contentDisposition(contentDisposition.merge(content.disposition))
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
            } horizontal: {
                HAxis(partitions: 2)
            } vertical: {
                VAxis(partitions: 3)
                    .tickStroke(style: .tinyDashed)
            }
            //            .contentDisposition(left: -4, right: 7)
            .viewport(.trailing, 50)
            .padding(100)
            .background(Color.white)

            PlotView {
                BarView(
                    x: [-5, 1, 2, 3, 4, 5, 5.5],
                    y: [10, 50, 30, 40, 50, 55, 60, 70, 80, 90]
                )
                .barColor(.green)
            }
            //                        .contentDisposition(left: -5)
            .padding(100)
            .background(Color.white)
        }
        .contentDisposition(bottom: 8)
        .frame(height: 800)
    }
}
