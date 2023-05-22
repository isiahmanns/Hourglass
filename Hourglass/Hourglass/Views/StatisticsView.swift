import Charts
import SwiftUI

// TODO: - Annotation summary

struct StatisticsView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.start)])
    private var timeBlocks: FetchedResults<TimeBlock>

    let frame = (height: 300.0, width: 700.0)
    let daysPerFrame = 7

    var body: some View {
         //let timeChunks: [TimeBlock.Chunk] = timeBlocks.flatMap(\.chunks)
        let timeChunks = [TimeBlock.Chunk]()
        // let timeChunks = TestData.timeBlockChunks.sorted()//.prefix(1)
        // TODO: - Pad data

        if timeChunks.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "chart.bar")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color.background)
                Text(Copy.emptyState)
                    .multilineTextAlignment(.center)
            }
            .frame(width: frame.width, height: frame.height)
        } else {
            ScrollView(.vertical, showsIndicators: true) {
                Chart(timeChunks) { chunk in
                    BarMark(xStart: .value("Start", chunk.startSeconds),
                            xEnd: .value("End", chunk.endSeconds),
                            y: .value("Day", chunk.day),
                            height: .fixed(14))
                    .foregroundStyle(by: .value("Category", chunk.category.asString))
                }

                // MARK: - Legend
                .chartForegroundStyleScale([
                    "Focus": Color.accent,
                    "Rest": Color.onBackgroundSecondary
                ])
                .chartLegend(.visible)
                .chartLegend(position: .leading)

                // MARK: - Y Axis
                .chartYAxisLabel("Day", position: .topTrailing)
                .chartYAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisValueLabel(format: .dateTime.weekday().month().day())
                        AxisGridLine()
                        AxisTick()
                    }
                }
                .chartYAxis(.visible)
                .chartYScale(domain: (timeChunks.first!.day...timeChunks.last!.day.addingTimeInterval(24 * 3600)))
                /**
                 Note: Reverse domain could work too. Could pad the data with an extra day, empty time span.
                 This call makes Previews crash.
                 */
                //.chartYScale(domain: .automatic(reversed: true))

                // MARK: - X Axis
                .chartXAxisLabel("Time", position: .top, alignment: .center)
                .chartXScale(domain: [0, 24 * 3600])
                .chartXAxis {
                    AxisMarks(values: (0..<25).map { 3600 * $0 }) {
                        AxisGridLine()
                    }

                    AxisMarks(position: .top, values: stride(from: 0, through: 25, by: 3).map { 3600 * $0 }) { value in
                        if let valueInt = value.as(Int.self) {
                            let hour = valueInt / 3600
                            switch hour {
                            case 0:
                                AxisValueLabel("12am")
                            case 12:
                                AxisValueLabel("12pm")
                            default:
                                AxisValueLabel(String(hour % 12))
                            }
                        }

                        AxisTick()
                    }
                }

                // MARK: - Plot area
                .chartPlotStyle { plotContent in
                    let firstDay = timeChunks.first!.day
                    let lastDay = timeChunks.last!.day
                    let daySpanCount = Calendar.current.dateComponents([.day], from: firstDay, to: lastDay).day!
                    let plotHeight = frame.height * (Double(daySpanCount) / Double(daysPerFrame))

                    plotContent
                        .frame(width: frame.width, height: plotHeight)
                }

                // MARK: - Padding
                .padding(20)
            } // ScrollView
            .frame(minHeight: frame.height)
        }
    }
}

extension StatisticsView {
    enum Copy {
        static let emptyState = "There is no data to show.\nRevisit after completing a few time blocks."
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}

extension TimeBlock {
    struct Chunk: Identifiable, Comparable {
        static func < (lhs: TimeBlock.Chunk, rhs: TimeBlock.Chunk) -> Bool {
            lhs.day < rhs.day
        }

        let id = UUID()
        let day: Date
        let startSeconds: Int
        let endSeconds: Int
        let category: Timer.Category
    }
}

private extension TimeBlock {
    var startDate: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: start!)
    }

    var endDate: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: end!)
    }

    // TODO: - Test this with Core Data
    var doesIncludeNextDay: Bool {
        startDate.day! < endDate.day!
    }

    var chunks: [TimeBlock.Chunk] {
        if doesIncludeNextDay {
            let lastSecondOfDay = DateComponents(hour: 23, minute: 59, second: 59).secondOfDay
            let firstSecondOfDay = 0

            return [
                Chunk(day: startDate.ymdDate,
                     startSeconds: startDate.secondOfDay,
                     endSeconds: lastSecondOfDay,
                      category: Timer.Category(rawValue: Int(category))!),
                Chunk(day: endDate.ymdDate,
                     startSeconds: firstSecondOfDay,
                     endSeconds: endDate.secondOfDay,
                     category: Timer.Category(rawValue: Int(category))!)
            ]
        }

        return [Chunk(day: endDate.ymdDate,
                     startSeconds: startDate.secondOfDay,
                     endSeconds: endDate.secondOfDay,
                     category: Timer.Category(rawValue: Int(category))!)]
    }
}

extension DateComponents {
    var ymdDate: Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }

    var secondOfDay: Int {
        guard let hour, let minute, let second else { return -1 }
        return (hour * 3600) + (minute * 60) + second
    }
}
