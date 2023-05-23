import Charts
import SwiftUI

// TODO: - Annotation summary

struct StatisticsView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.start, order: .forward)])
    private var timeBlocks: FetchedResults<TimeBlock>

    @State var hoveredValue: (TimeBlock.Chunk?, Date?) = (nil, nil)

    let frame = (height: 300.0, width: 700.0)
    let daysPerFrame = 10

    var body: some View {
        //let timeChunks: [TimeBlock.Chunk] = timeBlocks.flatMap(\.chunks)
        //let timeChunks = [TimeBlock.Chunk]()
        let timeChunks = TestData.timeBlockChunks
        //let timeChunks = Array(TestData.timeBlockChunks.prefix(1))

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
            let timeChunks = timeChunks.sortedAndPadded()

            ScrollView(.vertical, showsIndicators: true) {
                Chart(timeChunks) { chunk in
                    // MARK: - Bar Marks
                    BarMark(xStart: .value("Start", chunk.startSeconds),
                            xEnd: .value("End", chunk.endSeconds),
                            y: .value("Day", chunk.date),
                            height: .fixed(14))
                    .foregroundStyle(by: .value("Category", chunk.category.asString))

                    // MARK: - Annotations
                    if case let (_, date) = hoveredValue, let date {
                        RectangleMark(y: .value("Day", date), height: 20)
                            .foregroundStyle(.primary.opacity(0.3))
                            .opacity(0.3)
                            //.foregroundStyle(.gray.opacity(0.2))
                            // TODO: - Opacity is not working here...
                    }

                    if case let (chunk, _) = hoveredValue, let chunk {
                        RectangleMark(xStart: .value("Start", chunk.startSeconds),
                                      xEnd: .value("End", chunk.endSeconds),
                                      y: .value("Day", chunk.date),
                                      height: 14)
                        .cornerRadius(2)
                    }
                }

                // MARK: - Legend
                .chartForegroundStyleScale([
                    "Focus": Color.accent,
                    "Rest": Color.onBackgroundSecondary
                ])
                .chartLegend(.visible)
                .chartLegend(position: .top, spacing: -12)

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
                //.chartYScale(domain: (timeChunks.first!.day...timeChunks.last!.day.addingTimeInterval(24 * 3600)))
                /**
                 Note: Reverse domain so as user scrolls down, they scroll back in time.
                 Padding the data with an extra day with empty time span to override hiding y axis labels for data sets spanning single day.
                 This call makes Previews crash.
                 */
                .chartYScale(domain: .automatic(reversed: true))

                // MARK: - X Axis
                .chartXAxisLabel("Time", position: .top, alignment: .center)
                .chartXScale(domain: [0, 24 * 3600])
                .chartXAxis {
                    AxisMarks(values: (0..<25).map { 3600 * $0 }) {
                        AxisGridLine()
                    }

                    let hoursBy3 = stride(from: 0, through: 25, by: 3).map { 3600 * $0 }
                    AxisMarks(preset: .aligned, position: .top, values: hoursBy3) { value in
                        if let valueInt = value.as(Int.self) {
                            let hour = valueInt / 3600
                            switch hour {
                            case 0:
                                AxisValueLabel("12am")
                            case 12:
                                AxisValueLabel("12pm")
                            case 24:
                                AxisValueLabel("")
                            default:
                                AxisValueLabel(String(hour % 12))
                            }
                        }

                        AxisTick()
                    }
                }

                // MARK: - Plot area
                .chartPlotStyle { plotContent in
                    let firstDay = timeChunks.first!.date
                    let lastDay = timeChunks.last!.date
                    let daySpanCount = Calendar.current.dateComponents([.day], from: firstDay, to: lastDay).day!
                    let plotHeight = frame.height * (Double(daySpanCount) / Double(daysPerFrame))

                    plotContent
                        .frame(width: frame.width, height: plotHeight)
                }

                // MARK: - Chart Overlay
                .chartOverlay { chartProxy in
                    GeometryReader { geoProxy in
                        Color.clear
                            .onContinuousHover { hoverPhase in
                                switch hoverPhase {
                                case .active(let hoverLocation):
                                    let origin = geoProxy[chartProxy.plotAreaFrame].origin
                                    let location = CGPoint(x: hoverLocation.x - origin.x,
                                                           y: hoverLocation.y - origin.y - 10)

                                    if let date = chartProxy.value(atY: location.y, as: Date.self),
                                       timeChunks.contains(date: date) {
                                        if let secondOfDay = chartProxy.value(atX: location.x, as: Int.self),
                                           let chunk = timeChunks.firstWhereContains(secondOfDay: secondOfDay, for: date) {
                                            print("second of day", secondOfDay, "date", date)
                                            hoveredValue = (chunk, chunk.date)
                                        } else {
                                            hoveredValue = (nil, date.ymdDate)
                                        }
                                    } else {
                                        hoveredValue = (nil, nil)
                                    }
                                case .ended:
                                    hoveredValue = (nil, nil)
                                }
                            }
                    }
                }

                // MARK: - Chart Padding
                .padding(20)
                .padding([.leading], 56)
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
            lhs.date < rhs.date
        }

        let id = UUID()

        /// Date (ymd) without timestamp, used to bucket all chunks belonging to the same day.
        let date: Date

        let startSeconds: Int
        let endSeconds: Int
        let category: Timer.Category
    }
}

private extension Array<TimeBlock.Chunk> {
    func sortedAndPadded() -> Self {
        let sortedCopy = sorted()
        let precedingDay = first!.date.addingTimeInterval(-24 * 3600)
        let precedingChunk = TimeBlock.Chunk(date: precedingDay, startSeconds: 0, endSeconds: 0, category: .focus)
        return [precedingChunk] + sortedCopy
    }

    func contains(date : Date) -> Bool {
        contains(where: { $0.date == date.ymdDate } )
    }

    func firstWhereContains(secondOfDay: Int, for date: Date) -> TimeBlock.Chunk? {
        filter { $0.date == date.ymdDate }
            .first(where: { $0.startSeconds <= secondOfDay && secondOfDay <= $0.endSeconds })
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
                Chunk(date: startDate.ymdDate,
                      startSeconds: startDate.secondOfDay,
                      endSeconds: lastSecondOfDay,
                      category: Timer.Category(rawValue: Int(category))!),
                Chunk(date: endDate.ymdDate,
                      startSeconds: firstSecondOfDay,
                      endSeconds: endDate.secondOfDay,
                      category: Timer.Category(rawValue: Int(category))!)
            ]
        }

        return [Chunk(date: endDate.ymdDate,
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

private extension Date {
    var ymdDate: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components)!
    }
}
