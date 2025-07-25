//
//  BalanceChartView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 26.07.2025.
//

import SwiftUI
import Charts

struct DateBalance: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Decimal

    var magnitude: Double { abs((amount as NSDecimalNumber).doubleValue) }
    var isPositive: Bool { amount >= 0 }
}

struct BalanceChartView: View {
    @EnvironmentObject private var viewModel: BankAccountViewModel
    let period: ChartPeriod

    @State private var selection: DateBalance?

    private var dataSet: [DateBalance] { viewModel.balances(for: period) }

    var body: some View {
        ChartContainerView(
            dataSet: dataSet,
            period: period,
            selection: $selection,
            nearestItem: nearestItem(to:)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func nearestItem(to targetDate: Date) -> DateBalance? {
        dataSet.min {
            abs($0.date.timeIntervalSince(targetDate)) < abs($1.date.timeIntervalSince(targetDate))
        }
    }
}

private struct ChartContainerView: View {
    let dataSet: [DateBalance]
    let period: ChartPeriod
    @Binding var selection: DateBalance?
    let nearestItem: (Date) -> DateBalance?

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter
    }()

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    var body: some View {
        Chart {
            ForEach(dataSet) { item in
                BarMark(
                    x: .value("Date", item.date),
                    y: .value("Balance", item.magnitude)
                )
                .foregroundStyle(item.isPositive ? Color.green : Color.red)
                .annotation(position: .overlay, alignment: .top) {
                    if selection?.id == item.id {
                        label(for: item)
                    }
                }
            }
        }
        .chartXAxis { xAxis() }
        .chartYAxis(.hidden)
        .chartOverlay { proxy in overlay(proxy: proxy) }
    }

    @AxisContentBuilder
    private func xAxis() -> some AxisContent {
        AxisMarks() { value in
            AxisValueLabel {
                axisLabel(for: value)
            }
        }
    }

    @ViewBuilder
    private func axisLabel(for value: AxisValue) -> some View {
        if let dateVal = value.as(Date.self) {
            Text(
                period == .day
                    ? ChartContainerView.dayFormatter.string(from: dateVal)
                    : ChartContainerView.monthFormatter.string(from: dateVal)
            )
            .font(.system(size: 10))
        }
    }

    private func overlay(proxy: ChartProxy) -> some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let origin = geometry[proxy.plotAreaFrame].origin
                            let locationX = value.location.x - origin.x
                            if let date: Date = proxy.value(atX: locationX) {
                                selection = nearestItem(date)
                            }
                        }
                        .onEnded { _ in selection = nil }
                )
        }
    }

    private func label(for item: DateBalance) -> some View {
        Text(item.amount.formattedPlain)
            .font(.caption2)
            .padding(6)
            .background(.regularMaterial)
            .cornerRadius(6)
    }
}

private extension Decimal {
    var formattedPlain: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber) ?? ""
    }
}
